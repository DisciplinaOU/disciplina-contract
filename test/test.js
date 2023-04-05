const Disciplina = artifacts.require('../contracts/Disciplina.sol');
const fs = require('fs');

it('constructs the valid Disciplina private header', async function () {
    var test = await Disciplina.new();
    var headerCbor = fs.readFileSync('assets/serialised-header.cbor');
    var {
        prevBlock,
        bodyProof: { root, transactionsNum }
    } = JSON.parse(fs.readFileSync('assets/serialised-header.json', 'utf-8'));

    var prevHash = Buffer.from(prevBlock, 'hex');
    var merkleRoot = Buffer.from(root, 'hex');

    var result = new Buffer.from((await test.constructPrivateHeader(prevHash, merkleRoot, transactionsNum)).slice(2), 'hex');
    expect(result).to.deep.equal(headerCbor);
});
