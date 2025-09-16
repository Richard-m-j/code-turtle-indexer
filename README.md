# 🐢 Code-Turtle Indexer

This GitHub Action indexes your codebase using Pinecone, preparing it for the `code-turtle-reviewer` action. Indexing allows the reviewer to understand the context of your code, leading to more accurate and relevant reviews.

## 🚀 How to Use

To use this action, you need to create a workflow file in your repository (e.g., `.github/workflows/code-turtle-indexer.yml`) and add the following code:

```yaml
name: 'Code-Turtle Indexer'

on:
  push:
    branches:
      - main

jobs:
  run-indexer:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Run Indexing
        uses: richard-m-j/code-turtle-indexer@v1
        with:
          pinecone_api_key: ${{ secrets.PINECONE_API_KEY }}
          pinecone_environment: ${{ secrets.PINECONE_ENVIRONMENT }}