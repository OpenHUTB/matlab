



function out=getCCallerPortSpecifitions(blkHandle)

    out=cell(1,2);
    portSpecs=get_param(blkHandle,'FunctionPortSpecification');


    inputArgs=portSpecs.InputArguments;
    inputArgSpec=cell(1,numel(inputArgs));
    for i=1:numel(inputArgs)
        info=cell(1,6);
        info{1}=inputArgs(i).Name;
        info{2}=inputArgs(i).Label;
        info{3}=inputArgs(i).Scope;
        info{4}=inputArgs(i).Type;
        info{5}=str2num(inputArgs(i).Size);%#ok
        if inputArgs(i).IsPassByReference==1
            info{6}=true;
        else
            info{6}=false;
        end
        inputArgSpec{i}=info;
    end

    out{1}=inputArgSpec;


    if~isempty(portSpecs.ReturnArgument)
        returnArgSpec=cell(1,6);
        returnArgSpec{1}=portSpecs.ReturnArgument.Name;
        returnArgSpec{2}=portSpecs.ReturnArgument.Label;
        returnArgSpec{3}=portSpecs.ReturnArgument.Scope;
        returnArgSpec{4}=portSpecs.ReturnArgument.Type;
        returnArgSpec{5}=str2num(portSpecs.ReturnArgument.Size);%#ok
        if portSpecs.ReturnArgument.IsPassByReference==1
            returnArgSpec{6}=true;
        else
            returnArgSpec{6}=false;
        end

        out{2}=returnArgSpec;
    end

end
