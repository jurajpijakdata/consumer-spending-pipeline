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
