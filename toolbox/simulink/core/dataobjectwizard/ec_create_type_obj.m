function ec_create_type_obj(modelName)










    if(nargin==0)

        modelName=get_param(new_system('','FromTemplate','factory_default_model'),'Name');
        cleanupObj=onCleanup(@()bdclose(modelName));
    end


    if((exist('ec_get_info_for_aliastype','file')==6)||...
        (exist('ec_get_info_for_aliastype','file')==2))

        objectList=ec_get_info_for_aliastype(modelName);
    else

        objectList=get_user_type_info_for_aliastype;
    end

    aliasMisMatch={};
    for i=1:length(objectList)
        mismatch=create_object_aliastype(modelName,objectList{i});
        if~isempty(mismatch)
            aliasMisMatch{end+1}=mismatch;%#ok
        end
    end

    aliasMisMatch=unique(aliasMisMatch);
    if~isempty(aliasMisMatch)

        str=cellstr2str(aliasMisMatch);
        MSLDiagnostic('Simulink:dow:CreateDataTypeWarning',str).reportAsWarning;
    end


