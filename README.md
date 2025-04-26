# Intellect Hub e-Registry Contract

The **Intellect Hub e-Registry** is a Clarity smart contract designed to enable decentralized registration, indexing, and authorization of intellectual contributions. It provides robust mechanisms for users to register, update, view, and control access to their digital work securely on the blockchain.

## ✨ Features

- **Register Intellectual Contributions**: Record metadata such as title, author, abstract, size, and keywords.
- **Access Management**: Control who can view or access each intellectual record.
- **Update Records**: Authors can update existing intellectual entries with new metadata.
- **Deregistration**: Authors can remove their contributions from the registry.
- **Optimized Queries**: Retrieve essential or full information efficiently.
- **Validation Framework**: Ensure data meets required standards before submission.

## 📚 Key Contract Components

- `intellectual-records` — Maps and stores registered intellectual content details.
- `access-registry` — Maps access rights for individual contributions.
- `record-sequence` — Global counter for assigning unique IDs to contributions.

## ⚡ Core Public Functions

- `register-intellectual-contribution`: Register a new intellectual asset.
- `update-intellectual-record`: Update an existing intellectual entry.
- `deregister-contribution`: Remove an intellectual record.
- `display-content-profile`: Fetch a formatted profile view.
- `retrieve-essential-data`, `retrieve-identity-only`, `retrieve-record-abstract`: Lightweight information retrieval.
- `create-contribution-display`: Full data display for a content ID.
- `verify-contribution-parameters`: Validation utility for contributions.

## 🚨 Error Handling

| Error Code | Description |
|------------|-------------|
| `u300` | Authorization failed |
| `u301` | Record not found |
| `u302` | Record already registered |
| `u303` | Invalid title format |
| `u304` | Invalid size parameter |
| `u305` | Access restricted |

## 🛠️ Deployment

This contract is written in [Clarity](https://docs.stacks.co/write-smart-contracts/clarity-language), the smart contract language for the Stacks blockchain.

To deploy:
1. Make sure you have a development environment for Clarity (e.g., Clarinet).
2. Add this contract file to your project.
3. Compile and test using Clarinet or another Clarity toolchain.
4. Deploy to a Stacks testnet or mainnet.

## 📄 License

This project is open-sourced under the [MIT License](LICENSE).
