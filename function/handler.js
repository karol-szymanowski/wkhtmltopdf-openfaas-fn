"use strict";

const wkhtmltopdf = require('wkhtmltopdf');
const MemoryStream = require('memorystream');

module.exports = async (event, context) => {
    const memStream = new MemoryStream();
    const html_utf8 = new Buffer(event.html_base64, 'base64').toString('utf8');
    wkhtmltopdf(html_utf8, event.options, (code, signal) => {
        context.done(null, { pdf_base64: memStream.read().toString('base64') });
    }).pipe(memStream);
}
