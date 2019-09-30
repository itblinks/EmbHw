onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_ctrl_lcd/clk_sti
add wave -noupdate /tb_ctrl_lcd/Reset_RI
add wave -noupdate /tb_ctrl_lcd/avs_WaitRequest
add wave -noupdate /tb_ctrl_lcd/DUT_ctrl_lcd_avalonSlave/avs_Address_DI
add wave -noupdate /tb_ctrl_lcd/DUT_ctrl_lcd_avalonSlave/avs_Write_SI
add wave -noupdate /tb_ctrl_lcd/DUT_ctrl_lcd_avalonSlave/avs_WriteData_DI
add wave -noupdate /tb_ctrl_lcd/DUT_ctrl_lcd_avalonSlave/lcd_ChipSelect_n_SO
add wave -noupdate /tb_ctrl_lcd/DUT_ctrl_lcd_avalonSlave/lcd_DataCommand_SO
add wave -noupdate /tb_ctrl_lcd/DUT_ctrl_lcd_avalonSlave/lcd_Write_n_SO
add wave -noupdate /tb_ctrl_lcd/DUT_ctrl_lcd_avalonSlave/lcd_Reset_n_SO
add wave -noupdate /tb_ctrl_lcd/lcd_Data_DIO
add wave -noupdate /tb_ctrl_lcd/DUT_ctrl_lcd_avalonSlave/RegWaitCnt
add wave -noupdate /tb_ctrl_lcd/DUT_ctrl_lcd_avalonSlave/RegLCDData
add wave -noupdate /tb_ctrl_lcd/DUT_ctrl_lcd_avalonSlave/RegCtrl
add wave -noupdate /tb_ctrl_lcd/DUT_ctrl_lcd_avalonSlave/SigCtrl
add wave -noupdate /tb_ctrl_lcd/DUT_ctrl_lcd_avalonSlave/CntActive
add wave -noupdate /tb_ctrl_lcd/DUT_ctrl_lcd_avalonSlave/WriteDone
add wave -noupdate /tb_ctrl_lcd/DUT_ctrl_lcd_avalonSlave/WriteActive
add wave -noupdate /tb_ctrl_lcd/DUT_ctrl_lcd_avalonSlave/LcdBusy
add wave -noupdate /tb_ctrl_lcd/DUT_ctrl_lcd_avalonSlave/TrigRstCnt
add wave -noupdate /tb_ctrl_lcd/DUT_ctrl_lcd_avalonSlave/TrigWRXCnt
add wave -noupdate /tb_ctrl_lcd/DUT_ctrl_lcd_avalonSlave/s_curr_wait_cnt
add wave -noupdate /tb_ctrl_lcd/DUT_ctrl_lcd_avalonSlave/s_next_wait_cnt
add wave -noupdate /tb_ctrl_lcd/DUT_ctrl_lcd_avalonSlave/s_curr_lcd
add wave -noupdate /tb_ctrl_lcd/DUT_ctrl_lcd_avalonSlave/s_next_lcd
add wave -noupdate /tb_ctrl_lcd/DUT_ctrl_lcd_avalonSlave/s_curr_send
add wave -noupdate /tb_ctrl_lcd/DUT_ctrl_lcd_avalonSlave/s_next_send
add wave -noupdate /tb_ctrl_lcd/DUT_ctrl_lcd_avalonSlave/SigWaitCnt
add wave -noupdate /tb_ctrl_lcd/DUT_ctrl_lcd_avalonSlave/wait_reset
add wave -noupdate /tb_ctrl_lcd/DUT_ctrl_lcd_avalonSlave/wait_write
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10067630 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 297
configure wave -valuecolwidth 143
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
configure wave -timelineunits ps
update
WaveRestoreZoom {9918928 ps} {10181072 ps}
