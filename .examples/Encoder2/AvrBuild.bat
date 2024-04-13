@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "D:\avr-projects\Encoder2\labels.tmp" -fI -W+ie -C V2E -o "D:\avr-projects\Encoder2\Encoder.hex" -d "D:\avr-projects\Encoder2\Encoder.obj" -e "D:\avr-projects\Encoder2\Encoder.eep" -m "D:\avr-projects\Encoder2\Encoder.map" "D:\avr-projects\Encoder2\Encoder.asm"
