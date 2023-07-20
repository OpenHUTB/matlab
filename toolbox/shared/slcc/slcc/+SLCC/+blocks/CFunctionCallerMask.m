classdef(Hidden)CFunctionCallerMask


    methods(Static,Hidden)
        function updateParams(blkH,fcnName,paramStrings,paramLabels)

            if isempty(paramStrings)
                maskObj=Simulink.Mask.get(blkH);
                if~isempty(maskObj)
                    maskSampleTime=get_param(blkH,'sampleTime');
                    maskObj.delete;
                    set_param(blkH,'sampleTime',maskSampleTime);
                end
                return;
            end

            maskObj=createMaskIfNeeded(blkH,fcnName);

            paramStrings=validParamNames(paramStrings);
            paramStrings{end+1}='SampleTime';
            paramsOnMask={maskObj.Parameters.Name};
            paramsToBeRemoved=setdiff(paramsOnMask,paramStrings);

            for i=1:numel(paramsToBeRemoved)
                maskObj.removeParameter(paramsToBeRemoved{i});
            end


            paramsOnMask={maskObj.Parameters.Name};
            for i=1:numel(paramsOnMask)
                pIncomingIdx=strcmp(paramStrings,paramsOnMask{i});
                paramObj=maskObj.getParameter(paramsOnMask{i});
                if~strcmp(paramsOnMask{i},'SampleTime')&&~strcmp(paramLabels{pIncomingIdx},paramObj.Prompt)
                    paramObj.Prompt=paramLabels{pIncomingIdx};
                end
            end


            paramsOnMask={maskObj.Parameters.Name};
            if isequal(paramsOnMask,paramStrings)
                return;
            end

            [paramsToBeAdded,iPS]=setdiff(paramStrings,paramsOnMask);
            for i=1:numel(paramsToBeAdded)
                if(~isequal(paramsToBeAdded{i},'SampleTime'))
                    addParam(maskObj,paramsToBeAdded{i},'0',paramLabels{iPS(i)});
                end
            end
            if(~any(strcmp(paramsOnMask,'SampleTime')))
                sampleTimePrompt=message('Simulink:blkprm_prompts:AllSrcBlksSampleTime');
                maskObj.addParameter('Prompt',getString(sampleTimePrompt),'Type','promote','TypeOptions',{'SampleTime'});
            end


            maskParamArray=maskObj.Parameters;

            paramsOnMask={maskObj.Parameters.Name};

            [~,paramOrderIndex]=ismember(paramStrings,paramsOnMask);
            maskObj.set('Parameters',maskParamArray(paramOrderIndex));
        end

        function blockUsesParamLabelAsName=initialize(blkH,fcnName,instanceParams,orderedParams,paramLabels)
            if isempty(instanceParams)
                createEmptyMask(blkH);
                return;
            end
            maskObj=createMaskIfNeeded(blkH,fcnName);
            instanceParamNames={instanceParams.Name};
            blockUsesParamLabelAsName=false;
            for i=1:numel(orderedParams)
                if useNameToMatchInstance(instanceParamNames,orderedParams,paramLabels)
                    instanceIdx=ismember(instanceParamNames,orderedParams{i});
                else



                    blockUsesParamLabelAsName=true;
                    instanceIdx=ismember(instanceParamNames,paramLabels{i});
                end
                addParam(maskObj,instanceParams(instanceIdx).Name,instanceParams(instanceIdx).Value,paramLabels{i});

            end
            sampleTimePrompt=message('Simulink:blkprm_prompts:AllSrcBlksSampleTime');
            maskObj.addParameter('Prompt',getString(sampleTimePrompt),'Type','promote','TypeOptions',{'SampleTime'});
        end
    end
end

function maskObj=createMaskIfNeeded(blkH,fcnName)
    maskObj=Simulink.Mask.get(blkH);
    if(isempty(maskObj))
        maskObj=Simulink.Mask.create(blkH);
        maskObj.SelfModifiable='on';
    end
    blockHeaderGroup='CCBlockHeaderGroup';
    blockHeaderDC=maskObj.getDialogControl(blockHeaderGroup);
    fcnNameDCName='FcnNameTxt';
    if strcmpi(get_param(blkH,'BlockType'),'CFunction')
        groupPrompt='C Function Block';
        descPrompt=DAStudio.message('Simulink:CustomCode:CFunctionBlockDialogText');
    else
        groupPrompt='C Caller';
        descPrompt=DAStudio.message('Simulink:CustomCode:CallTheFunction',fcnName);
    end
    if isempty(blockHeaderDC)

        maskObj.addDialogControl('Type','group',...
        'Name',blockHeaderGroup,'Prompt',groupPrompt);
        maskObj.addDialogControl('Container',blockHeaderGroup,'Type','text',...
        'Name',fcnNameDCName,'Prompt',descPrompt);
        maskObj.addDialogControl('Container',blockHeaderGroup,'Type','hyperlink',...
        'Name','BlockDialogLink',...
        'Prompt','Open Block Dialog',...
        'Callback','open_system(gcb,''force'')');
    else
        fcnNameDC=maskObj.getDialogControl(fcnNameDCName);
        if~isequal(fcnNameDC.Prompt,descPrompt)
            fcnNameDC.Prompt=descPrompt;
        end
    end
end

function createEmptyMask(blkH)
    maskObj=Simulink.Mask.get(blkH);
    if isempty(maskObj)

        assert(bdIsLibrary(bdroot(blkH)),'Expected Library model');
        assert(strcmpi(get_param(blkH,'BlockType'),'CFunction'),'Expected C Function block');

        maskObj=Simulink.Mask.create(blkH);
        maskObj.SelfModifiable='on';
    end

end
function addParam(maskObj,name,value,label)
    maskObj.addParameter('Type','edit','Name',name,'Prompt',label,...
    'Value',value,'Evaluate','on');
end

function paramStrings=validParamNames(paramStrings)

    for i=1:numel(paramStrings)
        if~isvarname(paramStrings(i))
            paramStrings(i)=matlab.lang.makeValidName(paramStrings(i),'Prefix','p');
        end
    end
end

function useName=useNameToMatchInstance(instanceParamNames,orderedParams,paramLabels)




    if isequal(instanceParamNames,orderedParams)
        useName=true;
    elseif isequal(instanceParamNames,paramLabels)
        useName=false;
    else
        useName=true;
    end
end