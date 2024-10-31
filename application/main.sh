#! /bin/bash
source ./config
ticketfile="./tickets"
numberfile="./tnumber"

#Function to Add a Ticket
add_ticket() {
  issue_description=$1
  ticketnumber=$(cat "$numberfile")
  ticketnumber=$((ticketnumber + 1))
  echo $ticketnumber > "$numberfile"
  echo "$ticketnumber \"$issue_description\"" >> $ticketfile
  echo "Ticket " $ticketnumber " has been created." > $responsepipe
}

assign_ticket () {
  if [[ ! -f $ticketfile ]] || [[ ! -s $ticketfile ]]; then
    echo "No tickets available to assign." > $responsepipe
  else
    oldest_ticket=$(head -n 1 $ticketfile)
    echo "$oldest_ticket" >> "$HOME/assigned"
    sed -i '1d' $ticketfile
    echo "Ticket assigned: $oldest_ticket" > $responsepipe

  fi
}

while true; do
  if read line < addaticket; then
    case $line in
    ADD*)
     add_ticket "${line#ADD }"
     ;;
    ASSIGN*)
     assign_ticket
     ;;
    *)
     echo "Unknown Command"
     ;;
    esac
   fi
  sleep 1
done
