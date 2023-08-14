function grpUnitProp=getUnitWidget(hDlgSource,unitPrompt,unitTag,unitVal,unitID)

    if isa(hDlgSource,'Stateflow.Data')==1
        c=sfprivate('getChartOf',hDlgSource.Id);
        blkH=sfprivate('chart2block',c);
        block=get_param(blkH,'Object');
    else
        block=hDlgSource.getBlock;
    end
    unitSystemsStr=getUnitSystemsString(block.handle);


    label.Type='text';
    label.Name=unitPrompt;
    label.Tag=[unitTag,'|UnitPrompt'];
    label.Buddy=unitTag;
    label.RowSpan=[1,1];
    label.ColSpan=[1,1];

    linkUnitSystems.Name=unitSystemsStr;
    linkUnitSystems.Type='hyperlink';
    linkUnitSystems.Tag=[unitTag,'|UnitLink'];
    linkUnitSystems.Enabled=true;
    linkUnitSystems.MatlabMethod='Simulink.UnitPrmWidget.openUnitConfiguratorDialog';
    linkUnitSystems.MatlabArgs={'%source'};
    linkUnitSystems.Alignment=7;
    linkUnitSystems.RowSpan=[1,1];
    linkUnitSystems.ColSpan=[2,2];

    editMain.Type='edit';
    editMain.Name='';
    editMain.Tag=unitTag;
    editMain.Value=unitVal;
    if isa(hDlgSource,'Stateflow.Data')==1
        editMain.Source=hDlgSource.Props.Unit;
        editMain.ObjectProperty='Name';
        editMain.ObjectMethod='getAutoCompleteData';
    else
        editMain.ObjectMethod='handleEditEvent';
    end
    editMain.MethodArgs={'%value',unitID,'%dialog'};
    editMain.ArgDataTypes={'mxArray','int32','handle'};
    editMain.NameLocation=1;
    editMain.AutoCompleteType='Custom';
    editMain.AutoCompleteViewColumn={' ',[DAStudio.message('Simulink:dialog:UnitsAutoCompleteViewColumnSymbolPrompt'),'                             '],...
    [DAStudio.message('Simulink:dialog:UnitsAutoCompleteViewColumnNamePrompt'),'                                               ']};
    editMain.AutoCompleteCompletionMode='UnfilteredPopupCompletion';
    editMain.RowSpan=[2,2];
    editMain.ColSpan=[1,2];

    grpUnitProp.Type='panel';
    grpUnitProp.Name='';
    grpUnitProp.Tag=[unitTag,'|UnitPanel'];
    grpUnitProp.LayoutGrid=[2,2];


    if strcmp(get_param(bdroot(block.handle),'BlockDiagramType'),'library')
        grpUnitProp.Items={label,editMain};
    else
        grpUnitProp.Items={label,linkUnitSystems,editMain};
    end

    grpUnitProp.RowSpan=[1,1];
    grpUnitProp.ColSpan=[1,1];
end

function unitSystemsStr=getUnitSystemsString(blockHandle)
    try
        unitSystems=Simulink.UnitConfiguratorBlockMgr.getUnitSystems(blockHandle);
        numUnitSystems=numel(unitSystems);
        if(numUnitSystems<=0)
            unitSystemsStr='...';
        elseif(numUnitSystems==1)
            unitSystemsStr=unitSystems(1).Name;
        elseif(numUnitSystems==2)
            unitSystemsStr=strjoin({unitSystems(1).Name,unitSystems(2).Name},', ');
        else
            unitSystemsStr=strjoin({unitSystems(1).Name,unitSystems(2).Name},', ');
            unitSystemsStr=[unitSystemsStr,', ...'];
        end
    catch
        unitSystemsStr='...';
    end
end
