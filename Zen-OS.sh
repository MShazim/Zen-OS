#!/bin/bash

#-------------------------- Function to display a main menu --------------------------
show_main_menu() {
    main_menu=$(zenity --title="ZEN-OS" --width=400 --height=500 --list --column="Options" --column="Description" \
        "1" "Display System Information" \
        "2" "Create a New Directory" \
        "3" "Delete Directory" \
        "4" "View Files in Specific Directory" \
        "5" "Search for a File" \
        "6" "Add File" \
        "7" "Delete File" \
        "8" "Update File" \
        "9" "Copy and Paste File" \
        "10" "Show Users" \
        "11" "Add User" \
        "12" "Delete User" \
        "13" "List Processes" \
        "14" "Shut Down")

    case $main_menu in
        1)
            display_system_info
            ;;
        2)
            create_directory
            ;;
        3)
            delete_directory
            ;;
        4)
            view_files
            ;;
        5)
            search_file
            ;;
        6)
            add_file
            ;;
        7)
            delete_file
            ;;
        8)
            update_file
            ;;
        9)
            copypaste_file
            ;;
        10)
            show_users
            ;;
        11)
            add_user
            ;;
        12)
            delete_user
            ;;
        13)
            list_processes
            ;;
        14)
            shutdown_system
            ;;
        *)
            zenity --error --title="Error" --text="Invalid option"
            show_main_menu
            ;;
    esac
}

#-------------------------- Function to display system information --------------------------
display_system_info() {
  system_info=$(echo -e "System Information:\n\nHostname: $(hostname)\n\nKernel Version: $(uname -r)\n\nCPU: $(grep 'model name' /proc/cpuinfo | head -n1 | cut -d ':' -f2 | sed -e 's/^ //')\n\nMemory: $(free -h | awk '/^Mem/ {print $2}')\n\nDisk Space:\n$(df -h)\n\nCurrent User: $(whoami)")
  zenity --info --title="System Information" --width=600 --height=500 --text="$system_info"
  show_main_menu
}


#-------------------------- Function to create a new directory --------------------------
create_directory() {
    new_dir=$(zenity --entry --title="Create Directory" --text="Enter the name of the new directory:")

    if [[ -z $new_dir ]]; then
        zenity --error --title="Error" --text="Directory name cannot be empty"
        create_directory
    fi

    mkdir $new_dir
    zenity --info --title="Success" --text="Directory '$new_dir' created successfully"
    show_main_menu
}

#-------------------------- Function to delete a directory --------------------------
delete_directory() {
    dir_to_delete=$(zenity --file-selection --directory --title="Select Directory to Delete")

    if [[ -z $dir_to_delete ]]; then
        show_main_menu
    fi

    rm -r $dir_to_delete
    zenity --info --title="Success" --text="Directory '$dir_to_delete' deleted successfully"
    show_main_menu
}

#-------------------------- Function to view files in the current directory- -------------------------
view_files() {
    current_dir=$(zenity --file-selection --directory --title="Select Directory")

    if [[ -z $current_dir ]]; then
        show_main_menu
    fi

    file_list=$(ls -al $current_dir)

    #zenity --text-info --title="Files in $current_dir" --width=600 --height=400 --filename=/dev/null --editable --text "$file_list"
    zenity --info --title="Files in $current_dir" --width=600 --height=300 --text="$file_list"
    show_main_menu
}

#-------------------------- Function to search for a file --------------------------
search_file() {
    file_name=$(zenity --entry --title="Search File" --text="Enter the name of the file to search:")

    if [[ -z $file_name ]]; then
        zenity --error --title="Error" --text="File name cannot be empty"
        search_file
    fi

    result=$(find / -name $file_name 2>/dev/null)

    if [[ -n $result ]]; then
        zenity --info --title="Search Result" --text="File '$file_name' found at:\n$result"
    else
        zenity --info --title="Search Result" --text="No files found with name '$file_name'"
    fi

    show_main_menu
}

#-------------------------- Function to add a new file --------------------------
add_file() {
    file_name=$(zenity --entry --title="Add File" --text="Enter the name of the new file:")

    if [[ -z $file_name ]]; then
        zenity --error --title="Error" --text="File name cannot be empty"
        add_file
    fi

    touch $file_name
    zenity --info --title="Success" --text="File '$file_name' added successfully"
    show_main_menu
}

#-------------------------- Function to delete a file --------------------------
delete_file() {
    file_to_delete=$(zenity --file-selection --title="Select File to Delete")

    if [[ -z $file_to_delete ]]; then
        show_main_menu
    fi

    rm $file_to_delete
    zenity --info --title="Success" --text="File '$file_to_delete' deleted successfully"
    show_main_menu
}

#-------------------------- Function to update a file --------------------------
update_file() {
    file_to_update=$(zenity --file-selection --title="Select File to Update")

    if [[ -z $file_to_update ]]; then
        show_main_menu
    fi

    new_content=$(zenity --text-info --title="Update File" --width=600 --height=400 --editable --filename="$file_to_update")

    echo "$new_content" > "$file_to_update"

    zenity --info --title="Success" --text="File '$file_to_update' updated successfully"
    show_main_menu
}

#-------------------------- Function to copy and paste a file --------------------------
copypaste_file() {
    file_name=$(zenity --file-selection --title="Select File to Move")
    destination_dir=$(zenity --file-selection --directory --title="Select Destination Directory")

    if [[ -z $file_name ]] || [[ -z $destination_dir ]]; then
        show_main_menu
    fi

    cp $file_name $destination_dir
    zenity --info --title="Success" --text="File '$file_name' copied and paste to '$destination_dir' successfully"
    show_main_menu
}

#-------------------------- Function to show users --------------------------
show_users() {
    users=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd)
    zenity --info --title="Users" --width=200 --height=150 --text="$users"
    show_main_menu
}

#-------------------------- Function to add a user --------------------------
add_user() {
    new_user=$(zenity --entry --title="Add User" --text="Enter the username of the new user:")

    if [[ -z $new_user ]]; then
        zenity --error --title="Error" --text="Username cannot be empty"
        add_user
    fi

    # Prompt for root password
    root_password=$(zenity --password --title="Root Password" --text="Enter the root password:")

    # Execute adduser command with sudo
    echo "$root_password" | sudo -S adduser $new_user

    zenity --info --title="Success" --text="User '$new_user' added successfully"
    show_main_menu
}

#-------------------------- Function to delete a user --------------------------
delete_user() {
    user_to_delete=$(zenity --entry --title="Delete User" --text="Enter the username of the user to delete:")

    if [[ -z $user_to_delete ]]; then
        zenity --error --title="Error" --text="Username cannot be empty"
        delete_user
    fi

    # Prompt for root password
    root_password=$(zenity --password --title="Root Password" --text="Enter the root password:")

    # Execute deluser command with sudo
    echo "$root_password" | sudo -S deluser $user_to_delete

    zenity --info --title="Success" --text="User '$user_to_delete' deleted successfully"
    show_main_menu
}

#-------------------------- Funtion to show all the running processes --------------------------
list_processes() {
    ps -e -o pid,user,%mem,%cpu,vsz,rss,tty,stat,start,time,command --sort=-%mem > processes.txt

    table_start="<table border='1' cellpadding='5' cellspacing='0'>"
    table_end="</table>"
    tr_start="<tr>"
    tr_end="</tr>"
    th_start="<th>"
    th_end="</th>"
    td_start="<td>"
    td_end="</td>"

    html_content="<html><head><style>th { background-color: #ddd; }</style></head><body>"
    html_content+="$table_start"
    html_content+="$tr_start$th_start PID $th_end$th_start User $th_end$th_start %MEM $th_end$th_start %CPU $th_end$th_start VSZ $th_end$th_start RSS $th_end$th_start TTY $th_end$th_start STAT $th_end$th_start Start $th_end$th_start Time $th_end$th_start Command $th_end$tr_end"

    while IFS= read -r line; do
        fields=($line)
        html_content+="$tr_start"
        for field in "${fields[@]}"; do
            html_content+="$td_start $field $td_end"
        done
        html_content+="$tr_end"
    done < "processes.txt"

    html_content+="$table_end</body></html>"

    echo "$html_content" > processes.html

    zenity --text-info --title="Running Processes" --width=1000 --height=600 --filename="processes.html" --html

    rm processes.txt processes.html
    show_main_menu
}

#-------------------------- Function to initiate system shutdown --------------------------
shutdown_system() {
    zenity --question --title="Shutdown" --text="Are you sure you want to shut down Zen-OS?" --default-cancel

    if [[ $? -eq 0 ]]; then
        zenity --info --title="Shutdown" --text="Shutting down ZEN-OS..."
        pkill -f OS_Project.sh
    fi

    exit 0
}


#-------------------------- Start the application by displaying the main menu --------------------------
show_main_menu