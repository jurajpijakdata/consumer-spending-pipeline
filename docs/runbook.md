## "No module named …" although the package was installed
**Cause:** plain `pip` installed into the global Python, not the venv
(and an interrupted pip upgrade had broken the venv's own pip).
**Fix:** always use `python -m pip …`. If pip itself is broken, delete `.venv`
and create it again. Check with `python -m pip show <package>` → Location.
