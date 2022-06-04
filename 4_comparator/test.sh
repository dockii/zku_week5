set -e
if [ -f ../powersOfTau28_hez_final_16.ptau ]; then
    echo "powersOfTau28_hez_final_16.ptau already exists. Skipping."
else
    pushd ../
    echo 'Downloading powersOfTau28_hez_final_16.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_16.ptau
    popd
fi

echo "compiling force_equal_if_enabled"
circom force_equal_if_enabled.circom --r1cs --wasm --sym

cd force_equal_if_enabled_js;
node generate_witness.js force_equal_if_enabled.wasm ../input.json ../witness.wtns
cd ..
#
snarkjs groth16 setup force_equal_if_enabled.r1cs ../powersOfTau28_hez_final_16.ptau force_equal_if_enabled_0000.zkey
echo "test" | snarkjs zkey contribute force_equal_if_enabled_0000.zkey force_equal_if_enabled_final.zkey --name="1st Contributor Name" -v
snarkjs zkey verify force_equal_if_enabled.r1cs ../powersOfTau28_hez_final_16.ptau force_equal_if_enabled_final.zkey
snarkjs zkey export verificationkey force_equal_if_enabled_final.zkey verification_key.json
snarkjs groth16 prove force_equal_if_enabled_final.zkey witness.wtns proof.json public.json
snarkjs groth16 verify verification_key.json public.json proof.json

### this circuit will not compile because the constraint is generated inside if condition that depends on the unknown (the `enabled` input)
echo "compiling bad_force_equal_if_enabled"
circom bad_force_equal_if_enabled.circom --r1cs --wasm --sym

# cd bad_force_equal_if_enabled_js;
# node generate_witness.js bad_force_equal_if_enabled.wasm ../input.json ../witness.wtns
# cd ..
# #
# snarkjs groth16 setup bad_force_equal_if_enabled.r1cs ../powersOfTau28_hez_final_16.ptau bad_force_equal_if_enabled_0000.zkey
# echo "test" | snarkjs zkey contribute bad_force_equal_if_enabled_0000.zkey bad_force_equal_if_enabled_final.zkey --name="1st Contributor Name" -v
# snarkjs zkey verify bad_force_equal_if_enabled.r1cs ../powersOfTau28_hez_final_16.ptau bad_force_equal_if_enabled_final.zkey
# snarkjs zkey export verificationkey bad_force_equal_if_enabled_final.zkey verification_key.json
# snarkjs groth16 prove bad_force_equal_if_enabled_final.zkey witness.wtns proof.json public.json
# snarkjs groth16 verify verification_key.json public.json proof.json
