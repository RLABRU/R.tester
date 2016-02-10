-- Fake Sense codes that complement original codes.
FakeSense  = {
-- Request aborted by R.tester core -----------------
['0DEFC0DE'] = 'Request aborted by R.tester core — OFFLINE MODE',
['07270000'] = 'Request aborted by R.tester core — WRITE PROTECTION ACTIVE',
['052602F0'] = 'Request aborted by R.tester core — BUFFER TOO BIG TO TRANSFER',
['052602F1'] = 'Request aborted by R.tester core — BUFFER ALLOCATION ERROR',
['052602F8'] = 'Request aborted by R.tester core — BAD LSI REQUEST - INVALID PARAMETER',
['BAD00000'] = 'Request aborted by R.tester core — DEVICE LOST',
-- Request aborted by driver --------------------------
['0BADC0DE'] = 'Request aborted by driver — UNKNOWN REASON',
['0FADDEAD'] = 'Request aborted by driver — DEVICE LOST',
['052000E0'] = 'Request aborted by driver — INVALID FUNCTION',
['052602E0'] = 'Request aborted by driver — INVALID PARAMETER',
['050006E0'] = 'Request aborted by driver — DEVICE I/O ERROR'
}