import js from '@eslint/js'
import globals from 'globals'
import reactHooks from 'eslint-plugin-react-hooks'
import reactRefresh from 'eslint-plugin-react-refresh'
import { defineConfig, globalIgnores } from 'eslint/config'

export default defineConfig([
  globalIgnores(['dist']),
  {
    files: ['**/*.{js,jsx}'],
    extends: [
      js.configs.recommended,
      reactHooks.configs.flat.recommended,
      reactRefresh.configs.vite,
    ],
    languageOptions: {
      ecmaVersion: 2020,
      globals: globals.browser,
      parserOptions: {
        ecmaVersion: 'latest',
        ecmaFeatures: { jsx: true },
        sourceType: 'module',
      },
    },
    rules: {
      // Allow PascalCase args (icon: Icon pattern in React) and _-prefixed args
      'no-unused-vars': ['warn', {
        varsIgnorePattern: '^[A-Z_]',
        argsIgnorePattern: '^_|^[A-Z]',
        destructuredArrayIgnorePattern: '^_',
        caughtErrors: 'none',
      }],
      // React Hooks compiler rules: warn to avoid breaking CI builds on existing patterns
      'react-hooks/purity': 'warn',
      'react-hooks/set-state-in-effect': 'warn',
      // Fast-refresh: warn only — informational, does not block CI
      'react-refresh/only-export-components': ['warn', { allowConstantExport: true }],
    },
  },
])
