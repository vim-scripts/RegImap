call SetParameters({'filetype' : 'common'})
call RegImap('\<ph ', '|' . PH() . '|' . PH())

call RegImap('\<cdate', '\=strftime("%Y-%m-%d")')
