#!/usr/bin/env node

/**
 * Generate Merkle Proof for a Specific Address
 * 
 * Usage:
 *   node scripts/generateProof.js 0x1234567890123456789012345678901234567890
 * 
 * Requires: whitelist_data.json (created by generateWhitelist.js)
 * Output: Merkle proof array for the given address
 */

const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');
const fs = require('fs');

// Get address from command line
const userAddress = process.argv[2];

if (!userAddress) {
  console.error('❌ Error: No address provided!');
  console.log('\n📝 Usage:');
  console.log('   node scripts/generateProof.js 0x1234567890123456789012345678901234567890\n');
  process.exit(1);
}

if (!fs.existsSync('whitelist_data.json')) {
  console.error('❌ Error: whitelist_data.json not found!');
  console.log('\n📝 Run generateWhitelist.js first:');
  console.log('   node scripts/generateWhitelist.js whitelist.txt\n');
  process.exit(1);
}

try {
  // Load whitelist data
  const data = JSON.parse(fs.readFileSync('whitelist_data.json', 'utf8'));
  const addressLower = userAddress.toLowerCase();

  // Check if address is whitelisted
  if (!data.addresses.includes(addressLower)) {
    console.error('❌ Error: Address not in whitelist!');
    console.log('\n🔍 Searched for:', addressLower);
    console.log('\n💡 Tip: Make sure the address is in your whitelist.txt file\n');
    process.exit(1);
  }

  // Recreate Merkle tree
  const leaves = data.addresses.map(addr => keccak256(addr));
  const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });

  // Generate proof
  const leaf = keccak256(addressLower);
  const proof = tree.getProof(leaf).map(x => '0x' + x.data.toString('hex'));

  // Verify proof
  const root = tree.getRoot();
  const verified = tree.verify(proof, leaf, root);

  // Display results
  console.log('\n✅ Merkle Proof Generated!\n');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('👤 Address:', userAddress);
  console.log('✓  Status: Whitelisted');
  console.log('🔐 Merkle Root:', data.merkleRoot);
  console.log('\n📜 Proof Array:');
  console.log(JSON.stringify(proof, null, 2));
  console.log('\n🔍 Verification:', verified ? '✅ Valid' : '❌ Invalid');
  console.log('\n📋 For Smart Contract (Solidity):');
  console.log(`   bytes32[] memory proof = new bytes32[](${proof.length});`);
  proof.forEach((p, i) => {
    console.log(`   proof[${i}] = ${p};`);
  });
  console.log('\n📋 For JavaScript (ethers.js):');
  console.log(`   const proof = ${JSON.stringify(proof)};`);
  console.log(`   await contract.mint(quantity, proof, { value: ethers.parseEther("0.1") });`);
  console.log('\n📋 For CLI (cast):');
  console.log(`   cast send $CONTRACT "mint(uint256,bytes32[])" 1 "${JSON.stringify(proof)}" --value 0.1ether`);
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  // Save proof to file
  const proofData = {
    address: userAddress,
    proof: proof,
    merkleRoot: data.merkleRoot,
    verified: verified,
    generatedAt: new Date().toISOString()
  };

  const filename = `proof_${addressLower.slice(2, 8)}.json`;
  fs.writeFileSync(filename, JSON.stringify(proofData, null, 2));
  console.log(`💾 Proof saved to: ${filename}\n`);

} catch (error) {
  console.error('❌ Error:', error.message);
  process.exit(1);
}

