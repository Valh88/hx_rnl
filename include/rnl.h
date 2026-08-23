/* RNL dynamic library - C interface.
 * Generated from lib/RNLDynLib.pas - do not edit by hand.
 * zlib licensed, see the repository LICENSE. */
#ifndef RNL_H_INCLUDED
#define RNL_H_INCLUDED

#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

#define RNL_API extern

/* opaque handles */
typedef void *rnl_instance_h;
typedef void *rnl_random_h;
typedef void *rnl_message_h;
typedef void *rnl_compressor_h;
typedef void *rnl_host_h;
typedef void *rnl_peer_h;
typedef void *rnl_channel_h;
typedef void *rnl_network_h;
typedef void *rnl_network_real_h;
typedef void *rnl_network_virtual_h;
typedef void *rnl_network_interference_h;
typedef void *rnl_turn_network_h;
typedef void *rnl_turn_allocation_h;
typedef void *rnl_stun_message_h;
typedef void *rnl_discovery_server_h;
typedef void *rnl_dtls12_client_h;
typedef void *rnl_dtls13_client_h;
typedef void *rnl_cha_cha20_context_h;
typedef void *rnl_poly1305_context_h;
typedef void *rnl_sha256_context_h;
typedef void *rnl_sha512_context_h;
typedef void *rnl_sha1_context_h;
typedef void *rnl_md5_context_h;
typedef void *rnl_blake2_b_context_h;
typedef void *rnl_hmac_context_h;

/* status codes */
#define RNL_OK 0
#define RNL_ERR_INVALID_ARGUMENT (-1)
#define RNL_ERR_OUT_OF_MEMORY (-2)
#define RNL_ERR_INVALID_HANDLE (-3)
#define RNL_ERR_BUFFER_TOO_SMALL (-4)
#define RNL_ERR_NOT_FOUND (-5)
#define RNL_ERR_UNSUPPORTED (-6)
#define RNL_ERR_EXCEPTION (-7)
#define RNL_ERR_COMPRESSION_FAILED (-8)
#define RNL_ERR_AUTHENTICATION_FAILED (-9)

/* all structs below mirror packed Pascal records byte for byte */
#pragma pack(push,1)

/* address, platform independent layout */
struct rnl_address {
    uint8_t  host_addr[16];
    uint32_t scope_id;
    uint16_t port;
};

/* one host event; peer/message are borrowed until next service call */
struct rnl_event {
    int32_t       event_type;
    rnl_peer_h    peer;
    rnl_message_h message;
    uint8_t       channel;
    uint64_t      data;
    int32_t       denial_reason;
    uint16_t      mtu;
};

/* one reachable candidate of a peer */
struct rnl_candidate {
    uint8_t  host_addr[16];
    uint32_t scope_id;
    uint16_t port;
    uint8_t  kind;
    uint16_t socket_index;
    uint32_t priority;
    uint32_t foundation;
};

/* discovery browse request delivered to the accept callback */
struct rnl_discovery_request {
    uint8_t  service_id[16];
    uint32_t client_version;
    uint8_t  client_host[16];
    uint16_t client_port;
    uint8_t  meta_length;
    uint8_t  meta[255];
};

/* callback function pointer types */
#pragma pack(pop)

typedef void (*rnl_cb_self_test_report)(const char *name, size_t name_length, int32_t succeeded, void *user_data);
typedef int32_t (*rnl_cb_discovery_accept)(const struct rnl_discovery_request *request, void *user_data);
typedef void (*rnl_cb_peer_connect)(rnl_host_h host, rnl_peer_h peer, uint64_t data, void *user_data);
typedef void (*rnl_cb_peer_disconnect)(rnl_host_h host, rnl_peer_h peer, uint64_t data, void *user_data);
typedef void (*rnl_cb_peer_approval)(rnl_host_h host, rnl_peer_h peer, void *user_data);
typedef void (*rnl_cb_peer_denial)(rnl_host_h host, rnl_peer_h peer, int32_t denial_reason, void *user_data);
typedef void (*rnl_cb_peer_bandwidth_limits)(rnl_host_h host, rnl_peer_h peer, void *user_data);
typedef void (*rnl_cb_peer_mtu)(rnl_host_h host, rnl_peer_h peer, uint16_t mtu, void *user_data);
typedef void (*rnl_cb_peer_receive)(rnl_host_h host, rnl_peer_h peer, uint8_t channel, rnl_message_h message, void *user_data);

/* Synchronous token check, invoked while the corresponding handshake packet is
 * processed. token_kind is RNL_C_HOST_EVENT_TYPE_PEER_CHECK_CONNECTION_TOKEN or
 * RNL_C_HOST_EVENT_TYPE_PEER_CHECK_AUTHENTICATION_TOKEN; address points at the
 * remote rnl_address and token at the fixed-size token blob (128 bytes for
 * both kinds). Return nonzero to accept the peer, zero to deny it (the request
 * is then silently dropped). The callback runs on the thread calling
 * host_service. */
typedef int32_t (*rnl_cb_check_token)(rnl_host_h host, int32_t token_kind, const struct rnl_address *address, const void *token, void *user_data);

/* constants */
#define RNL_C_NO_ADDRESS_FAMILY 0
#define RNL_C_IPV4 1 << 0
#define RNL_C_IPV6 1 << 1
#define RNL_C_MESSAGE_FLAG_NO_ALLOCATE 1 << 0
#define RNL_C_MESSAGE_FLAG_NO_FREE 1 << 1
#define RNL_C_MESSAGE_FLAG_UNRELIABLE_ORDERED_CHANNEL_PREVIOUS_LOST 1 << 2
#define RNL_C_PEER_STATE_DISCONNECTED 0
#define RNL_C_PEER_STATE_CONNECTION_REQUESTING 1
#define RNL_C_PEER_STATE_CONNECTION_CHALLENGING 2
#define RNL_C_PEER_STATE_CONNECTION_AUTHENTICATING 3
#define RNL_C_PEER_STATE_CONNECTION_APPROVING 4
#define RNL_C_PEER_STATE_CONNECTED 5
#define RNL_C_PEER_STATE_DISCONNECT_LATER 6
#define RNL_C_PEER_STATE_DISCONNECTING 7
#define RNL_C_PEER_STATE_DISCONNECTION_ACKNOWLEDGING 8
#define RNL_C_PEER_STATE_DISCONNECTION_PENDING 9
#define RNL_C_PEER_RELIABLE_ORDERED_CHANNEL 0
#define RNL_C_PEER_RELIABLE_UNORDERED_CHANNEL 1
#define RNL_C_PEER_UNRELIABLE_ORDERED_CHANNEL 2
#define RNL_C_PEER_UNRELIABLE_UNORDERED_CHANNEL 3
#define RNL_C_HOST_SERVICE_STATUS_ERROR 0
#define RNL_C_HOST_SERVICE_STATUS_TIMEOUT 1
#define RNL_C_HOST_SERVICE_STATUS_INTERRUPT 2
#define RNL_C_HOST_SERVICE_STATUS_EVENT 3
#define RNL_C_HOST_EVENT_TYPE_NONE 0
#define RNL_C_HOST_EVENT_TYPE_PEER_CHECK_CONNECTION_TOKEN 1
#define RNL_C_HOST_EVENT_TYPE_PEER_CHECK_AUTHENTICATION_TOKEN 2
#define RNL_C_HOST_EVENT_TYPE_PEER_CONNECT 3
#define RNL_C_HOST_EVENT_TYPE_PEER_DISCONNECT 4
#define RNL_C_HOST_EVENT_TYPE_PEER_APPROVAL 5
#define RNL_C_HOST_EVENT_TYPE_PEER_DENIAL 6
#define RNL_C_HOST_EVENT_TYPE_PEER_BANDWIDTH_LIMITS 7
#define RNL_C_HOST_EVENT_TYPE_PEER_MTU 8
#define RNL_C_HOST_EVENT_TYPE_PEER_RECEIVE 9
#define RNL_C_HOST_ADDRESS_FAMILY_WORK_MODE_AUTOMATIC 0
#define RNL_C_HOST_ADDRESS_FAMILY_WORK_MODE_IPV4_ONLY 1
#define RNL_C_HOST_ADDRESS_FAMILY_WORK_MODE_IPV6_ONLY 2
#define RNL_C_HOST_ADDRESS_FAMILY_WORK_MODE_IPV4_ON_IPV6 3
#define RNL_C_HOST_ADDRESS_FAMILY_WORK_MODE_IPV4_AND_IPV6 4
#define RNL_C_PROTOCOL_TRANSCRIPT_BINDING_OFF 0
#define RNL_C_PROTOCOL_TRANSCRIPT_BINDING_ALLOWED 1
#define RNL_C_PROTOCOL_TRANSCRIPT_BINDING_REQUIRED 2
#define RNL_C_CONNECTION_DENIAL_REASON_UNKNOWN 0
#define RNL_C_CONNECTION_DENIAL_REASON_FULL 1
#define RNL_C_CONNECTION_DENIAL_REASON_TOO_LESS_CHANNELS 2
#define RNL_C_CONNECTION_DENIAL_REASON_TOO_MANY_CHANNELS 3
#define RNL_C_CONNECTION_DENIAL_REASON_WRONG_CHANNEL_TYPES 4
#define RNL_C_CONNECTION_DENIAL_REASON_UNAUTHORIZED 5
#define RNL_C_CERTIFICATE_VERDICT_ACCEPTED 0
#define RNL_C_CERTIFICATE_VERDICT_ABSENT 1
#define RNL_C_CERTIFICATE_VERDICT_BAD_SIGNATURE 2
#define RNL_C_CERTIFICATE_VERDICT_NOT_YET_VALID 3
#define RNL_C_CERTIFICATE_VERDICT_EXPIRED 4
#define RNL_C_CERTIFICATE_VERDICT_NO_CLOCK 5
#define RNL_C_CERTIFICATE_VERDICT_WRONG_SUBJECT 6
#define RNL_C_INVALID_SOCKET -1
#define RNL_C_SOCKET_WAIT_CONDITION_IO_RECEIVE 1 << 0
#define RNL_C_SOCKET_WAIT_CONDITION_IO_SEND 1 << 1
#define RNL_C_SOCKET_WAIT_CONDITION_IO_INTERRUPT 1 << 2
#define RNL_C_SOCKET_WAIT_CONDITION_SERVICE_INTERRUPT 1 << 3
#define RNL_C_CRYPTOGRAPHY_SELF_TEST_GROUP_CHECKSUMS 0
#define RNL_C_CRYPTOGRAPHY_SELF_TEST_GROUP_CURVE25519 1
#define RNL_C_CRYPTOGRAPHY_SELF_TEST_GROUP_NIST_CURVES 2
#define RNL_C_CRYPTOGRAPHY_SELF_TEST_GROUP_CERTIFICATES 3
#define RNL_C_CRYPTOGRAPHY_SELF_TEST_GROUP_CIPHERS 4
#define RNL_C_CRYPTOGRAPHY_SELF_TEST_GROUP_HASHES 5
#define RNL_C_CRYPTOGRAPHY_SELF_TEST_GROUP_KEY_DERIVATION 6
#define RNL_C_CRYPTOGRAPHY_SELF_TEST_GROUP_ENCODINGS_AND_CREDENTIALS 7
#define RNL_C_CRYPTOGRAPHY_SELF_TEST_GROUP_RECORD_LAYERS 8
#define RNL_C_HASH_MD5 0
#define RNL_C_HASH_SHA1 1
#define RNL_C_HASH_SHA256 2
#define RNL_C_HASH_SHA512 3
#define RNL_C_HASH_BLAKE2B 4
#define RNL_C_KEY_SIZE RNL_KEY_SIZE
#define RNL_C_CONNECTION_TOKEN_SIZE RNL_CONNECTION_TOKEN_SIZE
#define RNL_C_AUTHENTICATION_TOKEN_SIZE RNL_AUTHENTICATION_TOKEN_SIZE
#define RNL_C_MAXIMUM_PEER_CHANNELS RNL_MAXIMUM_PEER_CHANNELS
#define RNL_C_CERTIFICATE_SUBJECT_SIZE RNL_CERTIFICATE_SUBJECT_SIZE
#define RNL_C_CERTIFICATE_SIZE (RNL_CERTIFICATE_SUBJECT_SIZE+64+8)
#define RNL_C_PROTOCOL_VERSION RNL_PROTOCOL_VERSION
#define RNL_C_DISCOVERY_SERVER_FLAG_IPV6 1 << 1
#define RNL_C_DTLS_VERIFICATION_FINGERPRINT 1
#define RNL_C_DTLS12_CLIENT_STATE_AWAITING_HELLO_VERIFY_REQUEST 1
#define RNL_C_DTLS12_CLIENT_STATE_AWAITING_SERVER_FLIGHT 2
#define RNL_C_DTLS12_CLIENT_STATE_AWAITING_SERVER_FINISHED 3
#define RNL_C_DTLS12_CLIENT_STATE_ESTABLISHED 4
#define RNL_C_DTLS12_CLIENT_STATE_FAILED 5
#define RNL_C_DTLS13_CLIENT_STATE_AWAITING_SERVER_HELLO 1
#define RNL_C_DTLS13_CLIENT_STATE_AWAITING_ENCRYPTED_EXTENSIONS 2
#define RNL_C_DTLS13_CLIENT_STATE_AWAITING_CERTIFICATE 3
#define RNL_C_DTLS13_CLIENT_STATE_AWAITING_CERTIFICATE_VERIFY 4
#define RNL_C_DTLS13_CLIENT_STATE_AWAITING_SERVER_FINISHED 5
#define RNL_C_DTLS13_CLIENT_STATE_ESTABLISHED 6
#define RNL_C_DTLS13_CLIENT_STATE_FAILED 7

/* functions */
RNL_API void RNL_free(void *a_pointer);
RNL_API uint64_t RNL_protocol_version(void);
RNL_API int32_t RNL_instance_create(rnl_instance_h *a_instance);
RNL_API int32_t RNL_instance_destroy(rnl_instance_h a_instance);
RNL_API int32_t RNL_instance_time(rnl_instance_h a_instance, uint64_t *a_time);
RNL_API int32_t RNL_instance_set_time(rnl_instance_h a_instance, const uint64_t a_time);
RNL_API int32_t RNL_self_test_cryptography(rnl_cb_self_test_report a_report, void *a_user_data, int32_t *a_succeeded, size_t *a_count_checks, size_t *a_count_failures);
RNL_API int32_t RNL_self_test_cryptography_group(const int32_t a_group, rnl_cb_self_test_report a_report, void *a_user_data, int32_t *a_succeeded, size_t *a_count_checks, size_t *a_count_failures);
RNL_API int32_t RNL_address_from_string(char *a_string, size_t a_string_length, struct rnl_address *a_address);
RNL_API int32_t RNL_address_to_string(const struct rnl_address a_address, char *a_buffer, size_t a_buffer_size);
RNL_API uint8_t RNL_address_get_family(const struct rnl_address a_address);
RNL_API int32_t RNL_address_equals(const struct rnl_address a_address_a, const struct rnl_address a_address_b);
RNL_API uint16_t RNL_address_get_port(const struct rnl_address a_address);
RNL_API void RNL_address_set_port(struct rnl_address *a_address, const uint16_t a_port);
RNL_API int32_t RNL_address_get_host(const struct rnl_address a_address, void *a_buffer, size_t a_buffer_size);
RNL_API int32_t RNL_address_set_host(struct rnl_address *a_address, const void *a_host_buffer, const size_t a_host_buffer_size);
RNL_API uint32_t RNL_address_get_scope_id(const struct rnl_address a_address);
RNL_API void RNL_address_set_scope_id(struct rnl_address *a_address, const uint32_t a_scope_id);
RNL_API int32_t RNL_host_address_from_ipv4(const uint32_t a_ipv4, void *a_out_buffer, size_t a_out_buffer_size);
RNL_API int32_t RNL_host_address_equals(const void *a_host_address_a, const void *a_host_address_b);
RNL_API int32_t RNL_random_create(rnl_random_h *a_random);
RNL_API int32_t RNL_random_destroy(rnl_random_h a_random);
RNL_API int32_t RNL_random_get_bytes(rnl_random_h a_random, void *a_buffer, const size_t a_count);
RNL_API uint32_t RNL_random_get_u32(rnl_random_h a_random);
RNL_API uint64_t RNL_random_get_u64(rnl_random_h a_random);
RNL_API uint32_t RNL_random_get_bounded_u32(rnl_random_h a_random, const uint32_t a_bound);
RNL_API uint32_t RNL_random_get_uniform_bounded_u32(rnl_random_h a_random, const uint32_t a_bound);
RNL_API float RNL_random_get_float(rnl_random_h a_random);
RNL_API float RNL_random_get_absolute_float(rnl_random_h a_random);
RNL_API double RNL_random_get_double(rnl_random_h a_random);
RNL_API double RNL_random_get_absolute_double(rnl_random_h a_random);
RNL_API float RNL_random_get_gaussian_float(rnl_random_h a_random);
RNL_API float RNL_random_get_absolute_gaussian_float(rnl_random_h a_random);
RNL_API double RNL_random_get_gaussian_double(rnl_random_h a_random);
RNL_API double RNL_random_get_absolute_gaussian_double(rnl_random_h a_random);
RNL_API uint32_t RNL_random_get_gaussian_u32(rnl_random_h a_random, const uint32_t a_bound);
RNL_API int32_t RNL_message_create(const void *a_data, const uint32_t a_data_length, const uint32_t a_flags, rnl_message_h *a_message);
RNL_API int32_t RNL_message_inc_ref(rnl_message_h a_message);
RNL_API int32_t RNL_message_dec_ref(rnl_message_h a_message);
RNL_API void *RNL_message_data(rnl_message_h a_message);
RNL_API uint32_t RNL_message_data_length(rnl_message_h a_message);
RNL_API int32_t RNL_message_resize(rnl_message_h a_message, const uint32_t a_data_length);
RNL_API void *RNL_message_user_data(rnl_message_h a_message);
RNL_API int32_t RNL_message_set_user_data(rnl_message_h a_message, const void *a_user_data);
RNL_API uint32_t RNL_message_flags(rnl_message_h a_message);
RNL_API int32_t RNL_message_set_flags(rnl_message_h a_message, const uint32_t a_flags);
RNL_API uint32_t RNL_message_reference_counter(rnl_message_h a_message);
RNL_API int32_t RNL_compressor_create_deflate(rnl_compressor_h *a_compressor);
RNL_API int32_t RNL_compressor_create_lzbrrc(rnl_compressor_h *a_compressor);
RNL_API int32_t RNL_compressor_create_brrc(rnl_compressor_h *a_compressor);
RNL_API int32_t RNL_compressor_destroy(rnl_compressor_h a_compressor);
RNL_API int32_t RNL_compressor_compress(rnl_compressor_h a_compressor, const void *a_in_data, const size_t a_in_size, const void *a_out_data, const size_t a_out_limit, size_t *a_out_size);
RNL_API int32_t RNL_compressor_decompress(rnl_compressor_h a_compressor, const void *a_in_data, const size_t a_in_size, const void *a_out_data, const size_t a_out_limit, size_t *a_out_size);
RNL_API int32_t RNL_compressor_deflate_get_with_header(rnl_compressor_h a_compressor);
RNL_API int32_t RNL_compressor_deflate_set_with_header(rnl_compressor_h a_compressor, const int32_t a_value);
RNL_API int32_t RNL_compressor_deflate_get_greedy(rnl_compressor_h a_compressor);
RNL_API int32_t RNL_compressor_deflate_set_greedy(rnl_compressor_h a_compressor, const int32_t a_value);
RNL_API uint32_t RNL_compressor_deflate_get_skip_strength(rnl_compressor_h a_compressor);
RNL_API int32_t RNL_compressor_deflate_set_skip_strength(rnl_compressor_h a_compressor, const uint32_t a_value);
RNL_API uint32_t RNL_compressor_deflate_get_max_steps(rnl_compressor_h a_compressor);
RNL_API int32_t RNL_compressor_deflate_set_max_steps(rnl_compressor_h a_compressor, const uint32_t a_value);
RNL_API int32_t RNL_compressor_lzbrrc_get_greedy(rnl_compressor_h a_compressor);
RNL_API int32_t RNL_compressor_lzbrrc_set_greedy(rnl_compressor_h a_compressor, const int32_t a_value);
RNL_API uint32_t RNL_compressor_lzbrrc_get_skip_strength(rnl_compressor_h a_compressor);
RNL_API int32_t RNL_compressor_lzbrrc_set_skip_strength(rnl_compressor_h a_compressor, const uint32_t a_value);
RNL_API uint32_t RNL_compressor_lzbrrc_get_max_steps(rnl_compressor_h a_compressor);
RNL_API int32_t RNL_compressor_lzbrrc_set_max_steps(rnl_compressor_h a_compressor, const uint32_t a_value);
RNL_API int32_t RNL_chacha20_create(rnl_cha_cha20_context_h *a_context);
RNL_API int32_t RNL_chacha20_destroy(rnl_cha_cha20_context_h a_context);
RNL_API int32_t RNL_chacha20_initialize(rnl_cha_cha20_context_h a_context, const void *a_key, const void *a_nonce, const uint64_t a_counter);
RNL_API int32_t RNL_chacha20_endian_neutral_initialize(rnl_cha_cha20_context_h a_context, const void *a_key, const uint64_t a_nonce, const uint64_t a_counter);
RNL_API int32_t RNL_chacha20_xchacha20_initialize(rnl_cha_cha20_context_h a_context, const void *a_key, const void *a_nonce, const uint64_t a_counter);
RNL_API int32_t RNL_chacha20_rfc8439_initialize(rnl_cha_cha20_context_h a_context, const void *a_key, const void *a_nonce, const uint32_t a_counter);
RNL_API int32_t RNL_chacha20_process(rnl_cha_cha20_context_h a_context, void *a_output, const void *a_input, const size_t a_text_size, const int32_t a_use_plain_text);
RNL_API int32_t RNL_chacha20_stream(rnl_cha_cha20_context_h a_context, void *a_output, const size_t a_text_size);
RNL_API uint64_t RNL_chacha20_get_counter(rnl_cha_cha20_context_h a_context);
RNL_API int32_t RNL_chacha20_set_counter(rnl_cha_cha20_context_h a_context, const uint64_t a_counter);
RNL_API int32_t RNL_poly1305_create(rnl_poly1305_context_h *a_context);
RNL_API int32_t RNL_poly1305_destroy(rnl_poly1305_context_h a_context);
RNL_API int32_t RNL_poly1305_initialize(rnl_poly1305_context_h a_context, const void *a_key);
RNL_API int32_t RNL_poly1305_update(rnl_poly1305_context_h a_context, const void *a_message, const size_t a_message_size);
RNL_API int32_t RNL_poly1305_finalize(rnl_poly1305_context_h a_context, void *a_mac);
RNL_API int32_t RNL_poly1305_onetime_authenticate(void *a_mac, const void *a_input, const size_t a_input_length, const void *a_secret_key, int32_t *a_ok);
RNL_API int32_t RNL_poly1305_onetime_authenticate_verify(const void *a_comparison, const void *a_input, const size_t a_input_length, const void *a_secret_key);
RNL_API int32_t RNL_chacha20_poly1305_encrypt(void *a_cipher_text, void *a_tag, const void *a_key, const void *a_nonce, const void *a_associated_data, const size_t a_associated_data_size, const void *a_plain_text, const size_t a_plain_text_size);
RNL_API int32_t RNL_chacha20_poly1305_decrypt(void *a_plain_text, const void *a_key, const void *a_nonce, const void *a_tag, const void *a_associated_data, const size_t a_associated_data_size, const void *a_cipher_text, const size_t a_cipher_text_size, int32_t *a_ok);
RNL_API int32_t RNL_authenticated_encryption_encrypt(void *a_cipher_text, const void *a_key, const void *a_nonce, void *a_mac, const void *a_associated_data, const size_t a_associated_data_size, const void *a_plain_text, const size_t a_plain_text_size, int32_t *a_ok);
RNL_API int32_t RNL_authenticated_encryption_decrypt(void *a_plain_text, const void *a_key, const void *a_nonce, const void *a_mac, const void *a_associated_data, const size_t a_associated_data_size, const void *a_cipher_text, const size_t a_cipher_text_size, int32_t *a_ok);
RNL_API int32_t RNL_sha256_context_create(rnl_sha256_context_h *a_context);
RNL_API int32_t RNL_sha256_context_destroy(rnl_sha256_context_h a_context);
RNL_API int32_t RNL_sha256_context_initialize(rnl_sha256_context_h a_context);
RNL_API int32_t RNL_sha256_context_update(rnl_sha256_context_h a_context, const void *a_message, const size_t a_message_size);
RNL_API int32_t RNL_sha256_context_finalize(rnl_sha256_context_h a_context, void *a_hash);
RNL_API int32_t RNL_sha512_context_create(rnl_sha512_context_h *a_context);
RNL_API int32_t RNL_sha512_context_destroy(rnl_sha512_context_h a_context);
RNL_API int32_t RNL_sha512_context_initialize(rnl_sha512_context_h a_context, const int32_t a_as_sha384);
RNL_API int32_t RNL_sha512_context_update(rnl_sha512_context_h a_context, const void *a_message, const size_t a_message_size);
RNL_API int32_t RNL_sha512_context_finalize(rnl_sha512_context_h a_context, void *a_hash, const int32_t a_as_sha384);
RNL_API int32_t RNL_sha1_context_create(rnl_sha1_context_h *a_context);
RNL_API int32_t RNL_sha1_context_destroy(rnl_sha1_context_h a_context);
RNL_API int32_t RNL_sha1_context_initialize(rnl_sha1_context_h a_context);
RNL_API int32_t RNL_sha1_context_update(rnl_sha1_context_h a_context, const void *a_message, const size_t a_message_size);
RNL_API int32_t RNL_sha1_context_finalize(rnl_sha1_context_h a_context, void *a_hash);
RNL_API int32_t RNL_md5_context_create(rnl_md5_context_h *a_context);
RNL_API int32_t RNL_md5_context_destroy(rnl_md5_context_h a_context);
RNL_API int32_t RNL_md5_context_initialize(rnl_md5_context_h a_context);
RNL_API int32_t RNL_md5_context_update(rnl_md5_context_h a_context, const void *a_message, const size_t a_message_size);
RNL_API int32_t RNL_md5_context_finalize(rnl_md5_context_h a_context, void *a_hash);
RNL_API int32_t RNL_blake2b_context_create(rnl_blake2_b_context_h *a_context);
RNL_API int32_t RNL_blake2b_context_destroy(rnl_blake2_b_context_h a_context);
RNL_API int32_t RNL_blake2b_context_initialize(rnl_blake2_b_context_h a_context, const ptrdiff_t a_out_len, const void *a_key, const ptrdiff_t a_key_len, int32_t *a_ok);
RNL_API int32_t RNL_blake2b_context_update(rnl_blake2_b_context_h a_context, const void *a_message, const size_t a_message_size);
RNL_API int32_t RNL_blake2b_context_finalize(rnl_blake2_b_context_h a_context, void *a_hash);
RNL_API int32_t RNL_sha256_process(void *a_hash, const void *a_message, const size_t a_message_size);
RNL_API int32_t RNL_sha384_process(void *a_hash, const void *a_message, const size_t a_message_size);
RNL_API int32_t RNL_sha512_process(void *a_hash, const void *a_message, const size_t a_message_size);
RNL_API int32_t RNL_sha1_process(void *a_hash, const void *a_message, const size_t a_message_size);
RNL_API int32_t RNL_md5_process(void *a_hash, const void *a_message, const size_t a_message_size);
RNL_API int32_t RNL_blake2b_process(void *a_hash, const void *a_message, const size_t a_message_size, const ptrdiff_t a_out_len, const void *a_key, const ptrdiff_t a_key_len, int32_t *a_ok);
RNL_API int32_t RNL_hmac_process(const int32_t a_hash_id, void *a_mac, const void *a_key, const size_t a_key_size, const void *a_message, const size_t a_message_size, int32_t *a_ok);
RNL_API int32_t RNL_hmac_context_create(const int32_t a_hash_id, const void *a_key, const size_t a_key_size, rnl_hmac_context_h *a_context, int32_t *a_ok);
RNL_API int32_t RNL_hmac_context_destroy(rnl_hmac_context_h a_context);
RNL_API int32_t RNL_hmac_context_update(rnl_hmac_context_h a_context, const void *a_message, const size_t a_message_size);
RNL_API int32_t RNL_hmac_context_finalize(rnl_hmac_context_h a_context, void *a_mac, int32_t *a_ok);
RNL_API int32_t RNL_hmac_context_clear(rnl_hmac_context_h a_context);
RNL_API int32_t RNL_hkdf_extract(const int32_t a_hash_id, void *a_pseudo_random_key, const void *a_salt, const size_t a_salt_size, const void *a_input_keying_material, const size_t a_input_keying_material_size, int32_t *a_ok);
RNL_API int32_t RNL_hkdf_expand(const int32_t a_hash_id, void *a_output, const size_t a_output_size, const void *a_pseudo_random_key, const size_t a_pseudo_random_key_size, const void *a_info, const size_t a_info_size, int32_t *a_ok);
RNL_API int32_t RNL_tls13_expand_label(const int32_t a_hash_id, void *a_output, const size_t a_output_size, const void *a_secret, const size_t a_secret_size, const void *a_label, const size_t a_label_size, const void *a_context, const size_t a_context_size, int32_t *a_ok);
RNL_API int32_t RNL_tls13_derive_secret(const int32_t a_hash_id, void *a_secret, const void *a_parent_secret, const size_t a_parent_secret_size, const void *a_label, const size_t a_label_size, const void *a_transcript_hash, const size_t a_transcript_hash_size, int32_t *a_ok);
RNL_API int32_t RNL_x25519_generate_public_private_key_pair(rnl_random_h a_random, void *a_public_key, void *a_private_key, int32_t *a_ok);
RNL_API int32_t RNL_x25519_generate_shared_secret_key(void *a_shared_secret_key, const void *a_public_key, const void *a_private_key, int32_t *a_ok);
RNL_API int32_t RNL_curve25519_eval(void *a_result, const void *a_secret, const void *a_base_point, int32_t *a_ok);
RNL_API int32_t RNL_curve25519_is_weak_point(const void *a_k);
RNL_API int32_t RNL_curve25519_is_in_range(const void *a_x);
RNL_API void RNL_curve25519_clean(void *a_x);
RNL_API int32_t RNL_ed25519_derive_public_key(const void *a_private_key, void *a_public_key);
RNL_API int32_t RNL_ed25519_generate_public_private_key_pair(rnl_random_h a_random, void *a_public_key, void *a_private_key);
RNL_API int32_t RNL_ed25519_sign(const void *a_private_key, void *a_public_key, const void *a_message, const size_t a_message_size, void *a_signature);
RNL_API int32_t RNL_ed25519_verify(const void *a_signature, const void *a_public_key, const void *a_message, const size_t a_message_size);
RNL_API int32_t RNL_p256_generate_key_pair(rnl_random_h a_random, void *a_private_key, void *a_public_key);
RNL_API int32_t RNL_p256_shared_secret(const void *a_private_key, const void *a_peer_public_key, const size_t a_peer_public_key_size, void *a_secret, int32_t *a_ok);
RNL_API int32_t RNL_p256_verify_signature(const void *a_public_key, const size_t a_public_key_size, const void *a_hash, const size_t a_hash_size, const void *a_signature_r, const void *a_signature_s);
RNL_API int32_t RNL_p384_generate_key_pair(rnl_random_h a_random, void *a_private_key, void *a_public_key);
RNL_API int32_t RNL_p384_shared_secret(const void *a_private_key, const void *a_peer_public_key, const size_t a_peer_public_key_size, void *a_secret, int32_t *a_ok);
RNL_API int32_t RNL_p384_verify_signature(const void *a_public_key, const size_t a_public_key_size, const void *a_hash, const size_t a_hash_size, const void *a_signature_r, const void *a_signature_s);
RNL_API int32_t RNL_base64_encode(const void *a_data, const size_t a_data_size, char *a_out_buffer, size_t a_out_buffer_size);
RNL_API int32_t RNL_base64_decode(const char *a_text, const size_t a_text_length, void *a_out_buffer, const size_t a_out_buffer_size, size_t *a_out_size, int32_t *a_ok);
RNL_API uint32_t RNL_hash32(const void *a_location, const size_t a_size);
RNL_API int32_t RNL_memory_secure_is_equal(const void *a_location_a, const void *a_location_b, const size_t a_size);
RNL_API int32_t RNL_memory_secure_is_zero(const void *a_location, const size_t a_size);
RNL_API int32_t RNL_network_real_create(rnl_instance_h a_instance, rnl_network_real_h *a_network);
RNL_API int32_t RNL_network_virtual_create(rnl_instance_h a_instance, rnl_network_virtual_h *a_network);
RNL_API int32_t RNL_network_interference_create(rnl_instance_h a_instance, rnl_network_h a_underlying_network, rnl_network_interference_h *a_network);
RNL_API int32_t RNL_network_real_destroy(rnl_network_real_h a_network);
RNL_API int32_t RNL_network_virtual_destroy(rnl_network_virtual_h a_network);
RNL_API int32_t RNL_network_interference_destroy(rnl_network_interference_h a_network);
RNL_API int32_t RNL_network_address_set_host(void *a_network, const char *a_name, const size_t a_name_length, const uint8_t a_family, struct rnl_address *a_address, int32_t *a_ok);
RNL_API int32_t RNL_network_address_get_host(void *a_network, const struct rnl_address a_address, char *a_buffer, const size_t a_buffer_size, const int32_t a_flags, int32_t *a_ok);
RNL_API int32_t RNL_network_address_get_host_ip(void *a_network, const struct rnl_address a_address, char *a_buffer, const size_t a_buffer_size, int32_t *a_ok);
RNL_API int32_t RNL_network_address_get_primary_interface_host_ip(void *a_network, struct rnl_address *a_address, const uint8_t a_family, const int32_t a_interface_host_address_type, int32_t *a_ok);
RNL_API int32_t RNL_network_address_get_interface_host_ips(void *a_network, const uint8_t a_family, const int32_t a_interface_host_address_type, void *a_out_addresses, const size_t a_maximum_count, size_t *a_count, int32_t *a_ok);
RNL_API int32_t RNL_network_socket_create(void *a_network, const int32_t a_socket_type, const uint8_t a_family, int64_t *a_socket);
RNL_API int32_t RNL_network_socket_create_with_protocol(void *a_network, const int32_t a_socket_type, const uint8_t a_family, const int32_t a_protocol, int64_t *a_socket);
RNL_API int32_t RNL_network_socket_destroy(void *a_network, const int64_t a_socket);
RNL_API int32_t RNL_network_socket_shutdown(void *a_network, const int64_t a_socket, const int32_t a_how, int32_t *a_ok);
RNL_API int32_t RNL_network_socket_get_address(void *a_network, const int64_t a_socket, struct rnl_address *a_address, const uint8_t a_family, int32_t *a_ok);
RNL_API int32_t RNL_network_socket_set_option(void *a_network, const int64_t a_socket, const int32_t a_option, const int32_t a_value, int32_t *a_ok);
RNL_API int32_t RNL_network_socket_get_option(void *a_network, const int64_t a_socket, const int32_t a_option, int32_t *a_value, int32_t *a_ok);
RNL_API int32_t RNL_network_socket_bind(void *a_network, const int64_t a_socket, const struct rnl_address *a_address, const uint8_t a_family, int32_t *a_ok);
RNL_API int32_t RNL_network_socket_listen(void *a_network, const int64_t a_socket, const int32_t a_back_log, int32_t *a_ok);
RNL_API int32_t RNL_network_socket_connect(void *a_network, const int64_t a_socket, const struct rnl_address *a_address, const uint8_t a_family, int32_t *a_ok);
RNL_API int32_t RNL_network_socket_accept(void *a_network, const int64_t a_socket, struct rnl_address *a_address, const uint8_t a_family, int64_t *a_new_socket);
RNL_API int32_t RNL_network_socket_wait(void *a_network, const void *a_sockets, const size_t a_sockets_length, uint32_t *a_conditions, const int64_t a_timeout, int32_t *a_ok);
RNL_API int32_t RNL_network_send(void *a_network, const int64_t a_socket, const struct rnl_address *a_address, const void *a_data, const ptrdiff_t a_data_length, const uint8_t a_family, ptrdiff_t *a_sent);
RNL_API int32_t RNL_network_receive(void *a_network, const int64_t a_socket, struct rnl_address *a_address, void *a_data, const ptrdiff_t a_data_length, const uint8_t a_family, ptrdiff_t *a_received);
RNL_API int32_t RNL_network_send_stream(void *a_network, const int64_t a_socket, const void *a_data, const ptrdiff_t a_data_length, ptrdiff_t *a_sent);
RNL_API int32_t RNL_network_receive_stream(void *a_network, const int64_t a_socket, void *a_data, const ptrdiff_t a_data_length, ptrdiff_t *a_received);
RNL_API int32_t RNL_network_get_relayed_address(void *a_network, const int64_t a_socket, struct rnl_address *a_address, int32_t *a_ok);
RNL_API int32_t RNL_network_interference_set_simulated_factor(rnl_network_interference_h a_network, const int32_t a_which, const uint32_t a_value);
RNL_API uint32_t RNL_network_interference_get_simulated_factor(rnl_network_interference_h a_network, const int32_t a_which);
RNL_API int32_t RNL_stun_query(rnl_instance_h a_instance, void *a_network, const struct rnl_address a_server_address, const uint8_t a_family, const int64_t a_timeout_milliseconds, const ptrdiff_t a_count_retries, int32_t *a_success, struct rnl_address *a_mapped_address, int64_t *a_round_trip_time);
RNL_API int32_t RNL_stun_query_on_socket(rnl_instance_h a_instance, void *a_network, const int64_t a_socket, const struct rnl_address a_server_address, const uint8_t a_family, const int64_t a_timeout_milliseconds, const ptrdiff_t a_count_retries, int32_t *a_success, struct rnl_address *a_mapped_address, int64_t *a_round_trip_time);
RNL_API int32_t RNL_discovery_server_create(rnl_instance_h a_instance, void *a_network, const uint16_t a_port, const void *a_service_id, const uint32_t a_service_version, const struct rnl_address *a_service_address_ipv4, const struct rnl_address *a_service_address_ipv6, const uint32_t a_flags, rnl_cb_discovery_accept a_on_accept, void *a_user_data, const char *a_meta, const size_t a_meta_length, rnl_discovery_server_h *a_server);
RNL_API int32_t RNL_discovery_server_destroy(rnl_discovery_server_h a_server);
RNL_API int32_t RNL_discovery_server_shutdown(rnl_discovery_server_h a_server);
RNL_API uint16_t RNL_discovery_server_get_port(rnl_discovery_server_h a_server);
RNL_API int32_t RNL_discovery_server_get_service_id(rnl_discovery_server_h a_server, void *a_buffer);
RNL_API int32_t RNL_discovery_server_get_meta(rnl_discovery_server_h a_server, char *a_buffer, const size_t a_buffer_size);
RNL_API int32_t RNL_discovery_server_set_meta(rnl_discovery_server_h a_server, const char *a_meta, const size_t a_meta_length);
RNL_API int32_t RNL_discovery_client_discover(rnl_instance_h a_instance, void *a_network, const uint16_t a_port, const struct rnl_address *a_multicast_ipv4_address, const struct rnl_address *a_multicast_ipv6_address, const void *a_service_id, const uint32_t a_service_version, const char *a_meta, const size_t a_meta_length, const int32_t a_maximum_servers, const int32_t a_time_out, void *a_out_services, const size_t a_maximum_services, size_t *a_count_services);
RNL_API uint32_t RNL_candidate_priority(const int32_t a_kind, const uint32_t a_local_preference);
RNL_API void RNL_candidate_sort_by_priority(void *a_candidates, const size_t a_count_candidates);
RNL_API int32_t RNL_nat_predict_hole_punching_viability(const int32_t a_local_mapping_behaviour, const int32_t a_remote_mapping_behaviour);
RNL_API int32_t RNL_host_create(rnl_instance_h a_instance, void *a_network, rnl_host_h *a_host);
RNL_API int32_t RNL_host_destroy(rnl_host_h a_host);
RNL_API int32_t RNL_host_get_address(rnl_host_h a_host, struct rnl_address *a_address);
RNL_API int32_t RNL_host_set_address(rnl_host_h a_host, const struct rnl_address *a_address);
RNL_API int32_t RNL_host_start(rnl_host_h a_host, const int32_t a_address_family_work_mode);
RNL_API int32_t RNL_host_service(rnl_host_h a_host, struct rnl_event *a_event, const int64_t a_timeout, int32_t *a_status);
RNL_API int32_t RNL_host_connect_service(rnl_host_h a_host, struct rnl_event *a_event, const int64_t a_timeout, int32_t *a_status);
RNL_API int32_t RNL_host_check_events(rnl_host_h a_host, struct rnl_event *a_event, int32_t *a_has_event);
RNL_API int32_t RNL_host_event_free(rnl_host_h a_host);
RNL_API int32_t RNL_host_connect(rnl_host_h a_host, const struct rnl_address *a_address, const uint32_t a_count_channels, const uint64_t a_data, const void *a_connection_token, const void *a_authentication_token, const void *a_expected_remote_long_term_public_key, const void *a_expected_remote_certificate_subject, rnl_peer_h *a_peer);
RNL_API int32_t RNL_host_connect_via_candidates(rnl_host_h a_host, const void *a_candidates, const size_t a_count_candidates, const uint32_t a_count_channels, const uint64_t a_data, const void *a_connection_token, const void *a_authentication_token, const void *a_expected_remote_long_term_public_key, const void *a_expected_remote_certificate_subject, rnl_peer_h *a_peer);
RNL_API int32_t RNL_host_punch_candidates(rnl_host_h a_host, const void *a_candidates, const size_t a_count_candidates, size_t *a_count_sent);
RNL_API int32_t RNL_host_broadcast_message_data(rnl_host_h a_host, const uint8_t a_channel, const void *a_data, const uint32_t a_data_length, const uint32_t a_flags);
RNL_API int32_t RNL_host_flush(rnl_host_h a_host, int32_t *a_ok);
RNL_API int32_t RNL_host_interrupt(rnl_host_h a_host);
RNL_API int32_t RNL_host_gather_candidates(rnl_host_h a_host, const void *a_stun_servers, const size_t a_count_stun_servers, void *a_out_candidates, const size_t a_maximum_candidates, size_t *a_count_candidates, const int64_t a_timeout_milliseconds, int32_t *a_ok);
RNL_API int32_t RNL_host_detect_nat_mapping_behaviour(rnl_host_h a_host, const void *a_stun_servers, const size_t a_count_stun_servers, int32_t *a_success, int32_t *a_behaviour, int32_t *a_filtering_behaviour, int32_t *a_supports_rfc5780, struct rnl_address *a_local_address, struct rnl_address *a_mapped_address, ptrdiff_t *a_socket_index, const int64_t a_timeout_milliseconds, int32_t *a_ok);
RNL_API int32_t RNL_host_begin_stun_query(rnl_host_h a_host, const struct rnl_address *a_server_address, const ptrdiff_t a_socket_index, int32_t *a_ok);
RNL_API int32_t RNL_host_take_stun_result(rnl_host_h a_host, int32_t *a_success, ptrdiff_t *a_socket_index, struct rnl_address *a_server_address, struct rnl_address *a_mapped_address, int64_t *a_round_trip_time, int32_t *a_have_result);
RNL_API ptrdiff_t RNL_host_count_pending_stun_queries(rnl_host_h a_host);
RNL_API int32_t RNL_host_local_candidates(rnl_host_h a_host, void *a_out_candidates, const size_t a_maximum_candidates, size_t *a_count_candidates);
RNL_API int32_t RNL_host_set_certificate(rnl_host_h a_host, const void *a_certificate);
RNL_API int32_t RNL_host_clear_certificate(rnl_host_h a_host);
RNL_API int32_t RNL_host_add_certificate_authority_public_key(rnl_host_h a_host, const void *a_key);
RNL_API int32_t RNL_host_clear_certificate_authority_public_keys(rnl_host_h a_host);
RNL_API int32_t RNL_host_verify_certificate(rnl_host_h a_host, const void *a_certificate, const void *a_long_term_public_key, const void *a_expected_subject, int32_t *a_verdict);
RNL_API int32_t RNL_host_add_local_address(rnl_host_h a_host, const struct rnl_address *a_address);
RNL_API int32_t RNL_host_clear_local_addresses(rnl_host_h a_host);
RNL_API int32_t RNL_host_add_relay_host_address(rnl_host_h a_host, const void *a_host_address);
RNL_API int32_t RNL_host_get_channel_type(rnl_host_h a_host, const uint32_t a_index, int32_t *a_channel_type);
RNL_API int32_t RNL_host_set_channel_type(rnl_host_h a_host, const uint32_t a_index, const int32_t a_channel_type);
RNL_API int32_t RNL_host_get_long_term_private_key(rnl_host_h a_host, void *a_buffer, size_t a_buffer_size);
RNL_API int32_t RNL_host_set_long_term_private_key(rnl_host_h a_host, const void *a_buffer, const size_t a_buffer_size);
RNL_API int32_t RNL_host_get_long_term_public_key(rnl_host_h a_host, void *a_buffer, size_t a_buffer_size);
RNL_API int32_t RNL_host_set_long_term_public_key(rnl_host_h a_host, const void *a_buffer, const size_t a_buffer_size);
RNL_API int32_t RNL_host_set_on_peer_connect(rnl_host_h a_host, rnl_cb_peer_connect a_callback, void *a_user_data);
RNL_API int32_t RNL_host_set_on_peer_disconnect(rnl_host_h a_host, rnl_cb_peer_disconnect a_callback, void *a_user_data);
RNL_API int32_t RNL_host_set_on_peer_approval(rnl_host_h a_host, rnl_cb_peer_approval a_callback, void *a_user_data);
RNL_API int32_t RNL_host_set_on_peer_denial(rnl_host_h a_host, rnl_cb_peer_denial a_callback, void *a_user_data);
RNL_API int32_t RNL_host_set_on_peer_bandwidth_limits(rnl_host_h a_host, rnl_cb_peer_bandwidth_limits a_callback, void *a_user_data);
RNL_API int32_t RNL_host_set_on_peer_mtu(rnl_host_h a_host, rnl_cb_peer_mtu a_callback, void *a_user_data);
RNL_API int32_t RNL_host_set_on_check_token_callback(rnl_host_h a_host, rnl_cb_check_token a_callback, void *a_user_data);
RNL_API int32_t RNL_host_get_allow_incoming_connections(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_allow_incoming_connections(rnl_host_h a_host, const int32_t a_value);
RNL_API uint32_t RNL_host_get_maximum_count_peers(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_maximum_count_peers(rnl_host_h a_host, const uint32_t a_value);
RNL_API uint32_t RNL_host_get_maximum_count_channels(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_maximum_count_channels(rnl_host_h a_host, const uint32_t a_value);
RNL_API uint32_t RNL_host_get_incoming_bandwidth_limit(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_incoming_bandwidth_limit(rnl_host_h a_host, const uint32_t a_value);
RNL_API uint32_t RNL_host_get_outgoing_bandwidth_limit(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_outgoing_bandwidth_limit(rnl_host_h a_host, const uint32_t a_value);
RNL_API uint32_t RNL_host_get_reliable_channel_block_packet_window_size(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_reliable_channel_block_packet_window_size(rnl_host_h a_host, const uint32_t a_value);
RNL_API uint32_t RNL_host_get_encrypted_packet_sequence_window_size(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_encrypted_packet_sequence_window_size(rnl_host_h a_host, const uint32_t a_value);
RNL_API uint32_t RNL_host_get_keep_alive_window_size(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_keep_alive_window_size(rnl_host_h a_host, const uint32_t a_value);
RNL_API uint32_t RNL_host_get_receive_buffer_size(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_receive_buffer_size(rnl_host_h a_host, const uint32_t a_value);
RNL_API uint32_t RNL_host_get_send_buffer_size(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_send_buffer_size(rnl_host_h a_host, const uint32_t a_value);
RNL_API int32_t RNL_host_get_mtu_do_fragment(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_mtu_do_fragment(rnl_host_h a_host, const int32_t a_value);
RNL_API int32_t RNL_host_get_check_connection_tokens(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_check_connection_tokens(rnl_host_h a_host, const int32_t a_value);
RNL_API int32_t RNL_host_get_check_authentication_tokens(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_check_authentication_tokens(rnl_host_h a_host, const int32_t a_value);
RNL_API uint64_t RNL_host_get_protocol_id(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_protocol_id(rnl_host_h a_host, const uint64_t a_value);
RNL_API uint64_t RNL_host_get_pending_connection_timeout(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_pending_connection_timeout(rnl_host_h a_host, const uint64_t a_value);
RNL_API uint64_t RNL_host_get_pending_connection_send_timeout(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_pending_connection_send_timeout(rnl_host_h a_host, const uint64_t a_value);
RNL_API uint64_t RNL_host_get_pending_connection_salt_timeout(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_pending_connection_salt_timeout(rnl_host_h a_host, const uint64_t a_value);
RNL_API uint64_t RNL_host_get_pending_connection_short_term_key_pair_timeout(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_pending_connection_short_term_key_pair_timeout(rnl_host_h a_host, const uint64_t a_value);
RNL_API uint64_t RNL_host_get_pending_connection_challenge_timeout(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_pending_connection_challenge_timeout(rnl_host_h a_host, const uint64_t a_value);
RNL_API uint64_t RNL_host_get_pending_connection_nonce_timeout(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_pending_connection_nonce_timeout(rnl_host_h a_host, const uint64_t a_value);
RNL_API uint64_t RNL_host_get_pending_disconnection_timeout(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_pending_disconnection_timeout(rnl_host_h a_host, const uint64_t a_value);
RNL_API uint64_t RNL_host_get_pending_disconnection_send_timeout(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_pending_disconnection_send_timeout(rnl_host_h a_host, const uint64_t a_value);
RNL_API int64_t RNL_host_get_minimum_retransmission_timeout(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_minimum_retransmission_timeout(rnl_host_h a_host, const int64_t a_value);
RNL_API int64_t RNL_host_get_maximum_retransmission_timeout(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_maximum_retransmission_timeout(rnl_host_h a_host, const int64_t a_value);
RNL_API int64_t RNL_host_get_minimum_retransmission_timeout_limit(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_minimum_retransmission_timeout_limit(rnl_host_h a_host, const int64_t a_value);
RNL_API int64_t RNL_host_get_maximum_retransmission_timeout_limit(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_maximum_retransmission_timeout_limit(rnl_host_h a_host, const int64_t a_value);
RNL_API uint32_t RNL_host_get_maximum_reliable_block_packet_send_attempts(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_maximum_reliable_block_packet_send_attempts(rnl_host_h a_host, const uint32_t a_value);
RNL_API uint32_t RNL_host_get_maximum_outgoing_unreliable_message_age(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_maximum_outgoing_unreliable_message_age(rnl_host_h a_host, const uint32_t a_value);
RNL_API int32_t RNL_host_get_congestion_control(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_congestion_control(rnl_host_h a_host, const int32_t a_value);
RNL_API uint32_t RNL_host_get_maximum_unreliable_block_packets_per_dispatch(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_maximum_unreliable_block_packets_per_dispatch(rnl_host_h a_host, const uint32_t a_value);
RNL_API int32_t RNL_host_get_transcript_binding_mode(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_transcript_binding_mode(rnl_host_h a_host, const int32_t a_value);
RNL_API uint64_t RNL_host_get_pending_connection_protocol_fallback_timeout(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_pending_connection_protocol_fallback_timeout(rnl_host_h a_host, const uint64_t a_value);
RNL_API ptrdiff_t RNL_host_get_maximum_candidates_per_handshake_round(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_maximum_candidates_per_handshake_round(rnl_host_h a_host, const ptrdiff_t a_value);
RNL_API int32_t RNL_host_get_relay_rate_limiter_per_port(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_relay_rate_limiter_per_port(rnl_host_h a_host, const int32_t a_value);
RNL_API int64_t RNL_host_get_rate_limiter_relay_address_burst(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_rate_limiter_relay_address_burst(rnl_host_h a_host, const int64_t a_value);
RNL_API uint64_t RNL_host_get_rate_limiter_relay_address_period(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_rate_limiter_relay_address_period(rnl_host_h a_host, const uint64_t a_value);
RNL_API int64_t RNL_host_get_rate_limiter_host_address_burst(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_rate_limiter_host_address_burst(rnl_host_h a_host, const int64_t a_value);
RNL_API uint64_t RNL_host_get_rate_limiter_host_address_period(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_rate_limiter_host_address_period(rnl_host_h a_host, const uint64_t a_value);
RNL_API int64_t RNL_host_get_stun_query_timeout(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_stun_query_timeout(rnl_host_h a_host, const int64_t a_value);
RNL_API ptrdiff_t RNL_host_get_count_stun_query_attempts(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_count_stun_query_attempts(rnl_host_h a_host, const ptrdiff_t a_value);
RNL_API int32_t RNL_host_get_require_certificate(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_require_certificate(rnl_host_h a_host, const int32_t a_value);
RNL_API uint32_t RNL_host_get_current_time_minutes(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_current_time_minutes(rnl_host_h a_host, const uint32_t a_value);
RNL_API int32_t RNL_host_get_interruptible(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_interruptible(rnl_host_h a_host, const int32_t a_value);
RNL_API uint32_t RNL_host_get_incoming_bandwidth_rate(rnl_host_h a_host);
RNL_API uint32_t RNL_host_get_outgoing_bandwidth_rate(rnl_host_h a_host);
RNL_API size_t RNL_host_get_maximum_message_size(rnl_host_h a_host);
RNL_API uint32_t RNL_host_get_count_peers(rnl_host_h a_host);
RNL_API uint64_t RNL_host_get_total_received_data(rnl_host_h a_host);
RNL_API uint64_t RNL_host_get_total_received_packets(rnl_host_h a_host);
RNL_API uint64_t RNL_host_get_total_soft_send_failures(rnl_host_h a_host);
RNL_API uint64_t RNL_host_get_total_hard_send_failures(rnl_host_h a_host);
RNL_API uint64_t RNL_host_get_total_hard_receive_failures(rnl_host_h a_host);
RNL_API uint64_t RNL_host_get_total_dropped_outgoing_messages(rnl_host_h a_host);
RNL_API uint64_t RNL_host_get_total_peers_given_up_on(rnl_host_h a_host);
RNL_API uint64_t RNL_host_get_total_outgoing_bandwidth_deferred_dispatches(rnl_host_h a_host);
RNL_API uint64_t RNL_host_get_total_stalled_retransmissions(rnl_host_h a_host);
RNL_API uint64_t RNL_host_get_total_discarded_stale_outgoing_block_packets(rnl_host_h a_host);
RNL_API uint64_t RNL_host_get_total_rejected_remote_long_term_public_keys(rnl_host_h a_host);
RNL_API uint64_t RNL_host_get_total_accepted_certificates(rnl_host_h a_host);
RNL_API uint64_t RNL_host_get_total_rejected_certificates(rnl_host_h a_host);
RNL_API uint64_t RNL_host_get_total_rate_limited_connection_requests(rnl_host_h a_host);
RNL_API uint64_t RNL_host_get_total_relayed_connection_requests(rnl_host_h a_host);
RNL_API uint64_t RNL_host_get_total_relay_ceiling_rate_limited_connection_requests(rnl_host_h a_host);
RNL_API uint64_t RNL_host_get_total_simultaneous_connects_won(rnl_host_h a_host);
RNL_API uint64_t RNL_host_get_total_simultaneous_connects_given_up(rnl_host_h a_host);
RNL_API uint64_t RNL_host_get_total_peer_address_changes(rnl_host_h a_host);
RNL_API uint32_t RNL_host_get_connection_attempts_per_second(rnl_host_h a_host);
RNL_API uint32_t RNL_host_get_connection_challenge_difficulty_level(rnl_host_h a_host);
RNL_API int32_t RNL_host_set_on_peer_receive(rnl_host_h a_host, rnl_cb_peer_receive a_callback, void *a_user_data);
RNL_API int32_t RNL_stun_message_create(const uint16_t a_message_type, const void *a_transaction_id, rnl_stun_message_h *a_message);
RNL_API int32_t RNL_stun_message_create_with_fresh_transaction_id(const uint16_t a_message_type, rnl_random_h a_random, rnl_stun_message_h *a_message);
RNL_API int32_t RNL_stun_message_destroy(rnl_stun_message_h a_message);
RNL_API int32_t RNL_stun_message_assign(rnl_stun_message_h a_message, const void *a_data, const ptrdiff_t a_data_size, int32_t *a_ok);
RNL_API int32_t RNL_stun_message_build_xor_mask(rnl_stun_message_h a_message, void *a_mask_buffer);
RNL_API int32_t RNL_stun_message_add_attribute(rnl_stun_message_h a_message, const uint16_t a_attribute_type, const void *a_value, const ptrdiff_t a_value_size);
RNL_API int32_t RNL_stun_message_add_empty_attribute(rnl_stun_message_h a_message, const uint16_t a_attribute_type);
RNL_API int32_t RNL_stun_message_add_u32_attribute(rnl_stun_message_h a_message, const uint16_t a_attribute_type, const uint32_t a_value);
RNL_API int32_t RNL_stun_message_add_u16_attribute(rnl_stun_message_h a_message, const uint16_t a_attribute_type, const uint16_t a_value);
RNL_API int32_t RNL_stun_message_add_string_attribute(rnl_stun_message_h a_message, const uint16_t a_attribute_type, const void *a_value, const size_t a_value_length);
RNL_API int32_t RNL_stun_message_add_xor_address_attribute(rnl_stun_message_h a_message, const uint16_t a_attribute_type, const struct rnl_address *a_address);
RNL_API int32_t RNL_stun_message_add_message_integrity(rnl_stun_message_h a_message, const void *a_key, const ptrdiff_t a_key_size);
RNL_API int32_t RNL_stun_message_add_message_integrity_sha256(rnl_stun_message_h a_message, const void *a_key, const ptrdiff_t a_key_size);
RNL_API int32_t RNL_stun_message_add_fingerprint(rnl_stun_message_h a_message);
RNL_API int32_t RNL_stun_message_verify_message_integrity(rnl_stun_message_h a_message, const void *a_key, const ptrdiff_t a_key_size);
RNL_API int32_t RNL_stun_message_verify_message_integrity_sha256(rnl_stun_message_h a_message, const void *a_key, const ptrdiff_t a_key_size);
RNL_API int32_t RNL_stun_message_verify_fingerprint(rnl_stun_message_h a_message);
RNL_API int32_t RNL_stun_message_find_attribute(rnl_stun_message_h a_message, const uint16_t a_attribute_type, ptrdiff_t *a_value_position, ptrdiff_t *a_value_size, int32_t *a_found);
RNL_API int32_t RNL_stun_message_has_attribute(rnl_stun_message_h a_message, const uint16_t a_attribute_type);
RNL_API int32_t RNL_stun_message_read_u32_attribute(rnl_stun_message_h a_message, const uint16_t a_attribute_type, uint32_t *a_value, int32_t *a_found);
RNL_API int32_t RNL_stun_message_read_u16_attribute(rnl_stun_message_h a_message, const uint16_t a_attribute_type, uint16_t *a_value, int32_t *a_found);
RNL_API int32_t RNL_stun_message_read_string_attribute(rnl_stun_message_h a_message, const uint16_t a_attribute_type, void *a_out_buffer, const size_t a_buffer_size, size_t *a_out_size, int32_t *a_found);
RNL_API int32_t RNL_stun_message_read_address_attribute(rnl_stun_message_h a_message, const uint16_t a_attribute_type, struct rnl_address *a_address, int32_t *a_found);
RNL_API int32_t RNL_stun_message_read_error_code(rnl_stun_message_h a_message, uint32_t *a_code, void *a_reason_buffer, const size_t a_reason_buffer_size, size_t *a_reason_size, int32_t *a_found);
RNL_API uint16_t RNL_stun_message_get_message_type(rnl_stun_message_h a_message);
RNL_API ptrdiff_t RNL_stun_message_get_size(rnl_stun_message_h a_message);
RNL_API int32_t RNL_stun_message_is_valid(rnl_stun_message_h a_message);
RNL_API void *RNL_stun_message_data_pointer(rnl_stun_message_h a_message);
RNL_API int32_t RNL_stun_message_has_same_transaction_id(rnl_stun_message_h a_message, const void *a_transaction_id);
RNL_API int32_t RNL_turn_network_create(rnl_instance_h a_instance, void *a_underlying_network, const struct rnl_address *a_server_address, const char *a_username, const size_t a_username_length, const char *a_password, const size_t a_password_length, rnl_turn_network_h *a_new_network);
RNL_API int32_t RNL_turn_network_destroy(rnl_turn_network_h a_network);
RNL_API int32_t RNL_turn_network_set_transport(rnl_turn_network_h a_network, const int32_t a_value);
RNL_API int32_t RNL_turn_network_get_transport(rnl_turn_network_h a_network);
RNL_API int32_t RNL_turn_network_set_dtls_version(rnl_turn_network_h a_network, const int32_t a_value);
RNL_API int32_t RNL_turn_network_get_dtls_version(rnl_turn_network_h a_network);
RNL_API int32_t RNL_turn_network_set_dtls_server_name(rnl_turn_network_h a_network, const char *a_name, const size_t a_name_length);
RNL_API int32_t RNL_dtls_verification_create(void *a_handle);
RNL_API int32_t RNL_dtls_verification_destroy(void *a_handle);
RNL_API void RNL_dtls_verification_set_chain(void *a_handle, const char *a_host_name, const size_t a_host_name_length, const int64_t a_now_seconds_since_unix_epoch);
RNL_API void RNL_dtls_verification_set_fingerprints(void *a_handle, const int32_t a_allow_raw_public_key);
RNL_API int32_t RNL_dtls_verification_add_trusted_root(void *a_handle, const void *a_certificate, const ptrdiff_t a_certificate_size);
RNL_API int32_t RNL_dtls_verification_add_fingerprint(void *a_handle, const void *a_fingerprint);
RNL_API int32_t RNL_dtls12_client_create(rnl_random_h a_random, const char *a_server_name, const size_t a_server_name_length, const void *a_verification, rnl_dtls12_client_h *a_client);
RNL_API int32_t RNL_dtls12_client_destroy(rnl_dtls12_client_h a_client);
RNL_API void RNL_dtls12_client_start(rnl_dtls12_client_h a_client, const uint64_t a_now);
RNL_API void RNL_dtls12_client_process_datagram(rnl_dtls12_client_h a_client, const void *a_data, const ptrdiff_t a_data_size, const uint64_t a_now);
RNL_API void RNL_dtls12_client_update(rnl_dtls12_client_h a_client, const uint64_t a_now);
RNL_API int32_t RNL_dtls12_client_pop_outgoing_datagram(rnl_dtls12_client_h a_client, void *a_buffer, const ptrdiff_t a_maximum_data_size, ptrdiff_t *a_data_size, int32_t *a_ok);
RNL_API int32_t RNL_dtls12_client_send(rnl_dtls12_client_h a_client, const void *a_data, const ptrdiff_t a_data_size, int32_t *a_ok);
RNL_API int32_t RNL_dtls12_client_pop_application_data(rnl_dtls12_client_h a_client, void *a_buffer, const ptrdiff_t a_maximum_data_size, ptrdiff_t *a_data_size, int32_t *a_ok);
RNL_API int32_t RNL_dtls12_client_get_state(rnl_dtls12_client_h a_client);
RNL_API int32_t RNL_dtls12_client_get_failure(rnl_dtls12_client_h a_client);
RNL_API uint8_t RNL_dtls12_client_get_alert_description(rnl_dtls12_client_h a_client);
RNL_API int32_t RNL_dtls12_client_get_certificate_verdict(rnl_dtls12_client_h a_client);
RNL_API int32_t RNL_dtls13_client_create(rnl_random_h a_random, const char *a_server_name, const size_t a_server_name_length, const void *a_verification, rnl_dtls13_client_h *a_client);
RNL_API int32_t RNL_dtls13_client_destroy(rnl_dtls13_client_h a_client);
RNL_API void RNL_dtls13_client_start(rnl_dtls13_client_h a_client, const uint64_t a_now);
RNL_API void RNL_dtls13_client_process_datagram(rnl_dtls13_client_h a_client, const void *a_data, const ptrdiff_t a_data_size, const uint64_t a_now);
RNL_API void RNL_dtls13_client_update(rnl_dtls13_client_h a_client, const uint64_t a_now);
RNL_API int32_t RNL_dtls13_client_pop_outgoing_datagram(rnl_dtls13_client_h a_client, void *a_buffer, const ptrdiff_t a_maximum_data_size, ptrdiff_t *a_data_size, int32_t *a_ok);
RNL_API int32_t RNL_dtls13_client_send(rnl_dtls13_client_h a_client, const void *a_data, const ptrdiff_t a_data_size, int32_t *a_ok);
RNL_API int32_t RNL_dtls13_client_pop_application_data(rnl_dtls13_client_h a_client, void *a_buffer, const ptrdiff_t a_maximum_data_size, ptrdiff_t *a_data_size, int32_t *a_ok);
RNL_API int32_t RNL_dtls13_client_get_state(rnl_dtls13_client_h a_client);
RNL_API int32_t RNL_dtls13_client_get_failure(rnl_dtls13_client_h a_client);
RNL_API uint8_t RNL_dtls13_client_get_alert_description(rnl_dtls13_client_h a_client);
RNL_API int32_t RNL_dtls13_client_get_certificate_verdict(rnl_dtls13_client_h a_client);
RNL_API int32_t RNL_certificate_issue(void *a_certificate, const void *a_subject, const void *a_long_term_public_key, const uint32_t a_valid_from_minutes, const uint32_t a_valid_until_minutes, const void *a_authority_private_key, const void *a_authority_public_key);
RNL_API int32_t RNL_certificate_is_absent(const void *a_certificate);
RNL_API uint32_t RNL_certificate_minutes_from_unix_time(const uint64_t a_unix_time_seconds);
RNL_API int32_t RNL_x509_matches_host_name(const void *a_certificate_der, const size_t a_certificate_der_size, const char *a_host_name, const size_t a_host_name_length);
RNL_API int32_t RNL_x509_verify_chain(const void *a_chain_certificates, const void *a_chain_sizes, const size_t a_count_chain, const void *a_trusted_roots, const void *a_root_sizes, const size_t a_count_roots, const char *a_host_name, const size_t a_host_name_length, const int64_t a_now_seconds_since_unix_epoch, void *a_leaf_buffer, const size_t a_leaf_buffer_size, size_t *a_leaf_size, int32_t *a_verdict);
RNL_API int32_t RNL_host_get_has_certificate(rnl_host_h a_host);
RNL_API int32_t RNL_host_get_last_certificate_verdict(rnl_host_h a_host);
RNL_API int32_t RNL_peer_inc_ref(rnl_peer_h a_peer);
RNL_API int32_t RNL_peer_dec_ref(rnl_peer_h a_peer);
RNL_API int32_t RNL_peer_disconnect(rnl_peer_h a_peer, const uint64_t a_data, const int32_t a_delayed);
RNL_API int32_t RNL_peer_mtu_probe(rnl_peer_h a_peer, const uint32_t a_try_iterations_per_mtu_probe_size, const uint64_t a_mtu_probe_interval);
RNL_API int32_t RNL_peer_get_address(rnl_peer_h a_peer, struct rnl_address *a_address, int32_t *a_ok);
RNL_API uint32_t RNL_peer_get_local_peer_id(rnl_peer_h a_peer);
RNL_API uint32_t RNL_peer_get_remote_peer_id(rnl_peer_h a_peer);
RNL_API size_t RNL_peer_get_mtu(rnl_peer_h a_peer);
RNL_API uint64_t RNL_peer_get_remote_host_salt(rnl_peer_h a_peer);
RNL_API int32_t RNL_peer_set_remote_host_salt(rnl_peer_h a_peer, const uint64_t a_value);
RNL_API ptrdiff_t RNL_peer_get_count_channels(rnl_peer_h a_peer);
RNL_API int32_t RNL_peer_set_count_channels(rnl_peer_h a_peer, const ptrdiff_t a_value);
RNL_API int32_t RNL_peer_get_channel(rnl_peer_h a_peer, const ptrdiff_t a_index, rnl_channel_h *a_channel);
RNL_API int32_t RNL_peer_get_transcript_binding(rnl_peer_h a_peer);
RNL_API uint32_t RNL_peer_get_remote_incoming_bandwidth_limit(rnl_peer_h a_peer);
RNL_API uint32_t RNL_peer_get_remote_outgoing_bandwidth_limit(rnl_peer_h a_peer);
RNL_API uint32_t RNL_peer_get_incoming_bandwidth_rate(rnl_peer_h a_peer);
RNL_API uint32_t RNL_peer_get_outgoing_bandwidth_rate(rnl_peer_h a_peer);
RNL_API uint32_t RNL_peer_get_minimum_round_trip_time(rnl_peer_h a_peer);
RNL_API uint32_t RNL_peer_get_queueing_delay(rnl_peer_h a_peer);
RNL_API uint32_t RNL_peer_get_queue_depth(rnl_peer_h a_peer);
RNL_API uint32_t RNL_peer_get_delivery_rate(rnl_peer_h a_peer);
RNL_API uint32_t RNL_peer_get_maximum_delivery_rate(rnl_peer_h a_peer);
RNL_API uint32_t RNL_peer_get_bandwidth_weight(rnl_peer_h a_peer);
RNL_API int32_t RNL_peer_set_bandwidth_weight(rnl_peer_h a_peer, const uint32_t a_value);
RNL_API uint32_t RNL_peer_get_outgoing_bandwidth_share(rnl_peer_h a_peer);
RNL_API uint32_t RNL_peer_get_count_last_flight_resolved_packets(rnl_peer_h a_peer);
RNL_API uint32_t RNL_peer_get_count_last_flight_lost_packets(rnl_peer_h a_peer);
RNL_API uint32_t RNL_peer_get_count_congestion_control_runs(rnl_peer_h a_peer);
RNL_API uint32_t RNL_peer_get_congestion_control_rate(rnl_peer_h a_peer);
RNL_API uint32_t RNL_peer_get_count_packet_loss(rnl_peer_h a_peer);
RNL_API uint32_t RNL_peer_get_count_keep_alive_ping_resends(rnl_peer_h a_peer);
RNL_API int32_t RNL_peer_get_has_remote_certificate(rnl_peer_h a_peer);
RNL_API int32_t RNL_peer_get_remote_long_term_public_key(rnl_peer_h a_peer, void *a_buffer, size_t a_buffer_size);
RNL_API int32_t RNL_peer_get_remote_certificate(rnl_peer_h a_peer, void *a_buffer, size_t a_buffer_size);
RNL_API int32_t RNL_channel_send_message_data(rnl_channel_h a_channel, const void *a_data, const uint32_t a_data_length, const uint32_t a_flags);
RNL_API size_t RNL_channel_get_maximum_unfragmented_message_size(rnl_channel_h a_channel);
RNL_API size_t RNL_channel_get_maximum_message_size(rnl_channel_h a_channel);
RNL_API ptrdiff_t RNL_channel_get_count_pending_outgoing(rnl_channel_h a_channel);

#ifdef __cplusplus
}
#endif

#endif /* RNL_H_INCLUDED */
