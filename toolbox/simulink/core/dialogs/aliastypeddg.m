function dlgstruct=aliastypeddg(h,name,varargin)








    narginchk(2,3);
    slimModeForContainer=~isempty(varargin);

    rowIdx=0;





    rowIdx=rowIdx+1;
    dataTypeItems.builtinTypes=Simulink.DataTypePrmWidget.getBuiltinListForDataObjects('AliasType');


    dataTypeItems.scalingModes=Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB');
    dataTypeItems.signModes=Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');


    dataTypeItems.supportsEnumType=true;


    if~strcmp(name,'default')
        dataTypeItems.aliasObjectName=name;
    end


    if slimModeForContainer
        sourceObjForDTA=varargin{1};
    else
        sourceObjForDTA=h;
    end

    dataTypeGroup=Simulink.DataTypePrmWidget.getDataTypeWidget(sourceObjForDTA,...
    'BaseType',...
    DAStudio.message('Simulink:dialog:AliasTypeBaseTypePrompt'),...
    'BaseType',...
    h.BaseType,...
    dataTypeItems,...
    false);

    dataTypeGroup.RowSpan=[rowIdx,rowIdx];
    dataTypeGroup.ColSpan=[1,2];





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
    headerFile.Name=DAStudio.message('Simulink:dialog:DataTypeHeaderFilePrompt');
    headerFile.RowSpan=[2,2];
    headerFile.ColSpan=[1,2];
    headerFile.Type='edit';
    headerFile.Tag='headerFile_tag';
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
    description.Tag='description_tag';
    description.RowSpan=[rowIdx,rowIdx];
    description.ColSpan=[1,2];
    description.ObjectProperty='Description';





    [grpUserData,tabUserData]=get_userdata_prop_grp(h);














    tabDesign.Name=DAStudio.message('Simulink:dialog:DataTab1Prompt');
    tabDesign.LayoutGrid=[rowIdx,2];
    tabDesign.RowStretch=[zeros(1,rowIdx-1),1];
    tabDesign.ColStretch=[0,1];
    tabDesign.Items={dataTypeGroup,description};
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









    [grpAdditional,tabAdditionalProp]=get_additional_prop_grp(h,'AliasType','TabTwo');




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
    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'simulink_alias_type'};


