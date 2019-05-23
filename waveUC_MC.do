onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench_md_mas_mc/clk
add wave -noupdate /testbench_md_mas_mc/reset
add wave -noupdate /testbench_md_mas_mc/ADDR
add wave -noupdate /testbench_md_mas_mc/uut/MC/cont_rm/int_count
add wave -noupdate /testbench_md_mas_mc/uut/MC/cont_wm/int_count
add wave -noupdate /testbench_md_mas_mc/uut/MC/cont_wh/int_count
add wave -noupdate /testbench_md_mas_mc/uut/MC/Unidad_Control/state
add wave -noupdate /testbench_md_mas_mc/uut/MC/Unidad_Control/hit
add wave -noupdate /testbench_md_mas_mc/uut/MC/MC_data
add wave -noupdate /testbench_md_mas_mc/uut/MC/Unidad_Control/palabra_UC
add wave -noupdate /testbench_md_mas_mc/uut/MC/Unidad_Control/palabra
add wave -noupdate /testbench_md_mas_mc/uut/MC/Din
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {222 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 345
configure wave -valuecolwidth 101
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
WaveRestoreZoom {0 ns} {630 ns}
