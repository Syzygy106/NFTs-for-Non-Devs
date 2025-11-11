#!/usr/bin/env node

/**
 * Generate Provenance Hash for NFT Collection
 * 
 * Usage:
 *   node scripts/generateProvenance.js metadata/
 * 
 * Input: Directory containing JSON metadata files
 * Output: Provenance hash (console + provenance.txt)
 * 
 * The provenance hash proves the collection order was predetermined
 * and not manipulated after the sale.
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// Resolve metadata directory:
// 1) CLI arg if provided
// 2) Default to repo assets/metadata
// 3) Fallback to local "metadata" folder
const repoAssetsMetadata = path.resolve(__dirname, "../../../assets/metadata");
let metadataDir = process.argv[2] || repoAssetsMetadata;
if (!fs.existsSync(metadataDir)) {
  metadataDir = "metadata";
}

if (!fs.existsSync(metadataDir)) {
  console.error(`❌ Error: Directory "${metadataDir}" not found!`);
  console.log('\n📝 Create a metadata directory with JSON files:');
  console.log('   metadata/0000.json');
  console.log('   metadata/0001.json');
  console.log('   metadata/0002.json');
  console.log('   ...\n');
  process.exit(1);
}

try {
  console.log(`\n📂 Using metadata directory: ${metadataDir}\n`);
  // Read all JSON files from metadata directory
  const files = fs.readdirSync(metadataDir)
    .filter(f => f.endsWith('.json'))
    .sort(); // Sort to ensure consistent order

  if (files.length === 0) {
    console.error(`❌ Error: No JSON files found in "${metadataDir}"!`);
    process.exit(1);
  }

  console.log('\n📊 Processing Metadata Files...\n');

  // Hash each file
  const fileHashes = [];
  files.forEach((file, index) => {
    const filePath = path.join(metadataDir, file);
    const content = fs.readFileSync(filePath);
    const hash = crypto.createHash('sha256').update(content).digest('hex');
    fileHashes.push(hash);
    
    // Show progress
    if (index < 5 || index === files.length - 1) {
      console.log(`   ${index.toString().padStart(4, ' ')}. ${file} → ${hash.slice(0, 16)}...`);
    } else if (index === 5) {
      console.log(`   ... (${files.length - 6} more files)`);
    }
  });

  // Combine all hashes and create final provenance hash
  const combined = fileHashes.join('');
  const provenanceHash = '0x' + crypto.createHash('sha256').update(combined).digest('hex');

  // Create detailed output
  const output = {
    provenanceHash: provenanceHash,
    totalFiles: files.length,
    fileHashes: fileHashes,
    files: files,
    generatedAt: new Date().toISOString(),
    algorithm: 'SHA256 of concatenated SHA256 hashes'
  };

  // Save results
  fs.writeFileSync('provenance.txt', provenanceHash);
  fs.writeFileSync('provenance_data.json', JSON.stringify(output, null, 2));

  // Display results
  console.log('\n✅ Provenance Hash Generated!\n');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('📊 Statistics:');
  console.log(`   Total Files: ${files.length}`);
  console.log(`   Algorithm: SHA256 of concatenated SHA256 hashes`);
  console.log('\n🔐 Provenance Hash:');
  console.log(`   ${provenanceHash}`);
  console.log('\n💾 Files Created:');
  console.log('   • provenance.txt (hash only)');
  console.log('   • provenance_data.json (full data for verification)');
  console.log('\n📝 Next Steps:');
  console.log('   1. Copy the Provenance Hash above');
  console.log('   2. Add to .env: PROVENANCE_HASH=' + provenanceHash);
  console.log('   3. KEEP provenance_data.json for post-reveal verification');
  console.log('   4. Publish this hash BEFORE your sale starts');
  console.log('\n⚠️  IMPORTANT:');
  console.log('   • This hash MUST be set BEFORE minting begins');
  console.log('   • It proves you didn\'t manipulate token rarity after sale');
  console.log('   • Users can verify this hash after reveal');
  console.log('\n🔍 Verification Process (After Reveal):');
  console.log('   1. User downloads revealed metadata from IPFS');
  console.log('   2. User runs this script on downloaded metadata');
  console.log('   3. User compares generated hash with on-chain PROVENANCE_HASH');
  console.log('   4. If they match → Collection integrity verified ✅');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  // Show hash comparison visualization
  console.log('📋 How to Verify (for users):');
  console.log('   node scripts/generateProvenance.js downloaded_metadata/');
  console.log('   cast call $CONTRACT "PROVENANCE_HASH()(bytes32)"');
  console.log('   # Both should output: ' + provenanceHash + '\n');

} catch (error) {
  console.error('❌ Error:', error.message);
  process.exit(1);
}

