#compiles the circuit
circom root.circom --r1cs --wasm --sym --c

# generate executables
node ./root_js/generate_witness.js ./root_js/root.wasm input.json witness.wtns

# start powers of tau ceremony
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v

# add secrets to the powers of tau
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v

# start powers of tau ceremony phase 2
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v

# generate proofs and verification keys
snarkjs groth16 setup root.r1cs pot12_final.ptau root_0000.zkey

# add secrets to the powers of tau
snarkjs zkey contribute root_0000.zkey root_0001.zkey --name="1st Contributor Name" -v

# exports verification keys
snarkjs zkey export verificationkey root_0001.zkey verification_key.json

# exports verification keys
snarkjs groth16 prove root_0001.zkey witness.wtns proof.json public.json

# verifies everything is correct
snarkjs groth16 verify verification_key.json public.json proof.json