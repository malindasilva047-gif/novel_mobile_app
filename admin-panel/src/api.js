const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL?.trim() || "http://127.0.0.1:8000";

async function request(path, options = {}) {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    headers: {
      "Content-Type": "application/json",
      ...(options.headers || {}),
    },
    ...options,
  });

  if (!response.ok) {
    const text = await response.text();
    throw new Error(text || `Request failed with status ${response.status}`);
  }

  if (response.status === 204) {
    return null;
  }

  return response.json();
}

export function getAdminBootstrap() {
  return request("/api/admin/bootstrap");
}

export function createCategory(payload) {
  return request("/api/admin/categories", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export function updateCategory(id, payload) {
  return request(`/api/admin/categories/${id}`, {
    method: "PUT",
    body: JSON.stringify(payload),
  });
}

export function deleteCategory(id) {
  return request(`/api/admin/categories/${id}`, {
    method: "DELETE",
  });
}

export function createBook(payload) {
  return request("/api/admin/books", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export function updateBook(id, payload) {
  return request(`/api/admin/books/${id}`, {
    method: "PUT",
    body: JSON.stringify(payload),
  });
}

export function deleteBook(id) {
  return request(`/api/admin/books/${id}`, {
    method: "DELETE",
  });
}

export { API_BASE_URL };
