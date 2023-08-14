


function spec=getCppInterfaceSpec(mdl_name)

    spec=[];
    model_classObj=RTW.getEncapsulationInterfaceSpecification(mdl_name);

    if isempty(model_classObj)
        return;
    end



    spec.Default=isa(model_classObj,'RTW.ModelCPPDefaultClass');

    spec.ModelClassName=model_classObj.ModelClassName;
    spec.FunctionName=model_classObj.FunctionName;
    spec.ClassNamespace=model_classObj.ClassNamespace;
    spec.Data=getArgumentData(model_classObj.Data);
    if isempty(model_classObj.Data)
        spec.hasReturn=false;
    else
        spec.hasReturn=strcmpi(model_classObj.Data(1).PositionString,'Return');
    end
































end


function ret=getArgumentData(input)
    ret={};
    for i=1:numel(input)
        in=input(i);
        data.PortName=in.SLObjectName;
        data.PortType=in.SLObjectType;
        data.PortNum=in.PortNum;
        data.Category=in.Category;
        data.ArgName=in.Argname;
        data.Position=in.Position;
        data.Qualifier=in.Qualifier;
        ret{end+1}=data;%#ok
    end
end


function ret=getArgument(func,mdl_name)
    ret={};
    mdlH=get_param(mdl_name,'Handle');
    numArgs=coder.mapping.internal.StepFunctionUtils.getNumArgs(func);
    for i=1:numArgs
        data.PortName=getPortName(coder.mapping.internal.StepFunctionMapping.getNameFromPosition(mdl_name,func,i));
        data.PortType=coder.mapping.internal.StepFunctionUtils.getSLObjectType(mdlH,func,i);
        data.PortNum=coder.mapping.internal.StepFunctionUtils.getPortNum(mdlH,func,i);
        data.Category=coder.mapping.internal.StepFunctionUtils.getCategory(func,i);
        data.ArgName=coder.mapping.internal.StepFunctionUtils.getArgName(func,i);
        data.Position=i;
        data.Qualifier=getQualifier(coder.mapping.internal.StepFunctionUtils.getQualifier(func,i));
        ret{end+1}=data;%#ok
    end
end


function out=getQualifier(qualifier)
    out=qualifier;
    if strcmpi(qualifier,'&')

        out='none';
    end
end


function out=getPortName(rtwname)
    names=strsplit(rtwname,filesep);
    out=names{end};
end
