function[customUpdate,statusUpdate,valueUpdate]=customRTW_UI(param,parents,~)



    statusUpdate=false;
    valueUpdate=false;



    customUpdate=true;

    copySim=parents('RTWUseSimCustomCode');
    if strcmp(copySim.Value,'on')
        newStatus=configset.internal.data.ParamStatus.ReadOnly;
        myParents=keys(parents);



        for i=1:length(myParents)
            if isempty(strfind(myParents{i},'RTWUseSimCustomCode'))
                pair=parents(myParents{i});
                break;
            end
        end
        newVal=pair.Value;
    else
        newStatus=configset.internal.data.ParamStatus.Normal;


        newVal=param.CS.(param.Name);
    end

    if~strcmp(param.Value,newVal)
        valueUpdate=true;
        param.Value=newVal;
    end

    if param.Status~=newStatus
        statusUpdate=true;
        param.Status=newStatus;
    end
end

