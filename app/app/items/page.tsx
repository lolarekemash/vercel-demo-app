"use client";

import { useEffect, useState } from "react";

export default function ItemsPage() {
  const [items, setItems] = useState([]);
  const [name, setName] = useState("");

  async function fetchItems() {
    const res = await fetch("/api/items");
    const data = await res.json();
    setItems(data);
  }

  async function addItem() {
    await fetch("/api/items", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name }),
    });

    setName("");
    fetchItems();
  }

  useEffect(() => {
    fetchItems();
  }, []);

  return (
    <div style={{ padding: 20 }}>
      <h1>Items</h1>

      <input
        value={name}
        onChange={(e) => setName(e.target.value)}
        placeholder="Enter item name"
      />
      <button onClick={addItem}>Add Item</button>

      <ul>
        {items.map((item: any) => (
          <li key={item.id}>{item.name}</li>
        ))}
      </ul>
    </div>
  );
}
