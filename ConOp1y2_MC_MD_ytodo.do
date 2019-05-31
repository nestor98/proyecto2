onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/uut/clk
add wave -noupdate /testbench/uut/reset
add wave -noupdate /testbench/uut/Mem_I/RAM
add wave -noupdate /testbench/uut/IR_ID
add wave -noupdate /testbench/uut/Register_bank/reg_file
add wave -noupdate -expand -group Contadores /testbench/uut/cont_ciclos/int_count
add wave -noupdate -expand -group Contadores /testbench/uut/cont_paradas_control/int_count
add wave -noupdate -expand -group Contadores /testbench/uut/cont_paradas_datos/int_count
add wave -noupdate -expand -group Contadores /testbench/uut/cont_paradas_memoria/int_count
add wave -noupdate -expand -group Contadores /testbench/uut/cont_mem_reads/int_count
add wave -noupdate -expand -group Contadores /testbench/uut/cont_mem_writes/int_count
add wave -noupdate /testbench/uut/pc/Dout
add wave -noupdate /testbench/uut/predictor_error
add wave -noupdate /testbench/uut/avanzar_ID
add wave -noupdate /testbench/uut/Mem_D/Mem_ready
add wave -noupdate -group MC_MD /testbench/uut/Mem_I/RAM
add wave -noupdate -group MC_MD /testbench/uut/Mem_D/RE
add wave -noupdate -group MC_MD /testbench/uut/Mem_D/WE
add wave -noupdate -group MC_MD /testbench/uut/Mem_D/ADDR
add wave -noupdate -group MC_MD /testbench/uut/Mem_D/MC/Unidad_Control/state
add wave -noupdate -group MC_MD /testbench/uut/Mem_D/MC/Unidad_Control/palabra_UC
add wave -noupdate -group MC_MD /testbench/uut/Mem_D/MC/Unidad_Control/palabra_buscada
add wave -noupdate -group MC_MD /testbench/uut/Mem_D/MC/Unidad_Control/hit
add wave -noupdate -group MC_MD /testbench/uut/Mem_D/MC/Unidad_Control/MC_send_data
add wave -noupdate -group MC_MD /testbench/uut/Mem_D/MC/MC_Bus_data_out
add wave -noupdate -group MC_MD /testbench/uut/Mem_D/MC/Unidad_Control/MC_bus_Rd_Wr
add wave -noupdate -group contMD /testbench/uut/Mem_D/controlador_MD/MD/RAM
add wave -noupdate -group contMD /testbench/uut/Mem_D/controlador_MD/state
add wave -noupdate -group contMD /testbench/uut/Mem_D/controlador_MD/BUS_RE
add wave -noupdate -group contMD /testbench/uut/Mem_D/controlador_MD/BUS_WE
add wave -noupdate -group contMD /testbench/uut/Mem_D/controlador_MD/MD_Bus_DEVsel
add wave -noupdate -group contMD /testbench/uut/Mem_D/controlador_MD/MD_Bus_TRDY
add wave -noupdate -group contMD /testbench/uut/Mem_D/controlador_MD/MD_send_data
add wave -noupdate -group contMD /testbench/uut/Mem_D/controlador_MD/Bus_AD
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {377 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 328
configure wave -valuecolwidth 91
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {124 ns} {415 ns}
bookmark add wave bookmark0 {{0 ns} {150 ns}} 2
