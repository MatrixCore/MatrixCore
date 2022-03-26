//
//  File.swift
//
//
//  Created by Finn Behrens on 13.03.22.
//

import Foundation

public struct MatrixMessageRelatesTo: Codable {
    public var inReplyTo: InReplyTo?

    enum CodingKeys: String, CodingKey {
        case inReplyTo = "m.in_reply_to"
    }

    public struct InReplyTo: Codable {
        public var eventID: String?

        enum CodingKeys: String, CodingKey {
            case eventID = "event_id"
        }
    }
}

/// This message is the most basic message and is used to represent text.
public struct MatrixMessageText: MatrixMessageType {
    public static let type = "m.text"

    /// The body of the message.
    public var body: String

    /// The format used in the ``formattedBody``.
    ///
    /// Currently only `org.matrix.custom.html` is supported.
    public var format: String?

    /// The formatted version of the body. This is required if ``format`` is specified.
    public var formattedBody: String?

    public var relatesTo: MatrixMessageRelatesTo?

    enum CodingKeys: String, CodingKey {
        case body, format
        case formattedBody = "formatted_body"
        case relatesTo = "m.relates_to"
    }
}

/// This message is similar to m.text except that the sender is ‘performing’ the
/// action contained in the body key, similar to /me in IRC.
///
/// This message should be prefixed by the name of the sender.
/// This message could also be represented in a different colour to
/// distinguish it from regular ``MatrixClient/MatrixMessageText`` messages.
public struct MatrixMessageEmote: MatrixMessageType {
    public static let type = "m.emote"

    /// The emote action to perform.
    public var body: String

    /// The format used in the ``formattedBody``.
    ///
    /// Currently only `org.matrix.custom.html` is supported.
    public var format: String?

    /// The formatted version of the body. This is required if ``format`` is specified.
    public var formattedBody: String?

    public var relatesTo: MatrixMessageRelatesTo?

    enum CodingKeys: String, CodingKey {
        case body, format
        case formattedBody = "formatted_body"
        case relatesTo = "m.relates_to"
    }
}

/// The m.notice type is primarily intended for responses from automated clients.
///
/// An ``MatrixClient/MatrixMessageNotice`` message must be treated
/// the same way as a regular ``MatrixClient/MatrixMessageText``
/// message with two exceptions.
/// Firstly, clients should present ``MatrixClient/MatrixMessageNotice``
/// messages to users in a distinct manner, and secondly, ``MatrixClient/MatrixMessageNotice``
/// messages must never be automatically responded to.
/// This helps to prevent infinite-loop situations where two automated clients continuously exchange messages.
public struct MatrixMessageNotice: MatrixMessageType {
    public static let type: String = "m.notice"

    /// The body of the message.
    public var body: String

    /// The format used in the ``formattedBody``.
    ///
    /// Currently only `org.matrix.custom.html` is supported.
    public var format: String?

    /// The formatted version of the body. This is required if ``format`` is specified.
    public var formattedBody: String?

    public var relatesTo: MatrixMessageRelatesTo?

    enum CodingKeys: String, CodingKey {
        case body, format
        case formattedBody = "formatted_body"
        case relatesTo = "m.relates_to"
    }
}

public struct MatrixMessageImage: MatrixMessageType {
    public static let type: String = "m.image"

    /// A textual representation of the image.
    ///
    /// This could be the alt text of the image, the filename of the image,
    /// or some kind of content description for accessibility e.g. ‘image attachment’.
    public var body: String

    /*
     /// Required if the file is encrypted.
     ///
     /// Information on the encrypted file, as specified in <doc:End-to-end-encryption>.
     public var file: EncryptedFile?
      */

    /// Metadata about the image referred to in url.
    public var info: ImageInfo?

    /// Required if the file is unencrypted.
    ///
    /// The URL (typically MXC URI) to the image.
    public var url: String?

    public var relatesTo: MatrixMessageRelatesTo?

    enum CodingKeys: String, CodingKey {
        case body
        case info
        case url
        case relatesTo = "m.relates_to"
    }

    public struct ImageInfo: Codable {
        /// The intended display height of the image in pixels.
        ///
        /// This may differ from the intrinsic dimensions of the image file.
        public var height: Int?

        /// The intended display width of the image in pixels.
        ///
        /// This may differ from the intrinsic dimensions of the image file.
        public var width: Int?

        // TODO: UTType?
        /// The mimetype of the image, e.g. image/jpeg.
        public var mimetype: String?

        /// Size of the image in bytes.
        public var size: Int?

        /*
         /// Information on the encrypted thumbnail file, as specified in <doc:End-to-end-encryption>.
         ///
         /// Only present if the thumbnail is encrypted.
         public var thumbnailFile: EncryptedFile?
         */

        /// Metadata about the image referred to in thumbnail_url.
        public var thumbnailInfo: ThumbnailInfo?

        /// The URL (typically MXC URI) to a thumbnail of the image.
        ///
        /// Only present if the thumbnail is unencrypted.
        public var thumbnailURL: String?

        enum CodingKeys: String, CodingKey {
            case height = "h"
            case width = "w"
            case mimetype, size
            // case thumbnailFile = "thumbnail_file"
            case thumbnailInfo = "thumbnail_info"
            case thumbnailURL = "thumbnail_url"
        }
    }
}

public extension MatrixMessageImage.ImageInfo {
    struct ThumbnailInfo: Codable {
        /// The intended display height of the image in pixels.
        ///
        /// This may differ from the intrinsic dimensions of the image file.
        public var height: Int?

        /// The intended display width of the image in pixels.
        ///
        /// This may differ from the intrinsic dimensions of the image file.
        public var width: Int?

        // TODO: UTType?
        /// The mimetype of the image, e.g. image/jpeg.
        public var mimetype: String?

        /// Size of the image in bytes.
        public var size: Int?

        enum CodingKeys: String, CodingKey {
            case height = "h"
            case width = "w"
            case mimetype, size
        }
    }
}

/// This message represents a generic file.
public struct MatrixMessageFile: MatrixMessageType {
    public static let type: String = "m.file"

    /// A human-readable description of the file.
    ///
    /// This is recommended to be the filename of the original upload.
    public var body: String

    /*
     /// Required if the file is encrypted.
     ///
     /// Information on the encrypted file, as specified in <doc:End-to-end-encryption>.
     public var file: EncryptedFile?
      */

    /// The original filename of the uploaded file.
    public var filename: String?

    /// Information about the file referred to in url.
    public var info: FileInfo?

    /// Required if the file is unencrypted. The URL (typically MXC URI) to the file.
    public var url: String?

    public var relatesTo: MatrixMessageRelatesTo?

    enum CodingKeys: String, CodingKey {
        case body
        case filename
        case info
        case url
        case relatesTo = "m.relates_to"
    }

    public struct FileInfo: Codable {
        // TODO: UTType?
        /// The mimetype of the image, e.g. image/jpeg.
        public var mimetype: String?

        /// Size of the image in bytes.
        public var size: Int?

        /*
         /// Information on the encrypted thumbnail file, as specified in <doc:End-to-end-encryption>.
         ///
         /// Only present if the thumbnail is encrypted.
         public var thumbnailFile: EncryptedFile?
         */

        /// Metadata about the image referred to in thumbnail_url.
        public var thumbnailInfo: MatrixMessageImage.ImageInfo.ThumbnailInfo?

        /// The URL (typically MXC URI) to a thumbnail of the image.
        ///
        /// Only present if the thumbnail is unencrypted.
        public var thumbnailURL: String?

        enum CodingKeys: String, CodingKey {
            case mimetype, size
            // case thumbnailFile = "thumbnail_file"
            case thumbnailInfo = "thumbnail_info"
            case thumbnailURL = "thumbnail_url"
        }
    }
}

/// This message represents a single audio clip.
public struct MatrixMessageAudio: MatrixMessageType {
    public static let type: String = "m.audio"

    ///  description of the audio e.g. ‘Bee Gees - Stayin’ Alive', or some kind of content description
    ///  for accessibility e.g. ‘audio attachment’.
    public var body: String

    /*
     /// Required if the file is encrypted.
     ///
     /// Information on the encrypted file, as specified in <doc:End-to-end-encryption>.
     public var file: EncryptedFile?
      */

    /// Metadata for the audio clip referred to in url.
    public var info: AudioInfo?

    /// Required if the file is unencrypted. The URL (typically MXC URI) to the audio clip.
    public var url: String?

    public var relatesTo: MatrixMessageRelatesTo?

    enum CodingKeys: String, CodingKey {
        case body
        case info
        case url
        case relatesTo = "m.relates_to"
    }

    public struct AudioInfo: Codable {
        /// The duration of the audio in milliseconds.
        public var duration: Int?

        // TODO: UTType?
        /// The mimetype of the image, e.g. image/jpeg.
        public var mimetype: String?

        /// The size of the audio clip in bytes.
        public var size: Int?
    }
}

/// This message represents a real-world location.
public struct MatrixMessageLocation: MatrixMessageType {
    public static let type: String = "m.location"

    /// A description of the location e.g. ‘Big Ben, London, UK’, or some kind of content
    /// description for accessibility e.g. ‘location attachment’.
    public var body: String

    /// A [geo URI (RFC5870)](https://datatracker.ietf.org/doc/html/rfc5870)
    /// representing this location.
    public var geoURI: String

    public var info: LocationInfo?

    public var relatesTo: MatrixMessageRelatesTo?

    enum CodingKeys: String, CodingKey {
        case body
        case info
        case geoURI = "geo_uri"
        case relatesTo = "m.relates_to"
    }

    public struct LocationInfo: Codable {
        /*
         /// Information on the encrypted thumbnail file, as specified in <doc:End-to-end-encryption>.
         ///
         /// Only present if the thumbnail is encrypted.
         public var thumbnailFile: EncryptedFile?
         */

        /// Metadata about the image referred to in thumbnail_url.
        public var thumbnailInfo: MatrixMessageImage.ImageInfo.ThumbnailInfo?

        /// The URL (typically MXC URI) to a thumbnail of the image.
        ///
        /// Only present if the thumbnail is unencrypted.
        public var thumbnailURL: String?

        enum CodingKeys: String, CodingKey {
            // case thumbnailFile = "thumbnail_file"
            case thumbnailInfo = "thumbnail_info"
            case thumbnailURL = "thumbnail_url"
        }
    }
}

/// This message represents a single video clip.
public struct MatrixMessageVideo: MatrixMessageType {
    public static let type: String = "m.video"

    /// A description of the video e.g. ‘Gangnam style’, or some kind of
    /// content description for accessibility e.g. ‘video attachment’.
    public var body: String

    /*
     /// Required if the file is encrypted.
     ///
     /// Information on the encrypted file, as specified in <doc:End-to-end-encryption>.
     public var file: EncryptedFile?
      */

    /// Metadata about the video clip referred to in url.
    public var info: VideoInfo?

    /// Required if the file is unencrypted. The URL (typically MXC URI) to the video clip.
    public var url: String?

    public var relatesTo: MatrixMessageRelatesTo?

    enum CodingKeys: String, CodingKey {
        case body
        case info
        case url
        case relatesTo = "m.relates_to"
    }

    public struct VideoInfo: Codable {
        /// The duration of the video in milliseconds.
        public var duration: Int?

        /// The height of the video in pixels.
        public var height: Int?

        /// The width of the video in pixels.
        public var width: Int?

        // TODO: UTType?
        /// The mimetype of the video, e.g. video/mp4.
        public var mimetype: String?

        /// Size of the video in bytes.
        public var size: Int?

        /*
         /// Information on the encrypted thumbnail file, as specified in <doc:End-to-end-encryption>.
         ///
         /// Only present if the thumbnail is encrypted.
         public var thumbnailFile: EncryptedFile?
         */

        /// Metadata about the image referred to in thumbnail_url.
        public var thumbnailInfo: MatrixMessageImage.ImageInfo.ThumbnailInfo?

        /// The URL (typically MXC URI) to a thumbnail of the image.
        ///
        /// Only present if the thumbnail is unencrypted.
        public var thumbnailUrl: String?

        enum CodingKeys: String, CodingKey {
            case duration
            case height = "h"
            case width = "w"
            case mimetype, size
            // case thumbnailFile = "thumbnail_file"
            case thumbnailInfo = "thumbnail_info"
            case thumbnailUrl = "thumbnail_url"
        }
    }
}
