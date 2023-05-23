package com.fastcampus.projectboard.dto.security;

import java.util.Map;

@SuppressWarnings("unchecked")
public record GoogleOAuth2Response(
        String sub,
        String email,
        String name
) {
    public static GoogleOAuth2Response from(Map<String, Object> attributes) {
        return new GoogleOAuth2Response(
                String.valueOf(attributes.get("sub")),
                String.valueOf(attributes.get("email")),
                String.valueOf(attributes.get("name"))
        );
    }

    public String sub() { return sub; }
    public String email() { return email; }
    public String nickname() { return name; }

}
