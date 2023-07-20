function str=getValueString(blk,blk_param)
    str=get_param(blk,blk_param);
    if~isempty(str)
        num=evalin('base',str);
        str=num2str(num);
    end
end
