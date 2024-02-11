#!/bin/bash
#######################################################
#
#        File: mycommands.sh.clean
#
# copy to mycommands.sh and add all your commands and functions here ...
#
#       Usage: will be executed when a bot command is received 
#
#     License: WTFPLv2 http://www.wtfpl.net/txt/copying/
#      Author: KayM (gnadelwartz), kay@rrr.de
#
#### $$VERSION$$ v1.52-1-g0dae2db
#######################################################
# shellcheck disable=SC1117

####################
# Config has moved to bashbot.conf
# shellcheck source=./commands.sh
[ -r "${BASHBOT_ETC:-.}/mycommands.conf" ] && source "${BASHBOT_ETC:-.}/mycommands.conf"  "$1"

##################
# lets's go
if [ "$1" = "startbot" ];then
    ###################
    # this section is processed on startup

    # run once after startup when the first message is received
    my_startup(){
	:
    }
    touch .mystartup
else
    # call my_startup on first message after startup
    # things to do only once
    [ -f .mystartup ] && rm -f .mystartup && _exec_if_function my_startup

    #############################
    # your own bashbot commands
    # NOTE: command can have @botname attached, you must add * to case tests...
    mycommands() {

	##############
	# a service Message was received
	# add your own stuff here
	if [ -n "${SERVICE}" ]; then
		# example: delete every service message
		if [ "${SILENCER}" = "yes" ]; then
			delete_message "${CHAT[ID]}" "${MESSAGE[ID]}"
		fi
	fi

	# remove keyboard if you use keyboards
	[ -n "${REMOVEKEYBOARD}" ] && remove_keyboard "${CHAT[ID]}" &
	[[ -n "${REMOVEKEYBOARD_PRIVATE}" &&  "${CHAT[ID]}" == "${USER[ID]}" ]] && remove_keyboard "${CHAT[ID]}" &

	# uncommet to fix first letter upper case because of smartphone auto correction
	#[[ "${MESSAGE}" =~  ^/[[:upper:]] ]] && MESSAGE="${MESSAGE:0:1}$(tr '[:upper:]' '[:lower:]' <<<"${MESSAGE:1:1}")${MESSAGE:2}"
	MESSAGE_LOWER=$(echo ${MESSAGE} | sed -e 's/\(.*\)/\L\1/')
	case "${MESSAGE}" in
		##################
		# example command, replace them by your own
		'/ls'*) # example echo command
#			send_normal_message "${CHAT[ID]}" "${MESSAGE}"
			send_markdown_message   "${CHAT[ID]}"  "\`${MESSAGE_LOWER}\n${CHAT[ID]}\n\`  \`$(ls -l| grep log)\`"
			send_markdownv2_message "${CHAT[ID]}" "*HI* this is a _markdown_ message ..."
                         send_normal_message "${CHAT[ID]}"  "${BOTSEND[ID]} - ${iBUTTON[USER_ID]} - ${iBUTTON[CHAT_ID]} - ${iBUTTON[DATA]}"

#			send_keyboard "${CHAT[ID]}" "Text that will appear in chat?" '[ "Yep" , "No" ]'
                        send_inline_buttons "${CHAT[ID]}" "Press Button ..." "   Button   |RANDOM-BUTTON" 
#                        CALLBACK="1" # enable callbacks
			;;
		'/b'*)# inline button, set CALLBACK=1 for processing callbacks
#                        send_normal_message "${CHAT[ID]}"  "${BOTSEND[ID]} - ${iBUTTON[USER_ID]} - ${iBUTTON[CHAT_ID]} - ${iBUTTON[DATA]} - ${CALLBACK}"
			send_inline_buttons "${CHAT[ID]}" "Press Button ..." "   Button   |RANDOM-BUTTON"
                        ;;
		##########
		# command overwrite examples
		# return 0 -> run default command afterwards
		# return 1 -> skip possible default commands
		'/info'*) # output date in front of regular info
			send_normal_message "${CHAT[ID]}" "$(date)"
			return 0
			;;
		'/kickme'*) # this will replace the /kickme command
			send_markdownv2_mesage "${CHAT[ID]}" "This bot will *not* kick you!"
			return 1
			;;
	esac
     }

     mycallbacks() {
	#######################
	# callbacks from buttons attached to messages will be  processed here
#	send_markdown_message   "${CHAT[ID]}"  "${iBUTTON[USER_ID]}+${iBUTTON[CHAT_ID]}"
 #       send_normal_message "${CHAT[ID]}" "${iBUTTON[USER_ID]} - ${iBUTTON[CHAT_ID]} - ${iBUTTON[DATA]}"
	case "${iBUTTON[USER_ID]}+${iBUTTON[CHAT_ID]}" in
	    'USERID1+'*) # do something for all callbacks from USER
		printf "%s: U=%s C=%s D=%s\n" "$(date)" "${iBUTTON[USER_ID]}" "${iBUTTON[CHAT_ID]}" "${iBUTTON[DATA]}"\
				>>"${DATADIR}/${iBUTTON[USER_ID]}.log"
		answer_callback_query "${iBUTTON[ID]}" "Request has been logged in your user log..."
		return
		;;
	    *'+CHATID1') # do something for all callbacks from CHAT
		printf "%s: U=%s C=%s D=%s\n" "$(date)" "${iBUTTON[USER_ID]}" "${iBUTTON[CHAT_ID]}" "${iBUTTON[DATA]}"\
				>>"${DATADIR}/${iBUTTON[CHAT_ID]}.log"
		answer_callback_query "${iBUTTON[ID]}" "Request has been logged in chat log..."
		return
		;;
	    'USERID2+CHATID2') # do something only for callbacks form USER in CHAT
		printf "%s: U=%s C=%s D=%s\n" "$(date)" "${iBUTTON[USER_ID]}" "${iBUTTON[CHAT_ID]}" "${iBUTTON[DATA]}"\
				>>"${DATADIR}/${iBUTTON[USER_ID]}-${iBUTTON[CHAT_ID]}.log"
		answer_callback_query "${iBUTTON[ID]}" "Request has been logged in user-chat log..."
		return
		;;

	    *)	# all other callbacks are processed here
		local callback_answer
		: # your processing here ...
                # message available?
                if [[ -n "${iBUTTON[CHAT_ID]}" && -n "${iBUTTON[MESSAGE_ID]}" ]]; then
                        if [ "${iBUTTON[DATA]}" = "RANDOM-BUTTON" ]; then
                            callback_answer="Button_pressed"
                            edit_inline_buttons "${iBUTTON[CHAT_ID]}" "${iBUTTON[MESSAGE_ID]}" "Button ${RANDOM}|RANDOM-BUTTON"
                        fi
                else
                            callback_answer="Button to old, sorry."
                fi
                # Telegram needs an ack each callback query, default empty
		answer_callback_query "${iBUTTON[ID]}" "${callback_answer}"
#	        send_normal_message "${iBUTTON[CHAT_ID]}"  "0- ${iBUTTON[ID]} -  ${iBUTTON[USER_ID]} - ${iBUTTON[CHAT_ID]} - ${iBUTTON[DATA]} - ${CALLBACK} - ${callback_answer}"
		;;
	esac
     }
     myinlines() {
	#######################
	# this fuinction is called only if you has set INLINE=1 !!
	# shellcheck disable=SC2128
	iQUERY="${iQUERY,,}"

	
	case "${iQUERY}" in
		##################
		# example inline command, replace it by your own
		"image "*) # search images with yahoo
			local search="${iQUERY#* }"
			answer_inline_multi "${iQUERY[ID]}" "$(my_image_search "${search}")"
			;;
	esac
     }

    #####################
    # place your processing functions here

    # example inline processing function, not really useful
    # $1 search parameter
    my_image_search(){
	local image result sep="" count="1"
	result="$(wget --user-agent 'Mozilla/5.0' -qO - "https://images.search.yahoo.com/search/images?p=$1" |  sed 's/</\n</g' | grep "<img src=")"
	while read -r image; do
		[ "${count}" -gt "20" ] && break
		image="${image#* src=\'}"; image="${image%%&pid=*}"
		[[ "${image}" = *"src="* ]] && continue
		printf "%s\n" "${sep}"; inline_query_compose "${RANDOM}" "photo" "${image}"; sep=","
		count=$(( count + 1 ))
	done <<<"${result}"
    }

    ###########################
    # example error processing
    # called when delete Message failed
    # func="$1" err="$2" chat="$3" user="$4" emsg="$5" remaining args
    bashbotError_delete_message() {
	log_debug "custom errorProcessing delete_message: ERR=$2 CHAT=$3 MSGID=$6 ERTXT=$5"
    }

    # called when error 403 is returned (and no func processing)
    # func="$1" err="$2" chat="$3" user="$4" emsg="$5" remaining args
    bashbotError_403() {
	log_debug "custom errorProcessing error 403: FUNC=$1 CHAT=$3 USER=${4:-no-user} MSGID=$6 ERTXT=$5"
    }
fi
