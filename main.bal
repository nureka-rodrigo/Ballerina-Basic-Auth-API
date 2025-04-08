import ballerina/http;
import ballerina/jwt;

configurable int port = 8080;

type Album readonly & record {|
    string id;
    string title;
    string artist;
    decimal price;
|};

type User readonly & record {|
    string id;
    string username;
    string password;
    string role;
|};

type ApiResponse record {|
    boolean success;
    string message;
    record {|
        string token?;
        record {}[]|record {}|string|int|boolean data?;
    |} payload?;
|};

table<Album> key(id) albums = table [
    {id: "1", title: "Blue Train", artist: "John Coltrane", price: 56.99},
    {id: "2", title: "Jeru", artist: "Gerry Mulligan", price: 17.99},
    {id: "3", title: "Sarah Vaughan and Clifford Brown", artist: "Sarah Vaughan", price: 39.99},
    {id: "4", title: "The Best of Ella Fitzgerald", artist: "Ella Fitzgerald", price: 29.99},
    {id: "5", title: "The Great Jazz Trio", artist: "The Great Jazz Trio", price: 49.99}
];

table<User> key(id) users = table [
    {id: "1", username: "admin", password: "admin", role: "admin"},
    {id: "2", username: "user", password: "user", role: "user"}
];

jwt:ValidatorConfig validatorConfig = {
    issuer: "wso2",
    signatureConfig: {
        certFile: "./resources/public.crt"
    }
};

function isHeaderPresent(string header) returns boolean {
    if (header == "" || !header.startsWith("Bearer ") || header.length() < 8) {
        return false;
    }

    return true;
}

function isTokenValid(string token) returns boolean {
    jwt:Payload|jwt:Error validationResult = jwt:validate(token, validatorConfig);

    if validationResult is jwt:Error {
        return false;
    }

    return true;
}

// @http:ServiceConfig {
//     auth: [
//         {
//             jwtValidatorConfig: {
//                 issuer: "wso2",
//                 signatureConfig: {
//                     certFile: "./resources/public.crt"
//                 },
//                 scopeKey: "scope"
//             },
//             scopes: ["admin", "user"]
//         }
//     ]
// }
service / on new http:Listener(port) {
    resource function post login(@http:Payload record {|string username; string password;|} credentials) returns ApiResponse|http:NotFound|http:InternalServerError {
        User? authenticatedUser = ();

        foreach User user in users {
            if (user.username == credentials.username && user.password == credentials.password) {
                authenticatedUser = user;
                break;
            }
        }

        if (authenticatedUser == ()) {
            return http:NOT_FOUND;
        }

        do {
            string[] scopes = [];

            if (authenticatedUser.role == "admin") {
                scopes = ["admin"];
            } else {
                scopes = ["user"];
            }

            map<json> customClaims = {
                "scope": scopes.length() == 1 ? scopes[0] : scopes.toString()
            };

            jwt:IssuerConfig issuerConfig = {
                username: authenticatedUser.username,
                issuer: "wso2",
                expTime: 3600,
                customClaims: customClaims,
                signatureConfig: {
                    config: {
                        keyFile: "./resources/private.key"
                    }
                }
            };

            string jwt = check jwt:issue(issuerConfig);

            ApiResponse response = {
                    success: true,
                    message: "Login successful",
                    payload: {
                        token: jwt
                    }
                };

            return response;
        } on fail {
            return http:INTERNAL_SERVER_ERROR;
        }
    }

    @http:ResourceConfig {
        auth: [
            {
                jwtValidatorConfig: {
                    issuer: "wso2",
                    signatureConfig: {
                        certFile: "./resources/public.crt"
                    },
                    scopeKey: "scope"
                },
                scopes: ["admin", "user"]
            }
        ]
    }
    resource function get albums() returns ApiResponse {
        ApiResponse response = {
            success: true,
            message: "Albums retrieved successfully",
            payload: {
                data: albums.toArray()
            }
        };

        return response;
    }

    @http:ResourceConfig {
        auth: [
            {
                jwtValidatorConfig: {
                    issuer: "wso2",
                    signatureConfig: {
                        certFile: "./resources/public.crt"
                    },
                    scopeKey: "scope"
                },
                scopes: ["admin", "user"]
            }
        ]
    }
    resource function get albums/[string id]() returns ApiResponse|http:NotFound {
        Album? album = albums[id];

        if (album is ()) {
            return http:NOT_FOUND;
        }

        ApiResponse response = {
            success: true,
            message: "Album retrieved successfully",
            payload: {
                data: album
            }
        };

        return response;
    }

    @http:ResourceConfig {
        auth: [
            {
                jwtValidatorConfig: {
                    issuer: "wso2",
                    signatureConfig: {
                        certFile: "./resources/public.crt"
                    },
                    scopeKey: "scope"
                },
                scopes: ["admin"]
            }
        ]
    }
    resource function post albums(@http:Header string authorization, @http:Payload Album newAlbum) returns ApiResponse|http:BadRequest|http:InternalServerError|http:Unauthorized|http:Forbidden {
        do {
            // Check if the authorization header is present
            if (isHeaderPresent(authorization) == false) {
                return http:UNAUTHORIZED;
            }

            // Extract the token from the authorization header
            string token = authorization.substring(7);

            if (isTokenValid(token) == false) {
                return http:FORBIDDEN;
            }

            Album? existingAlbum = albums[newAlbum.id];

            if (existingAlbum is Album) {
                return http:BAD_REQUEST;
            }

            ApiResponse response = {
                success: true,
                message: "Album added successfully",
                payload: {
                    data: newAlbum
                }
            };

            return response;
        } on fail {
            return http:INTERNAL_SERVER_ERROR;
        }
    }

    @http:ResourceConfig {
        auth: [
            {
                jwtValidatorConfig: {
                    issuer: "wso2",
                    signatureConfig: {
                        certFile: "./resources/public.crt"
                    },
                    scopeKey: "scope"
                },
                scopes: ["admin"]
            }
        ]
    }
    resource function put albums/[string id](@http:Header string authorization, @http:Payload Album updatedAlbum) returns ApiResponse|http:NotFound|http:InternalServerError|http:Unauthorized|http:Forbidden {
        do {
            // Check if the authorization header is present
            if (isHeaderPresent(authorization) == false) {
                return http:UNAUTHORIZED;
            }

            // Extract the token from the authorization header
            string token = authorization.substring(7);

            if (isTokenValid(token) == false) {
                return http:FORBIDDEN;
            }

            Album? existingAlbum = albums[id];

            if (existingAlbum is ()) {
                return http:NOT_FOUND;
            }

            albums.put(updatedAlbum);

            ApiResponse response = {
                success: true,
                message: "Album updated successfully",
                payload: {
                    data: updatedAlbum
                }
            };

            return response;
        } on fail {
            return http:INTERNAL_SERVER_ERROR;
        }
    }

    @http:ResourceConfig {
        auth: [
            {
                jwtValidatorConfig: {
                    issuer: "wso2",
                    signatureConfig: {
                        certFile: "./resources/public.crt"
                    },
                    scopeKey: "scope"
                },
                scopes: ["admin"]
            }
        ]
    }
    resource function delete albums/[string id](@http:Header string authorization) returns ApiResponse|http:NotFound|http:InternalServerError|http:Unauthorized|http:Forbidden {
        do {
            // Check if the authorization header is present
            if (isHeaderPresent(authorization) == false) {
                return http:UNAUTHORIZED;
            }

            // Extract the token from the authorization header
            string token = authorization.substring(7);

            if (isTokenValid(token) == false) {
                return http:FORBIDDEN;
            }

            Album? existingAlbum = albums[id];

            if (existingAlbum is ()) {
                return http:NOT_FOUND;
            }

            _ = albums.remove(id);

            ApiResponse response = {
                success: true,
                message: "Album deleted successfully",
                payload: {
                    data: existingAlbum
                }
            };

            return response;
        } on fail {
            return http:INTERNAL_SERVER_ERROR;
        }
    }
}
