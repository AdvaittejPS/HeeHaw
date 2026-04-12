#include <stdio.h>
#include <stdlib.h>
#include <time.h>

typedef unsigned char byte;
typedef unsigned int word;

// External function from the OpenCores AES C-model
void encrypt_128_key_expand_inline_no_branch(word state[], word key[]);

word rand_word() {
    word w = 0;
    int i;
    for(i=0; i<4; i++) {
        word x = rand() & 255;
        w = (w << 8) | x;
    }
    return w;
}

void rand_word_array(word w[], int bit_num) {
    int word_num = bit_num / 32;
    int i;
    for(i=0; i<word_num; i++)
        w[i] = rand_word();
}

// MODIFIED: Prints raw hex without the Verilog bit prefixes so $fscanf can read it
void fprint_raw_hex(FILE *fp, word w[], int bit_num) {
    int byte_num = bit_num / 8;
    int i;
    byte *b = (byte *)w;
    for(i=0; i<byte_num; i++) {
        fprintf(fp, "%02x", b[i]);
    }
}

int main() {
    const int num_case = 2000; // Matches our SV stress test length
    int bit_num = 128;
    int i;
    word state[4];
    word key[4]; // 128-bit key is 4 words

    // Seed the random number generator
    srand((unsigned int)time(NULL));

    // Open the output file
    FILE *fp = fopen("golden_vectors.txt", "w");
    if (fp == NULL) {
        printf("[!] Error: Could not open golden_vectors.txt for writing.\n");
        return 1;
    }

    printf("[*] Generating %d AES-128 Golden Vectors via C-Model...\n", num_case);

    for(i=0; i<num_case; i++) {
        rand_word_array(state, bit_num);
        rand_word_array(key, bit_num);
        
        // 1. Write the Key
        fprint_raw_hex(fp, key, bit_num);
        fprintf(fp, " ");
        
        // 2. Write the Plaintext (Before encryption modifies the state array)
        fprint_raw_hex(fp, state, bit_num);
        fprintf(fp, " ");
        
        // 3. Perform the mathematical encryption (modifies 'state' in-place)
        encrypt_128_key_expand_inline_no_branch(state, key);
        
        // 4. Write the Expected Ciphertext
        fprint_raw_hex(fp, state, bit_num);
        fprintf(fp, "\n");       
    }
    
    fclose(fp);
    printf("[+] Success! Saved to golden_vectors.txt\n");
    printf("[*] Place this file in your /tb directory for the QuestaSim testbench.\n");
    
    return 0;
}
