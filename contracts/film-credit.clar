;; Decentralized Film Credits Contract
;; Immutable credits for every contributor in a film

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-film-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))

;; Data Variables
(define-data-var film-count uint u0)

;; Data Maps
(define-map films
  { film-id: uint }
  {
    title: (string-ascii 100),
    producer: principal,
    release-year: uint,
    created-at: uint
  }
)

(define-map film-credits
  { film-id: uint, contributor: principal }
  {
    name: (string-utf8 50),
    role: (string-ascii 50),
    contribution: (string-utf8 200),
    added-at: uint
  }
)

(define-map contributor-films
  { contributor: principal, index: uint }
  { film-id: uint }
)

(define-map contributor-film-count
  { contributor: principal }
  { count: uint }
)

;; Read-only functions
(define-read-only (get-film (film-id uint))
  (map-get? films { film-id: film-id })
)

(define-read-only (get-credit (film-id uint) (contributor principal))
  (map-get? film-credits { film-id: film-id, contributor: contributor })
)

(define-read-only (get-film-count)
  (var-get film-count)
)

(define-read-only (get-contributor-film-count (contributor principal))
  (default-to { count: u0 } (map-get? contributor-film-count { contributor: contributor }))
)

(define-read-only (get-contributor-film (contributor principal) (index uint))
  (map-get? contributor-films { contributor: contributor, index: index })
)

;; Public functions
(define-public (create-film (title (string-ascii 100)) (release-year uint))
  (let
    (
      (new-film-id (+ (var-get film-count) u1))
    )
    (asserts! (> (len title) u0) (err u104))
    (map-set films
      { film-id: new-film-id }
      {
        title: title,
        producer: tx-sender,
        release-year: release-year,
        created-at: block-height
      }
    )
    (var-set film-count new-film-id)
    (ok new-film-id)
  )
)

(define-public (add-credit
    (film-id uint)
    (contributor principal)
    (name (string-utf8 50))
    (role (string-ascii 50))
    (contribution (string-utf8 200)))
  (let
    (
      (film (unwrap! (get-film film-id) err-film-not-found))
      (contributor-count (get count (get-contributor-film-count contributor)))
    )
    ;; Only film producer can add credits
    (asserts! (is-eq tx-sender (get producer film)) err-unauthorized)

    ;; Ensure credit doesn't already exist
    (asserts! (is-none (get-credit film-id contributor)) err-already-exists)

    ;; Add the credit
    (map-set film-credits
      { film-id: film-id, contributor: contributor }
      {
        name: name,
        role: role,
        contribution: contribution,
        added-at: block-height
      }
    )

    ;; Update contributor's film list
    (map-set contributor-films
      { contributor: contributor, index: contributor-count }
      { film-id: film-id }
    )

    ;; Update contributor film count
    (map-set contributor-film-count
      { contributor: contributor }
      { count: (+ contributor-count u1) }
    )

    (ok true)
  )
)

(define-public (update-credit
    (film-id uint)
    (contributor principal)
    (name (string-utf8 50))
    (role (string-ascii 50))
    (contribution (string-utf8 200)))
  (let
    (
      (film (unwrap! (get-film film-id) err-film-not-found))
      (existing-credit (unwrap! (get-credit film-id contributor) err-film-not-found))
    )
    ;; Only film producer can update credits
    (asserts! (is-eq tx-sender (get producer film)) err-unauthorized)

    ;; Update the credit while preserving the original added-at time
    (map-set film-credits
      { film-id: film-id, contributor: contributor }
      {
        name: name,
        role: role,
        contribution: contribution,
        added-at: (get added-at existing-credit)
      }
    )

    (ok true)
  )
)
