export default {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'subject-case': [0, 'always', []],
  },
  ignores: [(commit) => commit === '^chore\(release\):(.*)'],
}
