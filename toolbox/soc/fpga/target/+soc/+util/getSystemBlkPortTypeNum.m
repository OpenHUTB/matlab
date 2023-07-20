function[type,num]=getSystemBlkPortTypeNum(blk,port)
    mask_str=get_param(blk,'MaskDisplay');

    pattern_num=['\w*(?=,''',port,''')'];
    matched_str=regexp(mask_str,pattern_num,'match');
    num=matched_str{1};

    pattern_type=['\w*(?='',',num,',''',port,''')'];
    matched_str=regexp(mask_str,pattern_type,'match');
    type=matched_str{1};

    num=str2double(num);

end