function platformStr=getPrettyPlatform(platformStr)











    xlateEnt=struct(...
    'PCWIN','',...
    'PCWIN64','',...
    'GLNX86','',...
    'GLNXA64','',...
    'MACI64','');
    xlateEnt=hwconnectinstaller.internal.getXlateEntries('hwconnectinstaller','setup','Common',xlateEnt);


    platformStr=strtrim(platformStr);
    pattern='(((PCWIN64)|(PCWIN)|(GLNX86)|(GLNXA64)|(MACI64)),\s*)*((PCWIN64)|(PCWIN)|(GLNX86)|(GLNXA64)|(MACI64))';
    tmpStr=regexp(platformStr,pattern,'match');
    if~(length(tmpStr)==1&&isequal(tmpStr{1},platformStr))
        error(message('hwconnectinstaller:setup:InvalidPlatformString',platformStr));
    end



    platformStr=regexprep(platformStr,'PCWIN64',xlateEnt.PCWIN64);
    platformStr=regexprep(platformStr,'PCWIN',xlateEnt.PCWIN);
    platformStr=regexprep(platformStr,'GLNX86',xlateEnt.GLNX86);
    platformStr=regexprep(platformStr,'GLNXA64',xlateEnt.GLNXA64);
    platformStr=regexprep(platformStr,'MACI64',xlateEnt.MACI64);

end
