import React, { useEffect, useState } from "react";

// Set this at build time, e.g. REACT_APP_API_URL=http://your-backend:4000
const API_URL = process.env.REACT_APP_API_URL || "http://localhost:4000";

export default function App() {
  const [items, setItems] = useState([]);
  const [name, setName] = useState("");
  const [loading, setLoading] = useState(false);

  const loadItems = async () => {
    setLoading(true);
    try {
      const res = await fetch(`${API_URL}/api/items`);
      const data = await res.json();
      setItems(data);
    } catch (err) {
      console.error("Failed to load items", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadItems();
  }, []);

  const addItem = async (e) => {
    e.preventDefault();
    if (!name.trim()) return;
    await fetch(`${API_URL}/api/items`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name }),
    });
    setName("");
    loadItems();
  };

  const deleteItem = async (id) => {
    await fetch(`${API_URL}/api/items/${id}`, { method: "DELETE" });
    loadItems();
  };

  return (
    <div style={{ maxWidth: 480, margin: "40px auto", fontFamily: "sans-serif" }}>
      <h1>Items</h1>

      <form onSubmit={addItem} style={{ display: "flex", gap: 8, marginBottom: 20 }}>
        <input
          value={name}
          onChange={(e) => setName(e.target.value)}
          placeholder="New item name"
          style={{ flex: 1, padding: 8 }}
        />
        <button type="submit" style={{ padding: "8px 16px" }}>Add</button>
      </form>

      {loading ? (
        <p>Loading...</p>
      ) : (
        <ul style={{ listStyle: "none", padding: 0 }}>
          {items.map((item) => (
            <li
              key={item.id}
              style={{
                display: "flex",
                justifyContent: "space-between",
                padding: "8px 0",
                borderBottom: "1px solid #eee",
              }}
            >
              {item.name}
              <button onClick={() => deleteItem(item.id)} style={{ color: "red" }}>
                Delete
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
