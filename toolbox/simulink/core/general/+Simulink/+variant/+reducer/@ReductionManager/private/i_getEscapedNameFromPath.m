
function name=i_getEscapedNameFromPath(blockPath)



    name=get_param(blockPath,'Name');




    name=i_getEscapedName(name);
end


