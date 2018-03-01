#include <stdlib.h>
#include <nfc/nfc.h>
#include <openssl/sha.h>

int
main(int argc, const char *argv[])
{
  nfc_device *pnd;
  nfc_target nt;

  // Allocate only a pointer to nfc_context
  nfc_context *context;

  // Initialize libnfc and set the nfc_context
  nfc_init(&context);
  if (context == NULL)
    exit(EXIT_FAILURE);

  // Display libnfc version
  (void)argc;

  // Open, using the first available NFC device which can be in order of selection:
  //   - default device specified using environment variable or
  //   - first specified device in libnfc.conf (/etc/nfc) or
  //   - first specified device in device-configuration directory (/etc/nfc/devices.d) or
  //   - first auto-detected (if feature is not disabled in libnfc.conf) device
  pnd = nfc_open(context, NULL);

  if (pnd == NULL)
    exit(EXIT_FAILURE);

  // Set opened NFC device to initiator mode
  if (nfc_initiator_init(pnd) < 0) {
    nfc_perror(pnd, "nfc_initiator_init");
    exit(EXIT_FAILURE);
  }

  // Poll for a ISO14443A (MIFARE) tag
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

  nfc_close(pnd); // Close NFC device
  nfc_exit(context); // Release the context
  exit(EXIT_SUCCESS);
}
