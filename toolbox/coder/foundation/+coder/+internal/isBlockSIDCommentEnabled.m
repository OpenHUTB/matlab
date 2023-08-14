function out=isBlockSIDCommentEnabled(modelName)
    out=false;
    try
        if isValidSlObject(slroot,modelName)
            out=strcmp(get_param(modelName,'BlockCommentType'),'BlockSIDComment')&&...
            strcmp(get_param(modelName,'IsERTTarget'),'on');
        end
    catch
    end


