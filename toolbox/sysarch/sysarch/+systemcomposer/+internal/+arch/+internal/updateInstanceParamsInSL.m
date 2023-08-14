function updateInstanceParamsInSL(blockH,paramName,fieldName,value)





    if isa(blockH,'systemcomposer.architecture.model.design.BaseComponent')

        compWrapper=systemcomposer.internal.getWrapperForImpl(blockH);
        blockH=compWrapper.SimulinkHandle;
        pName=string(paramName);
        idx=strfind(pName,'.');
        if~isempty(idx)
            paramName=pName.extractAfter(idx(end));
        end
        if~any(compWrapper.getParameterNames.matches(paramName))
            paramName=regexprep(pName,['.*',compWrapper.Name,'\/'],'');
        end

    end
    if blockH<=0
        return;
    end
    if~blockisa(blockH,'ModelReference')
        return;
    end


    instParams=get_param(blockH,'InstanceParameters');
    doUpdate=false;


    paramName=replace(paramName,{'.','/'},'_');

    if isempty(instParams)
        error('systemcomposer:Parameter:CannotSetUnresolvedParameter',message(...
        'SystemArchitecture:Parameter:CannotSetUnresolvedParameter',paramName).getString);
    end


    foundParam=false;
    for i=1:numel(instParams)
        aParam=instParams(i);
        name=systemcomposer.internal.arch.internal.getFullNameFromInstanceParameter(aParam.Name,aParam.Path);

        if~isempty(find(strcmp(name,paramName),1))
            foundParam=true;
            if strcmp(fieldName,'Value')

                if~strcmp(value,aParam.Value)
                    instParams(i).Value=char(value);
                    doUpdate=true;
                end
            elseif strcmp(fieldName,'Argument')

                if value~=aParam.Argument
                    instParams(i).Argument=value;
                    doUpdate=true;
                end
            else
                assert(false,'Can only sync field Value or Argument of instance parameters');
            end
        end
    end

    if~foundParam
        error('systemcomposer:Parameter:CannotSetUnresolvedParameter',message(...
        'SystemArchitecture:Parameter:CannotSetUnresolvedParameter',paramName).getString);
    end

    if doUpdate
        set_param(blockH,'InstanceParameters',instParams);
    end
