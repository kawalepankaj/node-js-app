const request = require("supertest");
const app = require("./app");

test("GET / returns welcome message", async () => {
  const response = await request(app).get("/");

  expect(response.statusCode).toBe(200);
  expect(response.text).toMatch(/Welcome to/);
});

test("GET /health returns status ok", async () => {
  const response = await request(app).get("/health");

  expect(response.statusCode).toBe(200);
  expect(response.body).toEqual(
    expect.objectContaining({
      status: "ok",
      app: expect.any(String),
    })
  );
});
