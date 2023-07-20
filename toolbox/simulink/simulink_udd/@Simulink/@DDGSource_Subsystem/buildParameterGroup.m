function prmGrp=buildParameterGroup(source)

    if source.isSlimDialog

        prmGrp=buildSlimDialog(source);
    else

        prmGrp=buildNormalDialog(source);
    end
end


function paramGrp=buildNormalDialog(source)

    paramGrp.Name=DAStudio.message('Simulink:dialog:Parameters');
    paramGrp.Source=source.getBlock;
    paramGrp.Tag='ParameterTabContainerVar';

    paramGrp.RowSpan=[2,2];
    paramGrp.ColSpan=[1,1];

    paramGrp.Type='tab';
    paramGrp.Tabs={};


    currTab=1;
    paramGrp.Tabs{currTab}=getMainPart(source);


    currTab=currTab+1;
    paramGrp.Tabs{currTab}=getCodeGenPart(source);


    if showConcurrency(source)
        currTab=currTab+1;
        paramGrp.Tabs{currTab}=getConcurrencyPart(source);
    end


    currTab=currTab+1;
    paramGrp.Tabs{currTab}=getSubsystemRefPart(source);
end


function prmItems=buildSlimDialog(source)


    prmPanel.Type='panel';
    prmPanel.Tag='ParameterTabContainerVar';
    prmPanel.RowSpan=[1,1];
    prmPanel.ColSpan=[1,2];
    prmPanel.LayoutGrid=[5,1];
    prmPanel.RowStretch=[0,0,0,0,1];
    prmPanel.Visible=1;
    prmPanel.Enabled=1;
    prmPanel.ToolTip='';

    prmPanel.Items={};


    currRow=1;
    togglePanel=getMainPart(source);
    togglePanel.RowSpan=[currRow,currRow];
    prmPanel.Items{end+1}=togglePanel;


    currRow=currRow+1;
    togglePanel=getCodeGenPart(source);
    togglePanel.RowSpan=[currRow,currRow];
    prmPanel.Items{end+1}=togglePanel;


    if showConcurrency(source)
        currRow=currRow+1;
        togglePanel=getConcurrencyPart(source);
        togglePanel.RowSpan=[currRow,currRow];
        prmPanel.Items{end+1}=togglePanel;
    end


    currRow=currRow+1;
    togglePanel=getSubsystemRefPart(source);
    togglePanel.RowSpan=[currRow,currRow];
    prmPanel.Items{end+1}=togglePanel;


    currRow=currRow+1;
    panel.Name='';
    panel.Type='panel';
    panel.RowSpan=[currRow,currRow];
    panel.ColSpan=[1,2];
    prmPanel.Items{end+1}=panel;

    prmItems={prmPanel};
end


function thisPart=getMainPart(source)

    thisPart.Name=DAStudio.message('Simulink:dialog:ModelTabOneName');
    thisPart.Items=createMainTabItems(source);
    thisPart.Tag='Tab0';

    if source.isSlimDialog
        thisPart=configTP(thisPart);
    else
        thisPart=configTab(thisPart);
    end
end

function thisPart=getCodeGenPart(source)

    thisPart.Name=DAStudio.message('Simulink:dialog:SigpropTabTwoName');
    thisPart.Items=createCodeGenTabItems(source);
    thisPart.Tag='Tab1';
    if source.isSlimDialog
        thisPart=configTP(thisPart);
    else
        thisPart=configTab(thisPart);
    end
end

function thisPart=getConcurrencyPart(source)
    thisPart.Name=DAStudio.message('Simulink:dialog:Concurrency');
    thisPart.Items=createConcurrencyTabItems(source);
    thisPart.Tag='Tab2';
    if source.isSlimDialog
        thisPart=configTP(thisPart);
    else
        thisPart=configTab(thisPart);
    end
end

function thisPart=getSubsystemRefPart(source)

    thisPart.Name=DAStudio.message('Simulink:SubsystemReference:SRTabText');
    thisPart.Tag='subsystem_ref_tab_tag';
    thisPart.Items=createSubsystemRefTabItems(source);
    if source.isSlimDialog
        thisPart=configTP(thisPart);
    else
        thisPart=configTab(thisPart);
    end
end


function thisPart=configTab(part)
    [maxRow,maxCol]=getMaxSize(part.Items);

    rowIdx=maxRow+1;


    spacer.Name='';
    spacer.Type='text';
    spacer.RowSpan=[rowIdx,rowIdx];
    spacer.ColSpan=[1,maxCol];

    thisPart=part;
    thisPart.Items{end+1}=spacer;
    thisPart.LayoutGrid=[rowIdx,maxCol];
    thisPart.ColStretch=ones(1,maxCol);
    thisPart.RowStretch=[zeros(1,(rowIdx-1)),1];
end


function thisPart=configTP(part)

    [maxRow,~]=getMaxSize(part.Items);
    thisPart=part;
    thisPart.Type='togglepanel';
    thisPart.ColSpan=[1,2];
    thisPart.ColStretch=[1,1];
    thisPart.LayoutGrid=[maxRow,2];
    thisPart.Expand=1;
end


function ret=showConcurrency(source)
    ret=false;

    if(slfeature('SLMulticore')==0)
        return;
    end

    if getIsCondExecSubsystem(source,source.getBlock)
        return;
    end

    model=bdroot(source.getBlock.handle);
    if strcmp(get_param(model,'ConcurrentTasks'),'off')
        return;
    end

    prmVal=get_param(source.getBlock.handle,'TreatAsAtomicUnit');
    if strcmp(prmVal,'off')

        return;
    end

    if strcmp(get_param(model,'ExplicitPartitioning'),'on')

        return;
    end
    ret=true;
end


function[maxRow,maxCol]=getMaxSize(items)
    maxRow=0;
    maxCol=0;
    for idx=1:numel(items)
        currItem=items{idx};
        colSpan=currItem.ColSpan;
        if maxCol<colSpan(2)
            maxCol=colSpan(2);
        end
        rowSpan=currItem.RowSpan;
        if maxRow<rowSpan(2)
            maxRow=rowSpan(2);
        end
    end
end

