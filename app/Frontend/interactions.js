const API_URL = "https://me-central1-fiery-protocol-466303-p6.cloudfunctions.net/sahaba-gcp-function";
const API_KEY = "…"; // consider moving server-side
const COOKIE_NAME = "VID";
const countEl = document.getElementById("count");

/* ---------- Utilities ---------- */
const randId = () => "_" + Math.random().toString(36).slice(2, 11);

const setCookie = (name, value, days = 30) => {
  const d = new Date(Date.now() + days * 864e5);
  document.cookie = `${encodeURIComponent(name)}=${encodeURIComponent(value)};expires=${d.toUTCString()};path=/`;
};

const getCookie = name =>
  document.cookie
    .split("; ")
    .find(c => c.startsWith(`${encodeURIComponent(name)}=`))
    ?.split("=")[1] || "";

/* ---------- Networking ---------- */
async function callCounterAPI(isNewVisitor) {
  const method = isNewVisitor ? "POST" : "GET";
  const res = await fetch(API_URL, {
    method
  });
  if (!res.ok) throw new Error(`${method} to visitor API failed`);
  const { Visitor_Count: count = 0 } = await res.json();
  return count;
}

/* ---------- Flow ---------- */
async function initVisitorCounter() {
  try {
    const isNew = !getCookie(COOKIE_NAME);
    if (isNew) setCookie(COOKIE_NAME, randId());

    const count = await callCounterAPI(isNew);
    countEl.textContent = count.toLocaleString("en-US"); // 1,234
  } catch (err) {
    console.error(err);
    countEl.textContent = "—"; // graceful fallback
  }
}

document.addEventListener("DOMContentLoaded", initVisitorCounter);
