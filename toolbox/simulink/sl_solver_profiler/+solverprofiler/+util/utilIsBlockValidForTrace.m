
function flag=utilIsBlockValidForTrace(blkName)
    try
        flag=Simulink.Structure.HiliteTool.isValidBlock(get_param(blkName,'handle'));
    catch
        flag=false;
    end

end