import ballerina/http;

# HTTP port for the service
configurable int port = 8080;

# JWT validator configuration
public final http:JwtValidatorConfig JWT_VALIDATOR_CONFIG = {
    issuer: "wso2",
    signatureConfig: {
        certFile: "./resources/public.crt"
    },
    scopeKey: "scope"
};

# Security scope constants
public const string[] SCOPE_ADMIN = ["admin"];
public const string[] SCOPE_USER = ["user"];
public const string[] SCOPE_ALL = ["admin", "user"];
