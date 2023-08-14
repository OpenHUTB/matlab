function RLCLoadCback(block)





    MV=get_param(block,'MaskVisibilities');
    MV{7}=get_param(block,'Setx0');
    MV{9}=get_param(block,'SetiL0');
    set_param(block,'MaskVisibilities',MV);