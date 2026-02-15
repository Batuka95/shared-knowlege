#!/system/bin/sh
#
# fast_touch.sh — сверхбыстрые tap и swipe на эмуляторе BlueStacks
#
# Использование:
#   fast_touch.sh tap X Y
#   fast_touch.sh swipe X1 Y1 X2 Y2 [STEPS]
#
# Пример:
#   fast_touch.sh tap 300 500
#   fast_touch.sh swipe 100 200 400 800 20
#

# По умолчанию давление пальца
PRESSURE=50

# Ищем первое подходящее event-устройство с ABS_MT_POSITION_X/Y
EVENT_DEV=event6

if [ -z "$EVENT_DEV" ]; then
  echo "Ошибка: не найдено подходящего /dev/input/eventX" >&2
  exit 1
fi

DEVICE="/dev/input/${EVENT_DEV}"
SENDEVENT=$(command -v sendevent || echo "/system/bin/sendevent")

# Функция печати помощи
usage() {
  echo "Использование:"
  echo "  $0 tap X Y"
  echo "  $0 swipe X1 Y1 X2 Y2 [STEPS]"
  exit 1
}

# Touch down (начало касания)
_down() {
  local X=$1 Y=$2
  $SENDEVENT $DEVICE 3 57 0        # ABS_MT_TRACKING_ID — новая касательная точка
  $SENDEVENT $DEVICE 3 53 $X       # ABS_MT_POSITION_X
  $SENDEVENT $DEVICE 3 54 $Y       # ABS_MT_POSITION_Y
  $SENDEVENT $DEVICE 3 58 $PRESSURE# ABS_MT_PRESSURE
  $SENDEVENT $DEVICE 1 330 1       # BTN_TOUCH down
  $SENDEVENT $DEVICE 0 0 0         # SYN_REPORT
}

# Touch up (отпускание)
_up() {
  $SENDEVENT $DEVICE 3 57 -1       # ABS_MT_TRACKING_ID = -1 (конец касания)
  $SENDEVENT $DEVICE 1 330 0       # BTN_TOUCH up
  $SENDEVENT $DEVICE 0 0 0         # SYN_REPORT
}

# Быстрый tap в точке X,Y
tap() {
  [ $# -ne 2 ] && usage
  _down $1 $2
  _up
}

# Плавный swipe из X1,Y1 в X2,Y2 за STEPS шагов
swipe() {
  [ $# -lt 4 ] && usage
  local X1=$1 Y1=$2 X2=$3 Y2=$4 STEPS=${5:-10}
  local DX=$(( (X2 - X1) / STEPS ))
  local DY=$(( (Y2 - Y1) / STEPS ))
  local i X Y

  _down $X1 $Y1

  for i in $(seq 1 $STEPS); do
    X=$(( X1 + DX * i ))
    Y=$(( Y1 + DY * i ))
    $SENDEVENT $DEVICE 3 53 $X
    $SENDEVENT $DEVICE 3 54 $Y
    $SENDEVENT $DEVICE 0 0 0
  done

  _up
}

# Основной парсинг аргументов
[ $# -lt 1 ] && usage

case "$1" in
  tap)
    shift
    tap "$@"
    ;;
  swipe)
    shift
    swipe "$@"
    ;;
  *)
    usage
    ;;
esac

exit 0
