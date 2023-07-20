




function initUpdate(block,calledFrom)
    mws=get_param(bdroot(block),'ModelWorkspace');
    requiredMWSElements=["SampleInterval","ChannelImpulse","RowSize","Aggressors","ImpulseMatrix","SerdesIBIS"];
    externalInitMaskParameterName='ExternalInit';
    commentStepMaskParameterName='CommentStep';
    switch(calledFrom)
    case "Open"

        open_system(block,'mask');
        if~isempty(mws)&&all(arrayfun(@(x)mws.hasVariable(x),requiredMWSElements))
            maskObj=Simulink.Mask.get(block);
            maskNames={maskObj.Parameters.Name};

            if~any(contains(maskNames,externalInitMaskParameterName))||...
                ~any(contains(maskNames,commentStepMaskParameterName))
                return
            end

            initMaskExternalInit=maskObj.Parameters(strcmp(maskNames,externalInitMaskParameterName)).Value;
            if isempty(initMaskExternalInit)
                return
            end
            isExternalInitinMask=strcmp(initMaskExternalInit,'on');
            hasAllExtInitFiles=serdes.utilities.externalinit.hasExternalInitFiles;
            hasExtInitCodeInInit=checkInitCode(block);

            if isExternalInitinMask&&~hasAllExtInitFiles&&hasExtInitCodeInInit

                error(message('serdes:utilities:ExternalInitFilesMissing'));
            end
        end
    case "Initialization"
        if~isempty(mws)&&all(arrayfun(@(x)mws.hasVariable(x),requiredMWSElements))
            maskObj=Simulink.Mask.get(block);
            maskNames={maskObj.Parameters.Name};

            if~any(contains(maskNames,externalInitMaskParameterName))||...
                ~any(contains(maskNames,commentStepMaskParameterName))
                return
            end

            initMaskExternalInit=maskObj.Parameters(strcmp(maskNames,externalInitMaskParameterName)).Value;
            if isempty(initMaskExternalInit)
                return
            end
            isExternalInitinMask=strcmp(initMaskExternalInit,'on');
            hasAllExtInitFiles=serdes.utilities.externalinit.hasExternalInitFiles;
            hasExtInitCodeInInit=checkInitCode(block);


            if isExternalInitinMask&&~hasAllExtInitFiles&&hasExtInitCodeInInit

                error(message('serdes:utilities:ExternalInitFilesMissing'));
            elseif isExternalInitinMask&&~hasAllExtInitFiles&&~hasExtInitCodeInInit

                error(message('serdes:utilities:ExternalInitChangesNotApplied'));
            elseif~isExternalInitinMask&&hasAllExtInitFiles&&hasExtInitCodeInInit

                error(message('serdes:utilities:ExternalInitChangesNotApplied'));
            end
        end
    end
end

function hasExtInitCodeInInit=checkInitCode(blockPath)
    hasExtInitCodeInInit=false;
    blocks={'Tx','Rx'};
    openingCommentExternalInit='% NOTE: This init function has been converted to external init.  Do not edit here.';
    for blockIdx=1:size(blocks,2)
        mlFcnName=[bdroot(blockPath),'/',blocks{blockIdx},'/Init/Initialize Function/MATLAB Function'];
        emChart=find(slroot,'-isa','Stateflow.EMChart','Path',mlFcnName);
        if~isempty(emChart)
            initCode=emChart.Script;
            if contains(initCode,openingCommentExternalInit)
                hasExtInitCodeInInit=true;
            end
        end
    end
end

