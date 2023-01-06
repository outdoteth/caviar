const fs = require("fs");
const path = require("path");
const { defaultAbiCoder } = require("ethers/lib/utils");
const { StandardMerkleTree } = require("@openzeppelin/merkle-tree");

const generateMerkleProof = (tokenId, tokenIds) => {
  const tree = StandardMerkleTree.of(
    tokenIds.map((v) => [v]),
    ["uint256"]
  );

  const proof = tree.getProof([tokenId]);

  return proof;
};

const main = async () => {
  const rankingFile = process.argv[2];
  const tokenId = process.argv[3];

  const { tokenIds } = JSON.parse(
    fs.readFileSync(path.join(__dirname, "../rankings", rankingFile), {
      encoding: "utf8",
    })
  );

  const merkleProof = generateMerkleProof(tokenId, tokenIds);

  process.stdout.write(defaultAbiCoder.encode(["bytes32[]"], [merkleProof]));
  process.exit();
};

main();

module.exports = { generateMerkleProof };
