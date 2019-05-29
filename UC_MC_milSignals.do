onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench_md_mas_mc/clk
add wave -noupdate /testbench_md_mas_mc/reset
add wave -noupdate /testbench_md_mas_mc/ADDR
add wave -noupdate -expand -group MC /testbench_md_mas_mc/uut/MC/Unidad_Control/state
add wave -noupdate -expand -group MC /testbench_md_mas_mc/uut/MC/Unidad_Control/hit
add wave -noupdate -expand -group MC /testbench_md_mas_mc/uut/MC/MC_data
add wave -noupdate -expand -group MC /testbench_md_mas_mc/uut/MC/Unidad_Control/palabra_UC
add wave -noupdate -expand -group MC /testbench_md_mas_mc/uut/MC/Din
add wave -noupdate -expand -group MC /testbench_md_mas_mc/uut/MC/mux_origen
add wave -noupdate -expand -group MC /testbench_md_mas_mc/uut/MC/ready
add wave -noupdate -expand -group MC /testbench_md_mas_mc/uut/MC/RE
add wave -noupdate -expand -group MC /testbench_md_mas_mc/uut/MC/WE
add wave -noupdate -expand -group MC /testbench_md_mas_mc/uut/MC/MC_frame
add wave -noupdate -expand -group MC /testbench_md_mas_mc/uut/MC/MC_WE
add wave -noupdate -expand -group MC /testbench_md_mas_mc/uut/MC/MC_RE
add wave -noupdate -group contadores /testbench_md_mas_mc/uut/MC/cont_rm/int_count
add wave -noupdate -group contadores /testbench_md_mas_mc/uut/MC/cont_wm/int_count
add wave -noupdate -group contadores /testbench_md_mas_mc/uut/MC/cont_wh/int_count
add wave -noupdate -group ctrlBUS /testbench_md_mas_mc/uut/MC/Bus_TRDY
add wave -noupdate -group ctrlBUS /testbench_md_mas_mc/uut/MC/Bus_DevSel
add wave -noupdate -expand -group MD /testbench_md_mas_mc/uut/controlador_MD/MD_addr
add wave -noupdate -expand -group MD /testbench_md_mas_mc/uut/controlador_MD/MD_Dout
add wave -noupdate -expand -group MD /testbench_md_mas_mc/uut/controlador_MD/MD/RAM
add wave -noupdate -expand -group MC_mas_MD /testbench_md_mas_mc/uut/Dout
add wave -noupdate -expand -group MC_mas_MD /testbench_md_mas_mc/uut/Mem_ready
add wave -noupdate -expand -group MC_mas_MD /testbench_md_mas_mc/uut/RE
add wave -noupdate -expand -group MC_mas_MD /testbench_md_mas_mc/uut/WE
add wave -noupdate -expand -group MC_mas_MD /testbench_md_mas_mc/uut/Din
add wave -noupdate -expand -group MC_mas_MD /testbench_md_mas_mc/uut/ADDR
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {145 ns} 0} {{Cursor 2} {21 ns} 0} {{Cursor 3} {155 ns} 0} {{Cursor 4} {235 ns} 0} {{Cursor 5} {315 ns} 0} {{Cursor 6} {455 ns} 0}
quietly wave cursor active 6
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
WaveRestoreZoom {0 ns} {525 ns}
bookmark add wave bookmark0 {{0 ns} {150 ns}} 2
