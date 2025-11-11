#!/usr/bin/env node

/**
 * Generate Merkle Root for Whitelist
 * 
 * Usage:
 *   npm install merkletreejs keccak256
 *   node scripts/generateWhitelist.js whitelist.txt
 * 
 * Input: Text file with one address per line
 * Output: Merkle root (console + merkle_root.txt)
 */

const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');
const fs = require('fs');

// Get input file from command line
const inputFile = process.argv[2] || 'whitelist.txt';

if (!fs.existsSync(inputFile)) {
  console.error(`❌ Error: File "${inputFile}" not found!`);
  console.log('\n📝 Create a whitelist.txt file with one address per line:');
  console.log('   0x1234567890123456789012345678901234567890');
  console.log('   0xabcdefabcdefabcdefabcdefabcdefabcdefabcd');
  console.log('   ...\n');
  process.exit(1);
}

try {
  // Read and parse addresses
  const addresses = fs.readFileSync(inputFile, 'utf8')
    .split('\n')
    .map(line => line.trim())
    .filter(line => line.length > 0 && line.startsWith('0x'))
    .map(addr => addr.toLowerCase());

  if (addresses.length === 0) {
    console.error('❌ Error: No valid addresses found in file!');
    process.exit(1);
  }

  // Create Merkle tree
  const leaves = addresses.map(addr => keccak256(addr));
  const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });
  const root = '0x' + tree.getRoot().toString('hex');

  // Save results
  const output = {
    merkleRoot: root,
    totalAddresses: addresses.length,
    addresses: addresses,
    tree: tree.toString()
  };

  fs.writeFileSync('merkle_root.txt', root);
  fs.writeFileSync('whitelist_data.json', JSON.stringify(output, null, 2));

  // Display results
  console.log('\n✅ Whitelist Merkle Root Generated!\n');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('📊 Statistics:');
  console.log(`   Total Addresses: ${addresses.length}`);
  console.log('\n🔐 Merkle Root:');
  console.log(`   ${root}`);
  console.log('\n💾 Files Created:');
  console.log('   • merkle_root.txt (root only)');
  console.log('   • whitelist_data.json (full data)');
  console.log('\n📝 Next Steps:');
  console.log('   1. Copy the Merkle Root above');
  console.log('   2. Add to .env: WHITELIST_MERKLE_ROOT=' + root);
  console.log('   3. Use generateProof.js to create proofs for users');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  // Show first few addresses as sample
  if (addresses.length > 0) {
    console.log('📋 Sample Addresses (first 5):');
    addresses.slice(0, 5).forEach((addr, i) => {
      console.log(`   ${i + 1}. ${addr}`);
    });
    if (addresses.length > 5) {
      console.log(`   ... and ${addresses.length - 5} more\n`);
    }
  }

} catch (error) {
  console.error('❌ Error:', error.message);
  process.exit(1);
}

