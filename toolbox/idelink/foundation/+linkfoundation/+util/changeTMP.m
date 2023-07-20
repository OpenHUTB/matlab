function changeTMP




    newDir=uigetdir;
    if newDir~=0
        setenv('TMP',newDir)
    else
        linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:EmptyPathString'));
    end
end