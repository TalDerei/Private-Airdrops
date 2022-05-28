# zkDrop: Private Lottery Airdrop System with Zero-Knowledge Proofs<br />
<p align="center">
<br />
Tal Derei <br />
Zero-Knowledge University (ZKU)<br />
April 2022<br />
</p>

## Motivation<br />
To motivate this construction, we must map out the current landscape of public crypto airdrops. To encourage participation in their protocol, blockchain-based projects typically airdrop free ERC-20 tokens to early adopters and active participants in their community. This system of distributing ERC-20 tokens for governance purposes (i.e. token-voting mechanism) is flawed. Participating in these airdrop events requires revealing your public wallet address (i.e. public key), and thereby doxxing your financial history associated with your public identity. Linking your public metamask address to a web3 platform reveals everything about yourself, since your public address is a gateway to publicly available transaction history on the blockchain. Consider, for example, if a protocol decides to blacklist your address from being eligible for an airdrop based on your DAO voting history? This warranted a private airdrop system with a lottery service enabling users to claim ERC-20/ERC-721 airdrops completely anonymously, without revealing their primary public keys (i.e. public identities). Additionally, the private airdrop system incorperates a lottery system layer, allowing for verifiable randomness and fairness mechanisms for drawing lottery winners. Private lotteries are essential for applications that reward users on their participation while keeping their identities anonymous.<br />

The zero knowledge aspect comes from the fact that proof verification happens without associating a users address to the commitment they provided. The user can prove to the smart contract that they know some key/secret pair corresponding to a commitment without revealing which commitment they're associated with. This allows a user to collect an airdrop from any wallet (e.g. burner wallet) by supplying their key/secret pair that generates a valid commitment. Each commitment acts as a lottery ticket, and your secret/key pair serves as your identity to retrieve the prize!	


The project is currently deployed on [Harmony Mainnet](https://explorer.harmony.one/) and the frontend is hosted on [Vercel](https://github.com/vercel/vercel).

**Production Link:**

https://zk-drop.vercel.app/

**zkDrop Demo Video:**

https://www.youtube.com/watch?v=dwbhJYUpA2E

**Github Gist:**

https://gist.github.com/TalDerei/513712a2fd147183b6cbd8a8c4ea3ac1

## Project Structure

```Build```

Hermez Power's of Tau Ceremony, circuit (wasm file) and verification key

```Circuits```

Circom circuits with merkle-tree functionalty

```Contracts```

Solidity smart contracts 

```Frontend```

Frontend code built on a React/NextJS framework and hosted on Vercel

```Scripts```

Runs Plonk prover and deploys smart contracts

```Public```

List of sample keys, secrets, and commitments

## Tools and Resources

- Circom 2 (ZK-SNARK Compiler)<br />
- SnarkyJS (Typescript/Javascript framework for zk-SNARKs)<br />
- Tornado Cash<br />
- React / Next.js / Vercel <br />
- Ether.js / Hardhat / Ganache<br />

## Technical Specifications <br />

**_Merkle-Tree Construction_**<br />
**1.** Construct a merkle tree of commitments, where commitment = hash(key, secret), as lottery entries for the airdrop. These commitments are stored off-chain for now.<br />
**2.** Recursively hash merkle tree and publish merkle root hash on-chain, serving as a vector commitment<br />
**3.** User submits merkle path proof and claims airdrop, without revealing which commitment is associated with their public key. Everytime a user enters an input (i.e. the key/secret pair), it generates a witness that serves as an input into the proof generation algorithm. A Pederson hash function is used to create the commitments, which can be swapped for a more efficient Poseidon hash function in the future.<br />
<br />
**_Circuits: Proof Generation and Verification_**<br />
The circom circuit references and builds on a simplified version of the Tornado Cash: https://github.com/chnejohnson/simple-tornado. The circuits (currently 2^16 constraints) are compiled and proven with Plonk.  A verifier contract handling the proof verification on-chain is then automatically generated by circom/SnarkyJS. 

Note, the zkey file is currently 60 mb using Plonk and Hermez's Powers of Tau ceremony. Modifying my circuit to support more commitments involves increasing the number of constraints and size of the zkey file respectively. If pushing a larger zkey file through the browser becomes non-trivial, the codebase supports Groth16, requiring a trusted setup (i.e. Power of Tau MPC Ceremony). 
<br />
<br />
**_On-Chain Solidity Contract_**<br />
The airdrop contracts are based on a _Factory Design Pattern_ desribed by [Openzeppelin](https://soliditydeveloper.com/clonefactory), responsible for [1] calling the compiled proof-verification contract to verify the proof, [2] checking against the nullifier set to prevent double-withdrawals, [3] redeeming the airdrop. The lottery component additionally adds verifiable fairness by incorperating a pseudorandom number generator based on _block.difficulty_ and _block.timestamp_ for choosing commitments to be apart of the eligibility set, i.e. a subset of total commitments eligibile to collect the airdrop. 
<br />
<br />
**_Long-Term Considerations_**<br />
The system can be extended to incorporate a simple reputation service meeting certain on-chain requirements (i.e. checking whether users have more than 10 ONE in their wallet). This requires a combination of semaphores and some external oracle service (trusted third-party entity) verifying the validity of the on-chain information before creating the proof. Currently, the system collects commitments by submitting them through a centralized provider like 
[Github Gist](https://gist.github.com/TalDerei/513712a2fd147183b6cbd8a8c4ea3ac1). Swapping out the pseudorandomness mechanism in the smart contracts with [Harmony VRF](https://docs.harmony.one/home/developers/tools/harmony-vrf) is in the pipeline as well.
<br />


## Configuration and Setup <br />
Run "**_npm install_**" inside the root directory in order to install the proper dependencies. Then navigate to ```Frontend```, execute "**_npm install_**", and follow the steps outlined in the readme.

1\. **Execute Scripts:**

- `scripts` folder contains the following executeable scripts and typescript files:
  * **0_groth16.sh**: groth16 prover
  * **0_plonk.sh**: plonk prover
  * **1_commitments.ts**: generates sample key/secret pairs + commitments
  * **2_deploy.ts**: deploys solidity smart contracts
- Inside the root directory, add a "**.env**" file with your metamask private key. Then run "**sh scripts/0_plonk.sh**" that generates a `build` folder in the root directory containing the compiled plonk circuit, verification smart contract, and verifier key. It then copies over the circuit_final.zkey and circuit.wasm (web friendly circuit representation in web assembly) to the `frontend/public` folder, making it available to the browser.
- Inside the root directory, then delete the existing sample commitments .txt files in `public`, and run "**npx hardhat run scripts/1_commitments.ts --network localhost**" which generates the sample commitments that will be deployed in the smart contract as calldata. 
- Inside the root directory, then run "**npx hardhat run scripts/2_deploy.ts --network localhost**" to deploy the sample smart contracts on localhost. You can change 'localhost' to either 'testnet' or 'mainnet' to deploy on the [Harmony Testnet](explorer.pops.one) or [Harmony Mainnet](explorer.harmony.one) respectively. The typscript file deploys:
  * ERC-20 contract (ERC20PresetFixedSupply Openzeppelin Contract)
  * NFT contract (MintingContract.sol)
  * Verifier contract (MerkVerifier.sol)
  * Factory contract (PrivateLotteryFactory.sol)
  * Implementation contract (PrivateLottery.sol)
  * Proxy contract (i.e. factory contract deploys instance of implementation contract)

These contracts are structured according to the [Factory Design Pattern](https://soliditydeveloper.com/clonefactory). After deploying the contracts, the root hash and commitments are stored on-chain in order to reconstruct state. The typescript file then interacts with the proxy contract address to randomly select a pool of commitments stored in the smart contract's calldata to be part of the eligibility set (i.e. subset of the commitments eligible to collect an airdrop). 

2\. **Testing on Localhost:**

- Start up a local ganache client or run "**npx hardhat node**" in a seperate terminal to spin up a local hardhat blockchain network. Then start up the developement server with "npm run dev" on the `frontend` in a seperate terminal window, and navigate to "http://localhost:3000/airdrop/test". The UI page contains 3 buttons:
  *  "Calculate Commitment", computes a commitment by hashing two private values (a secret and a nullifier), and checks the commitment against a merkle tree of commitments by generating a merkle path proof.
  *  "Calculate Proof", generates the proof calldata by using the public verification key (circuit_final.zkey), compiled zero knowledge circuit (circuit.wasm), private key/secret pair used to construct the commitment, and nullifierHash to avoid double spending. 
  *  "Collect Drop", passes the proof and nullifierHash to the verification smart contract. 

## Credits and Related Work<br />

Credit to A16Z (https://github.com/a16z/zkp-merkle-airdrop-lib). This application modifies the A16Z core repo by incorperating the cloned factory and proxy patterns to the smart contracts and adding a lottery system, implementing ERC-721 (in addition to ERC-20) private airdrops, and interactive NextJS UI.
