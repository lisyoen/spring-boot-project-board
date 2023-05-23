package com.fastcampus.projectboard.dto.security;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

@DisplayName("DTO - Google OAuth 2.0 인증 응답 데이터 테스트")
class GoogleOAuth2ResponseTest {
    private final ObjectMapper mapper = new ObjectMapper();

    @DisplayName("인증 결과를 Map(deserialized json)으로 받으면, 카카오 인증 응답 객체로 변환한다.")
    @Test
    void givenMapFromJson_whenInstantiating_thenReturnsGoogleResponseObject() throws Exception {
        // Given
        String serializedResponse = """
                {
                    "localId": "testid",
                    "email": "user@example.com",
                    "displayName": "John Doe",
                    "providerUserInfo": [
                            {
                              "providerId": "password",
                              "displayName": "John Doe",
                              "photoUrl": "http://localhost:8080/img1234567890/photo.png",
                              "federatedId": "user@example.com",
                              "email": "user@example.com",
                              "rawId": "user@example.com",
                              "screenName": "user@example.com"
                            }
                    ],
                    "lastLoginAt": "1484628946000"
                }
                """;
        Map<String, Object> attributes = mapper.readValue(serializedResponse, new TypeReference<>() {});

        // When
        GoogleOAuth2Response result = GoogleOAuth2Response.from(attributes);

        // Then
        assertThat(result)
                .hasFieldOrPropertyWithValue("email", "user@example.com");
    }

}