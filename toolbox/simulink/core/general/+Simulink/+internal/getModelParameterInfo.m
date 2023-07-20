function paramInfo=getModelParameterInfo(mdlName)





    mdlH=load_system(mdlName);


    mdlArgNames=get_param(mdlH,'ParameterArgumentNames');
    if isempty(mdlArgNames)
        paramInfo=[];
        return;
    end


    paramInfo=locInitParamInfo(mdlArgNames);
    paramInfo=locGetParamInfoFromMdlWks(paramInfo,mdlH);


    mdlMask=Simulink.Mask.get(mdlH);
    if~isempty(mdlMask)
        paramInfo=locUpdateParamInfoFromMdlMask(paramInfo,mdlMask);
    end

end

function info=locInitParamInfo(mdlArgNames)
    names=split(string(mdlArgNames),",");
    numNames=numel(names);
    info=cell(1,numNames);
    for i=1:numNames
        info{i}.Name=names(i);
    end
end

function info=locGetParamInfoFromMdlWks(info,mdlH)
    for i=1:numel(info)
        name=info{i}.Name;
        wks=get_param(mdlH,'ModelWorkspace');
        var=evalin(wks,name);
        if isa(var,'Simulink.Parameter')
            info{i}=locPopulatePrmObjInfo(name,var);
        elseif isa(var,'Simulink.LookupTable')

            assert(false,'Simulink.LookupTable not supported!');
        elseif isa(var,'Simulink.Breakpoint')

            assert(false,'Simulink.Breakpoint not supported!');
        else
            info{i}=locPopulateVarInfo(name,var);
        end
    end
end

function info=locPopulateVarInfo(name,var)
    info.Name=name;
    info.Value=var;
    info.DataType=string(class(var));
    info.Dimensions=size(var);
    if isreal(var)
        info.Complexity="real";
    else
        info.Complexity="complex";
    end
    info.Min=[];
    info.Max=[];
    info.Unit="";
    info.Type="Variable";
    info.MaskInfo=[];
end

function info=locPopulatePrmObjInfo(name,var)
    info.Name=name;
    info.Value=var.Value;
    info.DataType=string(var.DataType);
    info.Dimensions=var.Dimensions;
    info.Complexity=string(var.Complexity);
    info.Min=var.Min;
    info.Max=var.Max;
    info.Unit=string(var.Unit);
    info.Type="ParameterObject";
    info.MaskInfo=[];
end

function info=locUpdateParamInfoFromMdlMask(info,mdlMask)
    for i=1:numel(info)
        name=info{i}.Name;
        prm=mdlMask.getParameter(name);
        info{i}.MaskInfo.Prompt=string(prm.Prompt);
        info{i}.MaskInfo.ValueExpr=string(prm.Value);

    end
end