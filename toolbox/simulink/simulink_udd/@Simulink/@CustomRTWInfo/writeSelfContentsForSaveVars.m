function writeSelfContentsForSaveVars(obj,vs)









    if obj.SaveVarsCalledFromDataObject
        vs.writePropertyContents('CustomAttributes',obj.CustomAttributes);
    else

        DAStudio.error('MATLAB:savevars:SaveVarsUnsupportedClass')
    end


