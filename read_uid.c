#include <stdlib.h>
#include <nfc/nfc.h>
#include <openssl/sha.h>

int main() {
  nfc_device *pnd;
  nfc_target nt;
  nfc_context *context;

  nfc_init(&context);
  if (context == NULL)
    exit(EXIT_FAILURE);

  pnd = nfc_open(context, NULL);

  if (pnd == NULL)
    exit(EXIT_FAILURE);

  if (nfc_initiator_init(pnd) < 0) {
    nfc_perror(pnd, "nfc_initiator_init");
    exit(EXIT_FAILURE);
  }

  const nfc_modulation nmMifare = {
    .nmt = NMT_ISO14443A,
    .nbr = NBR_106,
  };

  if (nfc_initiator_select_passive_target(pnd, nmMifare, NULL, 0, &nt) > 0) {
    unsigned char hash[SHA256_DIGEST_LENGTH];
    SHA256(nt.nti.nai.abtUid, nt.nti.nai.szUidLen, hash);

    for (int szPos = 0; szPos < SHA256_DIGEST_LENGTH; szPos++)
      printf("%02x", hash[szPos]);
  }

  nfc_close(pnd);
  nfc_exit(context);
  exit(EXIT_SUCCESS);
}
