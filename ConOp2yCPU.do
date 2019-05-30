onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/uut/clk
add wave -noupdate /testbench/uut/reset
add wave -noupdate /testbench/uut/Mem_I/RAM
add wave -noupdate /testbench/uut/IR_ID
add wave -noupdate -group Contadores /testbench/uut/cont_ciclos/int_count
add wave -noupdate -group Contadores /testbench/uut/cont_paradas_control/int_count
add wave -noupdate -group Contadores /testbench/uut/cont_paradas_datos/int_count
add wave -noupdate -group Contadores /testbench/uut/cont_paradas_memoria/int_count
add wave -noupdate -group Contadores /testbench/uut/cont_mem_reads/int_count
add wave -noupdate -group Contadores /testbench/uut/cont_mem_writes/int_count
add wave -noupdate /testbench/uut/pc/Dout
add wave -noupdate /testbench/uut/predictor_error
add wave -noupdate /testbench/uut/avanzar_ID
add wave -noupdate /testbench/uut/Mem_D/Mem_ready
add wave -noupdate -expand -group MC_MD /testbench/uut/Mem_D/RE
add wave -noupdate -expand -group MC_MD /testbench/uut/Mem_D/WE
add wave -noupdate -expand -group MC_MD /testbench/uut/Mem_D/ADDR
add wave -noupdate -expand -group MC_MD /testbench/uut/Mem_D/MC/Unidad_Control/state
add wave -noupdate -expand -group MC_MD /testbench/uut/Mem_D/MC/Unidad_Control/palabra_UC
add wave -noupdate -expand -group MC_MD /testbench/uut/Mem_D/MC/Unidad_Control/palabra_buscada
add wave -noupdate -expand -group MC_MD /testbench/uut/Mem_D/MC/Unidad_Control/hit
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {358 ns} 0} {{Cursor 7} {172 ns} 0}
quietly wave cursor active 2
configure wave -namecolwidth 337
configure wave -valuecolwidth 75
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
bookmark add wave bookmark0 {{0 ns} {150 ns}} 2
