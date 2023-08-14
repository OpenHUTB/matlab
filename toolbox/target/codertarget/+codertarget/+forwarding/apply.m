function apply(hCS,tgtHWInfo)










    defFile=tgtHWInfo.getForwardingInfoFile();
    defFile=strrep(defFile,'$(TARGET_ROOT)',tgtHWInfo.TargetFolder);
    info=codertarget.forwarding.ForwardingInfo(defFile);

    for i=1:numel(info.Parameters)
        thisParam=info.Parameters{i};
        fieldnames=fields(thisParam);


        scope='CoderTarget';
        if ismember('Scope',fieldnames)
            scope=thisParam.Scope;
        end
        thisParam.Scope=scope;


        if ismember('ForwardingFcn',fieldnames)&&~isempty(thisParam.ForwardingFcn)
            loc_evaluateFcn(hCS,thisParam);
        end


        if ismember('NewValue',fieldnames)&&~isempty(thisParam.NewValue)
            loc_updateParameterValue(hCS,thisParam);
        end


        if ismember('NewName',fieldnames)&&~isempty(thisParam.NewName)
            loc_updateParameterName(hCS,thisParam);
        end
    end
end




function loc_evaluateFcn(hCS,param)




    try
        feval(param.ForwardingFcn,hCS,param.Name);
    catch ex


        warning(message('codertarget:setup:ParameterForwardingFcnError',param.Name,ex.message));
    end
end

function loc_updateParameterValue(hCS,param)


    value=loc_getParameterValue(hCS,param.Scope,param.Name);

    valuesToForward=strsplit(param.Value,',');
    if ismember(value,valuesToForward)
        loc_setParameterValue(hCS,param.Scope,param.Name,param.NewValue);
    end
end

function value=loc_getParameterValue(hCS,scope,name)


    if isequal(scope,'CoderTarget')
        value=codertarget.data.getParameterValue(hCS,name);
    else
        value=get_param(hCS,name);
    end
    if isnumeric(value)
        value=num2str(value);
    end
end

function loc_setParameterValue(hCS,scope,name,value)


    if isequal(scope,'CoderTarget')
        codertarget.data.setParameterValue(hCS,name,value);
    else
        set_param(hCS,name,value);
    end
end

function loc_updateParameterName(hCS,param)


    value=loc_getParameterValue(hCS,param.Scope,param.Name);
    loc_setParameterValue(hCS,param.Scope,param.NewName,value);
end