function dlgstruct=numerictypeddg(h,name,varargin)








    narginchk(2,3);
    slimModeForContainer=~isempty(varargin);

    rowIdx=0;






    rowIdx=rowIdx+1;
    dataTypeModeLbl.Name=DAStudio.message('Simulink:dialog:NumericTypeDataTypeModePrompt');
    dataTypeModeLbl.Type='text';
    dataTypeModeLbl.RowSpan=[rowIdx,rowIdx];
    dataTypeModeLbl.ColSpan=[1,1];
    dataTypeModeLbl.Tag='DataTypeModeLbl';

    dataTypeMode.Name='';
    dataTypeMode.RowSpan=[rowIdx,rowIdx];
    dataTypeMode.ColSpan=[2,2];
    dataTypeMode.Tag='DataTypeMode';
    dataTypeMode.Type='combobox';
    dataTypeMode.Entries=getPropAllowedValues(h,'DataTypeMode')';
    dataTypeMode.ObjectProperty='DataTypeMode';
    dataTypeMode.Mode=1;
    dataTypeMode.DialogRefresh=1;
    catVal=h.DataTypeMode;






    rowIdx=rowIdx+1;
    signednessLbl.Name=DAStudio.message('Simulink:dialog:NumericTypeSignednessPrompt');
    signednessLbl.Type='text';
    signednessLbl.RowSpan=[rowIdx,rowIdx];
    signednessLbl.ColSpan=[1,1];
    signednessLbl.Tag='SignednessLbl';

    signedness.Name='';
    signedness.RowSpan=[rowIdx,rowIdx];
    signedness.ColSpan=[2,2];
    signedness.Tag='Signedness';
    signedness.Type='combobox';
    signedness.Entries=getPropAllowedValues(h,'Signedness')';
    signedness.ObjectProperty='Signedness';
    signedness.Mode=1;
    signedness.DialogRefresh=1;

    if isscaledtype(h)
        signednessLbl.Visible=1;
        signedness.Visible=1;
    else
        signednessLbl.Visible=0;
        signedness.Visible=0;
    end






    rowIdx=rowIdx+1;
    wordLengthLbl.Name=DAStudio.message('Simulink:dialog:NumericTypeWordLengthPrompt');
    wordLengthLbl.Type='text';
    wordLengthLbl.RowSpan=[rowIdx,rowIdx];
    wordLengthLbl.ColSpan=[1,1];
    wordLengthLbl.Tag='WordLengthLbl';

    wordLength.Name='';
    wordLength.RowSpan=[rowIdx,rowIdx];
    wordLength.ColSpan=[2,2];
    wordLength.Tag='WordLength';
    wordLength.Type='edit';
    wordLength.ObjectProperty='WordLengthString';
    wordLength.Mode=1;
    wordLength.DialogRefresh=1;
    if(strcmp(catVal,'Double')||strcmp(catVal,'Single')||...
        strcmp(catVal,'Boolean'))||strcmp(catVal,'Half')
        wordLengthLbl.Visible=0;
        wordLength.Visible=0;
    else
        wordLengthLbl.Visible=1;
        wordLength.Visible=1;
    end







    rowIdx=rowIdx+1;
    fracLenLbl.Name=DAStudio.message('Simulink:dialog:NumericTypeFractionLengthPrompt');
    fracLenLbl.Type='text';
    fracLenLbl.RowSpan=[rowIdx,rowIdx];
    fracLenLbl.ColSpan=[1,1];
    fracLenLbl.Tag='FracLenLbl';

    fracLen.Name='';
    fracLen.RowSpan=[rowIdx,rowIdx];
    fracLen.ColSpan=[2,2];
    fracLen.Tag='FractionLength';
    fracLen.Type='edit';
    fracLen.ObjectProperty='FractionLengthString';
    fracLen.Mode=1;
    fracLen.DialogRefresh=1;
    if strcmp(catVal,'Fixed-point: binary point scaling')
        fracLenLbl.Visible=1;
        fracLen.Visible=1;
    else
        fracLenLbl.Visible=0;
        fracLen.Visible=0;
    end






    rowIdx=rowIdx+1;
    slopeLbl.Name=DAStudio.message('Simulink:dialog:NumericTypeSlopePrompt');
    slopeLbl.Type='text';
    slopeLbl.RowSpan=[rowIdx,rowIdx];
    slopeLbl.ColSpan=[1,1];
    slopeLbl.Tag='SlopeLbl';

    slope.Name='';
    slope.RowSpan=[rowIdx,rowIdx];
    slope.ColSpan=[2,2];
    slope.Type='edit';
    slope.Tag='Slope';
    slope.ObjectProperty='SlopeString';
    slope.Mode=1;
    slope.DialogRefresh=1;
    if(strcmp(catVal,'Fixed-point: slope and bias scaling'))
        slopeLbl.Visible=1;
        slope.Visible=1;
    else
        slopeLbl.Visible=0;
        slope.Visible=0;
    end;






    rowIdx=rowIdx+1;
    biasLbl.Name=DAStudio.message('Simulink:dialog:NumericTypeBiasPrompt');
    biasLbl.Type='text';
    biasLbl.RowSpan=[rowIdx,rowIdx];
    biasLbl.ColSpan=[1,1];
    biasLbl.Tag='BiasLbl';

    bias.Name='';
    bias.RowSpan=[rowIdx,rowIdx];
    bias.ColSpan=[2,2];
    bias.Type='edit';
    bias.Tag='Bias';
    bias.ObjectProperty='BiasString';
    bias.Mode=1;
    bias.DialogRefresh=1;
    if(strcmp(catVal,'Fixed-point: slope and bias scaling'))
        biasLbl.Visible=1;
        bias.Visible=1;
    else
        biasLbl.Visible=0;
        bias.Visible=0;
    end;





    rowIdx=rowIdx+1;
    dataTypeOverrideLbl.Name=DAStudio.message('Simulink:dialog:NumericTypeDataTypeOverridePrompt');
    dataTypeOverrideLbl.Type='text';
    dataTypeOverrideLbl.RowSpan=[rowIdx,rowIdx];
    dataTypeOverrideLbl.ColSpan=[1,1];
    dataTypeOverrideLbl.Tag='DataTypeOverrideLbl';

    comboDataTypeOverride.Name='';
    comboDataTypeOverride.RowSpan=[rowIdx,rowIdx];
    comboDataTypeOverride.ColSpan=[2,2];
    comboDataTypeOverride.Type='combobox';
    comboDataTypeOverride.Entries=getPropAllowedValues(h,'DataTypeOverride')';
    comboDataTypeOverride.Tag='DataTypeOverride';
    comboDataTypeOverride.ObjectProperty='DataTypeOverride';





    rowIdx=rowIdx+1;
    isAlias.Name=DAStudio.message('Simulink:dialog:NumericTypeIsAliasPrompt');
    isAlias.RowSpan=[rowIdx,rowIdx];
    isAlias.ColSpan=[1,1];
    isAlias.Type='checkbox';
    isAlias.Tag='IsAlias';
    isAlias.ObjectProperty='IsAlias';





    grpNumItems=0;
    grpCodeGen.Items={};





    grpNumItems=grpNumItems+1;
    dataScope.Name=DAStudio.message('Simulink:dialog:DataTypeDataScopePrompt');
    dataScope.RowSpan=[1,1];
    dataScope.ColSpan=[1,2];
    dataScope.Type='combobox';
    dataScope.Entries=h.getPropAllowedValues('DataScope')';
    dataScope.Tag='dataScope_tag';
    dataScope.ObjectProperty='DataScope';
    grpCodeGen.Items{grpNumItems}=dataScope;






    grpNumItems=grpNumItems+1;
    headerFile.Name='';
    headerFile.Name=DAStudio.message('Simulink:dialog:DataTypeHeaderFilePrompt');
    headerFile.RowSpan=[2,2];
    headerFile.ColSpan=[1,2];
    headerFile.Type='edit';
    headerFile.Tag='HeaderFile';
    headerFile.ObjectProperty='HeaderFile';
    grpCodeGen.Items{grpNumItems}=headerFile;




    rowIdx=rowIdx+1;
    grpCodeGen.Items=align_names(grpCodeGen.Items);
    grpCodeGen.LayoutGrid=[3,2];
    grpCodeGen.Name=DAStudio.message('Simulink:dialog:DataCodeGenOptionsPrompt');
    grpCodeGen.Type='group';
    grpCodeGen.RowSpan=[rowIdx,rowIdx];
    grpCodeGen.ColSpan=[1,2];
    grpCodeGen.RowStretch=[0,0,1];
    grpCodeGen.ColStretch=[0,1];
    grpCodeGen.Tag='grpCodeGen_tag';





    rowIdx=rowIdx+1;
    description.Name=DAStudio.message('Simulink:dialog:ObjectDescriptionPrompt');
    description.Type='editarea';
    description.Tag='Description';
    description.RowSpan=[rowIdx,rowIdx];
    description.ColSpan=[1,2];
    description.ObjectProperty='Description';





    [grpUserData,tabUserData]=get_userdata_prop_grp(h);














    tabDesign.Name=DAStudio.message('Simulink:dialog:DataTab1Prompt');
    tabDesign.LayoutGrid=[rowIdx,2];
    tabDesign.RowStretch=[zeros(1,rowIdx-1),1];
    tabDesign.ColStretch=[0,1];
    tabDesign.Items={dataTypeModeLbl,dataTypeMode,...
    signednessLbl,signedness,...
    wordLengthLbl,wordLength,...
    fracLenLbl,fracLen,...
    slopeLbl,slope,...
    biasLbl,bias,...
    dataTypeOverrideLbl,comboDataTypeOverride,...
    isAlias,...
    description};
    tabDesign.Tag='TabDesign';

    if slimModeForContainer
        tabDesign.Type='togglepanel';
        tabDesign.Expand=true;
    end





    tabCodeGen=createCodeGenTab(grpCodeGen);
    if slimModeForContainer
        tabCodeGen.Type='togglepanel';
        tabCodeGen.Expand=false;
    end









    [grpAdditional,tabAdditionalProp]=get_additional_prop_grp(h,'NumericType','TabTwo');




    dlgstruct.DialogTitle=[class(h),': ',name];

    items={tabDesign,tabCodeGen};
    if slimModeForContainer
        tabWhole.Type='panel';
        tabWhole.Items=items;
    else
        tabWhole.Type='tab';
        tabWhole.Tabs=items;
    end
    tabWhole.Tag='TabWhole';

    if(~isempty(grpAdditional.Items))
        if slimModeForContainer
            tabWhole.Items{end+1}=tabAdditionalProp;
        else
            tabWhole.Tabs{end+1}=tabAdditionalProp;
        end
    end

    if(~isempty(grpUserData.Items))
        if slimModeForContainer
            tabWhole.Items{end+1}=tabUserData;
        else
            tabWhole.Tabs{end+1}=tabUserData;
        end
    end
    dlgstruct.Items={tabWhole};

    if slimModeForContainer
        dlgstruct.DialogMode='Slim';
    end


    dlgstruct.Items=remove_duplicate_widget_tags(dlgstruct.Items);


    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'simulink_numeric_type'};


