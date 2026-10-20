## "No module named …" although the package was installed
**Cause:** plain `pip` installed into the global Python, not the venv
(and an interrupted pip upgrade had broken the venv's own pip).
**Fix:** always use `python -m pip …`. If pip itself is broken, delete `.venv`
and create it again. Check with `python -m pip show <package>` → Location.

## ADF test connection: "Login failed for user '<token-identified principal>'"
**Seen:** the Data Factory database user was created in the wrong database
(VS Code ran the script on the active, old connection).
**Fix:** check with `SELECT DB_NAME()`; run the script on the right connection
(MS SQL: Connect → choose it); drop the user from the wrong database.

## ADF: "found more columns than expected" (DelimitedTextMoreColumnsThanDefined)
**Cause:** titles contain quotes written as "" (e.g. 8"" for inches); ADF's default
escape character is a backslash, so it splits the title into extra columns.
**Fix:** dataset escape character = double quote (`"escapeChar": "\""`).
Check the dataset's code view {} — the UI change was not saved once.
