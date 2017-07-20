# OAIharvest

This is a shell script that is intended to harvest entire OAI sets or repositories.  Each harvest request might return output which includes a resumptionToken, and this resumptionToken is used to identify the next segment to harvest.  This script automatically parses the output for the resumptionTokens and submits the follow-up requests until no additional data remains to be retrieved.

It needs a lot of work.  It harvests the output without problems, but is missing a number of nifty features that would make it a worthwhile addition to the average OAI-geek's ~/bin directory.
