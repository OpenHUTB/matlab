function changes=upgradeSerDesBlocks(system,varargin)







    validateattributes(system,{'char'},{'nonempty'});
    p=inputParser;
    addParameter(p,'dryRun','off');
    parse(p,varargin{:});
    isDryRun=~strcmp(p.Results.dryRun,'off');


    maObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    changes={};


    blocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','SubSystem');
    blocks=maObj.filterResultWithExclusion(blocks);

    for blockIdx=1:length(blocks)
        block=blocks{blockIdx};
        hBlock=get_param(block,'Handle');
        maskObj=get_param(hBlock,'MaskObject');







        if isempty(maskObj)
            continue;
        end
        blockParts=strsplit(block,'/');
        if length(blockParts)~=3||...
            (~strcmp(blockParts{2},'Tx')&&~strcmp(blockParts{2},'Rx'))
            continue;
        end


        hSysObjHdl=find_system(block,'LookUnderMasks','on','FindAll','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FirstResultOnly','on','Type','block','BlockType','MATLABSystem',...
        'Name',maskObj.Type,'System',['serdes.',maskObj.Type]);
        if isempty(hSysObjHdl)
            continue;
        end

        sysName=get_param(hSysObjHdl,'System');
        blockName=getfullname(hBlock);
        paramNames=get_param(hBlock,'MaskNames');
        isSerDes=true;
        switch sysName
        case 'serdes.AGC'



            paramName='AveragingLength';
            newPrompt='Averaging length';
            changed=checkOrSetParamPrompt(hBlock,paramName,newPrompt,isDryRun);
            if changed
                changes{end+1}={blockName,paramName,...
                DAStudio.message('serdes:advisor:PromptChangeAction',newPrompt)};%#ok<AGROW>
            end
        case 'serdes.CDR'



            paramName='PhaseOffset';
            newPrompt='Phase offset (symbol time)';
            changed=checkOrSetParamPrompt(hBlock,paramName,newPrompt,isDryRun);
            if changed
                changes{end+1}={blockName,paramName,...
                DAStudio.message('serdes:advisor:PromptChangeAction',newPrompt)};%#ok<AGROW>
            end


            paramName='Step';
            if~any(contains(paramNames,paramName))
                changes{end+1}={blockName,paramName,...
                DAStudio.message('serdes:advisor:PromoteToMaskAction')};%#ok<AGROW>
                if~isDryRun
                    promoteCDRStep(maskObj,hSysObjHdl);
                end
            end


            paramName='ReferenceOffset';
            control=maskObj.getDialogControl(paramName);
            curTooltip=control.Tooltip;
            newTooltip='Reference clock frequency offset in parts per million (ppm)';
            if~strcmp(curTooltip,newTooltip)
                changes{end+1}={blockName,paramName,...
                DAStudio.message('serdes:advisor:TooltipChangeAction',newTooltip)};%#ok<AGROW>
                if~isDryRun
                    control.Tooltip=newTooltip;
                end
            end


            constraintName='refOffsetConstraint';
            constraint=maskObj.getParameterConstraint(constraintName);
            rules=constraint.ConstraintRules;
            newValue='-300';
            if~strcmp(rules.Minimum,newValue)
                changes{end+1}={blockName,paramName,...
                DAStudio.message('serdes:advisor:ConstraintValueChangeAction',...
                constraintName,'Minimum',newValue)};%#ok<AGROW>
                if~isDryRun
                    rules.Minimum=newValue;
                end
            end


            newValue='300';
            if~strcmp(rules.Maximum,newValue)
                changes{end+1}={blockName,paramName,...
                DAStudio.message('serdes:advisor:ConstraintValueChangeAction',...
                constraintName,'Maximum',newValue)};%#ok<AGROW>
                if~isDryRun
                    rules.Maximum=newValue;
                end
            end

        case 'serdes.CTLE'



            paramName='Specification';
            param=maskObj.getParameter(paramName);
            curCallback=param.Callback;
            newCallback='serdes.internal.callbacks.datapathCtleConfigUpdate(gcb);';


            if~any(contains(curCallback,newCallback))
                changes{end+1}={blockName,paramName,...
                DAStudio.message('serdes:advisor:AddConfigSelectCallbackAction')};%#ok<AGROW>
                if~isDryRun
                    if~isempty(curCallback)&&curCallback(end)~=';'
                        curCallback=[curCallback,';'];%#ok<AGROW>
                    end
                    param.Callback=[curCallback,newCallback];
                end
            end


            paramName='ACGain';
            param=maskObj.getParameter(paramName);
            curCallback=param.Callback;
            newCallback='serdes.internal.callbacks.datapathCtleConfigUpdate(gcb);';


            if~any(contains(curCallback,newCallback))
                changes{end+1}={blockName,paramName,...
                DAStudio.message('serdes:advisor:AddConfigSelectCallbackAction')};%#ok<AGROW>
                if~isDryRun
                    if~isempty(curCallback)&&curCallback(end)~=';'
                        curCallback=[curCallback,';'];%#ok<AGROW>
                    end
                    param.Callback=[curCallback,newCallback];
                end
            end


            paramName='ControlPlot';
            plotButton=maskObj.getDialogControl(paramName);
            if isempty(plotButton)
                changes{end+1}={blockName,paramName,...
                DAStudio.message('serdes:advisor:AddControlPlotButton')};%#ok<AGROW>
                if~isDryRun
                    addControlPlotButton(maskObj);
                end
            end

        case 'serdes.DFECDR'



            paramName='EqualizationStep';
            newPrompt='Adaptive step size (V)         ';
            changed=checkOrSetParamPrompt(hBlock,paramName,newPrompt,isDryRun);
            if changed
                changes{end+1}={blockName,paramName,...
                DAStudio.message('serdes:advisor:PromptChangeAction',newPrompt)};%#ok<AGROW>
            end


            constraintName='eqStepConstraint';
            constraint=maskObj.getParameterConstraint(constraintName);
            rules=constraint.ConstraintRules;
            curValue=rules.Sign;
            newValue={'positive';'zero'};
            if~isequal(curValue,newValue)
                changes{end+1}={blockName,paramName,...
                DAStudio.message('serdes:advisor:ConstraintValueChangeAction',...
                constraintName,'Sign',strjoin(newValue,', '))};%#ok<AGROW>
                if~isDryRun
                    rules.Sign=newValue;
                end
            end


            paramName='MinimumTap';
            newPrompt='Minimum DFE tap value(s) (V) ';
            changed=checkOrSetParamPrompt(hBlock,paramName,newPrompt,isDryRun);
            if changed
                changes{end+1}={blockName,paramName,...
                DAStudio.message('serdes:advisor:PromptChangeAction',newPrompt)};%#ok<AGROW>
            end


            paramName='MaximumTap';
            newPrompt='Maximum DFE tap value(s) (V)';
            changed=checkOrSetParamPrompt(hBlock,paramName,newPrompt,isDryRun);
            if changed
                changes{end+1}={blockName,paramName,...
                DAStudio.message('serdes:advisor:PromptChangeAction',newPrompt)};%#ok<AGROW>
            end


            paramName='PhaseOffset';
            newPrompt='Phase offset (symbol time)           ';
            changed=checkOrSetParamPrompt(hBlock,paramName,newPrompt,isDryRun);
            if changed
                changes{end+1}={blockName,paramName,...
                DAStudio.message('serdes:advisor:PromptChangeAction',newPrompt)};%#ok<AGROW>
            end


            paramName='ReferenceOffset';
            newPrompt='Reference offset (ppm)                ';
            changed=checkOrSetParamPrompt(hBlock,paramName,newPrompt,isDryRun);
            if changed
                changes{end+1}={blockName,paramName,...
                DAStudio.message('serdes:advisor:PromptChangeAction',newPrompt)};%#ok<AGROW>
            end


            control=maskObj.getDialogControl(paramName);
            curTooltip=control.Tooltip;
            newTooltip='Reference clock frequency offset in parts per million (ppm)';
            if~strcmp(curTooltip,newTooltip)
                changes{end+1}={blockName,paramName,...
                DAStudio.message('serdes:advisor:TooltipChangeAction',newTooltip)};%#ok<AGROW>
                if~isDryRun
                    control.Tooltip=newTooltip;
                end
            end


            paramName='ClockStep';
            newPrompt='Step (symbol time)                      ';
            changed=checkOrSetParamPrompt(hBlock,paramName,newPrompt,isDryRun);
            if changed
                changes{end+1}={blockName,paramName,...
                DAStudio.message('serdes:advisor:PromptChangeAction',newPrompt)};%#ok<AGROW>
            end


            constraintName='refOffsetConstraint';
            constraint=maskObj.getParameterConstraint(constraintName);
            rules=constraint.ConstraintRules;
            newValue='-300';
            if~strcmp(rules.Minimum,newValue)
                changes{end+1}={blockName,paramName,...
                DAStudio.message('serdes:advisor:ConstraintValueChangeAction',...
                constraintName,'Minimum',newValue)};%#ok<AGROW>
                if~isDryRun
                    rules.Minimum=newValue;
                end
            end


            newValue='300';
            if~strcmp(rules.Maximum,newValue)
                changes{end+1}={blockName,paramName,...
                DAStudio.message('serdes:advisor:ConstraintValueChangeAction',...
                constraintName,'Maximum',newValue)};%#ok<AGROW>
                if~isDryRun
                    rules.Maximum=newValue;
                end
            end


            paramName='Taps2x';
            taps2xDialogCtrl=maskObj.getDialogControl(paramName);
            if isempty(taps2xDialogCtrl)
                changes{end+1}={blockName,paramName,...
                DAStudio.message('serdes:advisor:PromoteToMaskAction')};%#ok<AGROW>
                if~isDryRun
                    promoteDFECDRTaps2x(hBlock,hSysObjHdl);
                    addInitTaps2x(hBlock,hSysObjHdl);
                end
            end

        case 'serdes.FFE'



            paramName='ControlPlot';
            plotButton=maskObj.getDialogControl(paramName);
            if isempty(plotButton)
                changes{end+1}={blockName,paramName,...
                DAStudio.message('serdes:advisor:AddControlPlotButton')};%#ok<AGROW>
                if~isDryRun
                    addControlPlotButton(maskObj);
                end
            end

        case 'serdes.SaturatingAmplifier'



            paramName='ControlPlot';
            plotButton=maskObj.getDialogControl(paramName);
            if isempty(plotButton)
                changes{end+1}={blockName,paramName,...
                DAStudio.message('serdes:advisor:AddControlPlotButton')};%#ok<AGROW>
                if~isDryRun
                    addControlPlotButton(maskObj);
                end
            end

        case 'serdes.VGA'



        case 'serdes.PassThrough'


            openCallback='serdes.internal.callbacks.datapathOpen(gcb);';
            curCallback=get_param(hBlock,'OpenFcn');
            if contains(curCallback,openCallback)
                changes{end+1}={blockName,'OpenFcn',...
                DAStudio.message('serdes:advisor:RemoveOpenCallbackAction')};%#ok<AGROW>
                if~isDryRun
                    newCallback=erase(curCallback,openCallback);
                    set_param(hBlock,'OpenFcn',newCallback);
                end
            end
        otherwise
            isSerDes=false;
        end


        if isSerDes

            mtv=get_param(hBlock,'MaskTunableValues');
            paramNames=get_param(hBlock,'MaskNames');
            for paramIdx=1:length(paramNames)
                if strcmp(mtv(paramIdx),'on')
                    changes{end+1}={blockName,paramNames{paramIdx},...
                    DAStudio.message('serdes:advisor:ChangePropertyAction',...
                    'Tunable','off')};%#ok<AGROW>
                end
            end
            if~isDryRun
                set_param(hBlock,'MaskTunableValues',...
                cellfun(@(x)'off',mtv,'UniformOutput',false));
            end


            curCallback=get_param(hBlock,'UndoDeleteFcn');
            newCallback='serdes.internal.callbacks.datapathUndoDelete(gcb);';

            if~any(contains(curCallback,newCallback))
                changes{end+1}={blockName,'UndoDeleteFcn',...
                DAStudio.message('serdes:advisor:AddUndoDeleteCallbackAction')};%#ok<AGROW>
                if~isDryRun
                    if~isempty(curCallback)&&curCallback(end)~=';'
                        curCallback=[curCallback,';'];%#ok<AGROW>
                    end
                    set_param(hBlock,'UndoDeleteFcn',[curCallback,newCallback]);
                end
            end
        end
    end

end

function changed=checkOrSetParamPrompt(hBlock,paramName,newPrompt,isDryRun)
    validateattributes(hBlock,{'double'},{'nonempty','scalar'});
    validateattributes(paramName,{'char'},{'nonempty'});
    validateattributes(newPrompt,{'char'},{'nonempty'});
    changed=false;
    prompts=get_param(hBlock,'MaskPrompts');
    paramNames=get_param(hBlock,'MaskNames');
    paramIdx=find(strcmp(paramNames,paramName));
    if~isempty(paramIdx)
        existPrompt=prompts(paramIdx(1));
        if~isempty(existPrompt)&&~strcmp(newPrompt,existPrompt)
            changed=true;
            if~isDryRun
                prompts{paramIdx(1)}=newPrompt;
                set_param(hBlock,'MaskPrompts',prompts);
            end
        end
    end
end

function promoteCDRStep(maskObj,hSysObjHdl)
    validateattributes(maskObj,{'Simulink.Mask'},{'nonempty','scalar'});
    validateattributes(hSysObjHdl,{'double'},{'nonempty','scalar'});

    containerName='ParametersGroup';
    if isempty(maskObj.getDialogControl(containerName))
        containerName='PametersGroup';
    end

    if~isempty(maskObj.getDialogControl(containerName))
        sysObjName=get_param(hSysObjHdl,'Name');

        maskObj.addParameter('Name','Step',...
        'Type','promote',...
        'TypeOptions',{[sysObjName,'/Step']},...
        'Prompt','Step (symbol time)',...
        'Evaluate','on',...
        'Tunable','off',...
        'NeverSave','off',...
        'Hidden','off',...
        'ReadOnly','off',...
        'Enabled','on',...
        'Visible','on',...
        'ShowTooltip','on',...
        'Container',containerName);

        control=maskObj.getDialogControl('Step');
        if~isempty(control)
            control.Tooltip='Phase resolution of recovered clock';

            maskObj.addParameterConstraint('Name','clkStepConstraint',...
            'Rules',{{'DataType','double',...
            'Dimension',{'scalar'},...
            'Complexity',{'real'},...
            'Sign',{'positive'},...
            'Finiteness',{'finite'},...
            'Maximum','0.5'}},...
            'Parameters',{'Step'});
        end
    end
end



function promoteDFECDRTaps2x(hBlock,hSysObjHdl)
    validateattributes(hBlock,{'double'},{'nonempty','scalar'});
    validateattributes(hSysObjHdl,{'double'},{'nonempty','scalar'});
    maskObj=get_param(hBlock,'MaskObject');
    sysObjName=get_param(hSysObjHdl,'Name');

    maskObj.addParameter('Name','Taps2x',...
    'Type','promote',...
    'TypeOptions',{[sysObjName,'/Taps2x']},...
    'Prompt','2x tap weights',...
    'Tunable','off',...
    'NeverSave','off',...
    'Hidden','off',...
    'ReadOnly','off',...
    'Enabled','on',...
    'Visible','on',...
    'ShowTooltip','on',...
    'Container','DFETab');

    control=maskObj.getDialogControl('Taps2x');
    control.Tooltip='Multiply all DFE tap weights by 2';
end



function addInitTaps2x(hBlock,hSysObjHdl)
    validateattributes(hBlock,{'double'},{'nonempty','scalar'});
    validateattributes(hSysObjHdl,{'double'},{'nonempty','scalar'});
    mlFcnName=[get_param(hBlock,'Parent'),'/Init/Initialize Function/MATLAB Function'];
    emChart=find(slroot,'-isa','Stateflow.EMChart','Path',mlFcnName);

    taps2xOnOff=get_param(hSysObjHdl,'Taps2x');
    if~isempty(emChart)&&~isempty(taps2xOnOff)


        initLines=splitlines(emChart.Script);
        blockName=get_param(hBlock,'Name');
        blockLineIdxs=startsWith(initLines,[blockName,'Init.']);
        if~isempty(blockLineIdxs)

            startPat=[blockName,'Init.Taps2x = '];
            if~any(startsWith(initLines(blockLineIdxs),startPat))
                lastLineIdx=find(blockLineIdxs,1,'last');
                if strcmp(taps2xOnOff,'on')
                    taps2xOneZero='true';
                else
                    taps2xOneZero='false';
                end
                newInitLine=[startPat,taps2xOneZero,';'];
                newInitLines=[initLines(1:lastLineIdx);{newInitLine};initLines(lastLineIdx+1:end)];
                emChart.Script=strjoin(newInitLines,'\n');
            end
        end
    end
end



function addControlPlotButton(maskObj)
    validateattributes(maskObj,{'Simulink.Mask'},{'nonempty','scalar'});
    panel=maskObj.getDialogControl('Container4');
    if isempty(panel)
        maskObj.addDialogControl('Name','Container4',...
        'Type','panel',...
        'Row','new');
    end
    maskObj.addDialogControl('Name','PaddingAbove',...
    'Type','text',...
    'Prompt','',...
    'HorizontalStretch','on',...
    'Row','new',...
    'Container','Container4');
    maskObj.addDialogControl('Name','ControlPlot',...
    'Type','pushbutton',...
    'Prompt','Visualize Response',...
    'Callback','serdes.internal.callbacks.plotBlockResponse(gcb);',...
    'Enabled','on',...
    'Visible','on',...
    'Row','current',...
    'HorizontalStretch','on',...
    'Container','Container4');
    maskObj.addDialogControl('Name','PaddingBelow',...
    'Type','text',...
    'Prompt','',...
    'HorizontalStretch','on',...
    'Row','current',...
    'Container','Container4');
end
