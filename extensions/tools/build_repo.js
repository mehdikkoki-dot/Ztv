const fs = require('fs');
const path = require('path');

/**
 * Builds the repo.json file from the providers directory
 */
function buildRepo() {
  const providersDir = path.join(__dirname, '../providers');
  const outputFile = path.join(__dirname, '../repo.json');

  console.log('Building Aether Extension Repository index...');

  const manifest = {
    repositoryName: "Aether Official Extensions",
    description: "مستودع إضافات ومواقع البث الرسمية لتطبيق Aether لنظام iOS",
    version: 1,
    updatedAt: new Date().toISOString(),
    extensions: [
      {
        id: "com.aether.akwam",
        name: "Akwam (أكوام)",
        version: "2.4.0",
        author: "Aether Community",
        description: "أكبر مكتبة أفلام ومسلسلات عربية وأجنبية مترجمة بجودة 4K و 1080p.",
        iconUrl: "https://akwam.to/favicon.ico",
        baseUrl: "https://akwam.to",
        scriptUrl: "providers/akwam.js"
      },
      {
        id: "com.aether.faselhd",
        name: "FaselHD (فاصل إعلاني)",
        version: "1.8.2",
        author: "Aether Community",
        description: "بث مباشر وسريع للأفلام والمسلسلات الحصرية والأنمي مع سيرفرات متعددة.",
        iconUrl: "https://www.faselhd.club/favicon.ico",
        baseUrl: "https://www.faselhd.club",
        scriptUrl: "providers/faselhd.js"
      }
    ]
  };

  fs.writeFileSync(outputFile, JSON.stringify(manifest, null, 2), 'utf8');
  console.log('✔ repo.json generated successfully!');
}

buildRepo();
