function panel=getDataTypeWidget(hProxy,dtName,dtPrompt,dtTag,dtVal,dtaItems,dtaOn)

































































































































































    if(isa(hProxy,'Simulink.SlidDAProxy'))
        slidObject=hProxy.getObject();
        hDlgSource=slidObject.WorkspaceObjectSharedCopy;
    else
        hDlgSource=hProxy;
    end


    dtaItems=setDefaultDtaItems(dtaItems);


    if slfeature('SLInt64')==0
        dtaItems.builtinTypes(strcmp(dtaItems.builtinTypes,'int64'))=[];
        dtaItems.builtinTypes(strcmp(dtaItems.builtinTypes,'uint64'))=[];
    end


    checkArguments(dtName,dtTag,dtVal,dtaItems,dtaOn);

    dtaItems.isAliasObject=isa(hDlgSource,'Simulink.AliasType');

    dtipOpen=false;
    try



        if isempty(findprop(hDlgSource,'UDTAssistOpen'))
            addInstanceProp(hDlgSource,'UDTAssistOpen','mxArray');
        end




        if isempty(findprop(hDlgSource,'UDTIPOpen'))
            addInstanceProp(hDlgSource,'UDTIPOpen','mxArray');
        end

        if isempty(hDlgSource.UDTAssistOpen)





            hDlgSource.UDTAssistOpen.tags={dtTag};
            hDlgSource.UDTAssistOpen.status={dtaOn};

        else


            whichTag=find(strcmp(dtTag,hDlgSource.UDTAssistOpen.tags),1);
            if isempty(whichTag)
                hDlgSource.UDTAssistOpen.tags=[hDlgSource.UDTAssistOpen.tags{:},{dtTag}];
                hDlgSource.UDTAssistOpen.status=[hDlgSource.UDTAssistOpen.status{:},{dtaOn}];
            else
                dtaOn=hDlgSource.UDTAssistOpen.status{whichTag};
            end
        end




        if isempty(findprop(hDlgSource,'UDTIPOpen'))
            addInstanceProp(hDlgSource,'UDTIPOpen','mxArray');
        end

        if isempty(hDlgSource.UDTIPOpen)



            hDlgSource.UDTIPOpen.tags={dtTag};
            hDlgSource.UDTIPOpen.status={dtipOpen};
        else


            whichTag=find(strcmp(dtTag,hDlgSource.UDTIPOpen.tags),1);
            if isempty(whichTag)
                hDlgSource.UDTIPOpen.tags=[hDlgSource.UDTIPOpen.tags{:},{dtTag}];
                hDlgSource.UDTIPOpen.status=[hDlgSource.UDTIPOpen.status{:},{dtipOpen}];
            else
                dtipOpen=hDlgSource.UDTIPOpen.status{whichTag};
            end

        end
    catch ME
        if strcmp(ME.identifier,'MATLAB:noSuchMethodOrField')...
            ||strcmp(ME.identifier,'MATLAB:UndefinedFunction')


        else
            rethrow(ME);
        end
    end


    hOpenDialogs=DAStudio.ToolRoot.getOpenDialogs(hProxy);


    if~isempty(hOpenDialogs)&&hOpenDialogs(1).isWidgetValid(dtTag)





        if~isa(hDlgSource,'Stateflow.Object')


            dtVal=hOpenDialogs(1).getComboBoxText(dtTag);
        end





        if dtaOn||~Simulink.data.isHandleObject(hDlgSource)



            prevDTAWidgetValues=getPrevDTAWidgetValues(hOpenDialogs(1),dtTag,dtaItems.scalingModes);




            if isempty(dtaItems.scalingModes)
                dtInfo=[];
            else
                [dtInfo.RepMaxInfo,dtInfo.RepMinInfo,dtInfo.ResolutionInfo,dtInfo.OtherInfo]=...
                collectDataTypeInfo(hOpenDialogs(1),dtTag,dtaItems);
            end
        else
            dtipOpen=false;
            dtInfo=[];
            prevDTAWidgetValues=[];
        end
    else




        dtipOpen=false;
        dtInfo=[];


        prevDTAWidgetValues=[];
    end






    res=Simulink.DataTypePrmWidget.parseDataTypeString(dtVal,dtaItems);
    if(res.isFixPt&&res.fixptProps.openAssistant)
        dtaOn=true;
    end



    curItems={};


    curRow=1;


    col=1;

    if~isempty(dtPrompt)
        dataTypeLbl=initTagNameType(dtTag,'UDTDataTypeLbl','','text');
        dataTypeLbl.Name=dtPrompt;
        dataTypeLbl.RowSpan=[curRow,curRow];
        dataTypeLbl.ColSpan=[col,col];
        dataTypeLbl.Buddy=dtTag;
        curItems{end+1}=dataTypeLbl;
        col=col+1;
    end



    curRow=1;

    dataTypeWidget=getDataTypeCombobox(hProxy,...
    dtName,...
    dtTag,...
    dtaItems);
    dataTypeWidget.Editable=true;

    dtaItems.PropertyName=dtName;
    dataTypeWidget.UserData=dtaItems;
    dataTypeWidget.RowSpan=[curRow,curRow];
    dataTypeWidget.ColSpan=[col,col];
    curItems{end+1}=dataTypeWidget;


    col=col+1;

    moreButton=getPushButtonWidget_More(dtTag);
    moreButton.RowSpan=[curRow,curRow];
    moreButton.ColSpan=[col,col];
    moreButton.Visible=~dtaOn;
    curItems{end+1}=moreButton;

    lessButton=getPushButtonWidget_Less(dtTag);
    lessButton.RowSpan=[curRow,curRow];
    lessButton.ColSpan=[col,col];
    lessButton.Visible=dtaOn;
    curItems{end+1}=lessButton;


    expandButton=getPushButtonWidget_Expand(hDlgSource,dtName,dtPrompt,dtTag,dtVal,dtaItems,dtaOn);
    expandButton.RowSpan=[curRow,curRow];
    expandButton.ColSpan=[col,col];
    expandButton.Visible=false;
    expandButton.PreferredSize=[18,-1];
    curItems{end+1}=expandButton;


    curRow=curRow+1;

    createDTA=dtaOn||~Simulink.data.isHandleObject(hDlgSource);
    dataTypeAssistGrp=getDataTypeAssistGrp(hDlgSource,...
    dtTag,...
    res,...
    dtaItems,...
    dtipOpen,...
    dtInfo,...
    prevDTAWidgetValues,...
    createDTA);

    dataTypeAssistGrp.RowSpan=[curRow,curRow];
    dataTypeAssistGrp.ColSpan=[1,col];

    dataTypeAssistGrp.Visible=lessButton.Visible;

    curItems{end+1}=dataTypeAssistGrp;


    panel=initTagNameType(dtTag,'DataTypePanel',-1,'panel');
    panel.Tag=Simulink.DataTypePrmWidget.getDataTypeWidgetTag(dtTag);
    panel=initContainerItems(panel,curItems);
    panel.ColStretch=zeros(1,col);

    if isempty(dtPrompt)
        panel.ColStretch(1)=1;
    else
        panel.ColStretch(2)=1;
    end












    function checkArguments(dtName,dtTag,dtVal,dtaItems,dtaOn)



        assert(isstruct(dtaItems),...
        'dtaItems must be a structure.');


        assert(~isempty(dtName),...
        'The data type parameter name cannot be empty.');


        assert(~isempty(dtTag),...
        'The data type parameter tag cannot be empty.');


        assert(dtTag(1)~='|'&&strcmp(dtTag,strtok(dtTag,'|')),...
        'The data type parameter tag cannot contain the character ''|''.');


        isempty(dtVal);


        assert(islogical(dtaOn),'Argument dtaOn must be a boolean.');



        if~isempty(dtaItems.scalingModes)&&any(strcmp('UDTIntegerMode',dtaItems.scalingModes))
            assert(length(dtaItems.scalingModes)==1,...
            'Integer mode cannot coexist with other scaling modes');
        end



        assert(isempty(dtaItems.scalingModes)||~isempty(dtaItems.signModes));



        if~isempty(dtaItems.scalingMinTag)
            assert(length(dtaItems.scalingMinTag)<=1,...
            'The can be at most one scalingMinTag');
        end
        if~isempty(dtaItems.scalingMaxTag)
            assert(length(dtaItems.scalingMaxTag)<=1,...
            'The can be at most one scalingMaxTag');
        end













        function dataTypeWidget=getDataTypeCombobox(hProxy,dtName,dtTag,dtaItems)

            if(isa(hProxy,'Simulink.SlidDAProxy'))
                slidObject=hProxy.getObject();
                hDlgSource=slidObject.WorkspaceObjectSharedCopy;
            else
                hDlgSource=hProxy;
            end

            entries=Simulink.DataTypePrmWidget.getDataTypeAllowedItems(dtaItems,hProxy);

            if~isempty(dtaItems.extras)
                for i=1:length(dtaItems.extras)
                    panel=dtaItems.extras(i);
                    if~isfield(panel,'hint')||isempty(panel.hint)
                        entries{end+1}=[panel.header,': <variable name>'];%#ok
                    else
                        entries{end+1}=[panel.header,': ',panel.hint];%#ok
                    end
                end
            end

            dataTypeWidget=initTagNameType(dtTag,'','combobox');
            dataTypeWidget.Entries=entries;
            dataTypeWidget.ObjectProperty=dtName;



            if isa(hDlgSource,'Simulink.SLDialogSource')
                dataTypeWidget.Source=hDlgSource.getBlock;
            else
                if Simulink.data.isHandleObject(hDlgSource)
                    dataTypeWidget.Source=hDlgSource;
                else


                end
            end

            dataTypeWidget.ToolTip=DAStudio.message('Simulink:dialog:UDTDataTypeToolTip');

            dataTypeWidget=setValueChangeCallback(dataTypeWidget);







            function moreButton=getPushButtonWidget_More(dtTag)


                moreButton=initTagNameType(dtTag,...
                'UDTShowDataTypeAssistBtn',...
                '',...
                'pushbutton');
                moreButton.Name='>>';
                moreButton.ToolTip=DAStudio.message('Simulink:dialog:UDTShowDataTypeAssistToolTip');
                moreButton=setButtonPushCallback(moreButton);







                function lessButton=getPushButtonWidget_Less(dtTag)


                    lessButton=initTagNameType(dtTag,...
                    'UDTHideDataTypeAssistBtn',...
                    '',...
                    'pushbutton');
                    lessButton.Name='<<';
                    lessButton.ToolTip=DAStudio.message('Simulink:dialog:UDTHideDataTypeAssistToolTip');
                    lessButton=setButtonPushCallback(lessButton);







                    function expandButton=getPushButtonWidget_Expand(hDlgSource,dtName,dtPrompt,dtTag,dtVal,dtaItems,dtaOn)


                        expandButton=initTagNameType(dtTag,...
                        'UDTExpandDataTypeAssistBtn',...
                        '',...
                        'pushbutton');
                        expandButton.Name='...';
                        expandButton.ToolTip=DAStudio.message('Simulink:dialog:UDTShowDataTypeAssistToolTip');
                        expandButton.MatlabMethod='Simulink.DataTypePrmWidget.createDataTypeAssistantFlyout';
                        expandButton.MatlabArgs={'%dialog','%tag',hDlgSource,dtName,dtPrompt,dtTag,dtVal,dtaItems,dtaOn};





















                        function curGroup=getDataTypeAssistGrp(hDlgSource,dtTag,res,dtaItems,dtipOpen,dtInfo,prevDTAWidgetValues,createDTA)


                            maxCol=4;

                            curItems={};

                            if createDTA

                                curRow=1;


                                dataTypeModeWidget=getDataTypeSpecMethodWidget(dtTag,res,dtaItems);
                                dataTypeModeWidget.RowSpan=[curRow,curRow];
                                dataTypeModeWidget.ColSpan=[1,1];
                                dataTypeModeWidget.Alignment=3;
                                dataTypeModeWidget.Visible=true;
                                curItems{end+1}=dataTypeModeWidget;

                                colRight=[2,maxCol];
                                rowRight=[curRow,curRow];




                                if~isempty(dtaItems.inheritRules)
                                    inheritWidget=getInheritRulesPanel(dtTag,...
                                    res,...
                                    dtaItems.inheritRules,...
                                    dtaItems.ruleTranslator,...
                                    prevDTAWidgetValues);
                                    inheritWidget.RowSpan=rowRight;
                                    inheritWidget.ColSpan=colRight;
                                    inheritWidget.Visible=res.isInherit;
                                    curItems{end+1}=inheritWidget;
                                end




                                if~isempty(dtaItems.builtinTypes)
                                    builtinWidget=getBuiltinTypeRadioButton(dtTag,...
                                    res,...
                                    dtaItems.builtinTypes,...
                                    prevDTAWidgetValues);
                                    builtinWidget.RowSpan=rowRight;
                                    builtinWidget.ColSpan=[2,2];
                                    builtinWidget.Visible=res.isBuiltin;
                                    curItems{end+1}=builtinWidget;


                                    if~strcmp(dtTag,'BaseType')

                                        dtoLbl=initTagNameType(dtTag,'UDTDTOBuiltinComboLbl','UDTDTOLbl','text');
                                        dtoLbl.RowSpan=rowRight;
                                        dtoLbl.ColSpan=[3,3];
                                        dtoLbl.Visible=res.isBuiltin;


                                        dtoWidget=getDTOWidget(dtTag,res,'UDTDTOBuiltinCombo',prevDTAWidgetValues);
                                        dtoWidget.RowSpan=rowRight;
                                        dtoWidget.ColSpan=[maxCol,maxCol];
                                        dtoWidget.Visible=res.isBuiltin;

                                        dtoLbl.Buddy=dtoWidget.Tag;
                                        curItems{end+1}=dtoLbl;
                                        curItems{end+1}=dtoWidget;
                                    end

                                end


                                if dtaItems.allowsExpression
                                    exprWidget=getDataTypeExprEdit(hDlgSource,dtTag,res,dtaItems,prevDTAWidgetValues);
                                    exprWidget.RowSpan=rowRight;
                                    exprWidget.ColSpan=colRight;
                                    exprWidget.Visible=res.isExpress;
                                    curItems{end+1}=exprWidget;
                                end


                                if~isempty(dtaItems.scalingModes)
                                    numScalingMinMaxTags=length(dtaItems.scalingMinTag)+length(dtaItems.scalingMaxTag);
                                    numScalingValueTags=length(dtaItems.scalingValueTags);
                                    fixptGrpWidget=getFixedPointGroup(dtTag,...
                                    res,...
                                    dtaItems.scalingModes,...
                                    dtaItems.signModes,...
                                    dtaItems.tattoos,...
                                    numScalingMinMaxTags,...
                                    numScalingValueTags,...
                                    prevDTAWidgetValues);
                                    fixptGrpWidget.RowSpan=rowRight;
                                    fixptGrpWidget.ColSpan=colRight;
                                    fixptGrpWidget.Visible=res.isFixPt;
                                    curItems{end+1}=fixptGrpWidget;
                                end

                                if(slfeature('SupportImageInDTA')==1)&&dtaItems.supportsImageDataType
                                    imageTypeGrpWidget=getImageTypeGroup(dtTag,...
                                    res,...
                                    prevDTAWidgetValues);
                                    imageTypeGrpWidget.RowSpan=rowRight;
                                    imageTypeGrpWidget.ColSpan=colRight;
                                    imageTypeGrpWidget.Visible=res.isImageType;
                                    curItems{end+1}=imageTypeGrpWidget;
                                end

                                if dtaItems.supportsEnumType
                                    enumTypeWidget=getEnumTypeEdit(hDlgSource,...
                                    dtTag,...
                                    res,...
                                    dtaItems.supportsEnumType,...
                                    prevDTAWidgetValues);
                                    enumTypeWidget.RowSpan=rowRight;
                                    enumTypeWidget.ColSpan=colRight;
                                    enumTypeWidget.Visible=res.isEnumType;
                                    curItems{end+1}=enumTypeWidget;
                                end

                                if dtaItems.supportsBusType
                                    busTypeWidget=getBusTypeGroup(hDlgSource,...
                                    dtTag,...
                                    res,...
                                    dtaItems.supportsBusType,...
                                    prevDTAWidgetValues);
                                    busTypeWidget.RowSpan=rowRight;
                                    busTypeWidget.ColSpan=colRight;
                                    busTypeWidget.Visible=res.isBusType;
                                    curItems{end+1}=busTypeWidget;
                                end

                                if(slfeature('CUSTOM_BUSES')==1)&&dtaItems.supportsConnectionBusType
                                    connBusTypeWidget=getConnBusTypeGroup(hDlgSource,...
                                    dtTag,...
                                    res,...
                                    dtaItems.supportsConnectionBusType,...
                                    prevDTAWidgetValues);
                                    connBusTypeWidget.RowSpan=rowRight;
                                    connBusTypeWidget.ColSpan=colRight;
                                    connBusTypeWidget.Visible=res.isConnectionBusType;
                                    curItems{end+1}=connBusTypeWidget;
                                end

                                if(slfeature('CUSTOM_BUSES')==1)&&dtaItems.supportsConnectionType
                                    connTypeWidget=getConnTypeEdit(hDlgSource,...
                                    dtTag,...
                                    res,...
                                    dtaItems.supportsConnectionType,...
                                    prevDTAWidgetValues);
                                    connTypeWidget.RowSpan=rowRight;
                                    connTypeWidget.ColSpan=colRight;
                                    connTypeWidget.Visible=res.isConnectionType;
                                    curItems{end+1}=connTypeWidget;
                                end

                                if slfeature('SLValueType')==1&&dtaItems.supportsValueTypeType
                                    valueTypeTypeWidget=getValueTypeTypeGroup(hDlgSource,...
                                    dtTag,...
                                    res,...
                                    dtaItems.supportsValueTypeType,...
                                    prevDTAWidgetValues);
                                    valueTypeTypeWidget.RowSpan=rowRight;
                                    valueTypeTypeWidget.ColSpan=colRight;
                                    valueTypeTypeWidget.Visible=res.isValueTypeType;
                                    curItems{end+1}=valueTypeTypeWidget;
                                end




                                if~isempty(dtaItems.extras)
                                    for i=1:length(dtaItems.extras)
                                        extraWidget=dtaItems.extras(i).container;
                                        extraWidget.RowSpan=rowRight;
                                        extraWidget.ColSpan=colRight;
                                        if res.isExtra&&res.extraProps.indexExtra+1==i
                                            extraWidget.Visible=true;
                                        else
                                            extraWidget.Visible=false;
                                        end
                                        curItems{end+1}=extraWidget;%#ok
                                    end
                                end

                                if~isempty(dtaItems.scalingModes)
                                    curRow=curRow+1;

                                    dataTypeDetailsPnl=getDataTypeInfoPanel(dtTag,...
                                    dtaItems.scalingMinTag,...
                                    dtaItems.scalingMaxTag,...
                                    dtaItems.scalingValueTags,...
                                    dtipOpen,...
                                    dtInfo);
                                    dataTypeDetailsPnl.RowSpan=[curRow,curRow];
                                    dataTypeDetailsPnl.ColSpan=[1,maxCol];
                                    dataTypeDetailsPnl.Visible=res.isFixPt;
                                    curItems{end+1}=dataTypeDetailsPnl;
                                end
                            end

                            curGroup=initTagNameType(dtTag,'UDTDataTypeAssistGrp','UDTDataTypeAssistGrp','group');

                            if createDTA
                                curGroup=initContainerItems(curGroup,curItems);
                                curGroup.ColStretch(1:end-1)=0;
                            end









                            function curWidget=getDataTypeSpecMethodWidget(dtTag,res,dtaItems)


                                curWidget=initTagNameType(dtTag,...
                                'UDTDataTypeSpecMethodRadio',...
                                'UDTDataTypeSpecMethodRadio',...
                                'combobox');
                                curWidget.Editable=false;

                                curWidget.Entries={};
                                if~isempty(dtaItems.inheritRules)
                                    curWidget.Entries{end+1}=DAStudio.message('Simulink:dialog:UDTInheritRadioEntry');
                                end

                                if~isempty(dtaItems.builtinTypes)
                                    curWidget.Entries{end+1}=DAStudio.message('Simulink:dialog:UDTBuiltinRadioEntry');
                                end

                                if~isempty(dtaItems.scalingModes)
                                    curWidget.Entries{end+1}=DAStudio.message('Simulink:dialog:UDTFixedPointRadioEntry');
                                end

                                if dtaItems.supportsEnumType
                                    curWidget.Entries{end+1}=DAStudio.message('Simulink:dialog:UDTEnumRadioEntry');
                                end

                                if dtaItems.supportsBusType
                                    curWidget.Entries{end+1}=DAStudio.message('Simulink:dialog:UDTBusRadioEntry');
                                end

                                if slfeature('SupportImageInDTA')==1&&dtaItems.supportsImageDataType
                                    curWidget.Entries{end+1}=DAStudio.message('Simulink:dialog:UDTImageRadioEntry');
                                end

                                if(slfeature('CUSTOM_BUSES')==1)&&dtaItems.supportsConnectionBusType
                                    curWidget.Entries{end+1}=DAStudio.message('Simulink:dialog:UDTConnectionBusRadioEntry');
                                end

                                if(slfeature('CUSTOM_BUSES')==1)&&dtaItems.supportsConnectionType
                                    curWidget.Entries{end+1}=DAStudio.message('Simulink:dialog:UDTConnectionRadioEntry');
                                end

                                if slfeature('SLValueType')==1&&dtaItems.supportsValueTypeType
                                    curWidget.Entries{end+1}=DAStudio.message('Simulink:dialog:UDTValueTypeRadioEntry');
                                end

                                if dtaItems.allowsExpression
                                    curWidget.Entries{end+1}=DAStudio.message('Simulink:dialog:UDTExprRadioEntry');
                                end

                                numBuiltinSpecMethods=length(curWidget.Entries);

                                if~isempty(dtaItems.extras)
                                    for i=1:length(dtaItems.extras)
                                        curWidget.Entries{end+1}=dtaItems.extras(i).name;
                                    end
                                end

                                curWidget=setValueChangeCallback(curWidget);

                                if res.isInherit
                                    dataTypeSpecMethodRadioEntry='UDTInheritRadioEntry';
                                elseif res.isBuiltin
                                    dataTypeSpecMethodRadioEntry='UDTBuiltinRadioEntry';
                                elseif res.isEnumType
                                    dataTypeSpecMethodRadioEntry='UDTEnumRadioEntry';
                                elseif res.isBusType
                                    dataTypeSpecMethodRadioEntry='UDTBusRadioEntry';
                                elseif slfeature('SupportImageInDTA')==1&&res.isImageType
                                    dataTypeSpecMethodRadioEntry='UDTImageRadioEntry';
                                elseif(slfeature('CUSTOM_BUSES')==1)&&res.isConnectionBusType
                                    dataTypeSpecMethodRadioEntry='UDTConnectionBusRadioEntry';
                                elseif(slfeature('CUSTOM_BUSES')==1)&&res.isConnectionType
                                    dataTypeSpecMethodRadioEntry='UDTConnectionRadioEntry';
                                elseif slfeature('SLValueType')==1&&res.isValueTypeType
                                    dataTypeSpecMethodRadioEntry='UDTValueTypeRadioEntry';
                                elseif res.isExpress
                                    dataTypeSpecMethodRadioEntry='UDTExprRadioEntry';
                                elseif res.isFixPt
                                    dataTypeSpecMethodRadioEntry='UDTFixedPointRadioEntry';
                                else

                                    dataTypeSpecMethodRadioEntry='';
                                end

                                specMethodRadioEntryList=getStdSpecMethodRadioEntryList(dtaItems);

                                index=find(strcmp(dataTypeSpecMethodRadioEntry,specMethodRadioEntryList));
                                if length(index)==1
                                    curWidget.Value=index-1;
                                else

                                    curWidget.Value=numBuiltinSpecMethods+res.extraProps.indexExtra;
                                end








                                function curWidget=getInheritRulesPanel(dtTag,res,rules,translator,prevDTAWidgetValues)


                                    curWidget=initTagNameType(dtTag,'UDTInheritPanel','','panel');


                                    ruleWidget=initTagNameType(dtTag,'UDTInheritRadio','','combobox');
                                    ruleWidget.Editable=false;
                                    ruleWidget=setValueChangeCallback(ruleWidget);
                                    if(res.isInherit)
                                        ruleWidget.Value=res.indexInherit;
                                    else
                                        if isempty(prevDTAWidgetValues)
                                            ruleWidget.Value=0;
                                        else
                                            ruleWidget.Value=prevDTAWidgetValues.rule;
                                        end
                                    end
                                    ruleWidget.RowSpan=[1,1];
                                    ruleWidget.ColSpan=[1,1];

                                    if isempty(translator)
                                        ruleWidget.Entries=Simulink.DataTypePrmWidget.udtMessages(rules);
                                        items={ruleWidget};

                                        curWidget=initContainerItems(curWidget,items);
                                        curWidget.LayoutGrid=[1,1];
                                        curWidget.ColStretch=1;
                                        curWidget.RowStretch=1;
                                    else
                                        [ruleWidget.Entries,comments]=feval(translator,rules);
                                        assert(length(ruleWidget.Entries)==length(rules));
                                        assert(length(comments)==length(rules));
                                        commentWidget.Tag=[dtTag,'|UDTInheritComment'];
                                        commentWidget.Type='text';
                                        commentWidget.Name=comments{ruleWidget.Value+1};
                                        commentWidget.UserData=comments;
                                        commentWidget.RowSpan=[2,2];
                                        commentWidget.ColSpan=[1,1];

                                        items={ruleWidget,commentWidget};

                                        curWidget=initContainerItems(curWidget,items);
                                        curWidget.LayoutGrid=[2,1];
                                        curWidget.ColStretch=1;
                                        curWidget.RowStretch=[0,1];
                                    end








                                    function curWidget=getBuiltinTypeRadioButton(dtTag,res,builtins,prevDTAWidgetValues)


                                        curWidget=initTagNameType(dtTag,'UDTBuiltinRadio','','combobox');
                                        curWidget.Editable=false;
                                        curWidget.Entries=builtins;

                                        curWidget=setValueChangeCallback(curWidget);

                                        if(res.isBuiltin)
                                            curWidget.Value=res.indexBuiltin;
                                        else
                                            if isempty(prevDTAWidgetValues)
                                                curWidget.Value=0;
                                            else
                                                curWidget.Value=prevDTAWidgetValues.builtin;
                                            end
                                        end








                                        function curWidget=getDataTypeExprEdit(hDlgSource,dtTag,res,dtaItems,prevDTAWidgetValues)


                                            curWidget=initTagNameType(dtTag,'UDTExprEdit','','combobox');

                                            curWidget.Entries={};




                                            filter.supportNumeric=0;
                                            filter.supportBus=0;
                                            if slfeature('SLValueType')==1
                                                filter.supportValueType=0;
                                            end
                                            filter.supportEnum=0;
                                            filter.supportAlias=0;
                                            if dtaItems.allowsExpression
                                                filter.supportNumeric=1;
                                            end
                                            if dtaItems.allowsExpression&&dtaItems.supportsEnumType
                                                filter.supportEnum=1;
                                            end
                                            if dtaItems.allowsExpression
                                                filter.supportAlias=2;
                                            end


                                            dtvarnames=slprivate('slGetUserDataTypesFromWSDD',hDlgSource,filter,dtaItems);


                                            for k=1:length(dtvarnames)
                                                dtname=dtvarnames{k};
                                                if~contains(dtname,'Enum: ')
                                                    curWidget.Entries=[curWidget.Entries,dtname];
                                                end
                                            end


                                            if isempty(curWidget.Entries)
                                                curWidget.Type='edit';
                                            end


                                            curWidget.Entries{end+1}='<data type expression>';


                                            if res.isExpress
                                                curWidget.Value=res.str;
                                            else
                                                if isempty(prevDTAWidgetValues)
                                                    curWidget.Value=curWidget.Entries{1};
                                                else
                                                    curWidget.Value=prevDTAWidgetValues.expr;
                                                end
                                            end

                                            curWidget.Editable=true;

                                            curWidget=setValueChangeCallback(curWidget);







                                            function curGroup=getFixedPointGroup(dtTag,...
                                                res,...
                                                scalingModes,...
                                                signModes,...
                                                tattoos,...
                                                numScalingMinMaxTags,...
                                                numScalingValueTags,...
                                                prevDTAWidgetValues)












                                                row1=[1,1];
                                                row2=[2,2];
                                                row3=[3,3];
                                                row4=[4,4];
                                                col1=[1,1];
                                                col2=[2,2];
                                                col3=[3,3];
                                                col4=[4,4];

                                                curItems={};


                                                signModeLbl=initTagNameType(dtTag,'UDTSignLbl','UDTSignRadio','text');
                                                signModeLbl.RowSpan=row1;
                                                signModeLbl.ColSpan=col1;


                                                signModeWidget=getSignModeWidget(dtTag,res,signModes,prevDTAWidgetValues);
                                                signModeWidget.RowSpan=row1;
                                                signModeWidget.ColSpan=col2;
                                                signModeWidget.Visible=true;

                                                signModeLbl.Buddy=signModeWidget.Tag;
                                                curItems{end+1}=signModeLbl;
                                                curItems{end+1}=signModeWidget;


                                                wordLengthLbl=initTagNameType(dtTag,'UDTWordLengthLbl','UDTWordLengthEdit','text');
                                                wordLengthLbl.RowSpan=row1;
                                                wordLengthLbl.ColSpan=col3;


                                                if isempty(tattoos.wordLength)
                                                    wordLengthWidget=initTagNameType(dtTag,'UDTWordLengthEdit','','edit');
                                                    wordLengthWidget=setValueChangeCallback(wordLengthWidget);
                                                    if res.isFixPt
                                                        wordLengthWidget.Value=res.fixptProps.wordLength;
                                                    else
                                                        if isempty(prevDTAWidgetValues)
                                                            wordLengthWidget.Value='16';
                                                        else
                                                            wordLengthWidget.Value=prevDTAWidgetValues.wl;
                                                        end
                                                    end
                                                else
                                                    wordLengthWidget=initTagNameType(dtTag,'UDTWordLengthEdit','','text');
                                                    wordLengthWidget.Name=tattoos.wordLength;
                                                end
                                                wordLengthWidget.Visible=true;
                                                wordLengthWidget.RowSpan=row1;
                                                wordLengthWidget.ColSpan=col4;

                                                wordLengthLbl.Buddy=wordLengthWidget.Tag;
                                                curItems{end+1}=wordLengthLbl;
                                                curItems{end+1}=wordLengthWidget;



                                                scalingModeLbl=initTagNameType(dtTag,'UDTScalingModeLbl','UDTScalingModeRadio','text');
                                                scalingModeLbl.RowSpan=row2;
                                                scalingModeLbl.ColSpan=col1;


                                                scalingModeWidget=getScalingSpecMethodWidget(dtTag,res,scalingModes,prevDTAWidgetValues);
                                                scalingModeWidget.Visible=true;
                                                scalingModeWidget.RowSpan=row2;
                                                scalingModeWidget.ColSpan=col2;
                                                scalingModeLbl.Buddy=scalingModeWidget.Tag;
                                                curItems{end+1}=scalingModeLbl;
                                                curItems{end+1}=scalingModeWidget;


                                                index=find(strcmp('UDTBinaryPointMode',scalingModes));
                                                if~isempty(index)


                                                    binPtVisible=false;
                                                    if(res.isFixPt&&(res.fixptProps.scalingMode==index-1))
                                                        binPtVisible=true;
                                                    end




                                                    if(~res.isFixPt&&~isempty(prevDTAWidgetValues))
                                                        binPtVisible=(prevDTAWidgetValues.sm==index-1);
                                                    end

                                                    fractionLengthLbl=initTagNameType(dtTag,...
                                                    'UDTFractionLengthLbl',...
                                                    'UDTFractionLengthEdit',...
                                                    'text');
                                                    fractionLengthLbl.RowSpan=row2;
                                                    fractionLengthLbl.ColSpan=col3;
                                                    fractionLengthLbl.Visible=binPtVisible;

                                                    if isempty(tattoos.fractionLength)
                                                        fractionLengthWidget=initTagNameType(dtTag,'UDTFractionLengthEdit','','edit');
                                                        fractionLengthWidget=setValueChangeCallback(fractionLengthWidget);
                                                        if res.isFixPt
                                                            fractionLengthWidget.Value=res.fixptProps.fractionLength;
                                                        else
                                                            if isempty(prevDTAWidgetValues)

                                                                fractionLengthWidget.Value='0';
                                                            else
                                                                fractionLengthWidget.Value=prevDTAWidgetValues.fl;
                                                            end
                                                        end
                                                    else
                                                        fractionLengthWidget=initTagNameType(dtTag,'UDTFractionLengthEdit','','text');
                                                        fractionLengthWidget.Name=tattoos.fractionLength;
                                                    end
                                                    fractionLengthWidget.RowSpan=row2;
                                                    fractionLengthWidget.ColSpan=col4;
                                                    fractionLengthWidget.Visible=binPtVisible;
                                                    fractionLengthLbl.Buddy=fractionLengthWidget.Tag;
                                                    curItems{end+1}=fractionLengthLbl;
                                                    curItems{end+1}=fractionLengthWidget;


                                                    dtoLbl=initTagNameType(dtTag,'UDTDTOBinaryPointComboLbl','UDTDTOLbl','text');
                                                    dtoLbl.RowSpan=row3;
                                                    dtoLbl.ColSpan=col1;
                                                    dtoLbl.Visible=binPtVisible;


                                                    dtoWidget=getDTOWidget(dtTag,res,'UDTDTOBinaryPointCombo',prevDTAWidgetValues);
                                                    dtoWidget.RowSpan=row3;
                                                    dtoWidget.ColSpan=col2;
                                                    dtoWidget.Visible=binPtVisible;

                                                    dtoLbl.Buddy=dtoWidget.Tag;
                                                    curItems{end+1}=dtoLbl;
                                                    curItems{end+1}=dtoWidget;

                                                    curWidget=initTagNameType(dtTag,...
                                                    'UDTFractionLengthScalingBtn',...
                                                    'UDTSetScalingBtn',...
                                                    'pushbutton');
                                                    curWidget.RowSpan=row3;
                                                    curWidget.ColSpan=[3,4];
                                                    curWidget.Alignment=7;
                                                    curWidget=setButtonPushCallback(curWidget);



                                                    showScalingBtn=((numScalingMinMaxTags+numScalingValueTags)>0);
                                                    curWidget.Visible=binPtVisible&&showScalingBtn;
                                                    curWidget.ToolTip=DAStudio.message('Simulink:dialog:UDTSetScalingToolTip');
                                                    curItems{end+1}=curWidget;
                                                end


                                                index=find(strcmp('UDTSlopeBiasMode',scalingModes));
                                                if~isempty(index)


                                                    slopeBiasGrpVisible=false;
                                                    if(res.isFixPt&&(res.fixptProps.scalingMode==index-1))
                                                        slopeBiasGrpVisible=true;
                                                    end




                                                    if(~res.isFixPt&&~isempty(prevDTAWidgetValues))
                                                        slopeBiasGrpVisible=(prevDTAWidgetValues.sm==index-1);
                                                    end

                                                    slopeLbl=initTagNameType(dtTag,'UDTSlopeLbl','UDTSlopeEdit','text');
                                                    slopeLbl.RowSpan=row2;
                                                    slopeLbl.ColSpan=col3;
                                                    slopeLbl.Visible=slopeBiasGrpVisible;


                                                    if isempty(tattoos.slope)
                                                        slopeWidget=initTagNameType(dtTag,'UDTSlopeEdit','','edit');
                                                        slopeWidget=setValueChangeCallback(slopeWidget);
                                                        if res.isFixPt
                                                            slopeWidget.Value=res.fixptProps.slope;
                                                        else
                                                            if isempty(prevDTAWidgetValues)

                                                                slopeWidget.Value='2^0';
                                                            else
                                                                slopeWidget.Value=prevDTAWidgetValues.slope;
                                                            end
                                                        end
                                                    else
                                                        slopeWidget=initTagNameType(dtTag,'UDTSlopeEdit','','text');
                                                        slopeWidget.Name=tattoos.slope;
                                                    end
                                                    slopeWidget.RowSpan=row2;
                                                    slopeWidget.ColSpan=col4;
                                                    slopeWidget.Visible=slopeBiasGrpVisible;
                                                    slopeLbl.Buddy=slopeWidget.Tag;
                                                    curItems{end+1}=slopeLbl;
                                                    curItems{end+1}=slopeWidget;

                                                    biasLbl=initTagNameType(dtTag,'UDTBiasLbl','UDTBiasEdit','text');
                                                    biasLbl.RowSpan=row3;
                                                    biasLbl.ColSpan=col3;
                                                    biasLbl.Visible=slopeBiasGrpVisible;

                                                    if isempty(tattoos.bias)
                                                        biasWidget=initTagNameType(dtTag,'UDTBiasEdit','','edit');
                                                        biasWidget=setValueChangeCallback(biasWidget);
                                                        if res.isFixPt
                                                            biasWidget.Value=res.fixptProps.bias;
                                                        else
                                                            if isempty(prevDTAWidgetValues)

                                                                biasWidget.Value='0';
                                                            else
                                                                biasWidget.Value=prevDTAWidgetValues.bias;
                                                            end
                                                        end
                                                    else
                                                        biasWidget=initTagNameType(dtTag,'UDTBiasEdit','','text');
                                                        biasWidget.Name=tattoos.bias;
                                                    end
                                                    biasWidget.RowSpan=row3;
                                                    biasWidget.ColSpan=col4;
                                                    biasWidget.Visible=slopeBiasGrpVisible;
                                                    biasLbl.Buddy=biasWidget.Tag;
                                                    curItems{end+1}=biasLbl;
                                                    curItems{end+1}=biasWidget;


                                                    dtoLbl=initTagNameType(dtTag,'UDTDTOSlopeBiasComboLbl','UDTDTOLbl','text');
                                                    dtoLbl.RowSpan=row4;
                                                    dtoLbl.ColSpan=col1;
                                                    dtoLbl.Visible=slopeBiasGrpVisible;


                                                    dtoWidget=getDTOWidget(dtTag,res,'UDTDTOSlopeBiasCombo',prevDTAWidgetValues);
                                                    dtoWidget.RowSpan=row4;
                                                    dtoWidget.ColSpan=col2;
                                                    dtoWidget.Visible=slopeBiasGrpVisible;

                                                    dtoLbl.Buddy=dtoWidget.Tag;
                                                    curItems{end+1}=dtoLbl;
                                                    curItems{end+1}=dtoWidget;

                                                    curWidget=initTagNameType(dtTag,...
                                                    'UDTSlopeBiasScalingBtn',...
                                                    'UDTSetScalingBtn',...
                                                    'pushbutton');
                                                    curWidget=setButtonPushCallback(curWidget);








                                                    showScalingBtn=(numScalingMinMaxTags==2)||(numScalingValueTags>0);
                                                    curWidget.Visible=slopeBiasGrpVisible&&showScalingBtn;
                                                    curWidget.RowSpan=row4;
                                                    curWidget.ColSpan=[3,4];
                                                    curWidget.Alignment=7;
                                                    curWidget.ToolTip=DAStudio.message('Simulink:dialog:UDTSetScalingToolTip');
                                                    curItems{end+1}=curWidget;
                                                end


                                                index=find(strcmp('UDTBestPrecisionMode',scalingModes));
                                                if~isempty(index)


                                                    bestPrecVisible=false;
                                                    if(res.isFixPt&&(res.fixptProps.scalingMode==index-1))
                                                        bestPrecVisible=true;
                                                    end




                                                    if(~res.isFixPt&&~isempty(prevDTAWidgetValues))
                                                        bestPrecVisible=(prevDTAWidgetValues.sm==index-1);
                                                    end

                                                    dtoLbl=initTagNameType(dtTag,'UDTDTOBestPrecComboLbl','UDTDTOLbl','text');
                                                    dtoLbl.RowSpan=row3;
                                                    dtoLbl.ColSpan=col1;
                                                    dtoLbl.Visible=bestPrecVisible;


                                                    dtoWidget=getDTOWidget(dtTag,res,'UDTDTOBestPrecCombo',prevDTAWidgetValues);
                                                    dtoWidget.RowSpan=row3;
                                                    dtoWidget.ColSpan=col2;
                                                    dtoWidget.Visible=bestPrecVisible;

                                                    dtoLbl.Buddy=dtoWidget.Tag;
                                                    curItems{end+1}=dtoLbl;
                                                    curItems{end+1}=dtoWidget;

                                                end

                                                curGroup=initTagNameType(dtTag,'UDTFixedPointGrp',-1,'panel');
                                                curGroup=initContainerItems(curGroup,curItems);

                                                curGroup.ColStretch=zeros(1,col4(end));
                                                curGroup.ColStretch(end)=1;







                                                function curGroup=getImageTypeGroup(dtTag,res,prevDTAWidgetValues)









                                                    row1=[1,1];
                                                    row2=[2,2];
                                                    row3=[3,3];

                                                    col1=[1,1];
                                                    col2=[2,2];
                                                    col3=[3,3];
                                                    col4=[4,4];

                                                    curItems={};


                                                    colorFormatLbl=initTagNameType(dtTag,'UDTColorFormatLbl','','text');
                                                    colorFormatLbl.Name=DAStudio.message('Simulink:dialog:UDTColorFormatRadio');
                                                    colorFormatLbl.RowSpan=row1;
                                                    colorFormatLbl.ColSpan=col1;


                                                    colorFormatWidget=initTagNameType(dtTag,...
                                                    'UDTColorFormatRadio',...
                                                    '',...
                                                    'combobox');
                                                    colorFormatWidget.Editable=false;

                                                    colorFormatWidget.Entries=getImageTypeFieldList('colorFormat');
                                                    colorFormatWidget=setValueChangeCallback(colorFormatWidget);
                                                    if res.isImageType
                                                        colorFormatWidget.Value=res.imageTypeProps.ColorFormat;
                                                    else
                                                        if isempty(prevDTAWidgetValues)
                                                            colorFormatWidget.Value=0;
                                                        else
                                                            colorFormatWidget.Value=prevDTAWidgetValues.ColorFormat;
                                                        end
                                                    end

                                                    colorFormatWidget.RowSpan=row1;
                                                    colorFormatWidget.ColSpan=col2;
                                                    colorFormatWidget.Visible=true;

                                                    colorFormatLbl.Buddy=colorFormatWidget.Tag;
                                                    curItems{end+1}=colorFormatLbl;
                                                    curItems{end+1}=colorFormatWidget;


                                                    rowsLbl=initTagNameType(dtTag,'UDTRowsLbl','','text');
                                                    rowsLbl.Name=DAStudio.message('Simulink:dialog:UDTRowsEdit');
                                                    rowsLbl.RowSpan=row1;
                                                    rowsLbl.ColSpan=col3;


                                                    rowsWidget=initTagNameType(dtTag,'UDTRowsEdit','','edit');
                                                    rowsWidget=setValueChangeCallback(rowsWidget);
                                                    if res.isImageType
                                                        rowsWidget.Value=res.imageTypeProps.Rows;
                                                    else
                                                        if isempty(prevDTAWidgetValues)
                                                            rowsWidget.Value='480';
                                                        else
                                                            rowsWidget.Value=prevDTAWidgetValues.Rows;
                                                        end
                                                    end
                                                    rowsWidget.Visible=true;
                                                    rowsWidget.RowSpan=row1;
                                                    rowsWidget.ColSpan=col4;

                                                    rowsLbl.Buddy=rowsWidget.Tag;
                                                    curItems{end+1}=rowsLbl;
                                                    curItems{end+1}=rowsWidget;


                                                    layoutLbl=initTagNameType(dtTag,'UDTLayoutLbl','','text');
                                                    layoutLbl.Name=DAStudio.message('Simulink:dialog:UDTLayoutRadio');
                                                    layoutLbl.RowSpan=row2;
                                                    layoutLbl.ColSpan=col1;


                                                    layoutWidget=initTagNameType(dtTag,'UDTLayoutRadio','','combobox');
                                                    layoutWidget.Editable=false;
                                                    layoutWidget.Entries=getImageTypeFieldList('layout');
                                                    layoutWidget=setValueChangeCallback(layoutWidget);

                                                    if res.isImageType
                                                        layoutWidget.Value=res.imageTypeProps.Layout;
                                                    else
                                                        if isempty(prevDTAWidgetValues)
                                                            layoutWidget.Value=0;
                                                        else
                                                            layoutWidget.Value=prevDTAWidgetValues.Layout;
                                                        end
                                                    end

                                                    layoutWidget.Visible=true;
                                                    layoutWidget.RowSpan=row2;
                                                    layoutWidget.ColSpan=col2;
                                                    layoutLbl.Buddy=layoutWidget.Tag;
                                                    curItems{end+1}=layoutLbl;
                                                    curItems{end+1}=layoutWidget;


                                                    colsLbl=initTagNameType(dtTag,'UDTColsLbl','','text');
                                                    colsLbl.Name=DAStudio.message('Simulink:dialog:UDTColsEdit');
                                                    colsLbl.RowSpan=row2;
                                                    colsLbl.ColSpan=col3;


                                                    colsWidget=initTagNameType(dtTag,'UDTColsEdit','','edit');
                                                    colsWidget=setValueChangeCallback(colsWidget);
                                                    if res.isImageType
                                                        colsWidget.Value=res.imageTypeProps.Cols;
                                                    else
                                                        if isempty(prevDTAWidgetValues)
                                                            colsWidget.Value='640';
                                                        else
                                                            colsWidget.Value=prevDTAWidgetValues.Cols;
                                                        end
                                                    end
                                                    colsWidget.Visible=true;
                                                    colsWidget.RowSpan=row2;
                                                    colsWidget.ColSpan=col4;

                                                    colsLbl.Buddy=colsWidget.Tag;
                                                    curItems{end+1}=colsLbl;
                                                    curItems{end+1}=colsWidget;


                                                    classUnderlyingLbl=initTagNameType(dtTag,'UDTClassUnderlyingLbl','','text');
                                                    classUnderlyingLbl.Name=DAStudio.message('Simulink:dialog:UDTClassUnderlyingRadio');
                                                    classUnderlyingLbl.RowSpan=row3;
                                                    classUnderlyingLbl.ColSpan=col1;


                                                    classUnderlyingWidget=initTagNameType(dtTag,'UDTClassUnderlyingRadio','','combobox');
                                                    classUnderlyingWidget.Editable=false;
                                                    classUnderlyingWidget.Entries=getImageTypeFieldList('classUnderlying');
                                                    classUnderlyingWidget=setValueChangeCallback(classUnderlyingWidget);
                                                    if res.isImageType
                                                        classUnderlyingWidget.Value=res.imageTypeProps.ClassUnderlying;
                                                    else
                                                        if isempty(prevDTAWidgetValues)
                                                            classUnderlyingWidget.Value=0;
                                                        else
                                                            classUnderlyingWidget.Value=prevDTAWidgetValues.ClassUnderlying;
                                                        end
                                                    end
                                                    classUnderlyingWidget.Visible=true;
                                                    classUnderlyingWidget.RowSpan=row3;
                                                    classUnderlyingWidget.ColSpan=col2;

                                                    classUnderlyingLbl.Buddy=classUnderlyingWidget.Tag;
                                                    curItems{end+1}=classUnderlyingLbl;
                                                    curItems{end+1}=classUnderlyingWidget;


                                                    channelsLbl=initTagNameType(dtTag,'UDTChannelsLbl','','text');
                                                    channelsLbl.Name=DAStudio.message('Simulink:dialog:UDTChannelsEdit');
                                                    channelsLbl.RowSpan=row3;
                                                    channelsLbl.ColSpan=col3;


                                                    channelsWidget=initTagNameType(dtTag,'UDTChannelsEdit','','edit');
                                                    channelsWidget=setValueChangeCallback(channelsWidget);
                                                    if res.isImageType
                                                        channelsWidget.Value=res.imageTypeProps.Channels;
                                                    else
                                                        if isempty(prevDTAWidgetValues)
                                                            channelsWidget.Value='3';
                                                        else
                                                            channelsWidget.Value=prevDTAWidgetValues.Channels;
                                                        end
                                                    end
                                                    channelsWidget.Visible=true;
                                                    channelsWidget.RowSpan=row3;
                                                    channelsWidget.ColSpan=col4;

                                                    channelsLbl.Buddy=channelsWidget.Tag;
                                                    curItems{end+1}=channelsLbl;
                                                    curItems{end+1}=channelsWidget;


                                                    curGroup=initTagNameType(dtTag,'UDTImageTypeGrp',-1,'panel');
                                                    curGroup=initContainerItems(curGroup,curItems);

                                                    curGroup.ColStretch=zeros(1,col4(end));
                                                    curGroup.ColStretch(end)=1;








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






                                                        function curWidget=getEnumTypeEdit(hDlgSource,dtTag,res,supportsEnumType,prevDTAWidgetValues)


                                                            curWidget=initTagNameType(dtTag,'UDTEnumTypeEdit','','combobox');

                                                            curWidget.Entries={};



                                                            filter.supportNumeric=0;
                                                            filter.supportBus=0;
                                                            if slfeature('SLValueType')==1
                                                                filter.supportValueType=0;
                                                            end
                                                            filter.supportEnum=0;
                                                            filter.supportAlias=0;
                                                            if supportsEnumType
                                                                filter.supportEnum=1;
                                                            end


                                                            dtvarnames=slprivate('slGetUserDataTypesFromWSDD',hDlgSource,filter,{});


                                                            for k=1:length(dtvarnames)
                                                                dtname=dtvarnames{k};
                                                                idx=strfind(dtname,'Enum: ');


                                                                if contains(dtname,'Enum: ')
                                                                    curWidget.Entries=[curWidget.Entries,dtname(idx+length('Enum: '):end)];
                                                                end
                                                            end


                                                            if isempty(curWidget.Entries)
                                                                curWidget.Type='edit';

                                                                curWidget.Entries{end+1}='<class name>';
                                                            end


                                                            if res.isEnumType
                                                                curWidget.Value=res.enumClassName;
                                                            else
                                                                if isempty(prevDTAWidgetValues)||...
                                                                    ~ismember(prevDTAWidgetValues.enum,curWidget.Entries)
                                                                    curWidget.Value=curWidget.Entries{1};
                                                                else
                                                                    curWidget.Value=prevDTAWidgetValues.enum;
                                                                end
                                                            end

                                                            if supportsEnumType
                                                                curWidget.Enabled=true;
                                                            else
                                                                curWidget.Enabled=false;
                                                            end

                                                            curWidget.Editable=true;

                                                            curWidget=setValueChangeCallback(curWidget);






                                                            function curGroup=getBusTypeGroup(hDlgSource,dtTag,res,supportsBusType,prevDTAWidgetValues)


                                                                curItems={};

                                                                BusTypeEdit=initTagNameType(dtTag,'UDTBusTypeEdit','','combobox');

                                                                BusTypeEdit.Entries={};


                                                                filter.supportNumeric=0;
                                                                filter.supportBus=0;
                                                                filter.supportEnum=0;
                                                                filter.supportAlias=0;
                                                                if supportsBusType
                                                                    filter.supportBus=1;
                                                                end


                                                                dtvarnames=slprivate('slGetUserDataTypesFromWSDD',hDlgSource,filter,{});


                                                                for k=1:length(dtvarnames)
                                                                    dtname=dtvarnames{k};
                                                                    idx=strfind(dtname,'Bus: ');


                                                                    if contains(dtname,'Bus: ')
                                                                        BusTypeEdit.Entries=[BusTypeEdit.Entries,dtname(idx+length('Bus: '):end)];
                                                                    end
                                                                end

                                                                if isempty(BusTypeEdit.Entries)
                                                                    BusTypeEdit.Type='edit';

                                                                    BusTypeEdit.Entries{end+1}='<object name>';
                                                                end


                                                                if res.isBusType
                                                                    BusTypeEdit.Value=res.busObjectName;
                                                                else
                                                                    if isempty(prevDTAWidgetValues)||...
                                                                        ~ismember(prevDTAWidgetValues.bus,BusTypeEdit.Entries)
                                                                        BusTypeEdit.Value=BusTypeEdit.Entries{1};
                                                                    else
                                                                        BusTypeEdit.Value=prevDTAWidgetValues.bus;
                                                                    end
                                                                end

                                                                if supportsBusType
                                                                    BusTypeEdit.Enabled=true;
                                                                else
                                                                    BusTypeEdit.Enabled=false;
                                                                end
                                                                BusTypeEdit.Editable=true;
                                                                BusTypeEdit=setValueChangeCallback(BusTypeEdit);

                                                                BusTypeEdit.RowSpan=[1,1];
                                                                BusTypeEdit.ColSpan=[1,1];
                                                                curItems{end+1}=BusTypeEdit;

                                                                BusCreateBtn=initTagNameType(dtTag,'UDTBusEditBtn','UDTBusEditBtn','pushbutton');
                                                                BusCreateBtn.RowSpan=[1,1];
                                                                BusCreateBtn.ColSpan=[2,2];
                                                                BusCreateBtn=setCallback(BusCreateBtn,'busEditEvent');
                                                                curItems{end+1}=BusCreateBtn;

                                                                curGroup=initTagNameType(dtTag,'UDTBusTypeGrp',-1,'panel');
                                                                curGroup=initContainerItems(curGroup,curItems);
                                                                curGroup.ColStretch=[1,0];







                                                                function curGroup=getConnBusTypeGroup(hDlgSource,dtTag,res,supportsConnectionBusType,prevDTAWidgetValues)


                                                                    curItems={};

                                                                    ConnBusTypeEdit=initTagNameType(dtTag,'UDTConnBusTypeEdit','','combobox');

                                                                    ConnBusTypeEdit.Entries={};


                                                                    filter.supportNumeric=0;
                                                                    filter.supportBus=0;
                                                                    filter.supportEnum=0;
                                                                    filter.supportAlias=0;
                                                                    if supportsConnectionBusType
                                                                        filter.supportBus=1;
                                                                    end


                                                                    dtvarnames=slprivate('slGetUserDataTypesFromWSDD',hDlgSource,filter,{});


                                                                    for k=1:length(dtvarnames)
                                                                        dtname=dtvarnames{k};
                                                                        idx=strfind(dtname,'Bus: ');


                                                                        if contains(dtname,'Bus: ')
                                                                            ConnBusTypeEdit.Entries=[ConnBusTypeEdit.Entries,dtname(idx+length('Bus: '):end)];
                                                                        end
                                                                    end

                                                                    if isempty(ConnBusTypeEdit.Entries)
                                                                        ConnBusTypeEdit.Type='edit';

                                                                        ConnBusTypeEdit.Entries{end+1}='<object name>';
                                                                    end


                                                                    if res.isConnectionBusType
                                                                        ConnBusTypeEdit.Value=res.connectionBusObjectName;
                                                                    else
                                                                        if isempty(prevDTAWidgetValues)||...
                                                                            ~ismember(prevDTAWidgetValues.connBus,ConnBusTypeEdit.Entries)
                                                                            ConnBusTypeEdit.Value=ConnBusTypeEdit.Entries{1};
                                                                        else
                                                                            ConnBusTypeEdit.Value=prevDTAWidgetValues.connBus;
                                                                        end
                                                                    end

                                                                    if supportsConnectionBusType
                                                                        ConnBusTypeEdit.Enabled=true;
                                                                    else
                                                                        ConnBusTypeEdit.Enabled=false;
                                                                    end
                                                                    ConnBusTypeEdit.Editable=true;
                                                                    ConnBusTypeEdit=setValueChangeCallback(ConnBusTypeEdit);

                                                                    ConnBusTypeEdit.RowSpan=[1,1];
                                                                    ConnBusTypeEdit.ColSpan=[1,1];
                                                                    curItems{end+1}=ConnBusTypeEdit;

                                                                    BusCreateBtn=initTagNameType(dtTag,'UDTBusEditBtn','UDTBusEditBtn','pushbutton');
                                                                    BusCreateBtn.RowSpan=[1,1];
                                                                    BusCreateBtn.ColSpan=[2,2];
                                                                    BusCreateBtn=setCallback(BusCreateBtn,'busEditEvent');
                                                                    curItems{end+1}=BusCreateBtn;

                                                                    curGroup=initTagNameType(dtTag,'UDTConnBusTypeGrp',-1,'panel');
                                                                    curGroup=initContainerItems(curGroup,curItems);
                                                                    curGroup.ColStretch=[1,0];







                                                                    function curWidget=getConnTypeEdit(hDlgSource,dtTag,res,supportsConnectionType,prevDTAWidgetValues)


                                                                        curWidget=initTagNameType(dtTag,'UDTConnTypeEdit','','combobox');

                                                                        curWidget.Entries={};


                                                                        physmodDoms=[];



                                                                        if Simulink.internal.isSimscapeInstalledAndLicensed
                                                                            physmodDoms=simscape.internal.availableDomains();
                                                                        end
                                                                        curWidget.Entries=[curWidget.Entries,physmodDoms'];


                                                                        if res.isConnectionType
                                                                            curWidget.Value=res.domainName;
                                                                        else
                                                                            if isa(hDlgSource,'Simulink.DDGSource')
                                                                                memberCheckVal=erase(hDlgSource.get_param('ConnectionType'),...
                                                                                'Connection: ');
                                                                            elseif isa(hDlgSource,'BusEditor.element')
                                                                                memberCheckVal=hDlgSource.daobject.Type;
                                                                            elseif isa(hDlgSource,'Simulink.typeeditor.app.Element')
                                                                                memberCheckVal=hDlgSource.SourceObject.Type;
                                                                            else
                                                                                memberCheckVal='';
                                                                            end
                                                                            if isempty(prevDTAWidgetValues)||...
                                                                                ~ismember(memberCheckVal,curWidget.Entries)
                                                                                curWidget.Value='<domain name>';
                                                                            else
                                                                                curWidget.Value=prevDTAWidgetValues.domainName;
                                                                            end
                                                                        end

                                                                        if supportsConnectionType
                                                                            curWidget.Enabled=true;
                                                                        else
                                                                            curWidget.Enabled=false;
                                                                        end

                                                                        curWidget.Editable=true;

                                                                        curWidget=setValueChangeCallback(curWidget);







                                                                        function curGroup=getValueTypeTypeGroup(hDlgSource,dtTag,res,supportsValueTypeType,prevDTAWidgetValues)

                                                                            curItems={};
                                                                            ValueTypeTypeEdit=initTagNameType(dtTag,'UDTValueTypeTypeEdit','','combobox');

                                                                            ValueTypeTypeEdit.Entries={};


                                                                            filter.supportNumeric=0;
                                                                            filter.supportBus=0;
                                                                            filter.supportEnum=0;
                                                                            filter.supportAlias=0;
                                                                            if supportsValueTypeType
                                                                                filter.supportValueType=1;
                                                                            end


                                                                            dtvarnames=slprivate('slGetUserDataTypesFromWSDD',hDlgSource,filter,{});


                                                                            for k=1:length(dtvarnames)
                                                                                dtname=dtvarnames{k};
                                                                                idx=strfind(dtname,'ValueType: ');


                                                                                if contains(dtname,'ValueType: ')
                                                                                    ValueTypeTypeEdit.Entries=[ValueTypeTypeEdit.Entries,dtname(idx+length('ValueType: '):end)];
                                                                                end
                                                                            end

                                                                            if isempty(ValueTypeTypeEdit.Entries)
                                                                                ValueTypeTypeEdit.Type='edit';

                                                                                ValueTypeTypeEdit.Entries{end+1}='<object name>';
                                                                            end


                                                                            if res.isValueTypeType
                                                                                ValueTypeTypeEdit.Value=res.valueTypeName;
                                                                            else
                                                                                if isempty(prevDTAWidgetValues)||...
                                                                                    ~ismember(prevDTAWidgetValues.valueType,ValueTypeTypeEdit.Entries)
                                                                                    ValueTypeTypeEdit.Value=ValueTypeTypeEdit.Entries{1};
                                                                                else
                                                                                    ValueTypeTypeEdit.Value=prevDTAWidgetValues.valueType;
                                                                                end
                                                                            end

                                                                            if supportsValueTypeType
                                                                                ValueTypeTypeEdit.Enabled=true;
                                                                            else
                                                                                ValueTypeTypeEdit.Enabled=false;
                                                                            end
                                                                            ValueTypeTypeEdit.Editable=true;
                                                                            ValueTypeTypeEdit=setValueChangeCallback(ValueTypeTypeEdit);

                                                                            ValueTypeTypeEdit.RowSpan=[1,1];
                                                                            ValueTypeTypeEdit.ColSpan=[1,1];
                                                                            curItems{end+1}=ValueTypeTypeEdit;

                                                                            ValueTypeCreateBtn=initTagNameType(dtTag,'UDTValueTypeEditBtn','UDTValueTypeEditBtn','pushbutton');
                                                                            ValueTypeCreateBtn.RowSpan=[1,1];
                                                                            ValueTypeCreateBtn.ColSpan=[2,2];
                                                                            ValueTypeCreateBtn=setCallback(ValueTypeCreateBtn,'valueTypeEditEvent');
                                                                            curItems{end+1}=ValueTypeCreateBtn;

                                                                            curGroup=initTagNameType(dtTag,'UDTValueTypeTypeGrp',-1,'panel');
                                                                            curGroup=initContainerItems(curGroup,curItems);
                                                                            curGroup.ColStretch=[1,0];







                                                                            function curWidget=getSignModeWidget(dtTag,res,signModes,prevDTAWidgetValues)


                                                                                curWidget=initTagNameType(dtTag,...
                                                                                'UDTSignRadio',...
                                                                                '',...
                                                                                'combobox');
                                                                                curWidget.Editable=false;
                                                                                curWidget.Entries=getStringsFromIDs(signModes);
                                                                                curWidget=setValueChangeCallback(curWidget);
                                                                                if res.isFixPt
                                                                                    curWidget.Value=res.fixptProps.signed;
                                                                                else
                                                                                    if isempty(prevDTAWidgetValues)
                                                                                        curWidget.Value=0;
                                                                                    else
                                                                                        curWidget.Value=prevDTAWidgetValues.sign;
                                                                                    end
                                                                                end





                                                                                function curWidget=getDTOWidget(dtTag,res,udtTag,~)


                                                                                    curWidget=initTagNameType(dtTag,...
                                                                                    udtTag,...
                                                                                    '',...
                                                                                    'combobox');
                                                                                    curWidget.Editable=false;
                                                                                    curWidget.Entries=getStringsFromIDs({'UDTDTOInherit','UDTDTOOff'});
                                                                                    curWidget=setValueChangeCallback(curWidget);
                                                                                    if res.isFixPt||res.isBuiltin
                                                                                        if isfield(res.fixptProps,'datatypeoverride')
                                                                                            if strcmpi(res.fixptProps.datatypeoverride,'''off''')
                                                                                                curWidget.Value=1;
                                                                                            else
                                                                                                curWidget.Value=0;
                                                                                            end
                                                                                        else
                                                                                            curWidget.Value=0;
                                                                                        end
                                                                                    else
                                                                                        curWidget.Value=0;
                                                                                    end







                                                                                    function curWidget=getScalingSpecMethodWidget(dtTag,res,scalingModes,prevDTAWidgetValues)


                                                                                        curWidget=initTagNameType(dtTag,'UDTScalingModeRadio','','combobox');
                                                                                        curWidget.Editable=false;

                                                                                        curWidget.Entries=getStringsFromIDs(scalingModes);

                                                                                        curWidget=setValueChangeCallback(curWidget);

                                                                                        if res.isFixPt
                                                                                            curWidget.Value=res.fixptProps.scalingMode;
                                                                                        else
                                                                                            if isempty(prevDTAWidgetValues)
                                                                                                if strcmp(scalingModes{end},'UDTBestPrecisionMode')



                                                                                                    curWidget.Value=length(scalingModes)-1;
                                                                                                else



                                                                                                    curWidget.Value=0;
                                                                                                end
                                                                                            else
                                                                                                curWidget.Value=prevDTAWidgetValues.sm;
                                                                                            end
                                                                                        end







                                                                                        function curItem=setValueChangeCallback(curItemIn)

                                                                                            curItem=setCallback(curItemIn,'valueChangeEvent');







                                                                                            function curItem=setButtonPushCallback(curItemIn)

                                                                                                curItem=setCallback(curItemIn,'buttonPushEvent');







                                                                                                function curItem=setCallback(curItemIn,actionStr)

                                                                                                    curItem=curItemIn;

                                                                                                    curItem.MatlabMethod='Simulink.DataTypePrmWidget.callbackDataTypeWidget';
                                                                                                    curItem.MatlabArgs={actionStr,'%dialog','%tag'};










                                                                                                    function specMethodTagList=getStdSpecMethodRadioEntryList(dtaItems)


                                                                                                        specMethodTagList={};
                                                                                                        if~isempty(dtaItems.inheritRules)
                                                                                                            specMethodTagList{end+1}='UDTInheritRadioEntry';
                                                                                                        end

                                                                                                        if~isempty(dtaItems.builtinTypes)
                                                                                                            specMethodTagList{end+1}='UDTBuiltinRadioEntry';
                                                                                                        end

                                                                                                        if~isempty(dtaItems.scalingModes)
                                                                                                            specMethodTagList{end+1}='UDTFixedPointRadioEntry';
                                                                                                        end

                                                                                                        if(dtaItems.supportsEnumType)
                                                                                                            specMethodTagList{end+1}='UDTEnumRadioEntry';
                                                                                                        end

                                                                                                        if(dtaItems.supportsBusType)
                                                                                                            specMethodTagList{end+1}='UDTBusRadioEntry';
                                                                                                        end

                                                                                                        if slfeature('SupportImageInDTA')==1&&(dtaItems.supportsImageDataType)
                                                                                                            specMethodTagList{end+1}='UDTImageRadioEntry';
                                                                                                        end

                                                                                                        if(slfeature('CUSTOM_BUSES')==1)&&(dtaItems.supportsConnectionBusType)
                                                                                                            specMethodTagList{end+1}='UDTConnectionBusRadioEntry';
                                                                                                        end

                                                                                                        if(slfeature('CUSTOM_BUSES')==1)&&(dtaItems.supportsConnectionType)
                                                                                                            specMethodTagList{end+1}='UDTConnectionRadioEntry';
                                                                                                        end

                                                                                                        if slfeature('SLValueType')==1&&(dtaItems.supportsValueTypeType)
                                                                                                            specMethodTagList{end+1}='UDTValueTypeRadioEntry';
                                                                                                        end

                                                                                                        if dtaItems.allowsExpression
                                                                                                            specMethodTagList{end+1}='UDTExprRadioEntry';
                                                                                                        end







                                                                                                        function strings=getStringsFromIDs(ids)


                                                                                                            strings=cell(1,length(ids));
                                                                                                            for i=1:length(ids)
                                                                                                                strings{i}=DAStudio.message(['Simulink:dialog:',ids{i}]);
                                                                                                            end






                                                                                                            function curPanel=getDataTypeInfoPanel(dtTag,scalingMinTag,scalingMaxTag,scalingValueTags,dtipOpen,dtInfo)


                                                                                                                curItems={};

                                                                                                                curWidget=initTagNameType(dtTag,'UDTDataTypeInfoContract','','image');
                                                                                                                curWidget.RowSpan=[1,1];
                                                                                                                curWidget.ColSpan=[1,1];
                                                                                                                imagepath=fullfile(matlabroot,'toolbox/simulink/simulink/@Simulink/@DataTypePrmWidget/private');
                                                                                                                curWidget.FilePath=fullfile(imagepath,'contract.png');
                                                                                                                curWidget=setButtonPushCallback(curWidget);
                                                                                                                curWidget.Alignment=6;
                                                                                                                curWidget.Visible=dtipOpen;
                                                                                                                curItems{end+1}=curWidget;

                                                                                                                curWidget=initTagNameType(dtTag,'UDTDataTypeInfoExpand','','image');
                                                                                                                curWidget.RowSpan=[1,1];
                                                                                                                curWidget.ColSpan=[1,1];
                                                                                                                imagepath=fullfile(matlabroot,'toolbox/simulink/simulink/@Simulink/@DataTypePrmWidget/private');
                                                                                                                curWidget.FilePath=fullfile(imagepath,'expand.png');
                                                                                                                curWidget=setButtonPushCallback(curWidget);
                                                                                                                curWidget.Alignment=6;
                                                                                                                curWidget.Visible=~dtipOpen;
                                                                                                                curItems{end+1}=curWidget;

                                                                                                                curWidget=initTagNameType(dtTag,'UDTDataTypeInfoLink','','hyperlink');
                                                                                                                curWidget.RowSpan=[1,1];
                                                                                                                curWidget.ColSpan=[2,2];
                                                                                                                curWidget.Alignment=1;
                                                                                                                curWidget.Name=DAStudio.message('Simulink:dialog:UDTIPLinkName');
                                                                                                                curWidget=setButtonPushCallback(curWidget);
                                                                                                                curItems{end+1}=curWidget;

                                                                                                                dtInfoTableItems={};

                                                                                                                dtInfoTable=getDataTypeInfoTable([dtTag,'|UDTInfoTab'],scalingMinTag,scalingMaxTag,scalingValueTags,dtInfo);
                                                                                                                dtInfoTable.RowSpan=[1,1];
                                                                                                                dtInfoTable.ColSpan=[1,1];
                                                                                                                dtInfoTable.Alignment=1;
                                                                                                                dtInfoTable.Visible=true;
                                                                                                                dtInfoTableItems{end+1}=dtInfoTable;

                                                                                                                curWidget=initTagNameType(dtTag,'UDTDataTypeInfoUpdate','','pushbutton');
                                                                                                                curWidget.RowSpan=[1,1];
                                                                                                                curWidget.ColSpan=[2,2];
                                                                                                                curWidget.Alignment=8;
                                                                                                                curWidget.Name=DAStudio.message('Simulink:dialog:UDTIPRefreshDetailsBtn');
                                                                                                                curWidget=setButtonPushCallback(curWidget);
                                                                                                                dtInfoTableItems{end+1}=curWidget;

                                                                                                                tablePanel=initTagNameType(dtTag,'UDTDataTypeInfoTblPnl',-1,'panel');
                                                                                                                tablePanel=initContainerItems(tablePanel,dtInfoTableItems);
                                                                                                                tablePanel.LayoutGrid=[1,2];
                                                                                                                tablePanel.ColStretch=[1,0];
                                                                                                                tablePanel.RowStretch=1;

                                                                                                                tablePanel.ColSpan=[1,2];
                                                                                                                tablePanel.RowSpan=[2,2];
                                                                                                                tablePanel.Visible=dtipOpen;
                                                                                                                curItems{end+1}=tablePanel;

                                                                                                                curPanel=initTagNameType(dtTag,'UDTDataTypeInfoPnl','','panel');
                                                                                                                curPanel=initContainerItems(curPanel,curItems);
                                                                                                                curPanel.LayoutGrid=[2,2];
                                                                                                                curPanel.ColStretch=[0,1];
                                                                                                                curPanel.RowStretch=[1,1];






                                                                                                                function table=getDataTypeInfoTable(tableTag,scalingMinTag,scalingMaxTag,scalingValueTags,dtInfo)




                                                                                                                    scalingTags=[scalingMaxTag,scalingValueTags{:},scalingMinTag];
                                                                                                                    numScalingTags=length(scalingTags);

                                                                                                                    table.Tag=tableTag;
                                                                                                                    table.Name='';
                                                                                                                    table.Type='panel';

                                                                                                                    align_left=5;
                                                                                                                    align_center=6;
                                                                                                                    align_right=7;

                                                                                                                    evalWarn=1;

                                                                                                                    imagepath=fullfile(matlabroot,'toolbox/simulink/simulink/@Simulink/@DataTypePrmWidget/private');
                                                                                                                    warnImagePath=fullfile(imagepath,'warning.png');
                                                                                                                    blankImagePath=fullfile(imagepath,'blank.png');

                                                                                                                    hasDTInfo=~isempty(dtInfo);


                                                                                                                    numValueRows=2+numScalingTags;

                                                                                                                    rowRepMax=1;
                                                                                                                    rowRepMin=numValueRows;
                                                                                                                    rowEmptyLine=rowRepMin+1;

                                                                                                                    rowResolution=rowEmptyLine+1;
                                                                                                                    maxRowIdx=rowResolution;

                                                                                                                    table.LayoutGrid=[maxRowIdx,6];



                                                                                                                    table.ColStretch=[0,0,0,1,0,1];


                                                                                                                    curItems=cell(1,(maxRowIdx-1)*6+2);


                                                                                                                    startItemIdx=1;
                                                                                                                    curWidget=initTagNameType(tableTag,'RepMaxWarn','','image');
                                                                                                                    curWidget.RowSpan=[rowRepMax,rowRepMax];
                                                                                                                    curWidget.ColSpan=[1,1];
                                                                                                                    curWidget.FilePath=warnImagePath;
                                                                                                                    curWidget.Alignment=align_center;
                                                                                                                    if hasDTInfo
                                                                                                                        curWidget.Visible=(dtInfo.RepMaxInfo.EvalStatus==evalWarn);
                                                                                                                    else
                                                                                                                        curWidget.Visible=false;
                                                                                                                    end
                                                                                                                    curItems{startItemIdx}=curWidget;

                                                                                                                    curWidget=initTagNameType(tableTag,'RepMaxName','','text');
                                                                                                                    if hasDTInfo
                                                                                                                        curWidget.Name=dtInfo.RepMaxInfo.Name;
                                                                                                                    else
                                                                                                                        curWidget.Name='';
                                                                                                                    end
                                                                                                                    curWidget.RowSpan=[rowRepMax,rowRepMax];
                                                                                                                    curWidget.ColSpan=[2,2];
                                                                                                                    curWidget.Alignment=align_left;
                                                                                                                    curItems{startItemIdx+1}=curWidget;

                                                                                                                    spacer.Name='  ';
                                                                                                                    spacer.Type='text';
                                                                                                                    spacer.RowSpan=[rowRepMax,rowRepMax];
                                                                                                                    spacer.ColSpan=[3,3];
                                                                                                                    curItems{startItemIdx+2}=spacer;

                                                                                                                    curWidget=initTagNameType(tableTag,'RepMaxVal','','text');
                                                                                                                    curWidget.RowSpan=[rowRepMax,rowRepMax];
                                                                                                                    curWidget.ColSpan=[4,4];
                                                                                                                    curWidget.Alignment=align_right;
                                                                                                                    if hasDTInfo
                                                                                                                        curWidget.Name=dtInfo.RepMaxInfo.Val;
                                                                                                                    else
                                                                                                                        curWidget.Name='';
                                                                                                                    end
                                                                                                                    curItems{startItemIdx+3}=curWidget;

                                                                                                                    spacer.Name='  ';
                                                                                                                    spacer.Type='text';
                                                                                                                    spacer.RowSpan=[rowRepMax,rowRepMax];
                                                                                                                    spacer.ColSpan=[5,5];
                                                                                                                    curItems{startItemIdx+4}=spacer;

                                                                                                                    curWidget=initTagNameType(tableTag,'RepMaxComm','','text');
                                                                                                                    curWidget.RowSpan=[rowRepMax,rowRepMax];
                                                                                                                    curWidget.ColSpan=[6,6];
                                                                                                                    curWidget.Alignment=align_left;
                                                                                                                    if hasDTInfo
                                                                                                                        curWidget.Name=dtInfo.RepMaxInfo.Comm;
                                                                                                                    else
                                                                                                                        curWidget.Name='';
                                                                                                                    end
                                                                                                                    curItems{startItemIdx+5}=curWidget;


                                                                                                                    for i=1:numScalingTags

                                                                                                                        startItemIdx=startItemIdx+6;
                                                                                                                        curWidget=initTagNameType(tableTag,[scalingTags{i},'Warn'],'','image');
                                                                                                                        curWidget.RowSpan=[rowRepMax+i,rowRepMax+i];
                                                                                                                        curWidget.ColSpan=[1,1];
                                                                                                                        curWidget.FilePath=warnImagePath;
                                                                                                                        curWidget.Alignment=align_center;
                                                                                                                        if hasDTInfo
                                                                                                                            curWidget.Visible=(dtInfo.OtherInfo{i}.EvalStatus==evalWarn);
                                                                                                                        else
                                                                                                                            curWidget.Visible=false;
                                                                                                                        end
                                                                                                                        curItems{startItemIdx}=curWidget;

                                                                                                                        curWidget=initTagNameType(tableTag,[scalingTags{i},'Name'],'','text');
                                                                                                                        curWidget.RowSpan=[rowRepMax+i,rowRepMax+i];
                                                                                                                        curWidget.ColSpan=[2,2];
                                                                                                                        curWidget.Alignment=align_left;
                                                                                                                        if hasDTInfo
                                                                                                                            curWidget.Name=dtInfo.OtherInfo{i}.Name;
                                                                                                                        else
                                                                                                                            curWidget.Name='';
                                                                                                                        end
                                                                                                                        curItems{startItemIdx+1}=curWidget;

                                                                                                                        spacer.Name='  ';
                                                                                                                        spacer.Type='text';
                                                                                                                        spacer.RowSpan=[rowRepMax+i,rowRepMax+i];
                                                                                                                        spacer.ColSpan=[3,3];
                                                                                                                        curItems{startItemIdx+2}=spacer;

                                                                                                                        curWidget=initTagNameType(tableTag,[scalingTags{i},'Val'],'','text');
                                                                                                                        curWidget.RowSpan=[rowRepMax+i,rowRepMax+i];
                                                                                                                        curWidget.ColSpan=[4,4];
                                                                                                                        curWidget.Alignment=align_right;
                                                                                                                        if hasDTInfo
                                                                                                                            curWidget.Name=dtInfo.OtherInfo{i}.Val;
                                                                                                                        else
                                                                                                                            curWidget.Name='';
                                                                                                                        end
                                                                                                                        curItems{startItemIdx+3}=curWidget;

                                                                                                                        spacer.Name='  ';
                                                                                                                        spacer.Type='text';
                                                                                                                        spacer.RowSpan=[rowRepMax+i,rowRepMax+i];
                                                                                                                        spacer.ColSpan=[5,5];
                                                                                                                        curItems{startItemIdx+4}=spacer;

                                                                                                                        curWidget=initTagNameType(tableTag,[scalingTags{i},'Comm'],'','text');
                                                                                                                        curWidget.RowSpan=[rowRepMax+i,rowRepMax+i];
                                                                                                                        curWidget.ColSpan=[6,6];
                                                                                                                        curWidget.Alignment=align_left;
                                                                                                                        if hasDTInfo
                                                                                                                            curWidget.Name=dtInfo.OtherInfo{i}.Comm;
                                                                                                                        else
                                                                                                                            curWidget.Name='';
                                                                                                                        end
                                                                                                                        curItems{startItemIdx+5}=curWidget;
                                                                                                                    end


                                                                                                                    startItemIdx=startItemIdx+6;
                                                                                                                    curWidget=initTagNameType(tableTag,'RepMinWarn','','image');
                                                                                                                    curWidget.RowSpan=[rowRepMin,rowRepMin];
                                                                                                                    curWidget.ColSpan=[1,1];
                                                                                                                    curWidget.FilePath=warnImagePath;
                                                                                                                    if hasDTInfo
                                                                                                                        curWidget.Visible=(dtInfo.RepMinInfo.EvalStatus==evalWarn);
                                                                                                                    else
                                                                                                                        curWidget.Visible=false;
                                                                                                                    end
                                                                                                                    curWidget.Alignment=align_center;
                                                                                                                    curItems{startItemIdx}=curWidget;

                                                                                                                    curWidget=initTagNameType(tableTag,'RepMinName','','text');
                                                                                                                    curWidget.RowSpan=[rowRepMin,rowRepMin];
                                                                                                                    curWidget.ColSpan=[2,2];
                                                                                                                    curWidget.Alignment=align_left;
                                                                                                                    if hasDTInfo
                                                                                                                        curWidget.Name=dtInfo.RepMinInfo.Name;
                                                                                                                    else
                                                                                                                        curWidget.Name='';
                                                                                                                    end
                                                                                                                    curItems{startItemIdx+1}=curWidget;

                                                                                                                    spacer.Name='  ';
                                                                                                                    spacer.Type='text';
                                                                                                                    spacer.RowSpan=[rowRepMin,rowRepMin];
                                                                                                                    spacer.ColSpan=[3,3];
                                                                                                                    curItems{startItemIdx+2}=spacer;

                                                                                                                    curWidget=initTagNameType(tableTag,'RepMinVal','','text');
                                                                                                                    curWidget.RowSpan=[rowRepMin,rowRepMin];
                                                                                                                    curWidget.ColSpan=[4,4];
                                                                                                                    curWidget.Alignment=align_right;
                                                                                                                    if hasDTInfo
                                                                                                                        curWidget.Name=dtInfo.RepMinInfo.Val;
                                                                                                                    else
                                                                                                                        curWidget.Name='';
                                                                                                                    end
                                                                                                                    curItems{startItemIdx+3}=curWidget;

                                                                                                                    spacer.Name='  ';
                                                                                                                    spacer.Type='text';
                                                                                                                    spacer.RowSpan=[rowRepMin,rowRepMin];
                                                                                                                    spacer.ColSpan=[5,5];
                                                                                                                    curItems{startItemIdx+4}=spacer;

                                                                                                                    curWidget=initTagNameType(tableTag,'RepMinComm','','text');
                                                                                                                    curWidget.RowSpan=[rowRepMin,rowRepMin];
                                                                                                                    curWidget.ColSpan=[6,6];
                                                                                                                    curWidget.Alignment=align_left;
                                                                                                                    if hasDTInfo
                                                                                                                        curWidget.Name=dtInfo.RepMinInfo.Comm;
                                                                                                                    else
                                                                                                                        curWidget.Name='';
                                                                                                                    end
                                                                                                                    curItems{startItemIdx+5}=curWidget;



                                                                                                                    startItemIdx=startItemIdx+6;
                                                                                                                    curWidget=initTagNameType(tableTag,'BlankIcon','','image');
                                                                                                                    curWidget.RowSpan=[rowEmptyLine,rowEmptyLine];
                                                                                                                    curWidget.ColSpan=[1,1];
                                                                                                                    curWidget.FilePath=blankImagePath;
                                                                                                                    curWidget.Visible=true;
                                                                                                                    curWidget.Alignment=align_center;
                                                                                                                    curItems{startItemIdx}=curWidget;


                                                                                                                    curWidget=initTagNameType(tableTag,'space','','text');
                                                                                                                    curWidget.RowSpan=[rowEmptyLine,rowEmptyLine];
                                                                                                                    curWidget.ColSpan=[2,5];
                                                                                                                    curWidget.Alignment=align_left;
                                                                                                                    curWidget.Name='';
                                                                                                                    curItems{startItemIdx+1}=curWidget;


                                                                                                                    startItemIdx=startItemIdx+2;
                                                                                                                    curWidget=initTagNameType(tableTag,'ResolutionWarn','','image');
                                                                                                                    curWidget.RowSpan=[rowResolution,rowResolution];
                                                                                                                    curWidget.ColSpan=[1,1];
                                                                                                                    curWidget.FilePath=warnImagePath;
                                                                                                                    if hasDTInfo
                                                                                                                        curWidget.Visible=(dtInfo.ResolutionInfo.EvalStatus==evalWarn);
                                                                                                                    else
                                                                                                                        curWidget.Visible=false;
                                                                                                                    end
                                                                                                                    curWidget.Alignment=align_center;
                                                                                                                    curItems{startItemIdx}=curWidget;

                                                                                                                    curWidget=initTagNameType(tableTag,'ResolutionName','','text');
                                                                                                                    curWidget.RowSpan=[rowResolution,rowResolution];
                                                                                                                    curWidget.ColSpan=[2,2];
                                                                                                                    curWidget.Alignment=align_left;
                                                                                                                    if hasDTInfo
                                                                                                                        curWidget.Name=dtInfo.ResolutionInfo.Name;
                                                                                                                    else
                                                                                                                        curWidget.Name='';
                                                                                                                    end
                                                                                                                    curItems{startItemIdx+1}=curWidget;

                                                                                                                    spacer.Name='  ';
                                                                                                                    spacer.Type='text';
                                                                                                                    spacer.RowSpan=[rowResolution,rowResolution];
                                                                                                                    spacer.ColSpan=[3,3];
                                                                                                                    curItems{startItemIdx+2}=spacer;

                                                                                                                    curWidget=initTagNameType(tableTag,'ResolutionVal','','text');
                                                                                                                    curWidget.RowSpan=[rowResolution,rowResolution];
                                                                                                                    curWidget.ColSpan=[4,4];
                                                                                                                    curWidget.Alignment=align_right;
                                                                                                                    if hasDTInfo
                                                                                                                        curWidget.Name=dtInfo.ResolutionInfo.Val;
                                                                                                                    else
                                                                                                                        curWidget.Name='';
                                                                                                                    end
                                                                                                                    curItems{startItemIdx+3}=curWidget;

                                                                                                                    spacer.Name='  ';
                                                                                                                    spacer.Type='text';
                                                                                                                    spacer.RowSpan=[rowResolution,rowResolution];
                                                                                                                    spacer.ColSpan=[5,5];
                                                                                                                    curItems{startItemIdx+4}=spacer;

                                                                                                                    curWidget=initTagNameType(tableTag,'ResolutionComm','','text');
                                                                                                                    curWidget.RowSpan=[rowResolution,rowResolution];
                                                                                                                    curWidget.ColSpan=[6,6];
                                                                                                                    curWidget.Alignment=align_left;
                                                                                                                    if hasDTInfo
                                                                                                                        curWidget.Name=dtInfo.ResolutionInfo.Comm;
                                                                                                                    else
                                                                                                                        curWidget.Name='';
                                                                                                                    end
                                                                                                                    curItems{startItemIdx+5}=curWidget;

                                                                                                                    table.Items=curItems;












                                                                                                                    function prevDTAWidgetValues=getPrevDTAWidgetValues(hDialog,dtTag,scalingModes)


                                                                                                                        tag=[dtTag,'|UDTInheritRadio'];
                                                                                                                        if hDialog.isWidgetValid(tag)
                                                                                                                            prevDTAWidgetValues.rule=hDialog.getWidgetValue(tag);
                                                                                                                        else
                                                                                                                            prevDTAWidgetValues.rule=0;
                                                                                                                        end

                                                                                                                        tag=[dtTag,'|UDTBuiltinRadio'];
                                                                                                                        if hDialog.isWidgetValid(tag)
                                                                                                                            prevDTAWidgetValues.builtin=hDialog.getWidgetValue(tag);
                                                                                                                        else
                                                                                                                            prevDTAWidgetValues.builtin=0;
                                                                                                                        end

                                                                                                                        tag=[dtTag,'|UDTExprEdit'];
                                                                                                                        if hDialog.isWidgetValid(tag)
                                                                                                                            prevDTAWidgetValues.expr=hDialog.getWidgetValue(tag);
                                                                                                                        else
                                                                                                                            prevDTAWidgetValues.expr='<data type expression>';
                                                                                                                        end

                                                                                                                        tag=[dtTag,'|UDTSignRadio'];
                                                                                                                        if hDialog.isWidgetValid(tag)
                                                                                                                            prevDTAWidgetValues.sign=hDialog.getWidgetValue(tag);
                                                                                                                        else
                                                                                                                            prevDTAWidgetValues.sign=0;
                                                                                                                        end

                                                                                                                        tag=[dtTag,'|UDTWordLengthEdit'];
                                                                                                                        if hDialog.isWidgetValid(tag)
                                                                                                                            prevDTAWidgetValues.wl=hDialog.getWidgetValue(tag);
                                                                                                                        else
                                                                                                                            prevDTAWidgetValues.wl='16';
                                                                                                                        end

                                                                                                                        tag=[dtTag,'|UDTScalingModeRadio'];
                                                                                                                        if hDialog.isWidgetValid(tag)
                                                                                                                            prevDTAWidgetValues.sm=hDialog.getWidgetValue(tag);
                                                                                                                        else
                                                                                                                            if~isempty(scalingModes)&&strcmp(scalingModes{end},'UDTBestPrecisionMode')



                                                                                                                                prevDTAWidgetValues.sm=length(scalingModes)-1;
                                                                                                                            else
                                                                                                                                prevDTAWidgetValues.sm=0;
                                                                                                                            end
                                                                                                                        end

                                                                                                                        tag=[dtTag,'|UDTFractionLengthEdit'];
                                                                                                                        if hDialog.isWidgetValid(tag)
                                                                                                                            prevDTAWidgetValues.fl=hDialog.getWidgetValue(tag);
                                                                                                                        else
                                                                                                                            prevDTAWidgetValues.fl='0';
                                                                                                                        end

                                                                                                                        tag=[dtTag,'|UDTSlopeEdit'];
                                                                                                                        if hDialog.isWidgetValid(tag)
                                                                                                                            prevDTAWidgetValues.slope=hDialog.getWidgetValue(tag);
                                                                                                                        else
                                                                                                                            prevDTAWidgetValues.slope='2^0';
                                                                                                                        end

                                                                                                                        tag=[dtTag,'|UDTBiasEdit'];
                                                                                                                        if hDialog.isWidgetValid(tag)
                                                                                                                            prevDTAWidgetValues.bias=hDialog.getWidgetValue(tag);
                                                                                                                        else
                                                                                                                            prevDTAWidgetValues.bias='0';
                                                                                                                        end

                                                                                                                        tag=[dtTag,'|UDTEnumTypeEdit'];
                                                                                                                        if hDialog.isWidgetValid(tag)
                                                                                                                            prevDTAWidgetValues.enum=hDialog.getWidgetValue(tag);
                                                                                                                        else
                                                                                                                            prevDTAWidgetValues.enum='<class name>';
                                                                                                                        end

                                                                                                                        tag=[dtTag,'|UDTBusTypeEdit'];
                                                                                                                        if hDialog.isWidgetValid(tag)
                                                                                                                            prevDTAWidgetValues.bus=hDialog.getWidgetValue(tag);
                                                                                                                        else
                                                                                                                            prevDTAWidgetValues.bus='<object name>';
                                                                                                                        end


                                                                                                                        if slfeature('SupportImageInDTA')==1
                                                                                                                            tag=[dtTag,'|UDTColorFormatRadio'];
                                                                                                                            if hDialog.isWidgetValid(tag)
                                                                                                                                prevDTAWidgetValues.ColorFormat=hDialog.getWidgetValue(tag);
                                                                                                                            else
                                                                                                                                prevDTAWidgetValues.ColorFormat=0;
                                                                                                                            end

                                                                                                                            tag=[dtTag,'|UDTRowsEdit'];
                                                                                                                            if hDialog.isWidgetValid(tag)
                                                                                                                                prevDTAWidgetValues.Rows=hDialog.getWidgetValue(tag);
                                                                                                                            else
                                                                                                                                prevDTAWidgetValues.Rows='480';
                                                                                                                            end

                                                                                                                            tag=[dtTag,'|UDTLayoutRadio'];
                                                                                                                            if hDialog.isWidgetValid(tag)
                                                                                                                                prevDTAWidgetValues.Layout=hDialog.getWidgetValue(tag);
                                                                                                                            else
                                                                                                                                prevDTAWidgetValues.Layout=0;
                                                                                                                            end

                                                                                                                            tag=[dtTag,'|UDTColsEdit'];
                                                                                                                            if hDialog.isWidgetValid(tag)
                                                                                                                                prevDTAWidgetValues.Cols=hDialog.getWidgetValue(tag);
                                                                                                                            else
                                                                                                                                prevDTAWidgetValues.Cols='640';
                                                                                                                            end

                                                                                                                            tag=[dtTag,'|UDTClassUnderlyingRadio'];
                                                                                                                            if hDialog.isWidgetValid(tag)
                                                                                                                                prevDTAWidgetValues.ClassUnderlying=hDialog.getWidgetValue(tag);
                                                                                                                            else
                                                                                                                                prevDTAWidgetValues.ClassUnderlying=0;
                                                                                                                            end

                                                                                                                            tag=[dtTag,'|UDTChannelsEdit'];
                                                                                                                            if hDialog.isWidgetValid(tag)
                                                                                                                                prevDTAWidgetValues.Channels=hDialog.getWidgetValue(tag);
                                                                                                                            else
                                                                                                                                prevDTAWidgetValues.Channels='3';
                                                                                                                            end
                                                                                                                        end

                                                                                                                        if slfeature('CUSTOM_BUSES')==1
                                                                                                                            tag=[dtTag,'|UDTConnBusTypeEdit'];
                                                                                                                            if hDialog.isWidgetValid(tag)
                                                                                                                                prevDTAWidgetValues.connBus=hDialog.getWidgetValue(tag);
                                                                                                                            else
                                                                                                                                prevDTAWidgetValues.connBus='<object name>';
                                                                                                                            end

                                                                                                                            tag=[dtTag,'|UDTConnTypeEdit'];
                                                                                                                            if hDialog.isWidgetValid(tag)
                                                                                                                                prevDTAWidgetValues.domainName=hDialog.getWidgetValue(tag);
                                                                                                                            else
                                                                                                                                prevDTAWidgetValues.domainName='<domain name>';
                                                                                                                            end
                                                                                                                        end

                                                                                                                        if slfeature('SLValueType')==1
                                                                                                                            tag=[dtTag,'|UDTValueTypeTypeEdit'];
                                                                                                                            if hDialog.isWidgetValid(tag)
                                                                                                                                prevDTAWidgetValues.valueType=hDialog.getWidgetValue(tag);
                                                                                                                            else
                                                                                                                                prevDTAWidgetValues.valueType='<object name>';
                                                                                                                            end
                                                                                                                        end







                                                                                                                        function addInstanceProp(hDlgSource,propName,propType)

                                                                                                                            switch Simulink.data.getScalarObjectLevel(hDlgSource)
                                                                                                                            case 1
                                                                                                                                hProp=schema.prop(hDlgSource,propName,propType);
                                                                                                                                hProp.AccessFlags.Serialize='off';
                                                                                                                                hProp.Visible='off';
                                                                                                                            case 2
                                                                                                                                hProp=addprop(hDlgSource,propName);
                                                                                                                                hProp.Transient=true;
                                                                                                                                hProp.Hidden=true;
                                                                                                                            otherwise
                                                                                                                                assert(false);
                                                                                                                            end









