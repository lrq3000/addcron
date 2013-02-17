addcron
=======

A simple Cron job adder, with automatic checking to avoid duplicates

This is mainly an excerpt from the OAMPS script, but it can be used for all purposes, not only game servers.

License
-------
This script is licensed under MIT license.

Author
------
Stephen Larroque

Usage
-----

    Usage: sh $SCRIPTNAME 'crondate' 'crontask' [OPTION]...
    Add only once a cron job to execute the specified crontask at a specified crondate interval. Will automatically check for duplicates, so that it will never add twice the same job inside cron.

    WARNING: only use absolute paths, else cron may not be able to execute the task, and also the check for duplicates will fail.

    Note: the duplicates checking will match any shorter crontask, eg: already added crontask 'mycronjob', if you try to add crontask 'mycron' it will be rejected because of being a duplicate.
      
      --verbose				Print verbose infos of oamps.sh
