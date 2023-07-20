

function[codePath,codeFileWithExt,lineNum]=splitCodeLoc(codeLoc)




    if isempty(codeLoc)||~ischar(codeLoc)
        DAStudio.error('Slci:results:InvalidInputArg');
    end

    toks=regexp(codeLoc,'(.*):(.*)','tokens');
    toks=toks{1};
    fileName=toks{1};
    lineNum=str2double(toks{2});

    [codePath,fName,fExt]=fileparts(fileName);
    codeFileWithExt=[fName,fExt];

end
