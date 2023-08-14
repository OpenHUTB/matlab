function lBuildVariant=getDataForBuildToolInfoML(coderOutput)




    switch(coderOutput)
    case 'rtw:lib'
        lBuildVariant=coder.make.enum.BuildVariant.STATIC_LIBRARY;
    case 'rtw:dll'
        lBuildVariant=coder.make.enum.BuildVariant.SHARED_LIBRARY;
    case{'rtw','rtw:exe','rtw.exe'}
        lBuildVariant=coder.make.enum.BuildVariant.STANDALONE_EXECUTABLE;
    otherwise
        lBuildVariant=coder.make.enum.BuildVariant.UNKNOWN;
    end

end


