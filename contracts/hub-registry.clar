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

;; Validation Helper Functions
(define-private (is-valid-keyword (keyword (string-ascii 40)))
  (and 
    (> (len keyword) u0)
    (< (len keyword) u41)
  )
)

;; Core Registration and Management Functions

;; Creates user interface visualization for content details
(define-public (display-content-profile (content-id uint))
  (let
    (
      (record-data (unwrap! (map-get? intellectual-records { content-id: content-id }) ERR_RECORD_NOT_FOUND))
    )
    ;; Generate interface-friendly data structure
    (ok {
      page-name: "Content Profile",
      content-title: (get content-title record-data),
      content-author: (get content-author record-data),
      content-abstract: (get content-abstract record-data),
      content-keywords: (get content-keywords record-data)
    })
  )
)

;; Alternative implementation with improved code organization
(define-public (register-intellectual-contribution (title (string-ascii 80)) (size uint) (abstract (string-ascii 256)) (keywords (list 8 (string-ascii 40))))
  (let
    (
      (content-id (+ (var-get record-sequence) u1))
    )
    (asserts! (> (len title) u0) ERR_INVALID_TITLE_FORMAT)
    (asserts! (< (len title) u81) ERR_INVALID_TITLE_FORMAT)
    (asserts! (> size u0) ERR_INVALID_SIZE_PARAMETER)
    (asserts! (< size u2000000000) ERR_INVALID_SIZE_PARAMETER)
    (asserts! (> (len abstract) u0) ERR_INVALID_TITLE_FORMAT)
    (asserts! (< (len abstract) u257) ERR_INVALID_TITLE_FORMAT)
    (asserts! (validate-all-keywords keywords) ERR_INVALID_TITLE_FORMAT)

    ;; Store contribution metadata in registry
    (map-insert intellectual-records
      { content-id: content-id }
      {
        content-title: title,
        content-author: tx-sender,
        content-size: size,
        registration-height: block-height,
        content-abstract: abstract,
        content-keywords: keywords
      }
    )

    ;; Establish initial access privileges for creator
    (map-insert access-registry
      { content-id: content-id, participant: tx-sender }
      { can-access: true }
    )
    (var-set record-sequence content-id)
    (ok content-id)
  )
)

;; Register new intellectual contribution to the system
(define-public (add-intellectual-record (title (string-ascii 80)) (size uint) (abstract (string-ascii 256)) (keywords (list 8 (string-ascii 40))))
  (let
    (
      (content-id (+ (var-get record-sequence) u1))
    )
    ;; Validate title properties
    (asserts! (> (len title) u0) ERR_INVALID_TITLE_FORMAT)
    (asserts! (< (len title) u81) ERR_INVALID_TITLE_FORMAT)

    ;; Validate size constraints
    (asserts! (> size u0) ERR_INVALID_SIZE_PARAMETER)
    (asserts! (< size u2000000000) ERR_INVALID_SIZE_PARAMETER)

    ;; Validate abstract requirements
    (asserts! (> (len abstract) u0) ERR_INVALID_TITLE_FORMAT)
    (asserts! (< (len abstract) u257) ERR_INVALID_TITLE_FORMAT)

    ;; Ensure keywords meet system requirements
    (asserts! (validate-all-keywords keywords) ERR_INVALID_TITLE_FORMAT)

    ;; Create new record in the intellectual registry
    (map-insert intellectual-records
      { content-id: content-id }
      {
        content-title: title,
        content-author: tx-sender,
        content-size: size,
        registration-height: block-height,
        content-abstract: abstract,
        content-keywords: keywords
      }
    )

    ;; Configure default access permissions
    (map-insert access-registry
      { content-id: content-id, participant: tx-sender }
      { can-access: true }
    )

    ;; Update sequence counter
    (var-set record-sequence content-id)
    (ok content-id)
  )
)

;; Update existing intellectual record metadata
(define-public (update-intellectual-record (content-id uint) (revised-title (string-ascii 80)) (revised-size uint) (revised-abstract (string-ascii 256)) (revised-keywords (list 8 (string-ascii 40))))
  (let
    (
      (record-data (unwrap! (map-get? intellectual-records { content-id: content-id }) ERR_RECORD_NOT_FOUND))
    )
    ;; Verify record existence and ownership
    (asserts! (record-exists-check content-id) ERR_RECORD_NOT_FOUND)
    (asserts! (is-eq (get content-author record-data) tx-sender) ERR_ACCESS_RESTRICTED)

    ;; Validate revised title
    (asserts! (> (len revised-title) u0) ERR_INVALID_TITLE_FORMAT)
    (asserts! (< (len revised-title) u81) ERR_INVALID_TITLE_FORMAT)

    ;; Validate revised size
    (asserts! (> revised-size u0) ERR_INVALID_SIZE_PARAMETER)
    (asserts! (< revised-size u2000000000) ERR_INVALID_SIZE_PARAMETER)

    ;; Validate revised abstract
    (asserts! (> (len revised-abstract) u0) ERR_INVALID_TITLE_FORMAT)
    (asserts! (< (len revised-abstract) u257) ERR_INVALID_TITLE_FORMAT)

    ;; Validate revised keywords
    (asserts! (validate-all-keywords revised-keywords) ERR_INVALID_TITLE_FORMAT)

    ;; Update record with new information
    (map-set intellectual-records
      { content-id: content-id }
      (merge record-data { 
        content-title: revised-title, 
        content-size: revised-size, 
        content-abstract: revised-abstract, 
        content-keywords: revised-keywords 
      })
    )
    (ok true)
  )
)

;; Remove intellectual record from registry
(define-public (deregister-contribution (content-id uint))
  (let
    (
      (record-data (unwrap! (map-get? intellectual-records { content-id: content-id }) ERR_RECORD_NOT_FOUND))
    )
    ;; Verify record exists
    (asserts! (record-exists-check content-id) ERR_RECORD_NOT_FOUND)
    ;; Ensure only author can remove
    (asserts! (is-eq (get content-author record-data) tx-sender) ERR_ACCESS_RESTRICTED)

    ;; Permanently remove record
    (map-delete intellectual-records { content-id: content-id })
    (ok true)
  )
)

;; Optimized Query Functions

;; Retrieve essential record information with reduced computational cost
(define-public (retrieve-essential-data (content-id uint))
  (let
    (
      (record-data (unwrap! (map-get? intellectual-records { content-id: content-id }) ERR_RECORD_NOT_FOUND))
    )
    ;; Return streamlined data structure to minimize processing
    (ok {
      content-title: (get content-title record-data),
      content-author: (get content-author record-data),
      content-size: (get content-size record-data)
    })
  )
)
;; This function provides core record information with optimized computational efficiency

;; Generate comprehensive display of intellectual contribution
(define-public (create-contribution-display (content-id uint))
  (let
    (
      (record-data (unwrap! (map-get? intellectual-records { content-id: content-id }) ERR_RECORD_NOT_FOUND))
    )
    ;; Format complete record details for presentation
    (ok {
      title: (get content-title record-data),
      author: (get content-author record-data),
      size: (get content-size record-data),
      abstract: (get content-abstract record-data),
      keywords: (get content-keywords record-data)
    })
  )
)

;; Ultra-efficient minimal record lookup
(define-public (retrieve-identity-only (content-id uint))
  (let
    (
      (record-data (unwrap! (map-get? intellectual-records { content-id: content-id }) ERR_RECORD_NOT_FOUND))
    )
    ;; Return absolute minimum identification data for maximum efficiency
    (ok {
      content-title: (get content-title record-data),
      content-author: (get content-author record-data)
    })
  )
)
;; This highly optimized function returns only basic identification information

;; Access record abstract text
(define-public (retrieve-record-abstract (content-id uint))
  (let
    (
      (record-data (unwrap! (map-get? intellectual-records { content-id: content-id }) ERR_RECORD_NOT_FOUND))
    )
    (ok (get content-abstract record-data))
  )
)

;; Contribution validation test framework
(define-public (verify-contribution-parameters (title (string-ascii 80)) (size uint) (abstract (string-ascii 256)) (keywords (list 8 (string-ascii 40))))
  (begin
    ;; Validate title specifications
    (asserts! (> (len title) u0) ERR_INVALID_TITLE_FORMAT)
    (asserts! (< (len title) u81) ERR_INVALID_TITLE_FORMAT)

    ;; Validate size specifications
    (asserts! (> size u0) ERR_INVALID_SIZE_PARAMETER)
    (asserts! (< size u2000000000) ERR_INVALID_SIZE_PARAMETER)

    ;; Validate abstract specifications
    (asserts! (> (len abstract) u0) ERR_INVALID_TITLE_FORMAT)
    (asserts! (< (len abstract) u257) ERR_INVALID_TITLE_FORMAT)

    ;; Ensure all keywords conform to system requirements
    (asserts! (validate-all-keywords keywords) ERR_INVALID_TITLE_FORMAT)

    (ok true)
  )
)

