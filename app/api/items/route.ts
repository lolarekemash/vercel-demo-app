import { NextResponse } from "next/server";
import { query } from "@/lib/db";

export async function GET() {
  const result = await query("SELECT id, name FROM items ORDER BY id");
  return NextResponse.json(result.rows);
}

export async function POST(req: Request) {
  const body = await req.json();
  const name = body.name || "unnamed";

  const result = await query(
    "INSERT INTO items (name) VALUES ($1) RETURNING id, name",
    [name]
  );

  return NextResponse.json(result.rows[0], { status: 201 });
}
