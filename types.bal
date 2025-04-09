# Represents an album in the music catalog
public type Album readonly & record {|
    string id;
    string title;
    string artist;
    decimal price;
|};

# Represents a user in the system
public type User readonly & record {|
    string id;
    string username;
    string password;
    string role;
|};

# Standard API response format
#
# + success - field description  
# + message - field description  
# + payload - field description
public type ApiResponse record {|
    boolean success;
    string message;
    record {|
        string token?;
        record {}[]|record {}|string|int|boolean data?;
    |} payload?;
|};
