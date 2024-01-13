function[meObj,systemH]=checkSystemValidity(obj,strict,coder)

    if nargin<2
        strict=false;
    end

    if nargin<3
        coder='';
    end

    if strcmp(coder,pslink.verifier.slcc.Coder.CODER_ID)
        badSystemId='polyspace:gui:pslink:badSystemSlcc';
        allowSubsystems=false;
    else
        badSystemId='polyspace:gui:pslink:badSystem';
        allowSubsystems=true;
    end

    meObj=[];

    try
        systemH=pslink.util.SimulinkHelper.getHandle(obj);
        modelH=bdroot(systemH);
        if isempty(systemH)||isempty(modelH)
            systemH=[];
            meObj=MException('pslink:badSystem',message(badSystemId).getString());
            return
        end
        type=get_param(systemH,'Type');
        if strcmpi(type,'block')&&strcmpi(get_param(systemH,'BlockType'),'subsystem')
            systemType='subsystem';
            if~allowSubsystems
                systemH=[];
                meObj=MException('pslink:badSystem',message(badSystemId).getString());
                return
            end
        elseif strcmpi(type,'block_diagram')
            systemType='block_diagram';
        elseif pslink.verifier.sfcn.isVerifiableSFcn(systemH)
            systemType='S-Function';
            if strict
                functionName=get_param(systemH,'FunctionName');
                functionPath=which(functionName);
                if isempty(functionPath)
                    meObj=MException('pslink:sfunctionNotFound',...
                    message('polyspace:gui:pslink:sfunctionNotFound',functionName).getString());
                    return
                end
                [~,~,functionExt]=fileparts(functionPath);
                if any(strcmp(functionExt,{'.p','.m'}))
                    meObj=MException('pslink:unsupportedSFunctionMATLAB',...
                    message('polyspace:gui:pslink:unsupportedSFunctionMATLAB',functionName).getString());
                    return
                end
                isNotSFcnCompatible=~sldv.code.sfcn.isSFcnCompatible(functionName,1,1);
                if isNotSFcnCompatible
                    meObj=MException('pslink:unsupportedSFunction',...
                    message('polyspace:gui:pslink:unsupportedSFunction',functionName).getString());
                    return
                end
            end
        else
            systemType='';
        end
    catch Me

        systemH=[];
        meObj=MException('pslink:badSystem',message('polyspace:gui:pslink:unexpectedErrorCheckingSystem',Me.message).getString());
        return
    end

    if isempty(systemH)||isempty(modelH)||isempty(systemType)
        systemH=[];
        meObj=MException('pslink:badSystem',message(badSystemId).getString());
        return
    end
    if strcmpi(get_param(modelH,'BlockDiagramType'),'library')
        meObj=MException('pslink:modelIsLib',message('polyspace:gui:pslink:modelIsLib',get_param(modelH,'Name')).getString());
        return
    end

