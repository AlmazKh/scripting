#!/bin/bash

draw_board(){
    clear    
    printf "Ход: № $STEP\n\n"
    D1="+---------------+"
    D2="|---------------|"
    S="%s\n|%3s|%3s|%3s|%3s|\n"
    printf $S $D1 ${M[0]:-" "} ${M[1]:-" "} ${M[2]:-" "} ${M[3]:-" "}
    printf $S $D2 ${M[4]:-" "} ${M[5]:-" "} ${M[6]:-" "} ${M[7]:-" "}
    printf $S $D2 ${M[8]:-" "} ${M[9]:-" "} ${M[10]:-" "} ${M[11]:-" "}
    printf $S $D2 ${M[12]:-" "} ${M[13]:-" "} ${M[14]:-" "} ${M[15]:-" "}
    printf "$D1\n\n"
    if (( ${#AVAILABLE_MOVEMENTS[@]} != 0 )); then
        printf "Неверный ход!\nНевозможно костяшку $ENTERED_VALUE передвинуть на пустую ячейку.\n"
        printf "Можно выбрать: "
        for NUMBER in "${AVAILABLE_MOVEMENTS[@]}"
        do
          echo -n "$NUMBER "
        done
        echo ""
    fi
    AVAILABLE_MOVEMENTS=()
}

init_game(){
    M=()
    EMPTY=
    DIRECTION=
    STEP=1
    numbers=($(shuf -i 0-15 -n 16))
    for i in {0..15}
    do
	if [[ "${numbers[i]}" == 0 ]]
	   then
		EMPTY=$i
		M[$i]=""
	   else 
		M[$i]="${numbers[i]}"
	fi
    done
    draw_board
}

update_empty_field(){
    M[$EMPTY]=${M[$1]}
    M[$1]=""
    EMPTY=$1
    STEP=$(($STEP+1))
}

quit_game(){
    while :
    do
        read -n 1 -s -p "Вы действительно хотите выйти [y/n]?"
        case $REPLY in
            y|Y) exit ;;
            n|N) return ;;
	    *) 
	       printf "\nОшибка. Введите y/Y или n/N\n"
	       continue ;;
        esac
    done
}

check_win(){
    for i in {0..14}
    do
        if [ "${M[i]}" != "$(( $i + 1 ))" ]
        then
            return
        fi
    done
    echo "Вы собрали головоломку за $STEP ходов. Хотите сыграть еще раз [y/n]?"
    while :
    do
        read -n 1 -s
        case $REPLY in
            y|Y)
                init_game
                break ;;
            n|N) exit ;;
            *)
               printf "\nОшибка. Введите y/Y или n/N\n"
               continue ;;
        esac
    done
}

calculate_available_movements(){
    AVAILABLE_MOVEMENTS=()
    if [ $((EMPTY-1)) -gt -1 ] && [ $((EMPTY % 4)) != 0 ]; then
        AVAILABLE_MOVEMENTS+=($((M[EMPTY-1])))
    fi
    if [ $((EMPTY+1)) -lt 16 ] && [ $((EMPTY % 4)) != 3 ]; then
        AVAILABLE_MOVEMENTS+=($((M[EMPTY+1])))
    fi
    if [ $((EMPTY-4)) -gt -1 ]; then
        AVAILABLE_MOVEMENTS+=($((M[EMPTY-4])))
    fi
    if [ $((EMPTY+4)) -lt 16 ]; then
        AVAILABLE_MOVEMENTS+=($((M[EMPTY+4])))
    fi
}

calculate_direction(){
    for i in "${!M[@]}"; do
        if [[ "${M[$i]}" -eq "$ENTERED_VALUE" ]]; then
          case $((i - EMPTY)) in
            -1) DIRECTION="a" ;;
            1) DIRECTION="d" ;;
            -4) DIRECTION="w" ;;
            4) DIRECTION="s" ;;
            *) calculate_available_movements ;;
          esac
	  break
        fi
    done
}

start_game(){
    while :
    do
        echo "Ваш ход (q - выход):"
        read ENTERED_VALUE
        case "$ENTERED_VALUE" in
  	    "q") quit_game ;;
	    [1-9]|1[0-5]) calculate_direction ;;
            *)
              calculate_available_movements 
              DIRECTION="" ;;
        esac
        case $DIRECTION in
             "s")
                [ $EMPTY -lt 12 ] && update_empty_field $(( $EMPTY + 4 )) ;;
             "d")
                COL=$(( $EMPTY % 4 ))
                [ $COL -lt 3 ] && update_empty_field $(( $EMPTY + 1 )) ;;
             "w")
                [ $EMPTY -gt 3 ] && update_empty_field $(( $EMPTY - 4 )) ;;
             "a")
                COL=$(( $EMPTY % 4 ))
                [ $COL -gt 0 ] && update_empty_field $(( $EMPTY - 1 )) ;;
        esac
        draw_board
        check_win
    done
}

init_game
start_game
