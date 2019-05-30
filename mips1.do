onerror {resume}
quietly set dataset_list [list sim vsim]
if {[catch {datasetcheck $dataset_list}]} {abort}
quietly WaveActivateNextPane {} 0
add wave -noupdate sim:/testbench/uut/clk
add wave -noupdate sim:/testbench/uut/reset
add wave -noupdate sim:/testbench/uut/cont_ciclos/int_count
add wave -noupdate sim:/testbench/uut/cont_paradas_control/int_count
add wave -noupdate sim:/testbench/uut/cont_paradas_datos/int_count
add wave -noupdate sim:/testbench/uut/cont_paradas_memoria/int_count
add wave -noupdate sim:/testbench/uut/cont_mem_reads/int_count
add wave -noupdate sim:/testbench/uut/cont_mem_writes/int_count
add wave -noupdate sim:/testbench/uut/pc/Dout
add wave -noupdate sim:/testbench/uut/IR_ID
add wave -noupdate sim:/testbench/uut/Mem_I/RAM
add wave -noupdate sim:/testbench/uut/Mem_ready
add wave -noupdate sim:/testbench/uut/avanzar_ID
add wave -noupdate sim:/testbench/uut/predictor_error
add wave -noupdate sim:/testbench/uut/Register_bank/reg_file
add wave -noupdate sim:/testbench/uut/Mem_D/MC/hit
add wave -noupdate sim:/testbench/uut/Mem_D/MC/wh
add wave -noupdate sim:/testbench/uut/Mem_D/MC/MC_data
add wave -noupdate sim:/testbench/uut/Mem_D/MC/wm
add wave -noupdate sim:/testbench/uut/Mem_D/MC/rm
add wave -noupdate sim:/testbench/uut/Mem_D/controlador_MD/MD/RAM
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {325 ns} 0} {{Cursor 2} {433 ns} 0}
quietly wave cursor active 2
configure wave -namecolwidth 322
configure wave -valuecolwidth 40
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
WaveRestoreZoom {391 ns} {506 ns}
