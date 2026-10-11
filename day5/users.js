```javascript
const loadButton = document.querySelector("#load-users");
const filterInput = document.querySelector("#filter-input");
const status = document.querySelector("#status");
const usersList = document.querySelector("#users-list");

let users = [];

async function loadUsers() {
    loadButton.disabled = true;
    status.textContent = "Loading users...";

    try {
        const response = await fetch(
            "https://jsonplaceholder.typicode.com/users"
        );

        if (!response.ok) {
            throw new Error(`HTTP error: ${response.status}`);
        }

        users = await response.json();
        renderUsers(users);

        status.textContent = `Successfully loaded ${users.length} users.`;
    } catch (error) {
        users = [];
        renderUsers([]);
        status.textContent = "Failed to load users. Please try again.";
        console.error("Error loading users:", error);
    } finally {
        loadButton.disabled = false;
    }
}

function renderUsers(list) {
    usersList.replaceChildren();

    if (list.length === 0) {
        if (filterInput.value.trim() !== "" && users.length > 0) {
            const message = document.createElement("li");
            message.textContent = "No users match your filter.";
            usersList.appendChild(message);
        }
        return;
    }

    list.forEach((user) => {
        const item = document.createElement("li");
        const name = document.createElement("h2");
        const email = document.createElement("p");
        const city = document.createElement("p");
        const company = document.createElement("p");

        name.textContent = user.name;
        email.textContent = `Email: ${user.email}`;
        city.textContent = `City: ${user.address.city}`;
        company.textContent = `Company: ${user.company.name}`;

        item.append(name, email, city, company);
        usersList.appendChild(item);
    });
}

loadButton.addEventListener("click", loadUsers);

filterInput.addEventListener("input", () => {
    const searchText = filterInput.value.trim().toLowerCase();

    const filteredUsers = users.filter((user) =>
        user.name.toLowerCase().includes(searchText)
    );

    renderUsers(filteredUsers);

    if (filteredUsers.length > 0) {
        status.textContent = `Showing ${filteredUsers.length} user(s).`;
    } else if (users.length > 0) {
        status.textContent = "No users match your filter.";
    }
});
```
