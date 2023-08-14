function[bSuccess,returnFileName]=createUniqueFile(parentPath,fileName)








    assert(~isempty(fileName),'File name should be non-empty');

    [~,name,ext]=fileparts(fileName);
    returnFileName=[name,ext];
    bSuccess=false;

    idx=1;
    limit=65535;
    while idx<=limit
        pathToCheck=fullfile(parentPath,returnFileName);
        if(exist(pathToCheck,'file')>0)
            returnFileName=[name,num2str(idx),ext];
            idx=idx+1;
        else
            bSuccess=true;
            break;
        end
    end
end
