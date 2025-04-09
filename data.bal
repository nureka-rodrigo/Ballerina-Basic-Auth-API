# Table of albums in the system
public final table<Album> key(id) albums = table [
    {id: "1", title: "Blue Train", artist: "John Coltrane", price: 56.99},
    {id: "2", title: "Jeru", artist: "Gerry Mulligan", price: 17.99},
    {id: "3", title: "Sarah Vaughan and Clifford Brown", artist: "Sarah Vaughan", price: 39.99},
    {id: "4", title: "The Best of Ella Fitzgerald", artist: "Ella Fitzgerald", price: 29.99},
    {id: "5", title: "The Great Jazz Trio", artist: "The Great Jazz Trio", price: 49.99}
];

# Table of users in the system
public final table<User> key(id) users = table [
    {id: "1", username: "admin", password: "admin", role: "admin"},
    {id: "2", username: "user", password: "user", role: "user"}
];
