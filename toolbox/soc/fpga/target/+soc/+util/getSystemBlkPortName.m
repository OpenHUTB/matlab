function[port_name]=getSystemBlkPortName(h_blk,type,num)

    mask_str=get_param(h_blk,'MaskDisplay');

    pattern=['(?<=port_label\(''',type,''',',num2str(num),','')\w*'];

    matched_str=regexp(mask_str,pattern,'match');

    if isempty(matched_str)
        port_name=num;
    else
        port_name=matched_str{1};
    end
end