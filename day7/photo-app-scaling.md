# SnapShare: Scaling Plan for a Photo-Sharing App

## 1. Assumptions and traffic estimates

SnapShare is a photo-sharing application where users upload photos and view a feed of photos from people they follow.

### Assumptions

- There are 10 million registered users.
- 10% of registered users are active each day.
- Each daily active user uploads one photo per day.
- Each daily active user views 50 feed pages per day.
- Each original photo is 2 MB.
- Each thumbnail is 50 KB.
- One day has 86,400 seconds.
- Peak traffic is five times the average traffic.
- All uploaded photos and thumbnails are retained for one year.
- For simplicity, storage estimates use decimal units: 1 GB = 1,000 MB and 1 TB = 1,000 GB.
- Storage estimates exclude backups, replicas, metadata, and compression savings.

### Daily active users

Daily active users = 10,000,000 × 10%

**Daily active users = 1,000,000**

### Photo uploads per second

Uploads per day = 1,000,000 × 1 = 1,000,000 uploads.

Average uploads per second = 1,000,000 ÷ 86,400

**Average uploads per second ≈ 11.6**

Peak uploads per second = 11.6 × 5

**Peak uploads per second ≈ 57.9**

### Feed views per second

Feed views per day = 1,000,000 × 50

Feed views per day = 50,000,000.

Average feed views per second = 50,000,000 ÷ 86,400

**Average feed views per second ≈ 579**

Peak feed views per second = 579 × 5

**Peak feed views per second ≈ 2,894**

### Photo storage per year

Original photo storage per day:

1,000,000 × 2 MB = 2,000,000 MB = 2,000 GB.

Original photo storage per year:

2,000 GB × 365 = 730,000 GB.

**Original photo storage per year = 730 TB.**

Thumbnail storage per day:

1,000,000 × 50 KB = 50,000,000 KB = 50 GB.

Thumbnail storage per year:

50 GB × 365 = 18,250 GB.

**Thumbnail storage per year = 18.25 TB.**

Total estimated photo and thumbnail storage per year:

730 TB + 18.25 TB = **748.25 TB**.

This estimate assumes one thumbnail per photo and does not include backups, replicas, or other storage overhead.

## 2. Is SnapShare read-heavy or write-heavy?

SnapShare is a read-heavy system because it handles approximately 579 feed views per second on average, compared with approximately 12 photo uploads per second. Feed views are much more frequent than uploads.

The architecture should therefore prioritise fast reads by using a CDN, a cache, and a database read replica. App servers should also be able to scale horizontally to handle increased traffic.

## 3. Where should photos be stored?

Photo files should be stored in object storage rather than directly inside the relational database. Photos are large binary files, and storing them in the database would increase its size, backup time, and storage costs.

The database should store photo metadata, such as the photo ID, owner ID, caption, upload time, and object storage key. The actual original photos and thumbnails should be stored in object storage, with the CDN delivering them to users.

## 4. Architecture diagram

```text
                    Users
                      |
                      v
              +---------------+
              |      CDN      |
              | Cached images  |
              +---------------+
                      |
                      v
              +---------------+
              | Load Balancer |
              +---------------+
                      |
              +-------+-------+
              |               |
              v               v
        +-----------+   +-----------+
        | App Server|   | App Server|
        |     1     |   |     2     |
        +-----------+   +-----------+
              |               |
              +-------+-------+
                      |
          +-----------+-----------+
          |           |           |
          v           v           v
     +---------+ +----------+ +-------------+
     |  Cache  | | Primary  | | Object      |
     |  Redis  | | Database | | Storage     |
     +---------+ +----+-----+ | Photos and  |
                     |       | thumbnails  |
                     v       +------+------+
              +--------------+       ^
              | Read Replica |       |
              +--------------+       |
                                     |
        App Server                   |
             |                       |
             v                       |
       +------------+                |
       | Job Queue  |                |
       +------+-----+                |
              |                      |
              v                      |
       +--------------+              |
       | Thumbnail    |--------------+
       | Worker       |
       +--------------+
```

## 5. What each component does

- **CDN:** Delivers cached photos and thumbnails from locations close to users, reducing latency and load on the application.
- **Load balancer:** Distributes incoming requests across available app servers to prevent one server from becoming overloaded.
- **App servers:** Handle authentication, upload requests, feed generation, validation, and business logic.
- **Redis cache:** Stores frequently requested feed data and other reusable information to reduce repeated database queries.
- **Primary database:** Stores durable relational data such as users, follows, photo metadata, captions, and permissions.
- **Database read replica:** Serves suitable read queries to reduce the workload on the primary database.
- **Object storage:** Stores the original photo files and generated thumbnails without filling the database with large binary files.
- **Job queue:** Holds thumbnail-generation jobs so photo uploads do not have to wait for image processing to finish.
- **Thumbnail worker:** Processes queued jobs, creates smaller thumbnail images, and saves them to object storage.

## 6. Photo upload flow

1. A user selects a photo and submits it through the application.
2. The app server authenticates the user and validates the upload, including its file type and size.
3. The server authorises the upload and provides an upload destination, such as a short-lived pre-signed object storage URL.
4. The client uploads the original photo to object storage, avoiding the need to send the entire file through the app server.
5. After the upload succeeds, the application records the photo metadata and storage key in the primary database.
6. The application places a thumbnail-generation job on the job queue.
7. A thumbnail worker takes the job, reads the original photo from object storage, and generates a 50 KB thumbnail.
8. The worker saves the thumbnail to object storage and updates the photo's processing status if necessary.
9. The CDN can cache and deliver the thumbnail when users view the photo in their feeds.
10. The photo becomes available in the relevant feeds according to the application's feed-generation and processing rules.

If thumbnail generation fails, the job can be retried without requiring the user to upload the original photo again.

## 7. Trade-offs

### Caching versus freshness

Caching feed data improves response times and reduces database load, but cached feeds may become outdated when a user uploads a photo or follows someone new. Cache invalidation and suitable expiration times help balance speed and freshness.

### Asynchronous processing versus immediate availability

Using a queue allows uploads to finish without waiting for thumbnail generation. However, thumbnails may not be immediately available, and the system must handle retries and failed jobs.

### Database read replicas versus consistency

Read replicas improve read capacity, but replication lag can cause a recent upload or update to be temporarily missing from a feed. The application may need to read recent changes from the primary database.

### Object storage and CDN versus control

Object storage and a CDN provide scalable, efficient photo delivery, but introduce additional services, configuration, and costs. Private photos also require appropriate access controls and secure delivery.

## 8. Conclusion

SnapShare should use a horizontally scalable application architecture with a load balancer, stateless app servers, Redis caching, a primary database with a read replica, object storage, a CDN, and asynchronous thumbnail processing. This design addresses the high volume of feed reads while allowing photo uploads and image processing to scale independently.
