function match=findAllSFBlks(hndl)




    match=get_param(hndl,"Type")=="block"&&...
    get_param(hndl,"BlockType")=="SubSystem"&&...
    get_param(hndl,"SFBlockType")~="NONE"&&...
    get_param(hndl,"SFBlockType")~="MATLAB Function";
end

