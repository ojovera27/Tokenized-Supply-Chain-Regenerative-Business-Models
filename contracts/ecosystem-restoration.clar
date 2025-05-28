;; Ecosystem Restoration Contract
;; Manages regenerative initiatives and restoration projects

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u500))
(define-constant ERR_PROJECT_NOT_FOUND (err u501))
(define-constant ERR_INVALID_PROJECT (err u502))

;; Restoration project tracking
(define-map restoration-projects
  { project-id: uint }
  {
    entity-id: uint,
    project-name: (string-ascii 50),
    ecosystem-type: (string-ascii 30),
    area-size: uint,
    start-date: uint,
    target-completion: uint,
    status: (string-ascii 20),
    carbon-sequestered: uint,
    biodiversity-score: uint
  }
)

;; Track project count
(define-data-var project-count uint u0)
(define-data-var total-carbon-sequestered uint u0)

;; Create restoration project
(define-public (create-restoration-project
  (entity-id uint)
  (project-name (string-ascii 50))
  (ecosystem-type (string-ascii 30))
  (area-size uint)
  (target-completion uint)
)
  (let ((project-id (+ (var-get project-count) u1)))
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (> area-size u0) ERR_INVALID_PROJECT)
    (map-set restoration-projects
      { project-id: project-id }
      {
        entity-id: entity-id,
        project-name: project-name,
        ecosystem-type: ecosystem-type,
        area-size: area-size,
        start-date: block-height,
        target-completion: target-completion,
        status: "active",
        carbon-sequestered: u0,
        biodiversity-score: u0
      }
    )
    (var-set project-count project-id)
    (ok project-id)
  )
)

;; Update project progress
(define-public (update-project-progress
  (project-id uint)
  (carbon-sequestered uint)
  (biodiversity-score uint)
  (status (string-ascii 20))
)
  (let
    (
      (project (unwrap! (map-get? restoration-projects { project-id: project-id }) ERR_PROJECT_NOT_FOUND))
      (carbon-diff (- carbon-sequestered (get carbon-sequestered project)))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (map-set restoration-projects
      { project-id: project-id }
      (merge project {
        carbon-sequestered: carbon-sequestered,
        biodiversity-score: biodiversity-score,
        status: status
      })
    )
    (var-set total-carbon-sequestered (+ (var-get total-carbon-sequestered) carbon-diff))
    (ok true)
  )
)

;; Get restoration project
(define-read-only (get-restoration-project (project-id uint))
  (map-get? restoration-projects { project-id: project-id })
)

;; Get project count
(define-read-only (get-project-count)
  (var-get project-count)
)

;; Get total carbon sequestered
(define-read-only (get-total-carbon-sequestered)
  (var-get total-carbon-sequestered)
)
