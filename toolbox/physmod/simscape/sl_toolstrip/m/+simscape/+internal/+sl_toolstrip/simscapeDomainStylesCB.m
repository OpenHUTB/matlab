function simscapeDomainStylesCB(cbInfo)
    modelName=getfullname(cbInfo.editorModel.handle);

    try
        if simscape.internal.styleModel(modelName)
            simscape.internal.styleModel(modelName,false);
        else
            simscape.internal.styleModel(modelName,true);
        end
    catch
    end

end