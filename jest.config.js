// For a detailed explanation regarding each configuration property, visit:
// https://jestjs.io/docs/en/configuration.html

module.exports = {
  bail: 10,
  clearMocks: true,

  setupFiles: [
    './spec/jest.setup.js'
  ],
  testEnvironment: "node",
  testMatch: [
    "**/spec/**.spec.js"
  ],

  testPathIgnorePatterns: [
    "\\\\node_modules\\\\"
  ],
  verbose: true
};
