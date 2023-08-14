function dlgstruct=blockpropddg(blk,dlgTag)



















    generalUsageText.Type='text';
    generalUsageText.Tag='GeneralUsageText';
    generalUsageText.Name=DAStudio.message('Simulink:dialog:infoTextDescription');
    generalUsageText.WordWrap=true;
    generalUsageText.RowSpan=[1,1];
    generalUsageText.ColSpan=[1,1];

    generalUsageGroup.Type='group';
    generalUsageGroup.Tag='GeneralUsageGroup';
    generalUsageGroup.Name=DAStudio.message('Simulink:dialog:usage');
    generalUsageGroup.Items={generalUsageText};
    generalUsageGroup.LayoutGrid=[1,1];


    openBlockText.Type='text';
    openBlockText.Tag='OpenBlockText';
    openBlockText.Name=DAStudio.message('Simulink:dialog:openfcnBlock');
    openBlockText.RowSpan=[1,1];
    openBlockText.ColSpan=[1,1];

    slashn=double(sprintf('\n'));
    blkname=strrep(blk.name,char(slashn),' ');
    openBlockLink.Type='hyperlink';
    openBlockLink.Tag='OpenBlockLink';
    openBlockLink.Name=blkname;
    openBlockLink.ToolTip=DAStudio.message('Simulink:dialog:openBlockTooltip');
    openBlockLink.MatlabMethod='open_system';
    openBlockLink.MatlabArgs={blk.getFullName};
    openBlockLink.RowSpan=[1,1];
    openBlockLink.ColSpan=[2,2];

    openBlockSpacer.Type='panel';
    openBlockSpacer.Tag='OpenBlockSpacer';
    openBlockSpacer.RowSpan=[1,1];
    openBlockSpacer.ColSpan=[3,3];

    openBlockGroup.Type='group';
    openBlockGroup.Tag='OpenBlockGroup';
    openBlockGroup.Items={openBlockText,openBlockLink,openBlockSpacer};
    openBlockGroup.LayoutGrid=[1,3];
    openBlockGroup.RowStretch=0;
    openBlockGroup.ColStretch=[0,0,1];


    descriptionEditArea.Type='editarea';
    descriptionEditArea.Tag='DescriptionEditArea';
    descriptionEditArea.Name=DAStudio.message('Simulink:dialog:ObjectDescriptionPrompt');
    descriptionEditArea.ToolTip=DAStudio.message('Simulink:dialog:EnterTextHere');
    descriptionEditArea.ObjectProperty='Description';
    descriptionEditArea.RowSpan=[1,4];
    descriptionEditArea.ColSpan=[1,1];

    priorityEdit.Type='edit';
    priorityEdit.Tag='PriorityEdit';
    priorityEdit.Name=DAStudio.message('Simulink:dialog:priority');
    priorityEdit.ToolTip=DAStudio.message('Simulink:dialog:EnterIntegerValue');
    priorityEdit.ObjectProperty='Priority';
    priorityEdit.NameLocation=2;
    priorityEdit.RowSpan=[5,5];
    priorityEdit.ColSpan=[1,1];
    priorityEdit.Value=get_param(blk.handle,'Priority');

    tagEdit.Type='edit';
    tagEdit.Tag='TagEdit';
    tagEdit.Name=DAStudio.message('Simulink:dialog:TagPrompt');
    tagEdit.ToolTip=DAStudio.message('Simulink:dialog:EnterTextHere');
    tagEdit.ObjectProperty='Tag';
    tagEdit.NameLocation=2;
    tagEdit.RowSpan=[6,6];
    tagEdit.ColSpan=[1,1];
    tagEdit.Value=get_param(blk.handle,'Tag');

    generalGroup.Type='group';
    generalGroup.Tag='GeneralGroup';
    generalGroup.Items={descriptionEditArea,priorityEdit,tagEdit};
    generalGroup.LayoutGrid=[6,1];
    generalGroup.RowStretch=[0,1,1,1,0,0];
    generalGroup.ColStretch=1;


    generalUsageGroup.RowSpan=[1,1];
    generalUsageGroup.ColSpan=[1,1];


    openBlockGroup.RowSpan=[2,2];
    openBlockGroup.ColSpan=[1,1];


    generalGroup.RowSpan=[3,5];
    generalGroup.ColSpan=[1,1];

    tab1.Tag='Tab1';
    tab1.Name=DAStudio.message('Simulink:dialog:generalLabel');
    tab1.Items={generalUsageGroup,openBlockGroup,generalGroup};
    tab1.LayoutGrid=[5,1];
    tab1.RowStretch=[0,0,1,1,1];
    tab1.ColStretch=0;




    annotationUsageText.Type='text';
    annotationUsageText.Tag='AnnotationUsageText';
    annotationUsageText.Name=DAStudio.message('Simulink:dialog:textBelowDescription');
    annotationUsageText.WordWrap=true;
    annotationUsageText.RowSpan=[1,1];
    annotationUsageText.ColSpan=[1,1];

    annotationUsageGroup.Type='group';
    annotationUsageGroup.Tag='AnnotationUsageGroup';
    annotationUsageGroup.Name=DAStudio.message('Simulink:dialog:usage');
    annotationUsageGroup.Items={annotationUsageText};
    annotationUsageGroup.LayoutGrid=[1,1];


    parametersStruct=Simulink.internal.getBlkParametersAndCallbacks(blk.handle,false);


    annotationListBox.Type='listbox';
    annotationListBox.Tag='AnnotationListBox';
    annotationListBox.Name=DAStudio.message('Simulink:dialog:BlockPropertyTokens');
    annotationListBox.ToolTip=DAStudio.message('Simulink:dialog:appendInstructionsDblClick');
    annotationListBox.Graphical=true;
    annotationListBox.Entries=parametersStruct.anno;
    annotationListBox.UserData=parametersStruct.anno;
    annotationListBox.ListDoubleClickCallback=@appendItemToAnnotationEditArea;
    annotationListBox.RowSpan=[1,8];
    annotationListBox.ColSpan=[1,2];

    rtArrowPushButton.Type='pushbutton';
    rtArrowPushButton.Tag='RtArrowPushButton';
    rtArrowPushButton.Name='>>';
    rtArrowPushButton.ToolTip=DAStudio.message('Simulink:dialog:appendInstructionsFromLeft');
    rtArrowPushButton.MatlabMethod='feval';
    rtArrowPushButton.MatlabArgs={@appendItemsToAnnotationEditArea,'%dialog'};
    rtArrowPushButton.MaximumSize=[35,25];
    rtArrowPushButton.RowSpan=[4,4];
    rtArrowPushButton.ColSpan=[3,3];

    annotationEditArea.Type='editarea';
    annotationEditArea.Tag='AnnotationEditArea';
    annotationEditArea.Name=DAStudio.message('Simulink:dialog:EnterTextAndTokens');
    annotationEditArea.ToolTip=DAStudio.message('Simulink:dialog:EditAnnotationStringsTooltip');
    annotationEditArea.ObjectProperty='AttributesFormatString';
    annotationEditArea.RowSpan=[1,7];
    annotationEditArea.ColSpan=[5,6];

    exampleText.Type='text';
    exampleText.Tag='ExampleText';
    exampleText.Name=DAStudio.message('Simulink:dialog:exampleSyntax');
    exampleText.RowSpan=[8,8];
    exampleText.ColSpan=[5,6];

    annotationGroup.Type='group';
    annotationGroup.Items={annotationListBox,rtArrowPushButton,annotationEditArea,exampleText};
    annotationGroup.LayoutGrid=[8,6];
    annotationGroup.RowStretch=zeros(1,8);
    annotationGroup.ColStretch=zeros(1,6);


    annotationUsageGroup.RowSpan=[1,1];
    annotationUsageGroup.ColSpan=[1,1];


    annotationGroup.RowSpan=[2,4];
    annotationGroup.ColSpan=[1,1];

    tab2.Name=DAStudio.message('Simulink:dialog:blockAnnotationLabel');
    tab2.Tag='Tab2';
    tab2.Items={annotationUsageGroup,annotationGroup};
    tab2.LayoutGrid=[4,1];
    tab2.RowStretch=[0,1,1,1];
    tab2.ColStretch=1;




    callbackUsageText.Type='text';
    callbackUsageText.Tag='CallbacksUsageText';
    callbackUsageText.Name=DAStudio.message('Simulink:dialog:callbackInstructions');
    callbackUsageText.WordWrap=true;
    callbackUsageText.RowSpan=[1,1];
    callbackUsageText.ColSpan=[1,1];

    callbackUsageGroup.Type='group';
    callbackUsageGroup.Tag='CallbackUsageGroup';
    callbackUsageGroup.Name=DAStudio.message('Simulink:dialog:usage');
    callbackUsageGroup.Items={callbackUsageText};
    callbackUsageGroup.LayoutGrid=[1,1];


    callbackFunctions=parametersStruct.cbk.fcns;
    callbackPanels=cell(1,length(callbackFunctions));
    enableCallbacks=enableCallbacksTab(blk.handle);


    for i=1:length(callbackFunctions)

        cbkFcnStr=callbackFunctions{i};
        cbkFcnLen=length(cbkFcnStr);
        if strcmp(cbkFcnStr(cbkFcnLen),'*')
            cbkFcnStr=cbkFcnStr(1:cbkFcnLen-1);
        end

        callbackEditArea.Type='editarea';
        callbackEditArea.Tag=[cbkFcnStr,'EditArea'];
        callbackEditArea.Name=DAStudio.message('Simulink:dialog:contentOfCallbackFunctionWithHole',cbkFcnStr);
        callbackEditArea.ToolTip=DAStudio.message('Simulink:dialog:EditingSelectedCallback');
        callbackEditArea.ObjectProperty=cbkFcnStr;
        callbackEditArea.Enabled=enableCallbacks;

        callbackPanel.Type='panel';
        callbackPanel.Tag=strcat('CallbacksPanel_',num2str(i));
        callbackPanel.Items={callbackEditArea};

        callbackPanels(i)={callbackPanel};
    end

    callbackPanelStack.Type='widgetstack';
    callbackPanelStack.RowSpan=[1,1];
    callbackPanelStack.ColSpan=[2,3];
    callbackPanelStack.Tag='CallbackPanelStack';
    callbackPanelStack.Items=callbackPanels;

    callbackTree.Type='tree';
    callbackTree.Tag='CallbackTree';
    callbackTree.Name=DAStudio.message('Simulink:dialog:CallbackFunctionsList');
    callbackTree.ToolTip=DAStudio.message('Simulink:dialog:selectCallbackFunction');
    callbackTree.Graphical=true;
    callbackTree.TreeSelectItems={0};
    callbackTree.TreeItems=transpose(callbackFunctions);
    callbackTree.TreeItemIds=num2cell(0:length(callbackTree.TreeItems)-1);
    callbackTree.TargetWidget='CallbackPanelStack';
    callbackTree.RowSpan=[1,1];
    callbackTree.ColSpan=[1,1];
    callbackGroup.Type='group';
    callbackGroup.Items={callbackTree,callbackPanelStack};
    callbackGroup.LayoutGrid=[1,3];
    callbackGroup.RowStretch=1;
    callbackGroup.ColStretch=[0,1,1];


    callbackUsageGroup.RowSpan=[1,1];
    callbackUsageGroup.ColSpan=[1,1];


    callbackGroup.RowSpan=[2,4];
    callbackGroup.ColSpan=[1,1];

    tab3.Name=DAStudio.message('Simulink:dialog:callbacksLabel');
    tab3.Tag='Tab3';
    tab3.Items={callbackUsageGroup,callbackGroup};
    tab3.LayoutGrid=[4,1];
    tab3.RowStretch=[0,1,1,1];
    tab3.ColStretch=1;


    tabContainer.Type='tab';
    tabContainer.Tag='TabContainer';
    tabContainer.Tabs={tab1,tab2,tab3};

    linkTitle='';
    if strcmp(get_param(blk.handle,'StaticLinkStatus'),'resolved')
        linkTitle=' (link)';
    end
    dlgstruct.DialogTitle=DAStudio.message('Simulink:dialog:blockPropertiesLabelTwoHoles',linkTitle,get_param(blk.handle,'name'));
    dlgstruct.DialogTag=dlgTag;
    dlgstruct.Source=blk.handle;
    dlgstruct.Items={tabContainer};
    dlgstruct.PostApplyCallback='feval';
    dlgstruct.PostApplyArgs={@postApplyHandler,'%source','%dialog'};
    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'blockpropertiesdialog'};
    dlgstruct.DefaultOk=true;
    dlgstruct.CloseCallback='feval';
    dlgstruct.CloseArgs={@onCloseDialog,blk.handle};
    if disableDialog(blk.handle)
        dlgstruct.DisableDialog=true;
    end











    dlgstruct.ExplicitShow=true;
end



function onCloseDialog(blkHandle)
    slInternal('removeDialogFromBlockUDIMap',blkHandle);
end

function[status,errMsg]=postApplyHandler(src,dlg)
    status=true;
    errMsg='';


    annoStr=get_param(src.handle,'AttributesFormatString');
    set_param(src.handle,'AttributesFormatString',annoStr);


    refresh(dlg);
end



function val=disableDialog(blkHdl)
    val=false;


    notInsideSSRefBlock=isempty(slInternal('getNearestParentSSRefBlock',blkHdl));
    bdIsLocked=strcmp(get_param(bdroot(blkHdl),'Lock'),'on');
    readOnly=(bdIsLocked&&notInsideSSRefBlock)||...
    strcmp(get_param(blkHdl,'StaticLinkStatus'),'implicit')||...
    Simulink.harness.internal.isActiveHarnessLockedCUT(blkHdl);
    if(readOnly)
        val=true;
    end
end


function val=enableCallbacksTab(blkHdl)
    val=true;
    if(strcmp(get_param(blkHdl,'StaticLinkStatus'),'resolved')||isConfigurableSubsystem(blkHdl))
        val=false;
    end
end


function appendItemToAnnotationEditArea(dlg,~,itemIndex)
    blkHdl=dlg.getDialogSource.handle;
    if disableDialog(blkHdl)
        return;
    end

    if~isempty(itemIndex)
        appendItemsToAnnotationEditArea(dlg);
    end
end


function appendItemsToAnnotationEditArea(dlg)
    data=dlg.getUserData('AnnotationListBox');
    selectedItemIndex=dlg.getWidgetValue('AnnotationListBox');
    existingText=deblank(dlg.getWidgetValue('AnnotationEditArea'));
    appendText='';
    for i=1:length(selectedItemIndex)
        selectedItem=data(selectedItemIndex(i)+1);
        appendText=[appendText,sprintf('\n'),selectedItem{1}];
    end
    if isempty(existingText)
        appendText=regexprep(appendText,'^\n(.*)','$1');
    else
        appendText=[existingText,appendText];
    end
    dlg.setWidgetValue('AnnotationEditArea',appendText);
end


function isConfig=isConfigurableSubsystem(blkHdl)
    isConfig=false;
    isSubsys=strcmp(get_param(blkHdl,'BlockType'),'SubSystem');
    if isSubsys
        tb=get_param(blkHdl,'TemplateBlock');
        isConfig=~isempty(tb)&&~strcmp(tb,'self')&&~strcmp(tb,'master');
    end
end
