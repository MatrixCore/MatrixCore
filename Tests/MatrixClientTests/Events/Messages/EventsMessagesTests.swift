//
//  File.swift
//
//
//  Created by Finn Behrens on 13.03.22.
//

import Foundation
@testable import MatrixClient
import XCTest

final class EventsMessagesTests: XCTestCase {
    func testMessageDecodeText() throws {
        let data = Data("""
        {
            "content": {
                "body": "This is an example text message",
                "format": "org.matrix.custom.html",
                "formatted_body": "<p>This is an example text message</p>",
                "msgtype": "m.text"
            }
        }
        """.utf8)

        let foo = try MatrixMessageContainer(fromJSON: data)

        let bar = foo.content as! MatrixMessageText

        XCTAssertEqual(bar.format, "org.matrix.custom.html")
        XCTAssertEqual(bar.formattedBody, "<p>This is an example text message</p>")
        XCTAssertEqual(bar.body, "This is an example text message")
    }

    func testMessageDecodeEmote() throws {
        let data = Data("""
        {
            "content": {
                "body": "thinks this is an example emote",
                "format": "org.matrix.custom.html",
                "formatted_body": "thinks <b>this</b> is an example emote",
                "msgtype": "m.emote"
            }
        }
        """.utf8)

        let decoded = try MatrixMessageContainer(fromJSON: data)

        guard let decoded = decoded.content as? MatrixMessageEmote else {
            XCTFail()
            return
        }

        XCTAssertEqual(decoded.body, "thinks this is an example emote")
        XCTAssertEqual(decoded.formattedBody, "thinks <b>this</b> is an example emote")
        XCTAssertEqual(decoded.format, "org.matrix.custom.html")
    }

    func testMessageDecodeNotice() throws {
        let data = Data("""
        {
        "content": {
        "body": "This is an example notice",
        "format": "org.matrix.custom.html",
        "formatted_body": "This is an <strong>example</strong> notice",
        "msgtype": "m.notice"
        },
        }
        """.utf8)

        let decoded = try MatrixMessageContainer(fromJSON: data)

        guard let decoded = decoded.content as? MatrixMessageNotice else {
            XCTFail()
            return
        }

        XCTAssertEqual(decoded.format, "org.matrix.custom.html")
        XCTAssertEqual(decoded.body, "This is an example notice")
        XCTAssertEqual(decoded.formattedBody, "This is an <strong>example</strong> notice")
    }

    func testMessageDecodeImage() throws {
        let data = Data("""
        {
            "content": {
                "body": "filename.jpg",
                "info": {
                    "h": 398,
                    "mimetype": "image/jpeg",
                    "size": 31037,
                    "w": 394
                },
                "msgtype": "m.image",
                "url": "mxc://example.org/JWEIFJgwEIhweiWJE"
            }
        }
        """.utf8)

        let decoded = try MatrixMessageContainer(fromJSON: data)

        guard let decoded = decoded.content as? MatrixMessageImage else {
            XCTFail()
            return
        }

        XCTAssertEqual(decoded.body, "filename.jpg")
        XCTAssertEqual(decoded.url, "mxc://example.org/JWEIFJgwEIhweiWJE")
        XCTAssertEqual(decoded.info?.height, 398)
        XCTAssertEqual(decoded.info?.width, 394)
        XCTAssertEqual(decoded.info?.mimetype, "image/jpeg")
        XCTAssertEqual(decoded.info?.size, 31037)
    }

    func testMessageDecodeFile() throws {
        let data = Data("""
        {
            "content": {
                "body": "something-important.doc",
                "filename": "something-important.doc",
                "info": {
                    "mimetype": "application/msword",
                    "size": 46144
                },
                "msgtype": "m.file",
                "url": "mxc://example.org/FHyPlCeYUSFFxlgbQYZmoEoe"
            }
        }
        """.utf8)

        let decoded = try MatrixMessageContainer(fromJSON: data)

        guard let decoded = decoded.content as? MatrixMessageFile else {
            XCTFail()
            return
        }

        XCTAssertEqual(decoded.body, "something-important.doc")
        XCTAssertEqual(decoded.filename, "something-important.doc")
        XCTAssertEqual(decoded.url, "mxc://example.org/FHyPlCeYUSFFxlgbQYZmoEoe")
        XCTAssertEqual(decoded.info?.mimetype, "application/msword")
        XCTAssertEqual(decoded.info?.size, 46144)
    }

    func testMessageDecodeLocation() throws {
        let data = Data("""
        {
            "content": {
                "body": "Big Ben, London, UK",
                "geo_uri": "geo:51.5008,0.1247",
                "info": {
                    "thumbnail_info": {
                        "h": 300,
                        "mimetype": "image/jpeg",
                        "size": 46144,
                        "w": 300
                    },
                    "thumbnail_url": "mxc://example.org/FHyPlCeYUSFFxlgbQYZmoEoe"
                },
                "msgtype": "m.location"
            }
        }
        """.utf8)

        let decoded = try MatrixMessageContainer(fromJSON: data)

        guard let decoded = decoded.content as? MatrixMessageLocation else {
            XCTFail()
            return
        }

        XCTAssertEqual(decoded.body, "Big Ben, London, UK")
        XCTAssertEqual(decoded.geoURI, "geo:51.5008,0.1247")
        XCTAssertEqual(decoded.info?.thumbnailURL, "mxc://example.org/FHyPlCeYUSFFxlgbQYZmoEoe")
        XCTAssertEqual(decoded.info?.thumbnailInfo?.height, 300)
        XCTAssertEqual(decoded.info?.thumbnailInfo?.width, 300)
        XCTAssertEqual(decoded.info?.thumbnailInfo?.size, 46144)
        XCTAssertEqual(decoded.info?.thumbnailInfo?.mimetype, "image/jpeg")
    }

    func testMessageDecodeVideo() throws {
        let data = Data("""
        {
            "content": {
                "body": "Gangnam Style",
                "info": {
                    "duration": 2140786,
                    "h": 320,
                    "mimetype": "video/mp4",
                    "size": 1563685,
                    "thumbnail_info": {
                        "h": 300,
                        "mimetype": "image/jpeg",
                        "size": 46144,
                        "w": 300
                    },
                    "thumbnail_url": "mxc://example.org/FHyPlCeYUSFFxlgbQYZmoEoe",
                    "w": 480
                },
                "msgtype": "m.video",
                "url": "mxc://example.org/a526eYUSFFxlgbQYZmo442"
            }
        }
        """.utf8)

        let decoded = try MatrixMessageContainer(fromJSON: data)

        guard let decoded = decoded.content as? MatrixMessageVideo else {
            XCTFail()
            return
        }

        XCTAssertEqual(decoded.body, "Gangnam Style")
        XCTAssertEqual(decoded.url, "mxc://example.org/a526eYUSFFxlgbQYZmo442")
        XCTAssertEqual(decoded.info?.duration, 2_140_786)
        XCTAssertEqual(decoded.info?.height, 320)
        XCTAssertEqual(decoded.info?.width, 480)
        XCTAssertEqual(decoded.info?.size, 1_563_685)
        XCTAssertEqual(decoded.info?.mimetype, "video/mp4")
        XCTAssertEqual(decoded.info?.thumbnailUrl, "mxc://example.org/FHyPlCeYUSFFxlgbQYZmoEoe")
        XCTAssertEqual(decoded.info?.thumbnailInfo?.height, 300)
        XCTAssertEqual(decoded.info?.thumbnailInfo?.width, 300)
        XCTAssertEqual(decoded.info?.thumbnailInfo?.size, 46144)
        XCTAssertEqual(decoded.info?.thumbnailInfo?.mimetype, "image/jpeg")
    }

    func testMessageTextRoundTrip() throws {
        let origText = MatrixMessageText(body: "foo", format: "org.matrix.custom.html", formattedBody: "bar")
        let orig = MatrixMessageContainer(content: origText)

        let data = try MatrixClient.encode(orig)

        let new = try MatrixMessageContainer(fromJSON: data)

        guard let new = new.content as? MatrixMessageText else {
            XCTFail()
            return
        }

        XCTAssertEqual(origText.body, new.body)
        XCTAssertEqual(origText.format, new.format)
        XCTAssertEqual(origText.formattedBody, new.formattedBody)
    }
}

struct MatrixMessageContainer: Codable {
    @MatrixCodableMessageType
    public var content: MatrixMessageType

    init(fromJSON data: Data) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        decoder.userInfo[.matrixMessageTypes] = MatrixClient.messageTypes

        let new = try decoder.decode(Self.self, from: data)
        self = new
    }

    public init(content: MatrixMessageType) {
        self.content = content
    }
}
