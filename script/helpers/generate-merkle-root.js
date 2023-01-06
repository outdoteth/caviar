const fs = require("fs");
const path = require("path");
const { StandardMerkleTree } = require("@openzeppelin/merkle-tree");

const generateMerkleRoot = (rankingFile) => {
  const { tokenIds } = JSON.parse(
    fs.readFileSync(path.join(__dirname, "../rankings", rankingFile), {
      encoding: "utf8",
    })
  );

  const tree = StandardMerkleTree.of(
    tokenIds.map((v) => [v]),
    ["uint256"]
  );

  return tree.root;
};

const main = async () => {
  const rankingFile = process.argv[2];
  const merkleRoot = generateMerkleRoot(rankingFile);

  process.stdout.write(merkleRoot);
  process.exit();
};

main();
