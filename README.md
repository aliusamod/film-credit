📜 README — Decentralized Film Credits Contract

Overview

The Decentralized Film Credits Contract is a Clarity smart contract that enables immutable, transparent, and verifiable recording of film credits on the blockchain.
It allows film producers to register new films, add contributors with their specific roles, and maintain a permanent record of creative contributions — ensuring that recognition for work remains tamper-proof and accessible.

🎬 Key Features

Film Registry: Producers can create new films with unique IDs and metadata (title, release year, timestamp).

Immutable Credits: Each contributor’s credit entry (name, role, and contribution) is permanently recorded and cannot be modified by unauthorized users.

Contributor Film History: Each contributor’s film participation is tracked and retrievable.

Role-Based Access Control: Only the film’s producer can add or update credits for that film.

Transparent Data Retrieval: Read-only functions allow anyone to query films, credits, and contributor records without altering the state.

🧩 Data Structures
Data Variables

film-count — Keeps track of the total number of films registered.

Data Maps

films — Stores metadata for each film (title, producer, release-year, created-at).

film-credits — Stores credit details for contributors per film.

contributor-films — Maps a contributor’s film list by index.

contributor-film-count — Tracks how many films a contributor has worked on.

⚙️ Functions
Read-Only Functions

get-film(film-id) — Returns details of a film by its ID.

get-credit(film-id, contributor) — Returns a contributor’s credit details for a specific film.

get-film-count() — Returns total number of registered films.

get-contributor-film-count(contributor) — Returns how many films a contributor is credited in.

get-contributor-film(contributor, index) — Returns the film ID for a contributor at a given index.

Public Functions

create-film(title, release-year)

Creates a new film entry.

Only requires a title and release year.

Returns a new unique film-id.

add-credit(film-id, contributor, name, role, contribution)

Adds a contributor credit to a film.

Only the film producer can call this function.

Ensures the same contributor isn’t added twice for the same film.

update-credit(film-id, contributor, name, role, contribution)

Updates an existing credit.

Only the film producer can update.

Preserves the original timestamp of when the credit was first added.

🚫 Error Codes
Code	Description
err u100	Unauthorized – only the contract owner allowed
err u101	Film not found
err u102	Credit already exists
err u103	Unauthorized producer
err u104	Invalid film title
🧠 Example Flow

Producer creates a film:

(create-film "The Immutable Story" u2025)


→ Returns (ok u1)

Producer adds contributor:

(add-credit u1 'SP123ABC "Alice" "Director" "Directed the film")


→ Returns (ok true)

Public query:

(get-credit u1 'SP123ABC)


→ Returns contributor details.

Producer updates contributor’s role or description:

(update-credit u1 'SP123ABC "Alice" "Director" "Directed and edited the film")


→ Returns (ok true)

🛠️ Deployment Notes

Built for the Stacks blockchain using Clarity language.

To deploy, use Clarinet
 or a Stacks testnet.

Ensure contract ownership and producer principals are properly configured.

Designed for transparency in the film industry, but adaptable for any creative or collaborative project (e.g., music, games, or art production).

📖 License

MIT License – free to use, modify, and distribute with attribution.