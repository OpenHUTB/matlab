




function[msg,errId]=isValidARIdentifier(cellstrToTest,idType,maxShortNameLength)

    if nargin>0
        cellstrToTest=convertStringsToChars(cellstrToTest);
    end

    if nargin>1
        idType=convertStringsToChars(idType);
    end

    msg='';
    cellstrToTest=cellstr(cellstrToTest);

    for idx=1:length(cellstrToTest)
        str=cellstrToTest{idx};

        [isvalid,msg,errId]=autosarcore.checkIdentifier(str,idType,maxShortNameLength);
        if~isvalid||~isempty(msg)
            return;
        end

    end

end


