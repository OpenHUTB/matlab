function match=findAllModelBlks(hndl)




    match=get_param(hndl,"Type")=="block"&&...
    get_param(hndl,"BlockType")=="ModelReference";
end
