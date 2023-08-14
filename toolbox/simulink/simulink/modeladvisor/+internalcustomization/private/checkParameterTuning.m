function ResultDescription=checkParameterTuning(system)




    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(true);

    model=bdroot(system);

    currentCheckObj=mdladvObj.CheckCellArray{mdladvObj.ActiveCheckID};
    currentCheckObj.Action.Enable=false;

    [errors,warnings]=locRunModel(model);

    ResultDescription=cell(0);
    ActionDescription=cell(0);
    ActionItems=cell(0);



    if(~isempty(errors))
        MsgID='Simulink:blocks:DivideByZero';
        if(locCheckErrorIssue(errors,MsgID))
            [ResultDescription,ActionDescription,ActionItems]=...
            locParseErrors(errors,MsgID,ResultDescription,ActionDescription,ActionItems);
        end
    end
    if(~isempty(warnings))
        MsgID='Simulink:blocks:DivideByZero';
        if(locCheckWarningIssue(warnings,MsgID))
            [ResultDescription,ActionDescription,ActionItems]=...
            locParseWarnings(warnings,MsgID,ResultDescription,ActionDescription,ActionItems);
        end
    end






    if(~isempty(errors))
        MsgID='Simulink:blocks:MPSwitchControlInputRangeError';
        if(locCheckErrorIssue(errors,MsgID))
            [ResultDescription,ActionDescription,ActionItems]=...
            locParseErrors(errors,MsgID,ResultDescription,ActionDescription,ActionItems);
        end
    end
    if(~isempty(warnings))
        MsgID='Simulink:blocks:MPSwitchControlInputOORIndexValue';
        if(locCheckWarningIssue(warnings,MsgID))
            [ResultDescription,ActionDescription,ActionItems]=...
            locParseWarnings(warnings,MsgID,ResultDescription,ActionDescription,ActionItems);
        end
    end

    if(~isempty(errors))
        MsgID='Simulink:blocks:SelIntegerOutOfBounds';
        if(locCheckErrorIssue(errors,MsgID))
            [ResultDescription,ActionDescription,ActionItems]=...
            locParseErrors(errors,MsgID,ResultDescription,ActionDescription,ActionItems);
        end
    end



    if(~isempty(warnings))
        MsgID='Simulink:blocks:RaiseToNegative';
        if(locCheckWarningIssue(warnings,MsgID))
            [ResultDescription,ActionDescription,ActionItems]=...
            locParseWarnings(warnings,MsgID,ResultDescription,ActionDescription,ActionItems);
        end
    end

    if(~isempty(ActionItems))
        currentCheckObj.ResultData.SampleTimeActions=ActionItems;
        currentCheckObj.ResultData.SampleTimeResults=ActionDescription;
        mdladvObj.setCheckResultStatus(false);
        currentCheckObj.Action.Enable=true;
        return;
    else
        ResultDescription=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:engine:MAParameterTuning_Pass'));
        return;
    end





    function[Errors,Warnings]=locRunModel(model)

        Errors=[];

        try
            handleWarningListener('enable');
            ocWarningHandler=onCleanup(@()handleWarningListener('disable'));

            load_system(model);
            ParameterStruct=struct();

            ParameterStruct.StopTime=get_param(model,'StartTime');

            origDirty=get_param(model,'Dirty');




            switchBlks=find_system(model,'LookInsideSubsystemReference','off','MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','MultiPortSwitch');
            origSwitchBlockMsgLevels=cell(length(switchBlks));
            for blkIdx=1:length(switchBlks)
                origSwitchBlockMsgLevels{blkIdx}=get_param(switchBlks{blkIdx},'DiagnosticForDefault');
                if(strcmpi(origSwitchBlockMsgLevels{blkIdx},'error'))
                    set_param(switchBlks{blkIdx},'DiagnosticForDefault','Warning');
                end
            end


            origSingleTaskRateTransMsgLevel=get_param(model,'SingleTaskRateTransMsg');
            if(strcmpi(origSingleTaskRateTransMsgLevel,'error'))

                ParameterStruct.SingleTaskRateTransMsg='warning';
            end

            origIntegerOverflowMsgLevel=get_param(model,'IntegerOverflowMsg');
            if(strcmpi(origIntegerOverflowMsgLevel,'error'))

                ParameterStruct.IntegerOverflowMsg='warning';
            end

            sim(model,ParameterStruct);

        catch ME
            Errors=ME;
        end


        Warnings=slsvWarningListener('get');
        for w=1:length(Warnings)
            Warnings{w}=locGetWarningForMdlRef(Warnings{w});
        end


        for blkIdx=1:length(switchBlks)
            set_param(switchBlks{blkIdx},'DiagnosticForDefault',origSwitchBlockMsgLevels{blkIdx});
        end
        set_param(model,'Dirty',origDirty);




        function handleWarningListener(enableAction)
            slsvWarningListener('clear');
            slsvWarningListener(enableAction);

            function hasErrorIssue=locCheckErrorIssue(errors,errorid)
                hasErrorIssue=false;
                if strcmpi(errors.identifier,errorid)
                    hasErrorIssue=true;
                    return;
                else
                    for errIdx=1:length(errors.cause)
                        if strcmpi(errors.cause{errIdx}.identifier,errorid)
                            hasErrorIssue=true;
                            return;
                        end
                    end
                end
                function hasWarnIssue=locCheckWarningIssue(warnings,warningid)
                    hasWarnIssue=false;
                    for warningIdx=1:length(warnings)
                        if strcmpi(warnings{warningIdx}.identifier,warningid)
                            hasWarnIssue=true;
                        end
                    end



                    function[ResultDescriptionRes,ActionDescriptionRes,ActionItemsRes]=...
                        locParseErrors(errors,errorid,ResultDescription,ActionDescription,ActionItems)
                        ResultDescriptionRes=ResultDescription;
                        ActionDescriptionRes=ActionDescription;
                        ActionItemsRes=ActionItems;

                        ResultDescription_one=cell(0);
                        ActionDescription_one=cell(0);
                        ActionItems_one=cell(0);

                        switch errorid
                        case 'Simulink:blocks:DivideByZero'
                            [ResultDescription_one,ActionDescription_one,ActionItems_one]=...
                            locParseForDivideByZeroError(errors);
                        case 'Simulink:blocks:MPSwitchControlInputRangeError'
                            [ResultDescription_one,ActionDescription_one,ActionItems_one]=...
                            locParseForInvalidIndexError(errors);
                        case 'Simulink:blocks:SelIntegerOutOfBounds'
                            [ResultDescription_one,ActionDescription_one,ActionItems_one]=...
                            locParseForSelectorError(errors);
                        otherwise
                            disp(DAStudio.message('ModelAdvisor:engine:UnknownIssue'));
                        end

                        ResultDescriptionRes=[ResultDescriptionRes,ResultDescription_one];
                        ActionDescriptionRes=[ActionDescriptionRes,ActionDescription_one];
                        ActionItemsRes=[ActionItemsRes,ActionItems_one];


                        function[ResultDescriptionRes,ActionDescriptionRes,ActionItemsRes]=...
                            locParseWarnings(warnings,warningid,ResultDescription,ActionDescription,ActionItems)
                            ResultDescriptionRes=ResultDescription;
                            ActionDescriptionRes=ActionDescription;
                            ActionItemsRes=ActionItems;
                            ResultDescription_one=cell(0);
                            ActionDescription_one=cell(0);
                            ActionItems_one=cell(0);

                            switch warningid
                            case{'Simulink:blocks:DivideByZero',...
                                'Simulink:blocks:MPSwitchControlInputOORIndexValue',...
                                'Simulink:blocks:RaiseToNegative'}
                                [ResultDescription_one,ActionDescription_one,ActionItems_one]=...
                                locParseForCtrlBlkWarning(warnings,warningid);
                            otherwise
                                disp(DAStudio.message('ModelAdvisor:engine:UnknownIssue'));
                            end

                            ResultDescriptionRes=[ResultDescriptionRes,ResultDescription_one];
                            ActionDescriptionRes=[ActionDescriptionRes,ActionDescription_one];
                            ActionItemsRes=[ActionItemsRes,ActionItems_one];




                            function[ResultDescription,ActionDescription,actionItem]=locParseForDivideByZeroError(errors)

                                MsgID='Simulink:blocks:DivideByZero';

                                if strcmpi(errors.identifier,MsgID)
                                    [ResultDescription,ActionDescription,actionItem]=...
                                    locParseOneMsgForCtrlBlk(errors,MsgID);
                                    return;
                                else
                                    for errIdx=1:length(errors.cause)
                                        if strcmpi(errors.cause{errIdx}.identifier,MsgID)
                                            [ResultDescription,ActionDescription,actionItem]=...
                                            locParseOneMsgForCtrlBlk(errors.cause{errIdx},MsgID);
                                            return;
                                        end
                                    end
                                end




                                function[ResultDescription,ActionDescription,actionItem]=locParseForInvalidIndexError(errors)

                                    MsgID='Simulink:blocks:MPSwitchControlInputRangeError';

                                    if strcmpi(errors.identifier,MsgID)
                                        [ResultDescription,ActionDescription,actionItem]=...
                                        locParseOneMsgForCtrlBlk(errors,MsgID);
                                        return;
                                    else
                                        for errIdx=1:length(errors.cause)
                                            if strcmpi(errors.cause{errIdx}.identifier,MsgID)
                                                [ResultDescription,ActionDescription,actionItem]=...
                                                locParseOneMsgForCtrlBlk(errors.cause{errIdx},MsgID);
                                                return;
                                            end
                                        end
                                    end

                                    function wOut=locGetWarningForMdlRef(wIn)
                                        wOut=wIn;
                                        if strcmpi(wIn.identifier,'Simulink:blocks:ForEachSS_WarningInOneIter')||...
                                            strcmpi(wIn.identifier,'Simulink:modelReference:NormalModeSimulationWarning')
                                            if length(wIn.cause)==1
                                                wOut=wIn.cause{1};
                                            end
                                        end



                                        function[ResultDescription,ActionDescription,actionItem]=locParseForSelectorError(errors)

                                            MsgID='Simulink:blocks:SelIntegerOutOfBounds';

                                            if strcmpi(errors.identifier,MsgID)
                                                [ResultDescription,ActionDescription,actionItem]=...
                                                locParseOneMsgForCtrlBlk(errors,MsgID);
                                                return;
                                            else
                                                for errIdx=1:length(errors.cause)
                                                    if strcmpi(errors.cause{errIdx}.identifier,MsgID)
                                                        [ResultDescription,ActionDescription,actionItem]=...
                                                        locParseOneMsgForCtrlBlk(errors.cause{errIdx},MsgID);
                                                        return;
                                                    end
                                                end
                                            end



                                            function[ResultDescription,ActionDescription,actionItem]=locParseForCtrlBlkWarning(warnings,warningid)

                                                ResultDescription=cell(0);
                                                ActionDescription=cell(0);
                                                actionItem=cell(0);
                                                for warningIdx=1:length(warnings)
                                                    if strcmpi(warnings{warningIdx}.identifier,warningid)
                                                        [ResultDescription_dbz,ActionDescription_dbz,actionItem_dbz]=...
                                                        locParseOneMsgForCtrlBlk(warnings{warningIdx},warningid);
                                                        ResultDescription=[ResultDescription,ResultDescription_dbz];
                                                        ActionDescription=[ActionDescription,ActionDescription_dbz];
                                                        actionItem=[actionItem,actionItem_dbz];
                                                    end
                                                end



                                                function[ResultDescription,ActionDescription,actionItem]=locParseOneMsgForCtrlBlk(diagObj,diagObjType)

                                                    ResultDescription=cell(0);
                                                    ActionDescription=cell(0);
                                                    actionItem='';

                                                    blockName=locParseBlockNameFromMsg(diagObj,diagObjType);
                                                    modelName=locParseModelNameFromMsg(diagObj,diagObjType);
                                                    canLoadModel=true;
                                                    try
                                                        load_system(modelName);
                                                    catch ME
                                                        canLoadModel=false;
                                                    end

                                                    parentSSBlock=get_param(blockName,'Parent');
                                                    ctrlBlk='';
                                                    if(~isempty(get_param(parentSSBlock,'Parent')))
                                                        ph=get_param(parentSSBlock,'PortHandles');


                                                        if~isempty(ph.Ifaction)
                                                            ctrlBlk=find_system(parentSSBlock,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','ActionPort');
                                                        elseif~isempty(ph.Trigger)
                                                            ctrlBlk=find_system(parentSSBlock,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','TriggerPort');
                                                        elseif~isempty(ph.Enable)
                                                            ctrlBlk=find_system(parentSSBlock,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','EnablePort');
                                                        end
                                                    end
                                                    if(~isempty(ctrlBlk))
                                                        [p,r]=locReplaceNewLine(ctrlBlk{1});
                                                        if canLoadModel
                                                            actionItem{1}=[p,'set_param(',r,', ''DisallowConstTsAndPrmTs'', ''on'')'];
                                                        else
                                                            actionItem{1}=';';
                                                        end

                                                        if strcmpi(diagObjType,'Simulink:blocks:DivideByZero')
                                                            ResultDescription=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:engine:MAParameterTuning_Suggest_DivideByZero',blockName,actionItem{1}));
                                                            if canLoadModel
                                                                ActionDescription=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:engine:MAParameterTuning_Selected_DivideByZero',ctrlBlk{1}));
                                                            else
                                                                ActionDescription=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:engine:MAParameterTuning_Selected_CannotLoadModel',modelName));
                                                            end
                                                        elseif strcmpi(diagObjType,'Simulink:blocks:MPSwitchControlInputRangeError')||...
                                                            strcmpi(diagObjType,'Simulink:blocks:MPSwitchControlInputOORIndexValue')
                                                            ResultDescription=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:engine:MAParameterTuning_Suggest_InvalidIndex',blockName,actionItem{1}));
                                                            if canLoadModel
                                                                ActionDescription=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:engine:MAParameterTuning_Selected_InvalidIndex',ctrlBlk{1}));
                                                            else
                                                                ActionDescription=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:engine:MAParameterTuning_Selected_CannotLoadModel',modelName));
                                                            end
                                                        elseif strcmpi(diagObjType,'Simulink:blocks:SelIntegerOutOfBounds')
                                                            ResultDescription=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:engine:MAParameterTuning_Suggest_Selector',blockName,actionItem{1}));
                                                            if canLoadModel
                                                                ActionDescription=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:engine:MAParameterTuning_Selected_Selector',ctrlBlk{1}));
                                                            else
                                                                ActionDescription=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:engine:MAParameterTuning_Selected_CannotLoadModel',modelName));
                                                            end
                                                        elseif strcmpi(diagObjType,'Simulink:blocks:RaiseToNegative')
                                                            ResultDescription=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:engine:MAParameterTuning_Suggest_RaiseToNegative',blockName,actionItem{1}));
                                                            if canLoadModel
                                                                ActionDescription=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:engine:MAParameterTuning_Selected_RaiseToNegative',ctrlBlk{1}));
                                                            else
                                                                ActionDescription=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:engine:MAParameterTuning_Selected_CannotLoadModel',modelName));
                                                            end
                                                        end
                                                    end

                                                    function[prefix,retStr]=locReplaceNewLine(blkStr)

                                                        cr=sprintf('\n');
                                                        newlinePos=strfind(blkStr,cr);
                                                        if(isempty(newlinePos))
                                                            prefix='';
                                                            retStr=['''',blkStr,''''];
                                                            return;
                                                        else
                                                            prefix='cr = sprintf(''\n''); ';
                                                            retStr='[';
                                                            newlinePos=[0,newlinePos,length(blkStr)+1];
                                                            for nlIdx=2:length(newlinePos)-1
                                                                retStr=[retStr,'''',blkStr(newlinePos(nlIdx-1)+1:newlinePos(nlIdx)-1),''', cr, '];
                                                            end
                                                            retStr=[retStr,'''',blkStr(newlinePos(end-1)+1:end),''']'];
                                                        end

                                                        function modelName=locParseModelNameFromMsg(diagObj,ErrorID)

                                                            blockName=locParseBlockNameFromMsg(diagObj,ErrorID);




                                                            sepPos=strfind(blockName,'/');
                                                            if(length(sepPos)==1)
                                                                modelName=blockName(1:sepPos-1);
                                                            else
                                                                modelName=blockName(1:sepPos(1)-1);
                                                            end

                                                            function blockName=locParseBlockNameFromMsg(diagObj,ErrorID)

                                                                switch ErrorID
                                                                case 'Simulink:blocks:MPSwitchControlInputRangeError'
                                                                    blockName=diagObj.arguments{1};
                                                                case 'Simulink:blocks:SelIntegerOutOfBounds'
                                                                    blockName=diagObj.arguments{3};
                                                                case 'Simulink:blocks:MPSwitchControlInputOORIndexValue'
                                                                    blockName=diagObj.arguments{1};
                                                                case 'Simulink:blocks:DivideByZero'
                                                                    blockName=diagObj.arguments{1};
                                                                case 'Simulink:blocks:RaiseToNegative'
                                                                    blockName=diagObj.arguments{1};
                                                                end

                                                                function inList=isBlockInBlockList(blocks_off,block_on)

                                                                    for blkIdx=1:length(blocks_off)
                                                                        if strcmpi(block_on,blocks_off{blkIdx})
                                                                            inList=true;
                                                                            return;
                                                                        end
                                                                    end
                                                                    inList=false;
