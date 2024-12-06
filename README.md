# Pacman Rollback Script

This is a simple script that rolls back packages upgraded by pacman between the provided date and the current date. The script blocks undoing changes older than 2 days.  
The script takes one single obligatory positional argument, which is the date from which to start rolling back changes. This argument can be formatted in any way recognised
by the `date` util.

## Examples
`rollback-upgrades.sh 2024-12-05 #Giving a full date as the starting date`

`rollback-upgrades.sh 241205 #Same as above, but with shortened format`

`rollback-upgrades.sh today #undoes all changes made today`

`rollback-upgrades.sh '3 days ago' #will be blocked by the script`
