function dlgstruct=getDialogSchema(this,~)

















    rowTotal=0;
    dlgstruct.Items=cell(1,0);

    numStates=length(this.StateInfo);
    numParams=length(this.ParamInfo);
    needStateParam=numStates>0&&numParams>0;


    expandAll=true;
    if numStates+numParams<4
        indSP=1;
        while indSP<=numStates&&expandAll
            numAcc=(length(this.StateInfo(indSP).ReaderBlocks)+...
            length(this.StateInfo(indSP).WriterBlocks)+...
            length(this.StateInfo(indSP).StateflowSfunctions))<4;
            expandAll=expandAll&&numAcc;
            indSP=indSP+1;
        end
        indSP=1;
        while indSP<=numParams&&expandAll
            numAcc=(length(this.ParamInfo(indSP).ReaderBlocks)+...
            length(this.ParamInfo(indSP).WriterBlocks)+...
            length(this.ParamInfo(indSP).StateflowSfunctions))<4;
            expandAll=expandAll&&numAcc;
            indSP=indSP+1;
        end
    else
        expandAll=false;
    end


    stateItems=cell(1,numStates);
    statePanelHeader='Simulink:dialog:StateName';
    stateReaderHeadingStr=DAStudio.message('Simulink:dialog:StateReaderBlocks');
    stateWriterHeadingStr=DAStudio.message('Simulink:dialog:StateWriterBlocks');
    stateStateflowSfunctionHeadingStr=DAStudio.message('Simulink:dialog:StateflowCharts');

    if numStates==1
        singlePanel=createNonTogglePanel(this.StateInfo(1),1,expandAll,...
        statePanelHeader,...
        stateReaderHeadingStr,...
        stateWriterHeadingStr,...
        stateStateflowSfunctionHeadingStr);
        stateItems=singlePanel.Items;
    else
        for ind=1:numStates
            singleStatePanel=createTogglePanel(this.StateInfo(ind),ind,expandAll,...
            statePanelHeader,...
            stateReaderHeadingStr,...
            stateWriterHeadingStr,...
            stateStateflowSfunctionHeadingStr);
            stateItems{ind}=singleStatePanel;
        end
    end


    if needStateParam
        rowTotal=rowTotal+1;
        stateTogglePanel=createTogglePanelHeading(DAStudio.message('Simulink:dialog:States'),rowTotal);
        stateTogglePanel.Items=stateItems;
        stateTogglePanel.LayoutGrid=[numStates,3];
        stateTogglePanel.Expand=expandAll;
        dlgstruct.Items=[dlgstruct.Items,stateTogglePanel];
    elseif numStates>0

        rowTotal=rowTotal+numStates;
        dlgstruct.Items=[dlgstruct.Items,stateItems];
    end


    paramItems=cell(1,numParams);
    paramPanelHeader='Simulink:dialog:ParamName';
    paramReaderHeadingStr=DAStudio.message('Simulink:dialog:ParamReaderBlocks');
    paramWriterHeadingStr=DAStudio.message('Simulink:dialog:ParamWriterBlocks');
    paramStateflowSfunctionHeadingStr=DAStudio.message('Simulink:dialog:StateflowCharts');

    if numParams==1
        singlePanel=createNonTogglePanel(this.ParamInfo(1),1,expandAll,...
        paramPanelHeader,...
        paramReaderHeadingStr,...
        paramWriterHeadingStr,...
        paramStateflowSfunctionHeadingStr);
        paramItems=singlePanel.Items;
    else
        for ind=1:numParams
            singleParamPanel=createTogglePanel(this.ParamInfo(ind),ind,expandAll,...
            paramPanelHeader,...
            paramReaderHeadingStr,...
            paramWriterHeadingStr,...
            paramStateflowSfunctionHeadingStr);
            paramItems{ind}=singleParamPanel;
        end
    end


    if needStateParam
        rowTotal=rowTotal+1;
        paramTogglePanel=createTogglePanelHeading(DAStudio.message('Simulink:dialog:Params'),rowTotal);
        paramTogglePanel.Items=paramItems;
        paramTogglePanel.LayoutGrid=[numParams,3];
        paramTogglePanel.Expand=expandAll;
        dlgstruct.Items=[dlgstruct.Items,paramTogglePanel];
    elseif numParams>0

        rowTotal=rowTotal+numParams;
        dlgstruct.Items=[dlgstruct.Items,paramItems];
    end


    dlgstruct.LayoutGrid=[rowTotal,3];
    dlgstruct.DialogTitle='Go to State/Parameter Reader/Writer Blocks';
    dlgstruct.StandaloneButtonSet={''};
    if expandAll&&numAcc==1
        dlgstruct.IsScrollable=false;
    else
        dlgstruct.IsScrollable=true;
    end
    dlgstruct.Transient=true;
    dlgstruct.DialogStyle='frameless';
    dlgstruct.MinimalApply=true;
    dlgstruct.ExplicitShow=true;
    dlgstruct.Spacing=10;
end




function singlePanel=createTogglePanel(info,ind,expandAll,heading0,heading1,heading2,heading3)














    numInnerRows=0;
    singlePanel=createTogglePanelHeading(DAStudio.message(heading0,info.Name),ind);
    singlePanel.Items=cell(1,0);
    singlePanel.Expand=expandAll;
    [singlePanel,numInnerRows]=addListToPanel(singlePanel,info,heading1,heading2,heading3,numInnerRows);
    singlePanel.LayoutGrid=[numInnerRows,3];
end



function singlePanel=createNonTogglePanel(info,ind,expandAll,heading0,heading1,heading2,heading3)
    numInnerRows=0;
    singlePanel.Items=cell(1,0);
    singlePanel=addListToPanel(singlePanel,info,heading1,heading2,heading3,numInnerRows);
    singlePanel.ContentsMargins=[2,2,2,2];
    singlePanel.Spacing=10;

end




function heading=createHeadingRow(headingStr,row)


    heading=cell(1,3);

    heading{1}.Type='text';
    heading{1}.Name=' ';
    heading{1}.RowSpan=[row,row];
    heading{1}.ColSpan=[1,1];


    heading{2}.Name=headingStr;
    heading{2}.Type='text';
    heading{2}.RowSpan=[row,row];
    heading{2}.ColSpan=[2,2];
    heading{2}.Alignment=1;
    heading{2}.Bold=true;

    heading{3}.Type='text';
    heading{3}.Name=' ';
    heading{3}.RowSpan=[row,row];
    heading{3}.ColSpan=[3,3];

end



function blockLink=createBlockLinkRow(blkHandle,row)


    blockLink=cell(1,3);

    blockLink{1}.Type='text';
    blockLink{1}.Name=' ';
    blockLink{1}.RowSpan=[row,row];
    blockLink{1}.ColSpan=[1,1];


    blockLink{2}.Name=getfullname(blkHandle);
    blockLink{2}.Type='hyperlink';
    blockLink{2}.ObjectMethod='hiliteBlockCB';
    blockLink{2}.MethodArgs={blkHandle};
    blockLink{2}.ArgDataTypes={'double'};
    blockLink{2}.RowSpan=[row,row];
    blockLink{2}.ColSpan=[2,2];
    blockLink{2}.Alignment=1;

    blockLink{3}.Type='text';
    blockLink{3}.Name=' ';
    blockLink{3}.RowSpan=[row,row];
    blockLink{3}.ColSpan=[3,3];

end


function togglePanel=createTogglePanelHeading(stateName,row)



    togglePanel.Name=stateName;
    togglePanel.Type='togglepanel';
    togglePanel.RowSpan=[row,row];
    togglePanel.ColSpan=[1,3];
    togglePanel.Alignment=1;

end



function[accessorsList,innerRow]=addToAccessorsList(headingStr,accessors,innerRow)



    innerRow=innerRow+1;
    accessorsList={};
    accessorsList=[accessorsList,createHeadingRow(headingStr,innerRow)];

    for k=1:length(accessors)
        innerRow=innerRow+1;
        blkHandle=accessors(k);
        accessorsList=[accessorsList,createBlockLinkRow(blkHandle,innerRow)];
    end
end



function[accessorsList,innerRow]=addBlankRow(innerRow)

    innerRow=innerRow+1;
    accessorsList={};

    blankRow.Type='text';
    blankRow.Name=' ';
    blankRow.ColSpan=[1,3];
    blankRow.RowSpan=[innerRow,innerRow];
    accessorsList=[accessorsList,blankRow];
end


function[retPanel,numInnerRows]=addListToPanel(singlePanel,info,heading1,heading2,heading3,numInnerRows)


    [moreList,numInnerRows]=addBlankRow(numInnerRows);
    singlePanel.Items=[singlePanel.Items,moreList];

    if~isempty(info.ReaderBlocks)
        [moreList,numInnerRows]=addToAccessorsList(heading1,info.ReaderBlocks,numInnerRows);
        singlePanel.Items=[singlePanel.Items,moreList];
    end

    if~isempty(info.WriterBlocks)
        [moreList,numInnerRows]=addToAccessorsList(heading2,info.WriterBlocks,numInnerRows);
        singlePanel.Items=[singlePanel.Items,moreList];
    end

    if~isempty(info.StateflowSfunctions)
        [moreList,numInnerRows]=addToAccessorsList(heading3,info.StateflowSfunctions,...
        numInnerRows);
        singlePanel.Items=[singlePanel.Items,moreList];
    end

    [moreList,numInnerRows]=addBlankRow(numInnerRows);
    singlePanel.Items=[singlePanel.Items,moreList];

    retPanel=singlePanel;
end
