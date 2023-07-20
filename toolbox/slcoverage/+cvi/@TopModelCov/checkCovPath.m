function fullCovPath=checkCovPath(modelName,covPath)












    if isempty(covPath)||...
        strcmpi(covPath,'/')

        fullCovPath=modelName;
        return;
    end
    if testValid(modelName,covPath)
        fullCovPath=covPath;
        return;
    end

    covPath=strrep(covPath,'//','#forwardSlash#');
    parts=split(string(covPath),'/');
    if all(cellfun(@isempty,parts))
        fullCovPath=modelName;
        return;
    end

    parts=parts(~cellfun('isempty',parts));

    parts=[{modelName},parts'];
    fullCovPath=join(parts,'/');
    fullCovPath=fullCovPath{1};
    fullCovPath=strrep(fullCovPath,'#forwardSlash#','//');
    if~testValid(modelName,fullCovPath)

        fullCovPath=modelName;
        warning(message('Slvnv:simcoverage:modelInit:InvalidPath',covPath,modelName));
    end
end

function res=testValid(modelName,fullCovPath)
    try

        blockType=get_param(fullCovPath,'BlockType');
        res=strcmpi(blockType,'subsystem');
    catch
        res=false;
    end

    res=res&&strcmpi(bdroot(fullCovPath),modelName);

end
