function outFilePath=fixFileSep(inFilePath)




    if ispc
        outFilePath=strrep(inFilePath,'/','\');
    else
        outFilePath=strrep(inFilePath,'\','/');
    end

end

