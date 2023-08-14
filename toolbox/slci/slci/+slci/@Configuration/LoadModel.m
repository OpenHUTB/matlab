function modelLoaded=LoadModel(aObj)





    modelLoaded=~isempty(find_system('flat','Name',aObj.getModelName()));
    if modelLoaded
        hModel=get_param(aObj.getModelName(),'handle');
        origDirty=get_param(hModel,'dirty');
        if(strcmp(origDirty,'on'))
            error(message('Slci:slci:ERRORS_DIRTYMODEL',aObj.getModelName()));
        end
    else

        load_system(aObj.getModelName());
    end
end



