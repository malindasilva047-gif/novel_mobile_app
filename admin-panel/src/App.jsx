import { useEffect, useMemo, useState } from "react";
import {
  API_BASE_URL,
  createAchievement,
  createBook,
  createCategory,
  createMenuItem,
  createNotification,
  createReadingList,
  deleteAchievement,
  deleteBook,
  deleteCategory,
  deleteMenuItem,
  deleteNotification,
  deleteReadingList,
  getAdminBootstrap,
  updateAchievement,
  updateBook,
  updateCategory,
  updateMenuItem,
  updateNotification,
  updateProfile,
  updateReadingList,
  updateWriteScreen,
} from "./api";

const EMPTY_CATEGORY = { name: "", topic_count: 0, tab_group: "explore", sort_order: 999 };
const EMPTY_BOOK = {
  title: "",
  author: "",
  description: "",
  cover_path: "",
  accent_hex: "#808080",
  section_name: "recently_updated",
  status_text: "Draft",
  rating: 0,
  genre: "",
  cta_label: "Read now",
  sort_order: 999,
};
const EMPTY_NOTIFICATION = { tab: "activity", title: "", message: "", created_at: "Now" };
const EMPTY_MENU = { section: "General", label: "", icon: "menu", route: "/" };
const EMPTY_LIST = { name: "", story_count: 0, cover_path: "" };
const EMPTY_ACHIEVEMENT = { title: "", subtitle: "", progress: 0, total: 100, badge_hex: "#119C95" };

function safeConfirm(message) {
  return window.confirm(message);
}

function asArray(value) {
  return Array.isArray(value) ? value : [];
}

export default function App() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const [categories, setCategories] = useState([]);
  const [books, setBooks] = useState([]);
  const [notifications, setNotifications] = useState([]);
  const [menuItems, setMenuItems] = useState([]);
  const [writeScreen, setWriteScreen] = useState({
    manage_tabs: ["Manage Stories", "Analytics"],
    story_tabs: ["Submitted", "Drafts"],
    filter_label: "All stories",
    sort_label: "Recently Updated",
    empty_title: "You have not submitted any story yet",
    empty_cta: "Submit Stories",
  });
  const [profile, setProfile] = useState({
    display_name: "",
    username: "",
    following: 0,
    followers: 0,
    blocked: 0,
    chapters_read: 0,
    social_karma: 0,
    day_streak: 0,
  });
  const [readingLists, setReadingLists] = useState([]);
  const [achievements, setAchievements] = useState([]);

  const [categoryForm, setCategoryForm] = useState(EMPTY_CATEGORY);
  const [bookForm, setBookForm] = useState(EMPTY_BOOK);
  const [notificationForm, setNotificationForm] = useState(EMPTY_NOTIFICATION);
  const [menuForm, setMenuForm] = useState(EMPTY_MENU);
  const [listForm, setListForm] = useState(EMPTY_LIST);
  const [achievementForm, setAchievementForm] = useState(EMPTY_ACHIEVEMENT);

  const stats = useMemo(
    () => ({
      categories: categories.length,
      books: books.length,
      notifications: notifications.length,
      menuItems: menuItems.length,
      lists: readingLists.length,
      achievements: achievements.length,
    }),
    [categories, books, notifications, menuItems, readingLists, achievements]
  );

  async function loadData() {
    try {
      setLoading(true);
      setError("");
      const payload = await getAdminBootstrap();
      setCategories(asArray(payload.categories));
      setBooks(asArray(payload.books));
      setNotifications(
        asArray(payload.notifications).map((item) => ({
          ...item,
          tab: item.tab ?? item.tab_name ?? "",
        }))
      );
      setMenuItems(
        asArray(payload.menu_items).map((item) => ({
          ...item,
          section: item.section ?? item.section_name ?? "",
          icon: item.icon ?? item.icon_name ?? "",
          route: item.route ?? item.route_name ?? "",
        }))
      );
      setWriteScreen(payload.write_screen || writeScreen);
      setProfile(payload.profile || profile);
      setReadingLists(asArray(payload.reading_lists));
      setAchievements(
        asArray(payload.achievements).map((item) => {
          const progressLabel = item.progress_label || "0/0";
          const [current, total] = progressLabel.split("/");
          return {
            ...item,
            progress: Number.parseInt(current || "0", 10) || 0,
            total:
              Number.parseInt((total || "0").split(" ")[0], 10) ||
              Number.parseInt(item.badge_value || "0", 10) ||
              0,
          };
        })
      );
    } catch (err) {
      setError(err.message || "Failed to load admin data");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function submitCreate(action, resetForm) {
    try {
      await action();
      resetForm();
      await loadData();
    } catch (err) {
      setError(err.message || "Action failed");
    }
  }

  async function submitDelete(action, message) {
    if (!safeConfirm(message)) return;
    try {
      await action();
      await loadData();
    } catch (err) {
      setError(err.message || "Delete failed");
    }
  }

  async function quickUpdate(action) {
    try {
      await action();
      await loadData();
    } catch (err) {
      setError(err.message || "Update failed");
    }
  }

  return (
    <div className="admin-shell">
      <header className="hero">
        <div>
          <p className="eyebrow">Novel CMS</p>
          <h1>Admin Control Panel</h1>
          <p className="subtitle">Manage mobile app content and all CRUD backend sections.</p>
        </div>
        <div className="endpoint">API: {API_BASE_URL}</div>
      </header>

      <section className="stats-grid">
        <article className="stat-card"><p>Categories</p><h3>{stats.categories}</h3></article>
        <article className="stat-card"><p>Stories</p><h3>{stats.books}</h3></article>
        <article className="stat-card"><p>Notifications</p><h3>{stats.notifications}</h3></article>
        <article className="stat-card"><p>Menu Items</p><h3>{stats.menuItems}</h3></article>
        <article className="stat-card"><p>Reading Lists</p><h3>{stats.lists}</h3></article>
        <article className="stat-card"><p>Achievements</p><h3>{stats.achievements}</h3></article>
      </section>

      {error ? <div className="error-banner">{error}</div> : null}
      {loading ? <p className="loading">Loading admin data...</p> : null}

      <section className="panel-grid">
        <article className="panel">
          <h2>Categories</h2>
          <form
            className="form-grid"
            onSubmit={(e) => {
              e.preventDefault();
              submitCreate(
                () => createCategory({
                  ...categoryForm,
                  topic_count: Number(categoryForm.topic_count || 0),
                  sort_order: Number(categoryForm.sort_order || 0),
                }),
                () => setCategoryForm(EMPTY_CATEGORY)
              );
            }}
          >
            <input placeholder="Name" value={categoryForm.name} onChange={(e) => setCategoryForm((v) => ({ ...v, name: e.target.value }))} required />
            <select value={categoryForm.tab_group} onChange={(e) => setCategoryForm((v) => ({ ...v, tab_group: e.target.value }))}>
              <option value="discover">discover</option>
              <option value="explore">explore</option>
            </select>
            <input type="number" placeholder="Topic count" value={categoryForm.topic_count} onChange={(e) => setCategoryForm((v) => ({ ...v, topic_count: Number(e.target.value || 0) }))} />
            <input type="number" placeholder="Sort" value={categoryForm.sort_order} onChange={(e) => setCategoryForm((v) => ({ ...v, sort_order: Number(e.target.value || 0) }))} />
            <button type="submit">Create Category</button>
          </form>
          <SimpleTable
            headers={["Name", "Group", "Count", "Sort", "Action"]}
            rows={categories.map((row) => [
              row.name,
              <InlineSelect value={row.tab_group} options={["discover", "explore"]} onChange={(val) => quickUpdate(() => updateCategory(row.id, { ...row, tab_group: val }))} />,
              <InlineNumber value={row.topic_count} onChange={(val) => quickUpdate(() => updateCategory(row.id, { ...row, topic_count: val }))} />,
              <InlineNumber value={row.sort_order} onChange={(val) => quickUpdate(() => updateCategory(row.id, { ...row, sort_order: val }))} />,
              <button className="danger" onClick={() => submitDelete(() => deleteCategory(row.id), "Delete this category?")}>Delete</button>,
            ])}
          />
        </article>

        <article className="panel">
          <h2>Stories</h2>
          <form
            className="form-grid"
            onSubmit={(e) => {
              e.preventDefault();
              submitCreate(
                () =>
                  createBook({
                    ...bookForm,
                    rating: Number(bookForm.rating || 0),
                    sort_order: Number(bookForm.sort_order || 0),
                  }),
                () => setBookForm(EMPTY_BOOK)
              );
            }}
          >
            <input placeholder="Title" value={bookForm.title} onChange={(e) => setBookForm((v) => ({ ...v, title: e.target.value }))} required />
            <input placeholder="Author" value={bookForm.author} onChange={(e) => setBookForm((v) => ({ ...v, author: e.target.value }))} required />
            <input placeholder="Genre" value={bookForm.genre} onChange={(e) => setBookForm((v) => ({ ...v, genre: e.target.value }))} required />
            <textarea placeholder="Description" rows={3} value={bookForm.description} onChange={(e) => setBookForm((v) => ({ ...v, description: e.target.value }))} />
            <div className="inline-grid">
              <select value={bookForm.section_name} onChange={(e) => setBookForm((v) => ({ ...v, section_name: e.target.value }))}>
                <option value="featured">featured</option>
                <option value="recently_updated">recently_updated</option>
                <option value="recently_completed">recently_completed</option>
              </select>
              <input type="number" step="0.1" min="0" max="5" value={bookForm.rating} onChange={(e) => setBookForm((v) => ({ ...v, rating: Number(e.target.value || 0) }))} />
            </div>
            <button type="submit">Create Story</button>
          </form>
          <SimpleTable
            headers={["Title", "Section", "Rating", "Sort", "Action"]}
            rows={books.map((row) => [
              row.title,
              <InlineSelect value={row.section_name} options={["featured", "recently_updated", "recently_completed"]} onChange={(val) => quickUpdate(() => updateBook(row.id, { ...row, section_name: val }))} />,
              <InlineNumber value={row.rating} step="0.1" onChange={(val) => quickUpdate(() => updateBook(row.id, { ...row, rating: val }))} />,
              <InlineNumber value={row.sort_order} onChange={(val) => quickUpdate(() => updateBook(row.id, { ...row, sort_order: val }))} />,
              <button className="danger" onClick={() => submitDelete(() => deleteBook(row.id), "Delete this story?")}>Delete</button>,
            ])}
          />
        </article>

        <article className="panel">
          <h2>Notifications</h2>
          <form className="form-grid" onSubmit={(e) => { e.preventDefault(); submitCreate(() => createNotification(notificationForm), () => setNotificationForm(EMPTY_NOTIFICATION)); }}>
            <input placeholder="Tab" value={notificationForm.tab} onChange={(e) => setNotificationForm((v) => ({ ...v, tab: e.target.value }))} required />
            <input placeholder="Title" value={notificationForm.title} onChange={(e) => setNotificationForm((v) => ({ ...v, title: e.target.value }))} required />
            <textarea placeholder="Message" rows={2} value={notificationForm.message} onChange={(e) => setNotificationForm((v) => ({ ...v, message: e.target.value }))} required />
            <button type="submit">Create Notification</button>
          </form>
          <SimpleTable
            headers={["Tab", "Title", "Message", "Action"]}
            rows={notifications.map((row) => [
              row.tab,
              row.title,
              row.message,
              <span className="actions">
                <button onClick={() => {
                  const title = window.prompt("New title", row.title);
                  if (title == null) return;
                  quickUpdate(() => updateNotification(row.id, { ...row, title }));
                }}>Edit</button>
                <button className="danger" onClick={() => submitDelete(() => deleteNotification(row.id), "Delete this notification?")}>Delete</button>
              </span>,
            ])}
          />
        </article>

        <article className="panel">
          <h2>Menu Items</h2>
          <form className="form-grid" onSubmit={(e) => { e.preventDefault(); submitCreate(() => createMenuItem(menuForm), () => setMenuForm(EMPTY_MENU)); }}>
            <input placeholder="Section" value={menuForm.section} onChange={(e) => setMenuForm((v) => ({ ...v, section: e.target.value }))} required />
            <input placeholder="Label" value={menuForm.label} onChange={(e) => setMenuForm((v) => ({ ...v, label: e.target.value }))} required />
            <input placeholder="Icon" value={menuForm.icon} onChange={(e) => setMenuForm((v) => ({ ...v, icon: e.target.value }))} required />
            <input placeholder="Route" value={menuForm.route} onChange={(e) => setMenuForm((v) => ({ ...v, route: e.target.value }))} required />
            <button type="submit">Create Menu Item</button>
          </form>
          <SimpleTable
            headers={["Section", "Label", "Route", "Action"]}
            rows={menuItems.map((row) => [
              row.section,
              row.label,
              row.route,
              <span className="actions">
                <button onClick={() => {
                  const label = window.prompt("New label", row.label);
                  if (label == null) return;
                  quickUpdate(() => updateMenuItem(row.id, { ...row, label }));
                }}>Edit</button>
                <button className="danger" onClick={() => submitDelete(() => deleteMenuItem(row.id), "Delete this menu item?")}>Delete</button>
              </span>,
            ])}
          />
        </article>

        <article className="panel">
          <h2>Write Screen Config</h2>
          <form className="form-grid" onSubmit={(e) => { e.preventDefault(); quickUpdate(() => updateWriteScreen(writeScreen)); }}>
            <input value={writeScreen.filter_label || ""} onChange={(e) => setWriteScreen((v) => ({ ...v, filter_label: e.target.value }))} placeholder="Filter label" />
            <input value={writeScreen.sort_label || ""} onChange={(e) => setWriteScreen((v) => ({ ...v, sort_label: e.target.value }))} placeholder="Sort label" />
            <input value={writeScreen.empty_title || ""} onChange={(e) => setWriteScreen((v) => ({ ...v, empty_title: e.target.value }))} placeholder="Empty title" />
            <input value={writeScreen.empty_cta || ""} onChange={(e) => setWriteScreen((v) => ({ ...v, empty_cta: e.target.value }))} placeholder="Empty CTA" />
            <button type="submit">Save Write Config</button>
          </form>
        </article>

        <article className="panel">
          <h2>Profile</h2>
          <form className="form-grid" onSubmit={(e) => { e.preventDefault(); quickUpdate(() => updateProfile(profile)); }}>
            <input value={profile.display_name || ""} onChange={(e) => setProfile((v) => ({ ...v, display_name: e.target.value }))} placeholder="Display name" />
            <input value={profile.username || ""} onChange={(e) => setProfile((v) => ({ ...v, username: e.target.value }))} placeholder="Username" />
            <div className="inline-grid">
              <input type="number" value={profile.followers || 0} onChange={(e) => setProfile((v) => ({ ...v, followers: Number(e.target.value || 0) }))} placeholder="Followers" />
              <input type="number" value={profile.following || 0} onChange={(e) => setProfile((v) => ({ ...v, following: Number(e.target.value || 0) }))} placeholder="Following" />
            </div>
            <button type="submit">Save Profile</button>
          </form>
        </article>

        <article className="panel">
          <h2>Reading Lists</h2>
          <form className="form-grid" onSubmit={(e) => { e.preventDefault(); submitCreate(() => createReadingList({ ...listForm, story_count: Number(listForm.story_count || 0) }), () => setListForm(EMPTY_LIST)); }}>
            <input placeholder="List name" value={listForm.name} onChange={(e) => setListForm((v) => ({ ...v, name: e.target.value }))} required />
            <input type="number" placeholder="Story count" value={listForm.story_count} onChange={(e) => setListForm((v) => ({ ...v, story_count: Number(e.target.value || 0) }))} />
            <input placeholder="Cover path" value={listForm.cover_path} onChange={(e) => setListForm((v) => ({ ...v, cover_path: e.target.value }))} />
            <button type="submit">Create Reading List</button>
          </form>
          <SimpleTable
            headers={["Name", "Count", "Action"]}
            rows={readingLists.map((row) => [
              row.name,
              row.story_count,
              <span className="actions">
                <button onClick={() => {
                  const name = window.prompt("New list name", row.name);
                  if (name == null) return;
                  quickUpdate(() => updateReadingList(row.id, { ...row, name }));
                }}>Edit</button>
                <button className="danger" onClick={() => submitDelete(() => deleteReadingList(row.id), "Delete this reading list?")}>Delete</button>
              </span>,
            ])}
          />
        </article>

        <article className="panel">
          <h2>Achievements</h2>
          <form className="form-grid" onSubmit={(e) => { e.preventDefault(); submitCreate(() => createAchievement({ ...achievementForm, progress: Number(achievementForm.progress || 0), total: Number(achievementForm.total || 0) }), () => setAchievementForm(EMPTY_ACHIEVEMENT)); }}>
            <input placeholder="Title" value={achievementForm.title} onChange={(e) => setAchievementForm((v) => ({ ...v, title: e.target.value }))} required />
            <input placeholder="Subtitle" value={achievementForm.subtitle} onChange={(e) => setAchievementForm((v) => ({ ...v, subtitle: e.target.value }))} />
            <div className="inline-grid">
              <input type="number" placeholder="Progress" value={achievementForm.progress} onChange={(e) => setAchievementForm((v) => ({ ...v, progress: Number(e.target.value || 0) }))} />
              <input type="number" placeholder="Total" value={achievementForm.total} onChange={(e) => setAchievementForm((v) => ({ ...v, total: Number(e.target.value || 0) }))} />
            </div>
            <button type="submit">Create Achievement</button>
          </form>
          <SimpleTable
            headers={["Title", "Progress", "Action"]}
            rows={achievements.map((row) => [
              row.title,
              `${row.progress}/${row.total}`,
              <span className="actions">
                <button onClick={() => {
                  const title = window.prompt("New title", row.title);
                  if (title == null) return;
                  quickUpdate(() => updateAchievement(row.id, { ...row, title }));
                }}>Edit</button>
                <button className="danger" onClick={() => submitDelete(() => deleteAchievement(row.id), "Delete this achievement?")}>Delete</button>
              </span>,
            ])}
          />
        </article>
      </section>
    </div>
  );
}

function SimpleTable({ headers, rows }) {
  return (
    <div className="table-wrap">
      <table>
        <thead>
          <tr>
            {headers.map((h) => <th key={h}>{h}</th>)}
          </tr>
        </thead>
        <tbody>
          {rows.length === 0 ? (
            <tr>
              <td colSpan={headers.length}>No records</td>
            </tr>
          ) : (
            rows.map((cells, idx) => (
              <tr key={idx}>
                {cells.map((cell, i) => <td key={i}>{cell}</td>)}
              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  );
}

function InlineSelect({ value, options, onChange }) {
  return (
    <select value={value || ""} onChange={(e) => onChange(e.target.value)}>
      {options.map((option) => <option key={option} value={option}>{option}</option>)}
    </select>
  );
}

function InlineNumber({ value, onChange, step = "1" }) {
  return (
    <input
      type="number"
      step={step}
      value={Number(value || 0)}
      onChange={(e) => onChange(Number(e.target.value || 0))}
    />
  );
}
