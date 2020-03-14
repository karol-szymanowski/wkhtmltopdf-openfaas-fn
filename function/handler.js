"use strict";

const wkhtmltopdf = require('wkhtmltopdf');
const MemoryStream = require('memorystream');

module.exports = async (event, callback) => {
    try {
        const body = JSON.parse(event);
        const memStream = new MemoryStream();
        const html_utf8 = Buffer.from(body.html_base64, 'base64').toString('utf8');
        wkhtmltopdf(html_utf8, body.options, (code, signal) => {
            callback(null, { pdf_base64: memStream.read().toString('base64') });
        }).pipe(memStream);
    } catch (e) {
        callback(e);
    }
};
