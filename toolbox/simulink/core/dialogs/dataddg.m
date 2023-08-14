function dlgOrPanel=dataddg(hProxy,name,type,varargin)

























    if~strcmp(type,'signal')
        isParam=true;

        valueEdit.Tag='ValueEdit';
    else
        isParam=false;

        initialValue.Tag='InitialValue';
    end




    isEmbeddedSignal=false;
    if~isa(hProxy,'Simulink.SlidDAProxy')&&hProxy.CoderInfo.HasContext
        if isParam
            hProxy=Simulink.SlidDAProxy(hProxy.getSlidParam);
        else
            isEmbeddedSignal=true;
        end
    end


    if isa(hProxy,'Simulink.SlidDAProxy')
        hSlidObject=hProxy.getObject();
        h=hSlidObject.WorkspaceObjectSharedCopy;
        if isempty(h)
            dlgOrPanel=[];
            return;
        end
        ownedByModel=true;
    else
        h=hProxy;
        ownedByModel=false;
    end

    ownedByDD=false;
    isRtnPanel=false;
    hasOverrideValueFromValueSource=false;

    if nargin>=4
        if islogical(varargin{1})
            isRtnPanel=varargin{1};
        elseif isa(varargin{1},'Simulink.data.dictionary.Section')
            ownedByDD=true;
        else
            DAStudio.error('Simulink:dialog:InvalidArgFourExpLogStat');
        end
    end

    if nargin>=5
        if(slfeature('CalibrationWorkflowInDD')>0)&&...
            (strcmp(varargin{2},'OverrideValue'))
            hasOverrideValueFromValueSource=true;
        end
    end

    if~hasOverrideValueFromValueSource&&nargin>=5
        parameter_help=varargin{2}.parameter_help;
        signal_help=varargin{2}.signal_help;
        mapfile=varargin{2}.mapfile;
    else
        parameter_help='simulink_parameter';
        signal_help='simulink_signal';
        mapfile='/mapfiles/simulink.map';
    end







    rowIdx=1;
    pnlObj.Type='panel';
    pnlObj.RowSpan=[rowIdx,rowIdx];
    pnlObj.ColSpan=[1,2];
    pnlObj.Tag='PnlObj';


    minimumLbl.Name=DAStudio.message('Simulink:dialog:DataMinimumPrompt');
    minimumLbl.Type='text';

    minimum.Name=minimumLbl.Name;
    minimum.HideName=1;
    minimum.Type='edit';
    minimum.Source=h;
    minimum.ObjectProperty='Min';
    minimum.Tag='Minimum';
    minimum.ToolTip=DAStudio.message('Simulink:dialog:DataMinimumToolTip');
    minimum.Mode=true;

    maximumLbl.Name=DAStudio.message('Simulink:dialog:DataMaximumPrompt');
    maximumLbl.Type='text';

    maximum.Name=maximumLbl.Name;
    maximum.HideName=1;
    maximum.Type='edit';
    maximum.Source=h;
    maximum.ObjectProperty='Max';
    maximum.Tag='Maximum';
    maximum.ToolTip=DAStudio.message('Simulink:dialog:DataMaximumToolTip');
    maximum.Mode=true;




    dataTypeItems.scalingMinTag={minimum.Tag};
    dataTypeItems.scalingMaxTag={maximum.Tag};
    if isParam
        dataTypeItems.scalingValueTags={valueEdit.Tag};
        builtinTypes=Simulink.DataTypePrmWidget.getBuiltinListForDataObjects('Parameter');
    else
        dataTypeItems.scalingValueTags={initialValue.Tag};
        builtinTypes=Simulink.DataTypePrmWidget.getBuiltinListForDataObjects('Signal');
    end


    dataTypeItems.scalingModes=Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB');
    dataTypeItems.signModes=Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');

    dataTypeItems.builtinTypes=builtinTypes;


    dataTypeItems.supportsEnumType=true;
    dataTypeItems.supportsBusType=true;


    dataTypeGroup=Simulink.DataTypePrmWidget.getDataTypeWidget(hProxy,...
    'DataType',...
    DAStudio.message('Simulink:dialog:DataDataTypePrompt'),...
    'DataType',...
    h.DataType,...
    dataTypeItems,...
    false);
    assert(isequal(dataTypeGroup.Items{2}.Tag,'DataType'));
    origCallback=dataTypeGroup.Items{2}.MatlabMethod;
    dataTypeGroup.Items{2}.MatlabMethod='dataddg_cb';
    dataTypeGroup.Items{2}.MatlabArgs={'%dialog','datatype_callback','%tag','valueChangeEvent',origCallback};


    if(slfeature('EnableStoredIntMinMax')>0)
        wsObj=[];
        if ownedByModel
            slidObj=hProxy.getObject();
            modelRootObj=get_param(slidObj.System.Handle,'Object');
            wsObj=modelRootObj.getWorkspace();
        elseif ownedByDD
            wsObj=varargin{1};
        end
        enableStoredIntMinMax=isValidProperty(h,'StoredIntMin',wsObj);
        grpStoredInteger=l_createStoredIntegerGroup(hProxy,'Simulink:dialog:StoredIntValuesPrompt',enableStoredIntMinMax,varargin{:});
        grpStoredInteger.Visible=enableStoredIntMinMax;


        assert(isequal(dataTypeGroup.Items{2}.ObjectProperty,'DataType'));
        if enableStoredIntMinMax
            minimum.DialogRefresh=true;
            maximum.DialogRefresh=true;
        end
    end

    dimensionsLbl.Name=DAStudio.message('dastudio:ddg:WSODimensions');
    dimensionsLbl.Type='text';
    dimensionsLbl.Tag='DimensionsLbl';

    dimensions.Name=dimensionsLbl.Name;
    dimensions.HideName=1;
    dimensions.Type='edit';
    dimensions.Tag='Dimensions';
    dimensions.Source=h;
    dimensions.ObjectProperty='Dimensions';
    dimensions.ToolTip=DAStudio.message('Simulink:dialog:DataDimensionsToolTip1');

    complexityLbl.Name=DAStudio.message('Simulink:dialog:DataComplexityPrompt');
    complexityLbl.Type='text';
    complexityLbl.Tag='ComplexityLbl';

    complexity.Name=complexityLbl.Name;
    complexity.HideName=1;
    complexity.Tag='Complexity';
    complexity.ToolTip=DAStudio.message('Simulink:dialog:DataComplexityToolTip1');


    unitsLbl.Name=DAStudio.message('Simulink:dialog:DataUnitPrompt');
    unitsLbl.Type='text';
    unitsLbl.Tag='UnitLbl';

    units.Name=unitsLbl.Name;
    units.HideName=1;
    units.Type='edit';
    units.Source=h;
    units.ToolTip=DAStudio.message('Simulink:dialog:DataUnitToolTip');

    units.ObjectProperty='Unit';
    units.Tag='Unit';
    units.AutoCompleteType='Custom';
    units.ObjectMethod='getAutoCompleteData';
    units.MethodArgs={'%value','%value','%dialog'};
    units.ArgDataTypes={'mxArray','mxArray','handle'};
    symbolPrompt=[DAStudio.message('Simulink:dialog:UnitsAutoCompleteViewColumnSymbolPrompt'),'                         '];
    namePrompt=[DAStudio.message('Simulink:dialog:UnitsAutoCompleteViewColumnNamePrompt'),'                                         '];
    units.AutoCompleteViewColumn={' ',symbolPrompt,namePrompt};
    units.AutoCompleteCompletionMode='UnfilteredPopupCompletion';
    rowIdx=rowIdx+1;
    units.RowSpan=[rowIdx,rowIdx];
    units.ColSpan=[2,4];


    units.Enabled=h.isValidProperty(units.ObjectProperty);
    if~units.Enabled
        units.ObjectProperty='';
        units.Value='';
    end


    isParameter=false;
    isDoubleParam=false;





    if isParam
        isParameter=true;
        if isequal(class(h.Value),'double')
            isDoubleParam=true;
        end


        helpTopicKey=parameter_help;

        if hasOverrideValueFromValueSource
            overrideValue.Name='Active value:';
            overrideValue.Type='edit';
            overrideValue.Tag='OverridenValueEdit';
            overrideValue.Enabled=false;
            overrideValue.Value=DAStudio.MxStringConversion.convertToString(varargin{3});
            overrideValue.RowSpan=[rowIdx,rowIdx+1];
            overrideValue.ColSpan=[1,4];
            rowIdx=rowIdx+2;
        end

        if hasOverrideValueFromValueSource
            valueEditLbl.Name='Default value:';
        else
            valueEditLbl.Name=DAStudio.message('Simulink:dialog:ParamValuePrompt');
        end
        valueEditLbl.Type='text';
        valueEditLbl.Tag='ValueEditLbl';

        valueEdit.Name=valueEditLbl.Name;
        valueEdit.HideName=1;
        valueEdit.Type='edit';
        valueEdit.Source=h;
        valueEdit.Tag='ValueEdit';
        valueEdit.ObjectProperty='Value';

        if isDoubleParam
            valueEdit.ToolTip=DAStudio.message('Simulink:dialog:ParamValueToolTip1');
        else
            valueEdit.ToolTip=DAStudio.message('Simulink:dialog:ParamValueToolTip2',class(h.Value));
        end

        valueEdit.Mode=true;
        valueEdit.DialogRefresh=true;

        if ownedByModel&&isequal(slfeature('MWSValueSource'),2)
            slidObj=hProxy.getObject();
            modelRootObj=get_param(slidObj.System.Handle,'Object');
            mdlName=modelRootObj.getFullName;

            try
                if isequal(get_param(mdlName,'HasValueManager'),'on')
                    valSrcMgr=get_param(mdlName,'ValueManager');
                    if~isempty(valSrcMgr)
                        effValue=valSrcMgr.getActiveValueThrowError(slidObj.UUID);
                        if~isempty(effValue)
                            defaultValue=DAStudio.MxStringConversion.convertToString(h.Value);
                            effectiveValue=DAStudio.MxStringConversion.convertToString(effValue);
                            overlay=valSrcMgr.getEffectiveOverlayThrowError(slidObj.UUID);
                            effectiveOverlay=overlay.getName;
                            assert(hProxy.isReadonlyProperty('Value'),'Effective value not readonly');

                            valueEdit.Source=hProxy;
                            valueEdit.Enabled=~hProxy.isReadonlyProperty('Value');
                            valueEdit.ToolTip=[effectiveValue,newline...
                            ,DAStudio.message('Simulink:dialog:OverriddenValue',defaultValue,effectiveOverlay)];
                        end
                    end
                end
            catch ME
                valueEdit.Enabled=false;
                valueEdit.ToolTip=[DAStudio.message('Simulink:Data:MWSInaccessibleOverriddenValue')...
                ,newline...
                ,DAStudio.message(ME.message)];
            end
        elseif isa(h.Value,'Simulink.data.Expression')
            valueEdit.Value=h.Value.ExpressionString;
        else
            valueEdit.Value=h.Value;
        end




        valueEditLbl.RowSpan=[rowIdx,rowIdx];
        valueEditLbl.ColSpan=[1,1];
        valueEdit.RowSpan=[rowIdx,rowIdx];
        rowIdx=rowIdx+1;
        valueEdit.ColSpan=[2,4];



        dataTypeGroup.RowSpan=[rowIdx,rowIdx+1];
        dataTypeGroup.ColSpan=[1,4];
        rowIdx=rowIdx+2;


        dimensionsLbl.RowSpan=[rowIdx,rowIdx];
        dimensionsLbl.ColSpan=[1,1];
        dimensions.RowSpan=[rowIdx,rowIdx];
        dimensions.ColSpan=[2,2];
        if slfeature('DimensionVariants')>1
            dimensions.Type='edit';
            dimensions.Enabled=1;
        else
            dimensions.Enabled=0;
        end
        dimensions.ToolTip=DAStudio.message('Simulink:dialog:DataDimensionsToolTip2');
        dimensions.Mode=true;

        complexityLbl.RowSpan=[rowIdx,rowIdx];
        complexityLbl.ColSpan=[3,3];
        complexity.RowSpan=[rowIdx,rowIdx];
        complexity.ColSpan=[4,4];

        if slfeature('ModelArgumentValueInterface')>1
            complexity.Type='combobox';
            complexity.Entries={DAStudio.message('Simulink:dialog:real_CB'),DAStudio.message('Simulink:dialog:complex_CB')};
            complexity.Source=h;
            complexity.ObjectProperty='Complexity';
            complexity.Enabled=~h.isReadonlyProperty('Complexity');
        else
            complexity.Type='edit';
            complexity.Value=l_translate(h.Complexity);
            complexity.Enabled=0;
        end
        complexity.ToolTip=DAStudio.message('Simulink:dialog:DataComplexityToolTip2');
        rowIdx=rowIdx+1;


        minimumLbl.RowSpan=[rowIdx,rowIdx];
        minimumLbl.ColSpan=[1,1];
        minimum.RowSpan=[rowIdx,rowIdx];
        minimum.ColSpan=[2,2];
        maximumLbl.RowSpan=[rowIdx,rowIdx];
        maximumLbl.ColSpan=[3,3];
        maximum.RowSpan=[rowIdx,rowIdx];
        maximum.ColSpan=[4,4];
        rowIdx=rowIdx+1;

        if slfeature('EnableStoredIntMinMax')>0
            grpStoredInteger.RowSpan=[rowIdx,rowIdx];
            grpStoredInteger.ColSpan=[1,4];
            rowIdx=rowIdx+1;
        end


        unitsLbl.RowSpan=[rowIdx,rowIdx];
        unitsLbl.ColSpan=[1,1];
        units.RowSpan=[rowIdx,rowIdx];
        rowIdx=rowIdx+1;



        if ownedByModel&&isParam
            argument.Name=DAStudio.message('Simulink:dialog:ArgumentText');
            argument.ObjectProperty='Argument';
            argument.Tag='chkArgument';
            argument.Type='checkbox';
            argument.Source=hProxy;
            argument.Enabled=true;
            if hProxy.isReadonlyProperty('Argument')
                argument.Enabled=false;
            end
            argument.Mode=true;
            argument.DialogRefresh=true;
            argument.RowSpan=[rowIdx,rowIdx];
            argument.ColSpan=[1,4];

            rowIdx=rowIdx+1;
        end


        pnlObj.LayoutGrid=[rowIdx,4];
        pnlObj.ColStretch=[0,1,0,1];

        if(slfeature('EnableStoredIntMinMax')>0)
            pnlObj.Items={valueEditLbl,valueEdit,...
            dataTypeGroup,...
            dimensionsLbl,dimensions,...
            complexityLbl,complexity,...
            minimumLbl,minimum,...
            maximumLbl,maximum,...
            grpStoredInteger,...
            unitsLbl,units};

            if hasOverrideValueFromValueSource
                pnlObj.Items={valueEditLbl,valueEdit,...
                overrideValue,...
                dataTypeGroup,...
                dimensionsLbl,dimensions,...
                complexityLbl,complexity,...
                minimumLbl,minimum,...
                maximumLbl,maximum,...
                grpStoredInteger,...
                unitsLbl,units};
            end

        else
            pnlObj.Items={valueEditLbl,valueEdit,...
            dataTypeGroup,...
            dimensionsLbl,dimensions,...
            complexityLbl,complexity,...
            minimumLbl,minimum,...
            maximumLbl,maximum,...
            unitsLbl,units};
            if hasOverrideValueFromValueSource
                pnlObj.Items={valueEditLbl,valueEdit,...
                overrideValue,...
                dataTypeGroup,...
                dimensionsLbl,dimensions,...
                complexityLbl,complexity,...
                minimumLbl,minimum,...
                maximumLbl,maximum,...
                unitsLbl,units};
            end
        end


        if ownedByModel&&isParam
            pnlObj.Items=[pnlObj.Items,argument];
        end
    else





        helpTopicKey=signal_help;


        dataTypeGroup.RowSpan=[rowIdx,rowIdx+1];
        dataTypeGroup.ColSpan=[1,4];
        rowIdx=rowIdx+2;


        dimensionsLbl.RowSpan=[rowIdx,rowIdx];
        dimensionsLbl.ColSpan=[1,1];
        dimensions.RowSpan=[rowIdx,rowIdx];
        dimensions.ColSpan=[2,2];


        dimensionsModeLbl.Name=DAStudio.message('Simulink:dialog:DataDimensionsModePrompt');
        dimensionsModeLbl.Type='text';
        dimensionsModeLbl.RowSpan=[rowIdx,rowIdx];
        dimensionsModeLbl.ColSpan=[3,3];
        dimensionsModeLbl.Tag='DimensionsModeLbl';

        dimensionsMode.Name=dimensionsModeLbl.Name;
        dimensionsMode.HideName=1;
        dimensionsMode.Type='combobox';
        dimensionsMode.Entries=l_translate(getPropAllowedValues(h,'DimensionsMode'));
        dimensionsMode.Source=h;
        dimensionsMode.ObjectProperty='DimensionsMode';
        dimensionsMode.RowSpan=[rowIdx,rowIdx];
        dimensionsMode.ColSpan=[4,4];
        dimensionsMode.Tag='DimensionsMode';
        dimensionsMode.ToolTip=DAStudio.message('Simulink:dialog:DataDimensionsModeToolTip');
        rowIdx=rowIdx+1;


        initialValueLbl.Name=DAStudio.message('Simulink:dialog:SignalInitialValuePrompt');
        initialValueLbl.Type='text';
        initialValueLbl.RowSpan=[rowIdx,rowIdx];
        initialValueLbl.ColSpan=[1,1];
        initialValueLbl.Tag='InitialValueLbl';

        initialValue.Name=initialValueLbl.Name;
        initialValue.HideName=1;
        initialValue.Type='edit';
        initialValue.RowSpan=[rowIdx,rowIdx];
        initialValue.ColSpan=[2,2];
        initialValue.Source=h;
        initialValue.ObjectProperty='InitialValue';
        initialValue.ToolTip=DAStudio.message('Simulink:dialog:SignalInitialValueToolTip');


        complexityLbl.RowSpan=[rowIdx,rowIdx];
        complexityLbl.ColSpan=[3,3];
        complexity.RowSpan=[rowIdx,rowIdx];
        complexity.ColSpan=[4,4];
        complexity.Type='combobox';
        complexity.Entries=l_translate(getPropAllowedValues(h,'Complexity'));
        complexity.Source=h;
        complexity.ObjectProperty='Complexity';
        rowIdx=rowIdx+1;


        minimumLbl.RowSpan=[rowIdx,rowIdx];
        minimumLbl.ColSpan=[1,1];
        minimum.RowSpan=[rowIdx,rowIdx];
        minimum.ColSpan=[2,2];
        maximumLbl.RowSpan=[rowIdx,rowIdx];
        maximumLbl.ColSpan=[3,3];
        maximum.RowSpan=[rowIdx,rowIdx];
        maximum.ColSpan=[4,4];
        rowIdx=rowIdx+1;


        if slfeature('EnableStoredIntMinMax')>0
            grpStoredInteger.RowSpan=[rowIdx,rowIdx];
            grpStoredInteger.ColSpan=[1,4];
            rowIdx=rowIdx+1;
        end

        unitsLbl.RowSpan=[rowIdx,rowIdx];
        unitsLbl.ColSpan=[1,1];
        units.RowSpan=[rowIdx,rowIdx];
        units.ColSpan=[2,2];



        sampleTimeLbl.Name=DAStudio.message('Simulink:dialog:SignalSampleTimePrompt');
        sampleTimeLbl.Type='text';
        sampleTimeLbl.RowSpan=[rowIdx,rowIdx];
        sampleTimeLbl.ColSpan=[3,3];
        sampleTimeLbl.Tag='SampleTimeLbl';

        sampleTime.Name=sampleTimeLbl.Name;
        sampleTime.HideName=1;
        sampleTime.Type='edit';
        sampleTime.RowSpan=[rowIdx,rowIdx];
        sampleTime.ColSpan=[4,4];
        sampleTime.Source=h;
        sampleTime.ObjectProperty='SampleTime';
        sampleTime.Tag='SampleTime';
        sampleTime.ToolTip=DAStudio.message('Simulink:dialog:SignalSampleTimeToolTip');
        rowIdx=rowIdx+1;


        sampleModeLbl.Name=DAStudio.message('Simulink:dialog:SignalSampleModePrompt');
        sampleModeLbl.Type='text';
        sampleModeLbl.RowSpan=[rowIdx,rowIdx];
        sampleModeLbl.ColSpan=[3,3];
        sampleModeLbl.Tag='SampleModeLbl';

        sampleMode.Name=sampleModeLbl.Name;
        sampleMode.HideName=1;
        sampleMode.Type='combobox';
        sampleMode.Entries=l_translate(getPropAllowedValues(h,'SamplingMode'));
        sampleMode.Source=h;
        sampleMode.ObjectProperty='SamplingMode';
        sampleMode.RowSpan=[rowIdx,rowIdx];
        sampleMode.ColSpan=[4,4];
        sampleMode.Tag='SampleMode';
        sampleMode.ToolTip=DAStudio.message('Simulink:dialog:SignalSampleModeToolTip');
        if strcmp(h.SamplingMode,'auto')
            sampleModeLbl.Visible=0;
            sampleMode.Visible=0;
        end
        rowIdx=rowIdx+1;

        pnlObj.LayoutGrid=[rowIdx,4];
        pnlObj.ColStretch=[0,1,0,1];
        if(slfeature('EnableStoredIntMinMax')>0)
            pnlObj.Items={dataTypeGroup,...
            dimensionsLbl,dimensions,...
            dimensionsModeLbl,dimensionsMode,...
            initialValueLbl,initialValue,...
            complexityLbl,complexity,...
            minimumLbl,minimum,...
            maximumLbl,maximum,...
            grpStoredInteger,...
            unitsLbl,units,...
            sampleTimeLbl,sampleTime,...
            sampleModeLbl,sampleMode};
        else
            pnlObj.Items={dataTypeGroup,...
            dimensionsLbl,dimensions,...
            dimensionsModeLbl,dimensionsMode,...
            initialValueLbl,initialValue,...
            complexityLbl,complexity,...
            minimumLbl,minimum,...
            maximumLbl,maximum,...
            unitsLbl,units,...
            sampleTimeLbl,sampleTime,...
            sampleModeLbl,sampleMode};
        end
    end





    scTooltipId='Simulink:dialog:DataStorageClassToolTip1';

    if isParameter
        if slfeature('ModelOwnedDataIM')==0
            scTooltipId='Simulink:dialog:DataStorageClassToolTip2';
        else
            scTooltipId='Simulink:dialog:ConfigureTextToolTipParameter';
        end
    end

    if isParam
        if slfeature('ModelOwnedDataIM')>0&&ownedByModel
            grpCodeGen=createCodeGenBtn(hProxy,...
            'Simulink:dialog:DataCodeGenOptionsPrompt',...
            scTooltipId,...
            'Parameter');
        else
            grpCodeGen=createCodeGenGroup(hProxy,...
            'Simulink:dialog:DataCodeGenOptionsPrompt',...
            scTooltipId);
        end
    else
        if ownedByModel&&slfeature('ModelOwnedDataIM')>0...
            &&slfeature('AllowSignalObjectsWithNonAutoSCInModelWS')==2
            grpCodeGen=createCodeGenBtn(hProxy,...
            'Simulink:dialog:DataCodeGenOptionsPrompt',...
            scTooltipId,...
            'Signal');
        else
            grpCodeGen=createCodeGenGroup(hProxy,...
            'Simulink:dialog:DataCodeGenOptionsPrompt',...
            scTooltipId);
        end
    end
    grpCodeGen.Visible=true;

    if isEmbeddedSignal||isempty(grpCodeGen.Items)
        grpCodeGen.Visible=false;
        grpCodeGen.Enabled=false;
    end

    if ownedByModel
        if isParam&&~hProxy.isValidProperty('StorageClass')&&...
            slfeature('ModelOwnedDataIM')==0
            grpCodeGen.Visible=false;
            grpCodeGen.Enabled=false;
        end

        if~isParam&&slfeature('ModelOwnedDataIM')>0&&...
            slfeature('AllowSignalObjectsWithNonAutoSCInModelWS')<2
            grpCodeGen.Visible=false;
            grpCodeGen.Enabled=false;
        end

        if~isParam&&slfeature('ModelOwnedDataIM')==0&&...
            slfeature('AllowSignalObjectsWithNonAutoSCInModelWS')==2
            grpCodeGen.Visible=false;
            grpCodeGen.Enabled=false;
        end
    end






    grpLoggingInfo.Items={};
    grpLoggingInfo.Type='panel';
    grpLoggingInfo.LayoutGrid=[1,1];

    grpLoggingInfo.Tag='GrpLoggingInfo';
    grpLoggingInfo.RowSpan=[3,3];
    grpLoggingInfo.ColSpan=[1,2];





    description.Name=DAStudio.message('Simulink:dialog:ObjectDescriptionPrompt');
    description.Type='editarea';
    description.RowSpan=[4,4];
    description.ColSpan=[1,2];
    description.Source=h;
    description.ObjectProperty='Description';
    description.Tag='Description';





    [grpUserData,tabUserData]=get_userdata_prop_grp(h);


















    tabDesign.Name=DAStudio.message('Simulink:dialog:DataTab1Prompt');
    tabDesign.LayoutGrid=[4,2];
    tabDesign.RowStretch=[0,0,0,1];
    tabDesign.ColStretch=[0,1];
    tabDesign.Source=h;
    tabDesign.Items={pnlObj,...
    grpLoggingInfo,...
    description};
    tabDesign.Tag='TabDesign';





    if(grpCodeGen.Visible)
        tabCodeGen=createCodeGenTab(grpCodeGen);
    end









    if isParam
        [grpAdditional,tabAdditionalProp]=get_additional_prop_grp(h,'Parameter','TabTwo');
    else
        [grpAdditional,tabAdditionalProp]=get_additional_prop_grp(h,'Signal','TabTwo');
    end




    dlgOrPanel=[];

    tabWhole.Type='tab';
    tabWhole.Tag='TabWhole';

    if(grpCodeGen.Visible)
        tabWhole.Tabs={tabDesign,tabCodeGen};
    else
        tabWhole.Tabs={tabDesign};
    end

    if(~isempty(grpAdditional.Items))
        tabWhole.Tabs{end+1}=tabAdditionalProp;
    end

    if(~isempty(grpUserData.Items))
        tabWhole.Tabs{end+1}=tabUserData;
    end

    dlgOrPanel.Items={tabWhole};


    dlgOrPanel.Items=remove_duplicate_widget_tags(dlgOrPanel.Items);

    if isRtnPanel

        dlgOrPanel.Type='panel';
    else

        if(strcmp(type,'signal')==1||strcmp(type,'data')==1)
            dlgOrPanel.DialogTitle=[class(h),': ',name];
        else
            dlgOrPanel.DialogTitle=['Data properties:',name];
        end

        dlgOrPanel.SmartApply=0;
        dlgOrPanel.PreApplyCallback='dataddg_cb';
        if(isParam)
            dlgOrPanel.PreApplyArgs={'%dialog','preapply_cb',h,isParam,valueEdit};
        else
            dlgOrPanel.PreApplyArgs={'%dialog','preapply_cb',h};
        end
        dlgOrPanel.MinimalApply=true;
        dlgOrPanel.HelpMethod='helpview';
        dlgOrPanel.HelpArgs={[docroot,mapfile],helpTopicKey};
    end
    if isParam&&isa(hProxy,'Simulink.SlidDAProxy')&&hProxy.isReadonlyProperty('Value')
        if~isequal(slfeature('MWSValueSource'),2)
            for i=1:numel(dlgOrPanel.Items)
                dlgOrPanel.Items{i}.Enabled=false;
            end
        end
    end

    dlgOrPanel.OpenCallback=@onDialogOpen;

end


function onDialogOpen(dlg)
    dlgSrc=dlg.getDialogSource();
    if any(strcmp(methods(class(dlgSrc)),'useCodeGen'))
        dlg.setEnabled('TabCodeGen',dlgSrc.useCodeGen());
    end
end

function str=l_translate(str)



    if iscell(str)
        for idx=1:length(str)
            str{idx}=l_translate(str{idx});
        end
    else
        switch str
        case 'auto'
            str=DAStudio.message('Simulink:dialog:auto_CB');
        case 'real'
            str=DAStudio.message('Simulink:dialog:real_CB');
        case 'complex'
            str=DAStudio.message('Simulink:dialog:complex_CB');
        case 'N/A'
            str=DAStudio.message('Simulink:dialog:NA_CB');
        case 'Fixed'
            str=DAStudio.message('Simulink:dialog:Fixed_CB');
        case 'Variable'
            str=DAStudio.message('Simulink:dialog:Variable_CB');
        case 'Frame based'
            str=DAStudio.message('Simulink:dialog:Frame_based_CB');
        case 'Sample based'
            str=DAStudio.message('Simulink:dialog:Sample_based_CB');
        otherwise
            assert(false,'Unexpected string for translation');
        end
    end
end


function grpStoredInt=l_createStoredIntegerGroup(hProxy,groupNameId,isvalid,varargin)







    grpStoredInt.Items={};
    if isa(hProxy,'Simulink.SlidDAProxy')
        hSlidObject=hProxy.getObject();
        h=hSlidObject.WorkspaceObjectSharedCopy;
        if isempty(h)
            return;
        end
        ownedByModel=true;
    else
        h=hProxy;
        ownedByModel=false;
    end

    ownedByDD=false;


    if nargin>=4
        if isa(varargin{1},'Simulink.data.dictionary.Section')
            ownedByDD=true;
        end
    end

    context=[];
    wsObj=[];
    if ownedByModel
        slidObj=hProxy.getObject();
        modelRootObj=get_param(slidObj.System.Handle,'Object');
        context=modelRootObj.getFullName;
        wsObj=modelRootObj.getWorkspace();
    elseif ownedByDD
        wsObj=varargin{1};
        context=varargin{1};
    end

    numItems=1;

    storedIntMinLbl.Name='Minimum:';
    storedIntMinLbl.Type='text';
    storedIntMinLbl.Visible=isvalid;
    storedIntMinLbl.RowSpan=[1,1];
    storedIntMinLbl.ColSpan=[1,1];
    grpStoredInt.Items{numItems}=storedIntMinLbl;

    numItems=numItems+1;

    storedIntMin.Name='SIMinimumEdit';
    storedIntMin.HideName=1;
    storedIntMin.Type='edit';
    storedIntMin.Source=h;
    storedIntMin.Value=getPropValue(h,'StoredIntMin',wsObj);
    storedIntMin.Tag='StoredIntMin';
    storedIntMin.ToolTip=DAStudio.message('Simulink:dialog:StoredIntMinToolTip');
    storedIntMin.Mode=true;
    storedIntMin.MatlabMethod='setPropValue';
    if ownedByDD
        storedIntMin.MatlabArgs={'%source','%tag','%value',context};
    else
        storedIntMin.MatlabArgs={'%source','%tag','%value',get_param(context,'modelworkspace')};
    end
    storedIntMin.Visible=isvalid;
    storedIntMin.RowSpan=[1,1];
    storedIntMin.ColSpan=[2,2];
    grpStoredInt.Items{numItems}=storedIntMin;

    numItems=numItems+1;


    storedIntMaxLbl.Name='Maximum:';
    storedIntMaxLbl.Type='text';
    storedIntMaxLbl.Visible=isvalid;
    storedIntMaxLbl.RowSpan=[1,1];
    storedIntMaxLbl.ColSpan=[3,3];
    grpStoredInt.Items{numItems}=storedIntMaxLbl;

    numItems=numItems+1;

    storedIntMax.Name='SIMaximumEdit';
    storedIntMax.HideName=1;
    storedIntMax.Type='edit';
    storedIntMax.Source=h;
    storedIntMax.Value=getPropValue(h,'StoredIntMax',wsObj);
    storedIntMax.Tag='StoredIntMax';
    storedIntMax.ToolTip=DAStudio.message('Simulink:dialog:StoredIntMaxToolTip');
    storedIntMax.Mode=true;
    storedIntMax.MatlabMethod='setPropValue';
    if ownedByDD
        storedIntMax.MatlabArgs={'%source','%tag','%value',context};
    else
        storedIntMax.MatlabArgs={'%source','%tag','%value',get_param(context,'modelworkspace')};
    end
    storedIntMax.Visible=isvalid;
    storedIntMax.RowSpan=[1,1];
    storedIntMax.ColSpan=[4,4];
    grpStoredInt.Items{numItems}=storedIntMax;


    grpStoredInt.Name=DAStudio.message(groupNameId);
    grpStoredInt.LayoutGrid=[1,4];
    grpStoredInt.ColStretch=[0,1,0,1];
    grpStoredInt.Type='group';
    grpStoredInt.Source=h;
    grpStoredInt.Tag='GroupStoredInt';
end





