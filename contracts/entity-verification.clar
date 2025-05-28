;; Entity Verification Contract
;; Validates regenerative businesses and their credentials

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ENTITY_NOT_FOUND (err u101))
(define-constant ERR_ALREADY_VERIFIED (err u102))

;; Entity verification status
(define-map verified-entities
  { entity-id: uint }
  {
    verified: bool,
    verification-date: uint,
    verifier: principal,
    regenerative-score: uint,
    business-type: (string-ascii 50)
  }
)

;; Track verification count
(define-data-var verification-count uint u0)

;; Verify a regenerative business entity
(define-public (verify-entity (entity-id uint) (business-type (string-ascii 50)) (regenerative-score uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-none (map-get? verified-entities { entity-id: entity-id })) ERR_ALREADY_VERIFIED)
    (map-set verified-entities
      { entity-id: entity-id }
      {
        verified: true,
        verification-date: block-height,
        verifier: tx-sender,
        regenerative-score: regenerative-score,
        business-type: business-type
      }
    )
    (var-set verification-count (+ (var-get verification-count) u1))
    (ok entity-id)
  )
)

;; Get entity verification status
(define-read-only (get-entity-status (entity-id uint))
  (map-get? verified-entities { entity-id: entity-id })
)

;; Check if entity is verified
(define-read-only (is-entity-verified (entity-id uint))
  (match (map-get? verified-entities { entity-id: entity-id })
    entity-data (get verified entity-data)
    false
  )
)

;; Get total verification count
(define-read-only (get-verification-count)
  (var-get verification-count)
)
