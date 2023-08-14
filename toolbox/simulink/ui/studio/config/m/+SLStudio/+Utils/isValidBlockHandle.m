function valid=isValidBlockHandle(handle)




    valid=(length(handle)==1)&&ishandle(handle)&&strcmpi(get_param(handle,'Type'),'block');
end
