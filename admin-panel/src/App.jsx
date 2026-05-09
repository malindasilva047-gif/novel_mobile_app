import { useEffect, useMemo, useState } from "react";
import {
  API_BASE_URL,
  createBook,
  createCategory,
  deleteBook,
  deleteCategory,
  getAdminBootstrap,
  updateBook,
  updateCategory,
} from "./api";

const EMPTY_CATEGORY = {
  name: "",
  topic_count: 0,
  tab_group: "explore",
  sort_order: 999,
};

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

export default function App() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [categories, setCategories] = useState([]);
  const [books, setBooks] = useState([]);
  const [categoryForm, setCategoryForm] = useState(EMPTY_CATEGORY);
  const [bookForm, setBookForm] = useState(EMPTY_BOOK);

  const stats = useMemo(
    () => ({
      categories: categories.length,
      books: books.length,
      discover: categories.filter((x) => x.tab_group === "discover").length,
      explore: categories.filter((x) => x.tab_group === "explore").length,
    }),
    [categories, books]
  );

  async function loadData() {
    try {
      setLoading(true);
      setError("");
      const payload = await getAdminBootstrap();
      setCategories(payload.categories || []);
      setBooks(payload.books || []);
    } catch (err) {
      setError(err.message || "Failed to load admin data");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadData();
  }, []);

  async function handleCreateCategory(e) {
    e.preventDefault();
    try {
      await createCategory({
        ...categoryForm,
        topic_count: Number(categoryForm.topic_count || 0),
        sort_order: Number(categoryForm.sort_order || 0),
      });
      setCategoryForm(EMPTY_CATEGORY);
      await loadData();
    } catch (err) {
      setError(err.message || "Failed to create category");
    }
  }

  async function handleCreateBook(e) {
    e.preventDefault();
    try {
      await createBook({
        ...bookForm,
        rating: Number(bookForm.rating || 0),
        sort_order: Number(bookForm.sort_order || 0),
      });
      setBookForm(EMPTY_BOOK);
      await loadData();
    } catch (err) {
      setError(err.message || "Failed to create story");
    }
  }

  async function handleQuickCategoryUpdate(category, patch) {
    try {
      await updateCategory(category.id, { ...category, ...patch });
      await loadData();
    } catch (err) {
      setError(err.message || "Failed to update category");
    }
  }

  async function handleQuickBookUpdate(book, patch) {
    try {
      await updateBook(book.id, { ...book, ...patch });
      await loadData();
    } catch (err) {
      setError(err.message || "Failed to update story");
    }
  }

  async function handleDeleteCategory(id) {
    if (!confirm("Delete this category?")) {
      return;
    }
    try {
      await deleteCategory(id);
      await loadData();
    } catch (err) {
      setError(err.message || "Failed to delete category");
    }
  }

  async function handleDeleteBook(id) {
    if (!confirm("Delete this story?")) {
      return;
    }
    try {
      await deleteBook(id);
      await loadData();
    } catch (err) {
      setError(err.message || "Failed to delete story");
    }
  }

  return (
    <div className="admin-shell">
      <header className="hero">
        <div>
          <p className="eyebrow">Novel CMS</p>
          <h1>Admin Control Panel</h1>
          <p className="subtitle">Manage discover tabs, categories, and stories from one place.</p>
        </div>
        <div className="endpoint">API: {API_BASE_URL}</div>
      </header>

      <section className="stats-grid">
        <article className="stat-card">
          <p>All Categories</p>
          <h3>{stats.categories}</h3>
        </article>
        <article className="stat-card">
          <p>Stories</p>
          <h3>{stats.books}</h3>
        </article>
        <article className="stat-card">
          <p>Discover Tabs</p>
          <h3>{stats.discover}</h3>
        </article>
        <article className="stat-card">
          <p>Explore Topics</p>
          <h3>{stats.explore}</h3>
        </article>
      </section>

      {error ? <div className="error-banner">{error}</div> : null}

      {loading ? <p className="loading">Loading admin data...</p> : null}

      <section className="panel-grid">
        <article className="panel">
          <h2>Add Category</h2>
          <form className="form-grid" onSubmit={handleCreateCategory}>
            <input
              placeholder="Category name"
              value={categoryForm.name}
              onChange={(e) => setCategoryForm((v) => ({ ...v, name: e.target.value }))}
              required
            />
            <select
              value={categoryForm.tab_group}
              onChange={(e) => setCategoryForm((v) => ({ ...v, tab_group: e.target.value }))}
            >
              <option value="discover">discover</option>
              <option value="explore">explore</option>
            </select>
            <input
              type="number"
              placeholder="Topic count"
              value={categoryForm.topic_count}
              onChange={(e) =>
                setCategoryForm((v) => ({ ...v, topic_count: Number(e.target.value || 0) }))
              }
            />
            <input
              type="number"
              placeholder="Sort order"
              value={categoryForm.sort_order}
              onChange={(e) =>
                setCategoryForm((v) => ({ ...v, sort_order: Number(e.target.value || 0) }))
              }
            />
            <button type="submit">Create Category</button>
          </form>

          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Group</th>
                  <th>Count</th>
                  <th>Sort</th>
                  <th>Action</th>
                </tr>
              </thead>
              <tbody>
                {categories.map((item) => (
                  <tr key={item.id}>
                    <td>{item.name}</td>
                    <td>
                      <select
                        value={item.tab_group}
                        onChange={(e) =>
                          handleQuickCategoryUpdate(item, { tab_group: e.target.value })
                        }
                      >
                        <option value="discover">discover</option>
                        <option value="explore">explore</option>
                      </select>
                    </td>
                    <td>
                      <input
                        type="number"
                        value={item.topic_count}
                        onChange={(e) =>
                          handleQuickCategoryUpdate(item, {
                            topic_count: Number(e.target.value || 0),
                          })
                        }
                      />
                    </td>
                    <td>
                      <input
                        type="number"
                        value={item.sort_order}
                        onChange={(e) =>
                          handleQuickCategoryUpdate(item, {
                            sort_order: Number(e.target.value || 0),
                          })
                        }
                      />
                    </td>
                    <td>
                      <button className="danger" onClick={() => handleDeleteCategory(item.id)}>
                        Delete
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </article>

        <article className="panel">
          <h2>Add Story</h2>
          <form className="form-grid" onSubmit={handleCreateBook}>
            <input
              placeholder="Story title"
              value={bookForm.title}
              onChange={(e) => setBookForm((v) => ({ ...v, title: e.target.value }))}
              required
            />
            <input
              placeholder="Author"
              value={bookForm.author}
              onChange={(e) => setBookForm((v) => ({ ...v, author: e.target.value }))}
              required
            />
            <input
              placeholder="Genre"
              value={bookForm.genre}
              onChange={(e) => setBookForm((v) => ({ ...v, genre: e.target.value }))}
              required
            />
            <textarea
              placeholder="Description"
              value={bookForm.description}
              onChange={(e) => setBookForm((v) => ({ ...v, description: e.target.value }))}
              rows={3}
              required
            />
            <div className="inline-grid">
              <select
                value={bookForm.section_name}
                onChange={(e) =>
                  setBookForm((v) => ({ ...v, section_name: e.target.value }))
                }
              >
                <option value="featured">featured</option>
                <option value="recently_updated">recently_updated</option>
                <option value="recently_completed">recently_completed</option>
              </select>
              <input
                type="number"
                step="0.1"
                min="0"
                max="5"
                value={bookForm.rating}
                onChange={(e) => setBookForm((v) => ({ ...v, rating: Number(e.target.value || 0) }))}
              />
            </div>
            <button type="submit">Create Story</button>
          </form>

          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Title</th>
                  <th>Section</th>
                  <th>Rating</th>
                  <th>Sort</th>
                  <th>Action</th>
                </tr>
              </thead>
              <tbody>
                {books.map((book) => (
                  <tr key={book.id}>
                    <td>{book.title}</td>
                    <td>
                      <select
                        value={book.section_name}
                        onChange={(e) =>
                          handleQuickBookUpdate(book, { section_name: e.target.value })
                        }
                      >
                        <option value="featured">featured</option>
                        <option value="recently_updated">recently_updated</option>
                        <option value="recently_completed">recently_completed</option>
                      </select>
                    </td>
                    <td>
                      <input
                        type="number"
                        step="0.1"
                        min="0"
                        max="5"
                        value={book.rating}
                        onChange={(e) =>
                          handleQuickBookUpdate(book, {
                            rating: Number(e.target.value || 0),
                          })
                        }
                      />
                    </td>
                    <td>
                      <input
                        type="number"
                        value={book.sort_order}
                        onChange={(e) =>
                          handleQuickBookUpdate(book, {
                            sort_order: Number(e.target.value || 0),
                          })
                        }
                      />
                    </td>
                    <td>
                      <button className="danger" onClick={() => handleDeleteBook(book.id)}>
                        Delete
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </article>
      </section>
    </div>
  );
}
