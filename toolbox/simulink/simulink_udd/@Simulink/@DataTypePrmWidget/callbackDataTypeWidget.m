function callbackDataTypeWidget(action,hDialog,tag)
















    try
        callbackDataTypeWidget_impl(action,hDialog,tag);
    catch ex
        throwAsCaller(ex);
    end

    function callbackDataTypeWidget_impl(action,hDialog,tag)

        switch action

        case{'buttonPushEvent','buttonSyncEvent'}

            buttonPushEvent(hDialog,tag);

            if strcmp(hDialog.getTitle,DAStudio.message('Simulink:dialog:UDTDataTypeAssistGrp'))
                return;
            end










            if strcmp(action,'buttonPushEvent')
                hOpenDialogs=DAStudio.ToolRoot.getOpenDialogs(hDialog.getSource);
                for i=1:length(hOpenDialogs)
                    hOpenDialog=hOpenDialogs(i);
                    if hOpenDialog~=hDialog&&...
                        ~strncmp(hOpenDialog.DialogTag,'Simulink:Dialog:Parameters',length('Simulink:Dialog:Parameters'))
                        Simulink.DataTypePrmWidget.callbackDataTypeWidget('buttonSyncEvent',...
                        hOpenDialog,...
                        tag);
                    end
                end
            end

        case{'valueChangeEvent','valueSyncEvent'}

            [needsSync,refreshDTList]=valueChangeEvent(action,hDialog,tag);

            if needsSync












                value=hDialog.getWidgetValue(tag);

                hOpenDialogs=DAStudio.ToolRoot.getOpenDialogs(hDialog.getSource);
                for i=1:length(hOpenDialogs)
                    hOpenDialog=hOpenDialogs(i);



                    if hOpenDialog~=hDialog&&~isempty(hOpenDialog.getTitle)


                        if refreshDTList


                            revertDTValueAndClearDirtyFlag(hOpenDialog,tag,value,...
                            hOpenDialog.getUserData(tag));

                            hOpenDialog.refresh();
                        else

                            hOpenDialog.setWidgetValue(tag,value);
                            Simulink.DataTypePrmWidget.callbackDataTypeWidget('valueSyncEvent',...
                            hOpenDialog,...
                            tag);
                        end
                    end
                end
            end

        case{'busEditEvent'}
            [~,dtTag]=getWidgetAndDataTypeTags(tag);
            busStr=hDialog.getWidgetValue(strcat(dtTag,'|UDTBusTypeEdit'));
            dataSource=checkDictionaryConnection(hDialog);
            if(isa(dataSource,'Simulink.dd.Connection')&&...
                dataSource.isOpen())
                buseditor('Create',busStr,Simulink.data.DataDictionary(dataSource.filespec));
            elseif isa(dataSource,'Simulink.interface.Dictionary')

                dataType=dataSource.getDataType(busStr);
                dataType.show();
            else
                buseditor('Create',busStr);
            end


        case{'valueTypeEditEvent'}
            [~,dtTag]=getWidgetAndDataTypeTags(tag);
            valueTypeStr=hDialog.getWidgetValue(strcat(dtTag,'|UDTValueTypeTypeEdit'));
            dataSource=checkDictionaryConnection(hDialog);
            if(isa(dataSource,'Simulink.dd.Connection')&&...
                dataSource.isOpen())
                slprivate('exploreListNode',dataSource.filespec,'dictionary',valueTypeStr);
            elseif isa(dataSource,'Simulink.interface.Dictionary')

                dataType=dataSource.getDataType(valueTypeStr);
                dataType.show();
            else
                slprivate('exploreListNode','','base',valueTypeStr);
            end

        otherwise
            assert(false,'Unknown callback');
        end







        function buttonPushEvent(hDialog,tag)


            [widgetTag,dtTag]=getWidgetAndDataTypeTags(tag);

            switch widgetTag

            case 'UDTShowDataTypeAssistBtn'

                setUDTAssistStatus(hDialog,dtTag,true);





                dialogSrc=getDialogSource(hDialog);
                if isa(dialogSrc,'Simulink.VariantControl')
                    dialogSrc=dialogSrc.Value;
                end

                if Simulink.data.isHandleObject(dialogSrc)
                    hDialog.refresh();
                    return;
                end

                hDialog.setVisible(strcat(dtTag,'|UDTShowDataTypeAssistBtn'),false);
                hDialog.setVisible(strcat(dtTag,'|UDTHideDataTypeAssistBtn'),true);
                hDialog.setVisible(strcat(dtTag,'|UDTDataTypeAssistGrp'),true);


                hDialog.setFocus(strcat(dtTag,'|UDTDataTypeSpecMethodRadio'));

            case 'UDTHideDataTypeAssistBtn'

                setUDTAssistStatus(hDialog,dtTag,false);





                dialogSrc=getDialogSource(hDialog);
                if Simulink.data.isHandleObject(dialogSrc)
                    hDialog.refresh();
                    return;
                end

                hDialog.setVisible(strcat(dtTag,'|UDTShowDataTypeAssistBtn'),true);
                hDialog.setVisible(strcat(dtTag,'|UDTHideDataTypeAssistBtn'),false);
                hDialog.setVisible(strcat(dtTag,'|UDTDataTypeAssistGrp'),false);


                hDialog.setFocus(dtTag);


            case{'UDTFractionLengthScalingBtn','UDTSlopeBiasScalingBtn'}
                oneTimeSetScaleFromRange(hDialog,dtTag);

            case{'UDTDataTypeInfoLink',...
                'UDTDataTypeInfoContract',...
                'UDTDataTypeInfoExpand'}
                dataTypeInfoTablePnlTag=strcat(dtTag,'|UDTDataTypeInfoTblPnl');
                dataTypeInfoExpandTag=strcat(dtTag,'|UDTDataTypeInfoExpand');
                dataTypeInfoContractTag=strcat(dtTag,'|UDTDataTypeInfoContract');
                if hDialog.isVisible(dataTypeInfoContractTag)
                    hDialog.setVisible(dataTypeInfoExpandTag,true);
                    hDialog.setVisible(dataTypeInfoContractTag,false);
                    hDialog.setVisible(dataTypeInfoTablePnlTag,false);
                    setUDTIPStatus(hDialog,dtTag,false);
                else
                    hDialog.setVisible(dataTypeInfoContractTag,true);
                    hDialog.setVisible(dataTypeInfoExpandTag,false);
                    setDataTypeInfoTable(hDialog,dtTag);
                    hDialog.setVisible(dataTypeInfoTablePnlTag,true);
                    setUDTIPStatus(hDialog,dtTag,true);
                end

            case 'UDTDataTypeInfoUpdate'
                setDataTypeInfoTable(hDialog,dtTag);

            otherwise
                assert(false,'Unknown callback');
            end






            function setUDTAssistStatus(hDialog,dtTag,status)



                try
                    dialogSrc=getDialogSource(hDialog);
                    if isa(dialogSrc,'Simulink.VariantControl')
                        dialogSrc=dialogSrc.Value;
                    end

                    if~isempty(dialogSrc.UDTAssistOpen)
                        whichTag=find(strcmp(dtTag,dialogSrc.UDTAssistOpen.tags),1);
                        assert(~isempty(whichTag));
                        dialogSrc.UDTAssistOpen.status{whichTag}=status;
                    end
                catch ME
                    if strcmp(ME.identifier,'MATLAB:noSuchMethodOrField')


                    else
                        rethrow(ME);
                    end
                end








                function setUDTIPStatus(hDialog,dtTag,status)


                    dialogSrc=getDialogSource(hDialog);
                    if~isempty(dialogSrc.UDTIPOpen)
                        whichTag=find(strcmp(dtTag,dialogSrc.UDTIPOpen.tags),1);
                        assert(~isempty(whichTag));
                        dialogSrc.UDTIPOpen.status{whichTag}=status;
                    end







                    function[needsSync,refreshDTList]=valueChangeEvent(action,hDialog,tag)


                        [widgetTag,dtTag]=getWidgetAndDataTypeTags(tag);

                        if strcmp(tag,dtTag)

                            dtaItems=hDialog.getUserData(dtTag);





                            newDataTypeStr=getPulldownText(hDialog,dtTag);


                            if strcmp(newDataTypeStr,DAStudio.message('Simulink:DataType:RefreshDataTypeInWorkspace'))





                                srcObj=hDialog.getWidgetSource(tag);
                                if(isa(srcObj,'Simulink.SlidDAProxy'))
                                    slidObject=srcObj.getObject();
                                    srcObj=slidObject.WorkspaceObjectSharedCopy;
                                end


                                slprivate('slGetUserDataTypesFromWSDD',...
                                hDialog.getWidgetSource(tag),[],[],true);


                                if(ismethod(srcObj,'getForwardedObject')&&~isempty(srcObj.getForwardedObject))
                                    srcObj=srcObj.getForwardedObject;
                                end
                                if~isempty(dtaItems)
                                    propName=dtaItems.PropertyName;
                                    if~isempty(srcObj)&&isprop(srcObj,propName)
                                        if isa(srcObj,'Simulink.Block')


                                            dialogSource=hDialog.getDialogSource();
                                            value=dialogSource.get_param(propName);
                                        else

                                            value=srcObj.(propName);
                                        end
                                    end

                                    revertDTValueAndClearDirtyFlag(hDialog,dtTag,value,dtaItems);
                                end



                                hDialog.refresh();



                                switch(action)
                                case 'valueChangeEvent'
                                    needsSync=true;
                                    refreshDTList=true;
                                case 'valueSyncEvent'
                                    needsSync=false;
                                    refreshDTList=false;
                                otherwise
                                    assert(false,'Unsupported event');
                                end



                                if isfield(dtaItems,'udtIndex')&&~isempty(dtaItems.udtIndex)
                                    handleComboboxChangeEventForBlocks(value,dtaItems.udtIndex,hDialog);
                                end


                                return;
                            end



                            if isfield(dtaItems,'udtIndex')&&~isempty(dtaItems.udtIndex)
                                handleComboboxChangeEventForBlocks(newDataTypeStr,dtaItems.udtIndex,hDialog);
                            end

                            handleValueChangeEventForDataObjects(hDialog,newDataTypeStr);

                            res=Simulink.DataTypePrmWidget.parseDataTypeString(newDataTypeStr,dtaItems);



                            if~strcmp(res.errMsg.id,'UDTNoError')
                                error(message(res.errMsg.id));
                            end

                            oldDataTypeMode=hDialog.getWidgetValue(strcat(dtTag,'|UDTDataTypeSpecMethodRadio'));
                            if(oldDataTypeMode~=res.indexSpecMethod)
                                hDialog.setWidgetValue(strcat(dtTag,'|UDTDataTypeSpecMethodRadio'),res.indexSpecMethod);
                                widgetTag='UDTDataTypeSpecMethodRadio';
                            end



                            setAssistantFromDataTypeStr(hDialog,dtTag,res);







                            if res.isFixPt&&res.fixptProps.openAssistant
                                showAssistTag=[dtTag,'|UDTShowDataTypeAssistBtn'];
                                if hDialog.isVisible(showAssistTag)
                                    Simulink.DataTypePrmWidget.callbackDataTypeWidget('buttonPushEvent',...
                                    hDialog,...
                                    showAssistTag);
                                end



                            end
                        else


                            changeMode=false;
                            if strcmp(tag,'Data type:|UDTDataTypeSpecMethodRadio')
                                changeMode=true;
                            end
                            setDataTypeStrFromAssistant(hDialog,dtTag,changeMode);
                        end

                        switch widgetTag
                        case 'UDTDataTypeSpecMethodRadio'
                            setSpecMethodVisible(hDialog,dtTag);

                        case 'UDTScalingModeRadio'
                            setScalingModeVisible(hDialog,dtTag);

                        otherwise

                        end

                        switch(action)
                        case 'valueChangeEvent'
                            needsSync=true;
                        case 'valueSyncEvent'
                            needsSync=false;
                        otherwise
                            assert(false,'Unsupported event');
                        end


                        refreshDTList=false;

                        if strcmp(hDialog.getTitle,DAStudio.message('Simulink:dialog:UDTDataTypeAssistGrp'))
                            needsSync=false;
                            return;
                        end






                        function handleComboboxChangeEventForBlocks(dataTypeStr,index,hDialog)


                            hDialogSource=getDialogSource(hDialog);
                            if isa(hDialogSource,'Simulink.SLDialogSource')


                                hDialogSource.handleEditEvent(dataTypeStr,int32(index),hDialog);
                            end



                            function handleValueChangeEventForDataObjects(hDialog,dataTypeStr)
                                isBusType=regexpi(dataTypeStr,'^Bus:','match');
                                if(~isempty(isBusType))
                                    hDialog.setEnabled('Unit',false);
                                else
                                    if(~hDialog.isEnabled('Unit'))
                                        hDialog.setEnabled('Unit',true);
                                    end
                                end




                                function setAssistantFromDataTypeStr(hDialog,dtTag,res)


                                    dtaItems=hDialog.getUserData(dtTag);
                                    specMethodTagList=getSpecMethodTagList(dtaItems);



                                    visibleSpecMethodTag='';

                                    if res.isInherit
                                        hDialog.setWidgetValue(strcat(dtTag,'|UDTInheritRadio'),res.indexInherit);
                                        if~isempty(dtaItems.ruleTranslator)
                                            commentWidgetTag=[dtTag,'|UDTInheritComment'];
                                            comments=hDialog.getUserData(commentWidgetTag);
                                            if~isempty(comments)
                                                hDialog.setWidgetValue(commentWidgetTag,comments{res.indexInherit+1});
                                            end
                                        end
                                        visibleSpecMethodTag='UDTInheritPanel';
                                    end

                                    if res.isBuiltin
                                        hDialog.setWidgetValue(strcat(dtTag,'|UDTBuiltinRadio'),res.indexBuiltin);
                                        visibleSpecMethodTag='UDTBuiltinRadio';
                                    end

                                    if res.isEnumType
                                        hDialog.setWidgetValue(strcat(dtTag,'|UDTEnumTypeEdit'),res.enumClassName);
                                        visibleSpecMethodTag='UDTEnumTypeEdit';
                                    end

                                    if res.isBusType
                                        hDialog.setWidgetValue(strcat(dtTag,'|UDTBusTypeEdit'),res.busObjectName);
                                        visibleSpecMethodTag='UDTBusTypeGrp';
                                    end

                                    if(slfeature('CUSTOM_BUSES')==1)&&res.isConnectionBusType
                                        hDialog.setWidgetValue(strcat(dtTag,'|UDTConnBusTypeEdit'),res.connectionBusObjectName);
                                        visibleSpecMethodTag='UDTConnBusTypeGrp';
                                    end

                                    if(slfeature('CUSTOM_BUSES')==1)&&res.isConnectionType
                                        hDialog.setWidgetValue(strcat(dtTag,'|UDTConnTypeEdit'),res.domainName);
                                        visibleSpecMethodTag='UDTConnTypeEdit';
                                    end

                                    if(slfeature('SLValueType')==1)&&res.isValueTypeType
                                        hDialog.setWidgetValue(strcat(dtTag,'|UDTValueTypeTypeEdit'),res.valueTypeName);
                                        visibleSpecMethodTag='UDTValueTypeTypeGrp';
                                    end

                                    if res.isExpress
                                        if isempty(res.str)
                                            hDialog.setWidgetValue(strcat(dtTag,'|UDTExprEdit'),'<data type expression>');
                                        else
                                            hDialog.setWidgetValue(strcat(dtTag,'|UDTExprEdit'),res.str);
                                        end
                                        visibleSpecMethodTag='UDTExprEdit';
                                    end

                                    if res.isFixPt
                                        scalingMode=res.fixptProps.scalingMode;
                                        setWidgetValueIfNecessary(hDialog,strcat(dtTag,'|UDTScalingModeRadio'),scalingMode);

                                        setWidgetValueIfNecessary(hDialog,strcat(dtTag,'|UDTSignRadio'),res.fixptProps.signed);

                                        setWidgetValueIfNecessary(hDialog,strcat(dtTag,'|UDTWordLengthEdit'),res.fixptProps.wordLength);

                                        switch dtaItems.scalingModes{scalingMode+1}
                                        case 'UDTBinaryPointMode'
                                            setWidgetValueIfNecessary(hDialog,strcat(dtTag,'|UDTFractionLengthEdit'),res.fixptProps.fractionLength);
                                        case 'UDTSlopeBiasMode'
                                            setWidgetValueIfNecessary(hDialog,strcat(dtTag,'|UDTSlopeEdit'),res.fixptProps.slope);
                                            setWidgetValueIfNecessary(hDialog,strcat(dtTag,'|UDTBiasEdit'),res.fixptProps.bias);
                                        case 'UDTBestPrecisionMode'

                                        case 'UDTIntegerMode'

                                        otherwise
                                            assert(false,'Unsupported scaling mode');
                                        end

                                        setScalingModeVisible(hDialog,dtTag);

                                        visibleSpecMethodTag='UDTFixedPointGrp';
                                    end

                                    if slfeature('SupportImageInDTA')==1&&res.isImageType
                                        setWidgetValueIfNecessary(hDialog,strcat(dtTag,'|UDTColorFormatRadio'),res.imageTypeProps.ColorFormat);

                                        setWidgetValueIfNecessary(hDialog,strcat(dtTag,'|UDTRowsEdit'),res.imageTypeProps.Rows);

                                        setWidgetValueIfNecessary(hDialog,strcat(dtTag,'|UDTLayoutRadio'),res.imageTypeProps.Layout);

                                        setWidgetValueIfNecessary(hDialog,strcat(dtTag,'|UDTColsEdit'),res.imageTypeProps.Cols);

                                        setWidgetValueIfNecessary(hDialog,strcat(dtTag,'|UDTClassUnderlyingRadio'),res.imageTypeProps.ClassUnderlying);

                                        setWidgetValueIfNecessary(hDialog,strcat(dtTag,'|UDTChannelsEdit'),res.imageTypeProps.Channels);

                                        visibleSpecMethodTag='UDTImageTypeGrp';
                                    end

                                    if res.isExtra
                                        extra=dtaItems.extras(res.extraProps.indexExtra+1);
                                        tagPrefix=Simulink.DataTypePrmWidget.getUniqueTagPrefix(dtTag);
                                        if isempty(res.extraProps.exprExtra)
                                            if isfield(extra,'hint')
                                                feval(extra.setval,hDialog,tagPrefix,extra.hint);
                                            else
                                                feval(extra.setval,hDialog,tagPrefix,'<variable name>');
                                            end
                                        else
                                            feval(extra.setval,hDialog,tagPrefix,res.extraProps.exprExtra);
                                        end
                                        visibleSpecMethodTag=extra.container.Tag;
                                    end

                                    visibilityFlags=strcmp(visibleSpecMethodTag,specMethodTagList);
                                    for i=1:length(visibilityFlags)
                                        switch specMethodTagList{i}
                                        case 'UDTBuiltinRadio'
                                            if visibilityFlags(i)
                                                hDialog.setVisible([dtTag,'|UDTBuiltinRadio'],true);
                                                hDialog.setVisible(strcat(dtTag,'|UDTDTOBuiltinComboLbl'),true);
                                                hDialog.setVisible(strcat(dtTag,'|UDTDTOBuiltinCombo'),true);
                                            else
                                                hDialog.setVisible([dtTag,'|UDTBuiltinRadio'],false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTDTOBuiltinComboLbl'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTDTOBuiltinCombo'),false);
                                            end
                                        case{'UDTInheritPanel','UDTExprEdit','UDTFixedPointGrp',...
                                            'UDTEnumTypeEdit','UDTBusTypeGrp','UDTImageTypeGrp'}
                                            hDialog.setVisible([dtTag,'|',specMethodTagList{i}],visibilityFlags(i));
                                        case 'UDTConnBusTypeGrp'
                                            if slfeature('CUSTOM_BUSES')==1
                                                hDialog.setVisible([dtTag,'|',specMethodTagList{i}],visibilityFlags(i));
                                            end
                                        case 'UDTConnTypeEdit'
                                            if slfeature('CUSTOM_BUSES')==1

                                                hDialog.setVisible([dtTag,'|',specMethodTagList{i}],visibilityFlags(i));
                                            end
                                        case 'UDTValueTypeTypeGrp'
                                            if slfeature('SLValueType')==1
                                                hDialog.setVisible([dtTag,'|',specMethodTagList{i}],visibilityFlags(i));
                                            end
                                        otherwise
                                            hDialog.setVisible(specMethodTagList{i},visibilityFlags(i));
                                        end
                                    end







                                    function setSpecMethodVisible(hDialog,dtTag)


                                        dtaItems=hDialog.getUserData(dtTag);
                                        specMethodTagList=getSpecMethodTagList(dtaItems);
                                        tag=[dtTag,'|UDTDataTypeSpecMethodRadio'];
                                        index=hDialog.getWidgetValue(tag);

                                        switch specMethodTagList{index+1}
                                        case 'UDTFixedPointGrp'
                                            setScalingModeVisible(hDialog,dtTag);
                                        otherwise
                                            hDialog.setVisible(strcat(dtTag,'|UDTSetScalingBtn'),false);
                                        end

                                        for i=1:length(specMethodTagList)
                                            switch specMethodTagList{i}
                                            case{'UDTInheritPanel','UDTBuiltinRadio','UDTExprEdit','UDTFixedPointGrp',...
                                                'UDTEnumTypeEdit','UDTBusTypeGrp','UDTImageTypeGrp'}
                                                hDialog.setVisible([dtTag,'|',specMethodTagList{i}],index+1==i)
                                            case 'UDTConnBusTypeGrp'
                                                if slfeature('CUSTOM_BUSES')==1
                                                    hDialog.setVisible([dtTag,'|',specMethodTagList{i}],index+1==i)
                                                end
                                            case 'UDTConnTypeEdit'
                                                if slfeature('CUSTOM_BUSES')==1

                                                    hDialog.setVisible([dtTag,'|',specMethodTagList{i}],index+1==i)
                                                end
                                            case 'UDTValueTypeTypeGrp'
                                                if slfeature('SlValueType')==1
                                                    hDialog.setVisible([dtTag,'|',specMethodTagList{i}],index+1==i)
                                                end
                                            otherwise
                                                hDialog.setVisible(specMethodTagList{i},index+1==i);
                                            end
                                        end

                                        hDialog.setVisible([dtTag,'|','UDTDataTypeInfoPnl'],...
                                        isequal(specMethodTagList{index+1},'UDTFixedPointGrp'));







                                        function setScalingModeVisible(hDialog,dtTag)


                                            dtaItems=hDialog.getUserData(dtTag);



                                            currentScalingPanel=getCurrentScalingPanel(hDialog,dtTag);
                                            switch currentScalingPanel
                                            case 'unknown'
                                                hDialog.setVisible(strcat(dtTag,'|UDTSlopeLbl'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTSlopeEdit'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTBiasLbl'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTBiasEdit'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTDTOSlopeBiasComboLbl'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTDTOSlopeBiasCombo'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTSlopeBiasScalingBtn'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTFractionLengthLbl'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTFractionLengthEdit'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTDTOBinaryPointComboLbl'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTDTOBinaryPointCombo'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTFractionLengthScalingBtn'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTDTOBestPrecComboLbl'),true);
                                                hDialog.setVisible(strcat(dtTag,'|UDTDTOBestPrecCombo'),true);
                                            case 'UDTBinaryPointPanel'
                                                hDialog.setVisible(strcat(dtTag,'|UDTSlopeLbl'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTSlopeEdit'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTBiasLbl'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTBiasEdit'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTDTOSlopeBiasComboLbl'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTDTOSlopeBiasCombo'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTSlopeBiasScalingBtn'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTFractionLengthLbl'),true);
                                                hDialog.setVisible(strcat(dtTag,'|UDTFractionLengthEdit'),true);
                                                hDialog.setVisible(strcat(dtTag,'|UDTDTOBinaryPointComboLbl'),true);
                                                hDialog.setVisible(strcat(dtTag,'|UDTDTOBinaryPointCombo'),true);
                                                scalingBtnVisible=~isempty(dtaItems.scalingMinTag)||...
                                                ~isempty(dtaItems.scalingMaxTag)||...
                                                ~isempty(dtaItems.scalingValueTags);
                                                hDialog.setVisible(strcat(dtTag,'|UDTFractionLengthScalingBtn'),scalingBtnVisible);
                                                hDialog.setVisible(strcat(dtTag,'|UDTDTOBestPrecComboLbl'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTDTOBestPrecCombo'),false);
                                            case 'UDTSlopeBiasPanel'
                                                hDialog.setVisible(strcat(dtTag,'|UDTFractionLengthLbl'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTFractionLengthEdit'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTDTOBinaryPointCombo'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTDTOBinaryPointComboLbl'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTFractionLengthScalingBtn'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTSlopeLbl'),true);
                                                hDialog.setVisible(strcat(dtTag,'|UDTSlopeEdit'),true);
                                                hDialog.setVisible(strcat(dtTag,'|UDTBiasLbl'),true);
                                                hDialog.setVisible(strcat(dtTag,'|UDTBiasEdit'),true);
                                                hDialog.setVisible(strcat(dtTag,'|UDTDTOSlopeBiasComboLbl'),true);
                                                hDialog.setVisible(strcat(dtTag,'|UDTDTOSlopeBiasCombo'),true);
                                                hDialog.setVisible(strcat(dtTag,'|UDTDTOBestPrecComboLbl'),false);
                                                hDialog.setVisible(strcat(dtTag,'|UDTDTOBestPrecCombo'),false);




                                                scalingBtnVisible=~isempty(dtaItems.scalingValueTags)||...
                                                (~isempty(dtaItems.scalingMinTag)&&...
                                                ~isempty(dtaItems.scalingMaxTag));
                                                hDialog.setVisible(strcat(dtTag,'|UDTSlopeBiasScalingBtn'),scalingBtnVisible);
                                            otherwise
                                                assert(false,'Unsupported scaling mode');
                                            end







                                            function setDataTypeStrFromAssistant(hDialog,dtTag,changeMode)


                                                dtaItems=hDialog.getUserData(dtTag);
                                                specMethodTagList=getSpecMethodTagList(dtaItems);
                                                indexSpecMethod=hDialog.getWidgetValue(strcat(dtTag,...
                                                '|UDTDataTypeSpecMethodRadio'));
                                                specMethodTag=specMethodTagList{indexSpecMethod+1};

                                                switch specMethodTag

                                                case 'UDTInheritPanel'

                                                    zeroIndex=hDialog.getWidgetValue(strcat(dtTag,'|UDTInheritRadio'));


                                                    if~isempty(dtaItems.ruleTranslator)
                                                        commentWidgetTag=[dtTag,'|UDTInheritComment'];
                                                        comments=hDialog.getUserData(commentWidgetTag);
                                                        hDialog.setWidgetValue(commentWidgetTag,comments{zeroIndex+1});
                                                    end

                                                    newDataTypeStr=dtaItems.inheritRules{zeroIndex+1};

                                                case 'UDTBuiltinRadio'

                                                    zeroIndex=hDialog.getWidgetValue(strcat(dtTag,'|UDTBuiltinRadio'));
                                                    dtoStrValue=hDialog.getWidgetValue(strcat(dtTag,'|UDTDTOBuiltinCombo'));
                                                    dtoValue=getDTOPropString(dtoStrValue);
                                                    if~isempty(dtoValue)
                                                        rawBuiltinStr=dtaItems.builtinTypes{zeroIndex+1};
                                                        newDataTypeStr=['fixdt(''',rawBuiltinStr,'''',dtoValue,')'];
                                                    else
                                                        newDataTypeStr=dtaItems.builtinTypes{zeroIndex+1};
                                                    end

                                                case 'UDTExprEdit'

                                                    dataTypeExprTag=strcat(dtTag,'|UDTExprEdit');
                                                    newDataTypeStr=hDialog.getWidgetValue(dataTypeExprTag);
                                                    if isempty(newDataTypeStr)
                                                        hDialog.setWidgetValue(dataTypeExprTag,'<data type expression>');
                                                        newDataTypeStr='<data type expression>';
                                                    end

                                                case 'UDTFixedPointGrp'

                                                    newDataTypeStr=getDataTypeStrFromFixPt(hDialog,dtTag,dtaItems);

                                                case 'UDTImageTypeGrp'

                                                    newDataTypeStr=getDataTypeStrFromImageType(hDialog,dtTag,changeMode);

                                                case 'UDTEnumTypeEdit'

                                                    enumClassNameTag=strcat(dtTag,'|UDTEnumTypeEdit');
                                                    enumClassName=hDialog.getWidgetValue(enumClassNameTag);
                                                    if isempty(enumClassName)
                                                        enumClassName='<class name>';
                                                        hDialog.setWidgetValue(enumClassNameTag,enumClassName);
                                                    end
                                                    newDataTypeStr=['Enum: ',enumClassName];

                                                case 'UDTBusTypeGrp'

                                                    busObjectNameTag=strcat(dtTag,'|UDTBusTypeEdit');
                                                    busObjectName=hDialog.getWidgetValue(busObjectNameTag);
                                                    if isempty(busObjectName)
                                                        busObjectName='<object name>';
                                                        hDialog.setWidgetValue(busObjectNameTag,busObjectName);
                                                    end
                                                    newDataTypeStr=['Bus: ',busObjectName];

                                                case 'UDTConnBusTypeGrp'

                                                    if slfeature('CUSTOM_BUSES')==1
                                                        connBusObjectNameTag=strcat(dtTag,'|UDTConnBusTypeEdit');
                                                        connBusObjectName=hDialog.getWidgetValue(connBusObjectNameTag);
                                                        if isempty(connBusObjectName)
                                                            connBusObjectName='<object name>';
                                                            hDialog.setWidgetValue(connBusObjectNameTag,connBusObjectName);
                                                        end
                                                        newDataTypeStr=['Bus: ',connBusObjectName];
                                                    end

                                                case 'UDTConnTypeEdit'

                                                    if slfeature('CUSTOM_BUSES')==1
                                                        connNameTag=strcat(dtTag,'|UDTConnTypeEdit');
                                                        connName=hDialog.getWidgetValue(connNameTag);
                                                        if isempty(connName)
                                                            connName='<domain name>';
                                                            hDialog.setWidgetValue(connNameTag,connName);
                                                        end
                                                        newDataTypeStr=['Connection: ',connName];
                                                    end

                                                case 'UDTValueTypeTypeGrp'
                                                    if slfeature('SLValueType')==1
                                                        valueTypeNameTag=strcat(dtTag,'|UDTValueTypeTypeEdit');
                                                        valueTypeName=hDialog.getWidgetValue(valueTypeNameTag);
                                                        if isempty(valueTypeName)
                                                            valueTypeName='<object name>';
                                                            hDialog.setWidgetValue(valueTypeNameTag,valueTypeName);
                                                        end
                                                        newDataTypeStr=['ValueType: ',valueTypeName];
                                                    end

                                                otherwise
                                                    isValidExtraSpecMethod=false;
                                                    for i=1:length(dtaItems.extras)
                                                        if strcmp(specMethodTag,dtaItems.extras(i).container.Tag)
                                                            tagPrefix=Simulink.DataTypePrmWidget.getUniqueTagPrefix(dtTag);
                                                            extraVal=feval(dtaItems.extras(i).getval,hDialog,tagPrefix);
                                                            if isempty(extraVal)
                                                                if~isfield(dtaItems.extras(i),'hint')
                                                                    newDataTypeStr=[dtaItems.extras(i).header,...
                                                                    ': <variable name>'];
                                                                else
                                                                    newDataTypeStr=[dtaItems.extras(i).header,...
                                                                    ': ',dtaItems.extras(i).hint];
                                                                end
                                                            else
                                                                newDataTypeStr=[dtaItems.extras(i).header,...
                                                                ': ',extraVal];
                                                            end
                                                            hDialog.setFocus(dtaItems.extras(i).container.Tag);
                                                            isValidExtraSpecMethod=true;
                                                            break;
                                                        end
                                                    end
                                                    if~isValidExtraSpecMethod
                                                        assert(false,'Unknown data type specification methods');
                                                    end
                                                end


                                                setComboboxValueAsUser(hDialog,dtTag,newDataTypeStr);















                                                function setComboboxValueAsUser(hDialog,dtTag,newDataTypeStr)


                                                    imd=DAStudio.imDialog.getIMWidgets(hDialog);
                                                    pulldown=imd.find('Tag',dtTag);
                                                    if ischar(hDialog.getWidgetValue(dtTag))

                                                        hDialog.setWidgetValue(dtTag,newDataTypeStr);
                                                        pulldown.selectbystring(newDataTypeStr);
                                                    else


                                                        index=find(strcmp(newDataTypeStr,pulldown.getAllItems));
                                                        if isempty(index)
                                                            index=0;
                                                        end
                                                        pulldown.select(index);
                                                    end








                                                    function newDataTypeStr=getDataTypeStrFromFixPt(hDialog,dtTag,dtaItems)


                                                        if isfield(dtaItems,'signModes')
                                                            signModeIndex=hDialog.getWidgetValue(strcat(dtTag,'|UDTSignRadio'));
                                                            switch dtaItems.signModes{signModeIndex+1}
                                                            case 'UDTUnsignedSign'
                                                                signStr='0,';
                                                            case 'UDTSignedSign'
                                                                signStr='1,';
                                                            case 'UDTInheritSign'
                                                                signStr='[],';
                                                            case 'UDTSameAsInputSign'
                                                                signStr='=,';
                                                            end
                                                        else
                                                            signMode=hDialog.getWidgetValue(strcat(dtTag,'|UDTSignRadio'));
                                                            if signMode==1
                                                                signStr='1,';
                                                            else
                                                                signStr='0,';
                                                            end
                                                        end

                                                        wordLengthStr=hDialog.getWidgetValue(strcat(dtTag,'|UDTWordLengthEdit'));

                                                        newDataTypeStr=['fixdt(',signStr,wordLengthStr];

                                                        scalingModeTagList=getScalingModeTagList(dtaItems);
                                                        indexScalingMode=hDialog.getWidgetValue(strcat(dtTag,'|UDTScalingModeRadio'));

                                                        if(indexScalingMode>=length(scalingModeTagList))

                                                            dtoStrValue=hDialog.getWidgetValue(strcat(dtTag,'|UDTDTOBestPrecCombo'));
                                                            dtoValue=getDTOPropString(dtoStrValue);
                                                            newDataTypeStr=[newDataTypeStr,dtoValue,')'];
                                                        else
                                                            switch scalingModeTagList{indexScalingMode+1}
                                                            case 'UDTBinaryPointPanel'

                                                                fractionLengthStr=hDialog.getWidgetValue(strcat(dtTag,'|UDTFractionLengthEdit'));
                                                                dtoStrValue=hDialog.getWidgetValue(strcat(dtTag,'|UDTDTOBinaryPointCombo'));
                                                                dtoValue=getDTOPropString(dtoStrValue);
                                                                newDataTypeStr=[newDataTypeStr,',',fractionLengthStr,dtoValue,')'];

                                                            case 'UDTSlopeBiasPanel'

                                                                slopeStr=hDialog.getWidgetValue(strcat(dtTag,'|UDTSlopeEdit'));
                                                                biasStr=hDialog.getWidgetValue(strcat(dtTag,'|UDTBiasEdit'));
                                                                dtoStrValue=hDialog.getWidgetValue(strcat(dtTag,'|UDTDTOSlopeBiasCombo'));
                                                                dtoValue=getDTOPropString(dtoStrValue);
                                                                newDataTypeStr=[newDataTypeStr,',',slopeStr,',',biasStr,dtoValue,')'];
                                                            otherwise
                                                                assert(false,'Unsupported scaling mode.');
                                                            end
                                                        end





                                                        function newDataTypeStr=getDataTypeStrFromImageType(hDialog,dtTag,changeMode)


                                                            if changeMode
                                                                newDataTypeStr='Simulink.ImageType(480,640,3)';
                                                                return;
                                                            end

                                                            rows=hDialog.getWidgetValue(strcat(dtTag,'|UDTRowsEdit'));
                                                            cols=hDialog.getWidgetValue(strcat(dtTag,'|UDTColsEdit'));
                                                            channels=hDialog.getWidgetValue(strcat(dtTag,'|UDTChannelsEdit'));

                                                            color_format_index=hDialog.getWidgetValue(strcat(dtTag,'|UDTColorFormatRadio'));
                                                            color_formats=getImageTypeFieldList('colorFormat');
                                                            ColorFormat=color_formats{color_format_index+1};
                                                            ColorFormat=addSingleQuotation(ColorFormat);

                                                            layout_index=hDialog.getWidgetValue(strcat(dtTag,'|UDTLayoutRadio'));
                                                            layouts=getImageTypeFieldList('layout');
                                                            Layout=layouts{layout_index+1};
                                                            Layout=addSingleQuotation(Layout);

                                                            class_underlying_index=hDialog.getWidgetValue(strcat(dtTag,'|UDTClassUnderlyingRadio'));
                                                            class_underlyings=getImageTypeFieldList('classUnderlying');
                                                            ClassUnderlying=class_underlyings{class_underlying_index+1};
                                                            ClassUnderlying=addSingleQuotation(ClassUnderlying);




                                                            if~isletter(channels)
                                                                switch(color_format_index)
                                                                case{0,1}
                                                                    if~strcmp(channels,'3')
                                                                        channels='3';
                                                                    end
                                                                case 2
                                                                    if~strcmp(channels,'4')
                                                                        channels='4';
                                                                    end
                                                                case 3
                                                                    if~strcmp(channels,'1')
                                                                        channels='1';
                                                                    end
                                                                end
                                                            end



                                                            if color_format_index==0&&layout_index==0&&class_underlying_index==0
                                                                newDataTypeStr=['Simulink.ImageType(',rows,',',cols,',',channels,')'];
                                                            else
                                                                newDataTypeStr=['Simulink.ImageType(',rows,',',cols,',',channels,','...
                                                                ,'''ColorFormat''',',',ColorFormat,',','''Layout''',',',Layout,',','''ClassUnderlying''',',',ClassUnderlying,')'];
                                                            end






                                                            function fieldList=getImageTypeFieldList(fieldName)
                                                                switch fieldName
                                                                case 'colorFormat'
                                                                    fieldList={DAStudio.message('Simulink:dialog:UDTColorFormatRGB'),...
                                                                    DAStudio.message('Simulink:dialog:UDTColorFormatBGR'),...
                                                                    DAStudio.message('Simulink:dialog:UDTColorFormatBGRA'),...
                                                                    DAStudio.message('Simulink:dialog:UDTColorFormatGrayscale')};
                                                                case 'layout'
                                                                    fieldList={DAStudio.message('Simulink:dialog:UDTLayoutColumnMajorPlanar'),...
                                                                    DAStudio.message('Simulink:dialog:UDTLayoutRowMajorInterleaved')};
                                                                case 'classUnderlying'
                                                                    fieldList={DAStudio.message('Simulink:dialog:UDTClassUnderlyinguint8'),...
                                                                    DAStudio.message('Simulink:dialog:UDTClassUnderlyinguint16'),...
                                                                    DAStudio.message('Simulink:dialog:UDTClassUnderlyinguint32'),...
                                                                    DAStudio.message('Simulink:dialog:UDTClassUnderlyingint8'),...
                                                                    DAStudio.message('Simulink:dialog:UDTClassUnderlyingint16'),...
                                                                    DAStudio.message('Simulink:dialog:UDTClassUnderlyingint32'),...
                                                                    DAStudio.message('Simulink:dialog:UDTClassUnderlyingsingle'),...
                                                                    DAStudio.message('Simulink:dialog:UDTClassUnderlyingdouble')};
                                                                otherwise
                                                                end






                                                                function str=addSingleQuotation(src)
                                                                    str=['''',src,''''];





                                                                    function dtoPropStr=getDTOPropString(dtoStrValue)

                                                                        if isempty(dtoStrValue)
                                                                            dtoPropStr='';
                                                                            return;
                                                                        end
                                                                        switch dtoStrValue
                                                                        case 0
                                                                            dtoPropStr='';
                                                                        case 1
                                                                            dtoPropStr=[', ','''DataTypeOverride''',', ','''Off'''];
                                                                        otherwise
                                                                            dtoPropStr='';
                                                                        end






                                                                        function oneTimeSetScaleFromRange(hDialog,dtTag)


                                                                            dtaItems=hDialog.getUserData(dtTag);

                                                                            signMode=getSignMode(hDialog,dtTag);
                                                                            currentScalingPanel=getCurrentScalingPanel(hDialog,dtTag);

                                                                            switch signMode

                                                                            case 'UDTInheritSign'
                                                                                signed=true;
                                                                                minWordLength=2;
                                                                                warnmsg=DAStudio.message('Simulink:dialog:UDTAssumeSignedWarn',...
                                                                                strtok(getWidgetLabel(hDialog,dtTag),':'));

                                                                                warndlg(warnmsg);
                                                                            case 'UDTSignedSign'
                                                                                signed=true;
                                                                                minWordLength=2;
                                                                            case 'UDTUnsignedSign'
                                                                                signed=false;
                                                                                minWordLength=1;
                                                                            otherwise
                                                                                assert(false,'Unsupported sign mode');
                                                                            end

                                                                            valueVec=[];



                                                                            [scalingTags,scalingTagTypes]=getScalingTagAndTypes(dtaItems.scalingMaxTag,...
                                                                            dtaItems.scalingValueTags,...
                                                                            dtaItems.scalingMinTag);
                                                                            numScalingTags=length(scalingTags);

                                                                            for i=1:numScalingTags
                                                                                scalingTag=scalingTags{i};
                                                                                assert(hDialog.isWidgetValid(scalingTag),['Invalid scaling tag: ',scalingTag]);
                                                                                prompt=getPromptForWidget(hDialog,scalingTags{i});



                                                                                if~hDialog.isEnabled(scalingTag)
                                                                                    curValue=[];
                                                                                else
                                                                                    curStr=hDialog.getWidgetValue(scalingTag);

                                                                                    try
                                                                                        curValue=evalOneScalingField(hDialog,scalingTag,scalingTagTypes(i));

                                                                                        if~isempty(curValue)&&~signed&&min(curValue)<0&&...
                                                                                            isequal(currentScalingPanel,'UDTBinaryPointPanel')



                                                                                            error(message('Simulink:dialog:UDTScalingNegativeValErr',''));
                                                                                        end
                                                                                    catch err
                                                                                        switch(err.identifier)
                                                                                        case{'Simulink:dialog:UDTScalingComplexValErr',...
                                                                                            'Simulink:dialog:UDTScalingNanValErr',...
                                                                                            'Simulink:dialog:UDTScalingNonNumValErr',...
                                                                                            'Simulink:dialog:UDTScalingNonScalarValErr'}

                                                                                            error(message(err.identifier,...
                                                                                            curStr,strtok(prompt,':'),...
                                                                                            DAStudio.message('Simulink:dialog:UDTScalingAllowedVals')...
                                                                                            ));

                                                                                        case 'Simulink:dialog:UDTScalingNegativeValErr'
                                                                                            error(message(err.identifier,strtok(prompt,':')));

                                                                                        case{'Simulink:dialog:UDTScalingEmptyFieldErr'...
                                                                                            ,'Simulink:dialog:UDTScalingPlusInfValErr'...
                                                                                            ,'Simulink:dialog:UDTScalingMinusInfValErr'}



                                                                                            curValue=[];

                                                                                        otherwise
                                                                                            error(message('Simulink:dialog:UDTScalingNoEvalErr',...
                                                                                            curStr,strtok(prompt,':')));
                                                                                        end
                                                                                    end
                                                                                end
                                                                                valueVec=[valueVec(:);curValue(:)];
                                                                            end


                                                                            if isempty(valueVec)
                                                                                switch currentScalingPanel
                                                                                case 'UDTBinaryPointPanel'
                                                                                    error(message('Simulink:dialog:UDTScalingValAllEmptyErr',...
                                                                                    getPrmListString(hDialog,scalingTags)));
                                                                                case 'UDTSlopeBiasPanel'
                                                                                    error(message('Simulink:dialog:UDTAllValsIdenticalErr',...
                                                                                    getPrmListString(hDialog,scalingTags)));
                                                                                end

                                                                                return;
                                                                            end

                                                                            try
                                                                                wordLengthStr=hDialog.getWidgetValue(strcat(dtTag,'|UDTWordLengthEdit'));

                                                                                wordLength=evalInContext(hDialog,wordLengthStr);
                                                                            catch err
                                                                                error(message('Simulink:dialog:UDTWordLengthNoEvalErr',wordLengthStr));
                                                                            end

                                                                            if wordLength<minWordLength
                                                                                if signed
                                                                                    error(message('Simulink:dialog:UDTWLTooSmallSignedErr'));
                                                                                else
                                                                                    error(message('Simulink:dialog:UDTWLTooSmallUnsignedErr'));
                                                                                end
                                                                            end

                                                                            containerType=fixdt(signed,wordLength);

                                                                            switch currentScalingPanel
                                                                            case 'UDTBinaryPointPanel'

                                                                                fractionLength=-max(fixptbestexp(valueVec,containerType));

                                                                                if(fractionLength==0)

                                                                                    fractionLength=0;
                                                                                end

                                                                                fractionLengthStr=SimulinkFixedPoint.DataType.compactButAccurateNum2Str(fractionLength);

                                                                                hDialog.setWidgetValue(strcat(dtTag,'|UDTFractionLengthEdit'),fractionLengthStr);

                                                                            case 'UDTSlopeBiasPanel'

                                                                                if signed
                                                                                    maxSI=(2^(wordLength-1))-1;
                                                                                    minSI=-(2^(wordLength-1));
                                                                                else
                                                                                    maxSI=(2^(wordLength))-1;
                                                                                    minSI=0;
                                                                                end

                                                                                maxRWV=max(valueVec);
                                                                                minRWV=min(valueVec);

                                                                                if maxRWV==minRWV
                                                                                    error(message('Simulink:dialog:UDTAllValsIdenticalErr',...
                                                                                    getPrmListString(hDialog,scalingTags)));
                                                                                end

                                                                                slope=(maxRWV-minRWV)/(maxSI-minSI);

                                                                                bias=minRWV-(slope*minSI);

                                                                                slopeStr=SimulinkFixedPoint.DataType.compactButAccurateNum2Str(slope);

                                                                                if length(slopeStr)>6

                                                                                    [f_slope,e_slope]=log2(slope);

                                                                                    if f_slope==0.5

                                                                                        e_slope=e_slope-1;
                                                                                        slopeStr=['2^(',SimulinkFixedPoint.DataType.compactButAccurateNum2Str(e_slope),')'];
                                                                                    end
                                                                                end

                                                                                hDialog.setWidgetValue(strcat(dtTag,'|UDTSlopeEdit'),slopeStr);

                                                                                biasStr=SimulinkFixedPoint.DataType.compactButAccurateNum2Str(bias);

                                                                                hDialog.setWidgetValue(strcat(dtTag,'|UDTBiasEdit'),biasStr);

                                                                            otherwise
                                                                                assertTxt='Should not be able to push "Calculate Best-Precision Scaling" button if panel is %s';
                                                                                assert(false,sprintf(assertTxt,currentScalingPanel));
                                                                            end

                                                                            setDataTypeStrFromAssistant(hDialog,dtTag,false);






                                                                            function panel=getCurrentScalingPanel(hDialog,dtTag)


                                                                                panel='unknown';

                                                                                dtaItems=hDialog.getUserData(dtTag);

                                                                                scalingModeTagList=getScalingModeTagList(dtaItems);
                                                                                index=hDialog.getWidgetValue([dtTag,'|UDTScalingModeRadio']);

                                                                                if index<length(scalingModeTagList)
                                                                                    panel=scalingModeTagList{index+1};
                                                                                end











                                                                                function specMethodTagList=getSpecMethodTagList(dtaItems)


                                                                                    specMethodTagList={};
                                                                                    if~isempty(dtaItems)
                                                                                        if~isempty(dtaItems.inheritRules)
                                                                                            specMethodTagList{end+1}='UDTInheritPanel';
                                                                                        end

                                                                                        if~isempty(dtaItems.builtinTypes)
                                                                                            specMethodTagList{end+1}='UDTBuiltinRadio';
                                                                                        end

                                                                                        if~isempty(dtaItems.scalingModes)
                                                                                            specMethodTagList{end+1}='UDTFixedPointGrp';
                                                                                        end

                                                                                        if dtaItems.supportsEnumType
                                                                                            specMethodTagList{end+1}='UDTEnumTypeEdit';
                                                                                        end

                                                                                        if dtaItems.supportsBusType
                                                                                            specMethodTagList{end+1}='UDTBusTypeGrp';
                                                                                        end

                                                                                        if slfeature('SupportImageInDTA')==1&&dtaItems.supportsImageDataType
                                                                                            specMethodTagList{end+1}='UDTImageTypeGrp';
                                                                                        end

                                                                                        if(slfeature('CUSTOM_BUSES')==1)&&dtaItems.supportsConnectionBusType
                                                                                            specMethodTagList{end+1}='UDTConnBusTypeGrp';
                                                                                        end

                                                                                        if(slfeature('CUSTOM_BUSES')==1)&&dtaItems.supportsConnectionType
                                                                                            specMethodTagList{end+1}='UDTConnTypeEdit';
                                                                                        end

                                                                                        if(slfeature('SLValueType')==1)&&dtaItems.supportsValueTypeType
                                                                                            specMethodTagList{end+1}='UDTValueTypeTypeGrp';
                                                                                        end

                                                                                        if dtaItems.allowsExpression
                                                                                            specMethodTagList{end+1}='UDTExprEdit';
                                                                                        end

                                                                                        if~isempty(dtaItems.extras)
                                                                                            for i=1:length(dtaItems.extras)
                                                                                                specMethodTagList{end+1}=dtaItems.extras(i).container.Tag;%#ok
                                                                                            end
                                                                                        end
                                                                                    end










                                                                                    function scalingModeTagList=getScalingModeTagList(dtaItems)


                                                                                        scalingModeTagList={};
                                                                                        if~isempty(dtaItems.scalingModes)
                                                                                            scalingModes=dtaItems.scalingModes;
                                                                                            scalingModeTagList=cell(1,length(scalingModes)-1);
                                                                                            for i=1:length(scalingModes)
                                                                                                switch scalingModes{i}
                                                                                                case 'UDTBinaryPointMode'
                                                                                                    scalingModeTagList{i}='UDTBinaryPointPanel';
                                                                                                case 'UDTSlopeBiasMode'
                                                                                                    scalingModeTagList{i}='UDTSlopeBiasPanel';
                                                                                                otherwise

                                                                                                end
                                                                                            end
                                                                                        end











                                                                                        function value=getPulldownText(hDialog,tag)


                                                                                            imd=DAStudio.imDialog.getIMWidgets(hDialog);
                                                                                            pulldown=imd.find('Tag',tag);
                                                                                            if~isempty(pulldown)
                                                                                                value=pulldown(1).currentText;
                                                                                            else
                                                                                                value='';
                                                                                            end











                                                                                            function prmListString=getPrmListString(hDialog,scalingTags)


                                                                                                numScalingTags=length(scalingTags);



                                                                                                prompt=getPromptForWidget(hDialog,scalingTags{1});
                                                                                                prmListString=strtok(prompt,':');

                                                                                                if(numScalingTags>1)
                                                                                                    for i=2:length(scalingTags)
                                                                                                        prompt=getPromptForWidget(hDialog,scalingTags{i});
                                                                                                        prmListString=[prmListString,', ',strtok(prompt,':')];%#ok
                                                                                                    end
                                                                                                end











                                                                                                function setWidgetValueIfNecessary(hDialog,tag,value)


                                                                                                    oldValue=hDialog.getWidgetValue(tag);
                                                                                                    if~isequal(oldValue,value)
                                                                                                        hDialog.setWidgetValue(tag,value)
                                                                                                    end







                                                                                                    function setDataTypeInfoTable(hDialog,dtTag)


                                                                                                        dtaItems=hDialog.getUserData(dtTag);
                                                                                                        [repMaxInfo,repMinInfo,resolutionInfo,otherInfo]=collectDataTypeInfo(hDialog,dtTag,dtaItems);

                                                                                                        scalingTags=[dtaItems.scalingMaxTag,dtaItems.scalingValueTags{:},dtaItems.scalingMinTag];

                                                                                                        tableTag=strcat(dtTag,'|UDTInfoTab');


                                                                                                        setDataTypeInfoRow(hDialog,...
                                                                                                        [tableTag,'|RepMax'],...
                                                                                                        repMaxInfo.Name,repMaxInfo.Val,repMaxInfo.Comm,repMaxInfo.EvalStatus);


                                                                                                        for i=1:length(scalingTags)

                                                                                                            rowTagPrefix=[tableTag,'|',scalingTags{i}];
                                                                                                            setDataTypeInfoRow(hDialog,...
                                                                                                            rowTagPrefix,...
                                                                                                            otherInfo{i}.Name,otherInfo{i}.Val,otherInfo{i}.Comm,otherInfo{i}.EvalStatus);
                                                                                                        end


                                                                                                        setDataTypeInfoRow(hDialog,...
                                                                                                        [tableTag,'|RepMin'],...
                                                                                                        repMinInfo.Name,repMinInfo.Val,repMinInfo.Comm,repMinInfo.EvalStatus);
                                                                                                        setDataTypeInfoRow(hDialog,...
                                                                                                        [tableTag,'|Resolution'],...
                                                                                                        resolutionInfo.Name,resolutionInfo.Val,resolutionInfo.Comm,resolutionInfo.EvalStatus);







                                                                                                        function signMode=getSignMode(hDialog,dtTag)

                                                                                                            dtaItems=hDialog.getUserData(dtTag);
                                                                                                            signModeIdx=hDialog.getWidgetValue(strcat(dtTag,'|UDTSignRadio'));
                                                                                                            signMode=dtaItems.signModes{signModeIdx+1};






                                                                                                            function setDataTypeInfoRow(hDialog,rowTagPrefix,name,value,comment,evalStatus)


                                                                                                                hDialog.setWidgetValue([rowTagPrefix,'Name'],name);
                                                                                                                hDialog.setWidgetValue([rowTagPrefix,'Val'],value);
                                                                                                                hDialog.setWidgetValue([rowTagPrefix,'Comm'],comment);


                                                                                                                evalOk=0;
                                                                                                                evalWarn=1;
                                                                                                                evalSkip=2;

                                                                                                                switch evalStatus
                                                                                                                case evalOk
                                                                                                                    hDialog.setVisible([rowTagPrefix,'Warn'],false);
                                                                                                                    hDialog.setEnabled([rowTagPrefix,'Val'],true);
                                                                                                                case evalWarn
                                                                                                                    hDialog.setVisible([rowTagPrefix,'Warn'],true);
                                                                                                                    hDialog.setEnabled([rowTagPrefix,'Val'],true);
                                                                                                                case evalSkip
                                                                                                                    hDialog.setVisible([rowTagPrefix,'Warn'],false);



                                                                                                                    hDialog.setEnabled([rowTagPrefix,'Val'],false);
                                                                                                                end






                                                                                                                function dialogSrc=getDialogSource(hDialog)

                                                                                                                    dialogSrc=hDialog.getSource;

                                                                                                                    if(isa(dialogSrc,'Simulink.SlidDAProxy'))
                                                                                                                        slidObject=dialogSrc.getObject();
                                                                                                                        dialogSrc=slidObject.WorkspaceObjectSharedCopy;
                                                                                                                    end

                                                                                                                    if ismethod(dialogSrc,'getForwardedObject')
                                                                                                                        dialogSrc=dialogSrc.getForwardedObject;
                                                                                                                    end








                                                                                                                    function dataSource=checkDictionaryConnection(hDialog)

                                                                                                                        dataSource='';
                                                                                                                        dialogSource=hDialog.getSource;
                                                                                                                        if isa(dialogSource,'BusEditor.element')
                                                                                                                            scope=dialogSource.getRoot.nodeconnection;
                                                                                                                            if scope.IsConnectedToDataDictionary
                                                                                                                                dataSource=scope.DataSource;
                                                                                                                            end
                                                                                                                            return;
                                                                                                                        end

                                                                                                                        if isa(dialogSource,'Simulink.typeeditor.app.Element')||...
                                                                                                                            isa(dialogSource,'Simulink.typeeditor.app.Object')
                                                                                                                            scope=dialogSource.getRoot.NodeConnection;
                                                                                                                            if scope.IsConnectedToDataDictionary
                                                                                                                                dataSource=scope.DataSource;
                                                                                                                            end
                                                                                                                            return;
                                                                                                                        end

                                                                                                                        if isa(dialogSource,'sl.interface.dictionaryApp.node.DesignNode')

                                                                                                                            dataSource=dialogSource.getInterfaceDictionary;
                                                                                                                            return;
                                                                                                                        end

                                                                                                                        if isprop(dialogSource,'m_ddConn')
                                                                                                                        else
                                                                                                                            if isa(dialogSource,'Stateflow.Data')||isa(dialogSource,'Stateflow.Message')

                                                                                                                                obj=dialogSource.Machine.getParent;
                                                                                                                            else
                                                                                                                                if ismethod(dialogSource,'getBlock')
                                                                                                                                    obj=dialogSource.getBlock;
                                                                                                                                elseif isprop(dialogSource,'Path')



                                                                                                                                    path=dialogSource.Path;
                                                                                                                                    if~isempty(path)
                                                                                                                                        obj=get_param(path,'Object');
                                                                                                                                        if isempty(obj)
                                                                                                                                            return;
                                                                                                                                        end
                                                                                                                                    else
                                                                                                                                        return;
                                                                                                                                    end
                                                                                                                                else
                                                                                                                                    return;
                                                                                                                                end
                                                                                                                                while true
                                                                                                                                    parentBlk=obj.getParent;
                                                                                                                                    if isa(parentBlk,'Simulink.Root')
                                                                                                                                        break;
                                                                                                                                    end
                                                                                                                                    obj=parentBlk;
                                                                                                                                end
                                                                                                                            end
                                                                                                                            assert(isa(obj,'Simulink.BlockDiagram'));

                                                                                                                            ddName=obj.DataDictionary;
                                                                                                                            if~isempty(ddName)

                                                                                                                                dataSource=Simulink.dd.open(ddName);
                                                                                                                                if sl.interface.dict.api.isInterfaceDictionary(dataSource.filespec)


                                                                                                                                    dataSource=Simulink.interface.dictionary.open(dataSource.filespec);
                                                                                                                                end
                                                                                                                            end
                                                                                                                        end







                                                                                                                        function revertDTValueAndClearDirtyFlag(hDialog,dtTag,value,dtaItems)


                                                                                                                            hDialog.setWidgetValue(dtTag,value);

                                                                                                                            hDialog.clearWidgetDirtyFlag(dtTag);


                                                                                                                            res=Simulink.DataTypePrmWidget.parseDataTypeString(value,dtaItems);


                                                                                                                            assert(strcmp(res.errMsg.id,'UDTNoError'));

                                                                                                                            hDialog.setWidgetValue(strcat(dtTag,'|UDTDataTypeSpecMethodRadio'),res.indexSpecMethod);

                                                                                                                            setAssistantFromDataTypeStr(hDialog,dtTag,res);



                                                                                                                            hDialog.clearWidgetDirtyFlag([dtTag,'|UDTDataTypeSpecMethodRadio']);

                                                                                                                            specMethodTagList=getSpecMethodTagList(dtaItems);
                                                                                                                            for i=1:length(specMethodTagList)
                                                                                                                                dtaTag=specMethodTagList{i};

                                                                                                                                if strcmp(dtaTag,'UDTBusTypeGrp')
                                                                                                                                    dtaTag='UDTBusTypeEdit';
                                                                                                                                elseif strcmp(dtaTag,'UDTConnBusTypeGrp')
                                                                                                                                    dtaTag='UDTConnBusTypeEdit';
                                                                                                                                elseif strcmp(dtaTag,'UDTValueTypeTypeGrp')
                                                                                                                                    dtaTag='UDTValueTypeTypeEdit';
                                                                                                                                end
                                                                                                                                hDialog.clearWidgetDirtyFlag([dtTag,'|',dtaTag]);
                                                                                                                            end








