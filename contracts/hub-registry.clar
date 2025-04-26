;; Intellect Hub e-Registry Contract
;; Facilitates digital registration, indexing and authorization of intellectual contributions



;; Contract Constants
(define-constant REGISTRY_ADMINISTRATOR tx-sender)
(define-constant ERR_AUTHORIZATION_FAILED (err u300))
(define-constant ERR_RECORD_NOT_FOUND (err u301))


;; Global Counter Management
(define-data-var record-sequence uint u0)

;; Primary Data Structures
(define-map intellectual-records
  { content-id: uint }
  {
    content-title: (string-ascii 80),
    content-author: principal,
    content-size: uint,
    registration-height: uint,
    content-abstract: (string-ascii 256),
    content-keywords: (list 8 (string-ascii 40))
  }
)

(define-map access-registry
  { content-id: uint, participant: principal }
  { can-access: bool }
)

(define-constant ERR_RECORD_ALREADY_REGISTERED (err u302))
(define-constant ERR_INVALID_TITLE_FORMAT (err u303))
(define-constant ERR_INVALID_SIZE_PARAMETER (err u304))
(define-constant ERR_ACCESS_RESTRICTED (err u305))

;; Internal Utility Functions
(define-private (record-exists-check (content-id uint))
  (is-some (map-get? intellectual-records { content-id: content-id }))
)

(define-private (validate-all-keywords (keywords (list 8 (string-ascii 40))))
  (and
    (> (len keywords) u0)
    (<= (len keywords) u8)
    (is-eq (len (filter is-valid-keyword keywords)) (len keywords))
  )
)

(define-private (is-record-author (content-id uint) (author principal))
  (match (map-get? intellectual-records { content-id: content-id })
    record-data (is-eq (get content-author record-data) author)
    false
  )
)

(define-private (get-content-size (content-id uint))
  (default-to u0 
    (get content-size 
      (map-get? intellectual-records { content-id: content-id })
    )
  )
)
