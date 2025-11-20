import { NextResponse } from "next/server";

let items: { id: number; name: string }[] = [];
let currentId = 1;

export async function GET() {
  return NextResponse.json(items);
}

export async function POST(request: Request) {
  const body = await request.json();
  console.log("Received POST:", body);

  const newItem = { id: currentId++, name: body.name };
  items.push(newItem);

  return NextResponse.json(newItem);
}
