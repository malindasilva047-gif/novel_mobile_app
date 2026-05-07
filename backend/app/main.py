from collections import defaultdict

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .database import get_connection

app = FastAPI(title="Novel Mobile Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def fetch_all(query: str, params=None):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)
    cursor.execute(query, params or ())
    rows = cursor.fetchall()
    cursor.close()
    connection.close()
    return rows


@app.get("/")
def healthcheck():
    return {"message": "Novel Mobile backend is running."}


@app.get("/api/bootstrap")
def bootstrap():
    discover_tabs = [
        row["name"]
        for row in fetch_all(
            "SELECT name FROM categories WHERE tab_group = 'discover' ORDER BY sort_order"
        )
    ]

    explore_topics = fetch_all(
        "SELECT name, topic_count FROM categories WHERE tab_group = 'explore' ORDER BY sort_order"
    )

    books = fetch_all(
        """
        SELECT id, title, author, description, cover_path, accent_hex, section_name,
               status_text, rating, genre, cta_label
        FROM books
        ORDER BY sort_order
        """
    )

    recently_updated = [
        {
            "id": book["id"],
            "title": book["title"],
            "author": book["author"],
            "cover_path": book["cover_path"],
            "accent_hex": book["accent_hex"],
        }
        for book in books
        if book["section_name"] == "recently_updated"
    ]

    recently_completed = [
        {
            "id": book["id"],
            "title": book["title"],
            "author": book["author"],
            "cover_path": book["cover_path"],
            "accent_hex": book["accent_hex"],
        }
        for book in books
        if book["section_name"] == "recently_completed"
    ]

    featured_raw = next(book for book in books if book["section_name"] == "featured")
    featured_book = {
        "id": featured_raw["id"],
        "title": featured_raw["title"],
        "author": featured_raw["author"],
        "description": featured_raw["description"],
        "status_text": featured_raw["status_text"],
        "rating": featured_raw["rating"],
        "genre": featured_raw["genre"],
        "cta": featured_raw["cta_label"],
    }

    library_entries = fetch_all(
        """
        SELECT le.reading_status, le.updated_text, le.chapters, le.primary_genre,
               le.secondary_genre, b.id, b.title, b.author, b.cover_path, b.accent_hex
        FROM library_entries le
        JOIN books b ON b.id = le.book_id
        ORDER BY le.sort_order
        """
    )

    library_payload = [
        {
            "book": {
                "id": row["id"],
                "title": row["title"],
                "author": row["author"],
                "cover_path": row["cover_path"],
                "accent_hex": row["accent_hex"],
            },
            "reading_status": row["reading_status"],
            "updated_text": row["updated_text"],
            "chapters": row["chapters"],
            "primary_genre": row["primary_genre"],
            "secondary_genre": row["secondary_genre"],
        }
        for row in library_entries
    ]

    write_meta = fetch_all("SELECT manage_tabs, story_tabs, filter_label, sort_label, empty_title, empty_cta FROM write_screen LIMIT 1")[0]
    write_screen = {
        "manage_tabs": write_meta["manage_tabs"].split(","),
        "story_tabs": write_meta["story_tabs"].split(","),
        "filter_label": write_meta["filter_label"],
        "sort_label": write_meta["sort_label"],
        "empty_title": write_meta["empty_title"],
        "empty_cta": write_meta["empty_cta"],
    }

    notifications = fetch_all(
        "SELECT tab_name AS tab, title, message, created_at FROM notifications ORDER BY sort_order"
    )

    menu_rows = fetch_all(
        "SELECT section_name, label, icon_name, route_name FROM menu_items ORDER BY section_order, sort_order"
    )
    menu_map = defaultdict(list)
    for row in menu_rows:
        menu_map[row["section_name"]].append(
            {
                "label": row["label"],
                "icon": row["icon_name"],
                "route": row["route_name"],
            }
        )

    menu_sections = [
        {"section": section, "items": items}
        for section, items in menu_map.items()
    ]

    profile = fetch_all(
        "SELECT display_name, username, following, followers, blocked, chapters_read, social_karma, day_streak FROM profiles LIMIT 1"
    )[0]
    reading_lists = fetch_all(
        "SELECT name, story_count, cover_path FROM reading_lists ORDER BY sort_order"
    )

    profile_payload = {
        **profile,
        "reading_lists": reading_lists,
    }

    achievement_rows = fetch_all(
        """
        SELECT group_name, title, subtitle, progress_label, badge_value, style
        FROM achievements
        ORDER BY group_order, sort_order
        """
    )
    achievement_map = defaultdict(list)
    for row in achievement_rows:
        achievement_map[row["group_name"]].append(
            {
                "title": row["title"],
                "subtitle": row["subtitle"],
                "progress_label": row["progress_label"],
                "badge_value": row["badge_value"],
                "style": row["style"],
            }
        )

    achievements = [
        {"group_name": group_name, "items": items}
        for group_name, items in achievement_map.items()
    ]

    return {
        "discover_tabs": discover_tabs,
        "recently_updated": recently_updated,
        "recently_completed": recently_completed,
        "featured_book": featured_book,
        "explore_topics": explore_topics,
        "library_entries": library_payload,
        "write_screen": write_screen,
        "notifications": notifications,
        "menu_sections": menu_sections,
        "profile": profile_payload,
        "achievements": achievements,
    }