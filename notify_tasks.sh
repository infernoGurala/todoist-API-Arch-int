    notify-send -a "Todoist" "Today's task inferno!" "Zero tasks found. Focus on Project X!"
else
    while IFS= read -r line; do
        TASK_ID=$(echo "$line" | awk '{print $1}')
        TASK_TIME=$(echo "$line" | awk '{print $4}')
        TASK_NAME=$(echo "$line" | awk '{$1=$2=$3=$4=""; print $0}' | sed 's/#[a-zA-Z]*//g' | sed 's/^ *//')

        if [[ "$TASK_TIME" =~ ^[0-9]{2}:[0-9]{2}$ ]]; then
            FRIENDLY_TIME=$(date -d "$TASK_TIME" +"%I:%M %p")
        else
            FRIENDLY_TIME="No time set"
        fi

        # Each notification runs in background independently
        (
            ACTION=$(notify-send -a "Todoist" "⏰ $FRIENDLY_TIME" "$TASK_NAME" \
                --action="done=✅ DONE" \
                --wait)
            if [[ "$ACTION" == "done" ]]; then
                todoist-done "$TASK_ID" "$TASK_NAME"
            fi
        ) &

        # Schedule due-time alert
        if [[ "$TASK_TIME" =~ ^[0-9]{2}:[0-9]{2}$ ]]; then
            echo "notify-send -u critical -a 'Todoist' '🔔 Due Now!' '$TASK_NAME'" | at "$TASK_TIME" 2>/dev/null
        fi

    done <<< "$RAW_DATA"
fi
```
