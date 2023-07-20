function grpCG=populateCodeGenWidgets(source,h,sigObjCache,options)





    rowIdx=1;


    if(~options.IgnoreNameWidget)
        txtStateID=create_widget(source,h,options.StateNamePrm,...
        rowIdx,0,3);


        txtStateID.Mode=1;

        txtStateID.DialogRefresh=true;
        txtStateID.Enabled=~h.isReadonlyProperty(options.StateNamePrm);
        rowIdx=rowIdx+1;
        groupItems={txtStateID};
    else
        groupItems={};
    end


    cbMustResolve=create_widget(source,h,'StateMustResolveToSignalObject',...
    rowIdx,0,3);
    cbMustResolve.Mode=1;
    cbMustResolve.DialogRefresh=true;

    cbMustResolve.Enabled=~isempty(h.(options.StateNamePrm))&&...
    ~h.isReadonlyProperty('StateMustResolveToSignalObject');

    signalResolutionControl=get_param(bdroot(h.Handle),'SignalResolutionControl');
    cbMustResolve.Visible=~isequal(signalResolutionControl,'None');

    groupItems=cat(2,groupItems,cbMustResolve);


    blkH=h.Handle;

    infoMap=get_param(bdroot(blkH),'StateAccessorInfoMap');

    if~isempty(infoMap)
        if(numel(infoMap.StateReaderBlockSet)>0)

            [stateReaderBlkHdls,stateReaderBlkNames]=getAvailableStateAccessorBlocks(blkH,'StateReader');
            if(~isempty(stateReaderBlkHdls))
                rowIdx=rowIdx+1;
                stateReaderBlks.Type='textbrowser';
                stateReaderBlks.Text=getRWBlksHTML(stateReaderBlkNames,stateReaderBlkHdls,true);
                stateReaderBlks.RowSpan=[rowIdx,rowIdx];
                stateReaderBlks.ColSpan=[1,3];
                stateReaderBlks.Tag='stateReaderBlks';
                groupItems=cat(2,groupItems,stateReaderBlks);
            end
        end

        if(numel(infoMap.StateWriterBlockSet)>0)

            [stateWriterBlkHdls,stateWriterBlkNames]=getAvailableStateAccessorBlocks(blkH,'StateWriter');
            if(~isempty(stateWriterBlkHdls))
                rowIdx=rowIdx+1;
                stateWriterBlks.Type='textbrowser';
                stateWriterBlks.Text=getRWBlksHTML(stateWriterBlkNames,stateWriterBlkHdls,false);
                stateWriterBlks.RowSpan=[rowIdx,rowIdx];
                stateWriterBlks.ColSpan=[1,3];
                stateWriterBlks.Tag='stateWriterBlks';
                groupItems=cat(2,groupItems,stateWriterBlks);
            end
        end
    end

    if(options.NeedSpacer)
        rowIdx=rowIdx+1;
        spacer.Name='';
        spacer.Type='text';
        spacer.RowSpan=[rowIdx,rowIdx];
        spacer.ColSpan=[1,3];
        groupItems=cat(2,groupItems,spacer);
    end

    grpCG.Items=groupItems;
    grpCG.ColStretch=[0,1,0];
    grpCG.RowStretch=[zeros(1,rowIdx-1),1];
    grpCG.LayoutGrid=[rowIdx,3];

end

function cscList_cmbbox_cb(dialog,cmbTag,source,h,cmbEntries)
    selectedItem=cmbEntries{dialog.getWidgetValue(cmbTag)+1};
    if~strcmp(h.getPropValue('StateStorageClass'),selectedItem)
        h.setPropValue('StateStorageClass',selectedItem);
    end
end

function fullClassname_cmbbox_cb(dialog,cmbTag,source,h,cmbEntries)
    selectedItem=cmbEntries{dialog.getWidgetValue(cmbTag)+1};
    oldVal=loc_comboboxIndexOfProp(h,'StateSignalObjectClass');
    if strcmp(selectedItem,DAStudio.message('Simulink:Signals:SIMULINK_OBJECT_LIST_CUSTOMIZE_MENU_ITEM'))
        dialog.setWidgetValue(cmbTag,oldVal);
    end

    if~strcmp(h.getPropValue('StateSignalObjectClass'),selectedItem)
        h.setPropValue('StateSignalObjectClass',selectedItem);
    end
end


function idx=loc_comboboxIndexOfProp(obj,prop)

    idx=0;
    cnt=0;
    values=configset.ert.getSigAttribFullClassList(obj.StateSignalObjectClass,true);
    value=get(obj,prop);
    for i=1:length(values)
        if strcmp(values{i},value)
            idx=cnt;
            return;
        end
        cnt=cnt+1;
    end
end




function[stateAccessorBlkHdls,stateAccessorBlkNames]=getAvailableStateAccessorBlocks(blkH,stateRW)
    mdl=bdroot(blkH);


    if(~strcmp(get_param(blkH,'BlockType'),'Memory'))


        availableStateAccessorBlks=find_system(mdl,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','BlockType',stateRW,'StateOwnerBlock',getfullname(blkH));
    else
        availableStateAccessorBlks={};
    end
    stateAccessorBlkHdls=cell(1,length(availableStateAccessorBlks));
    stateAccessorBlkNames=cell(1,length(availableStateAccessorBlks));
    for i=1:length(availableStateAccessorBlks)
        parentPath=get_param(availableStateAccessorBlks(i),'Parent');
        stateAccessorBlkHdls{i}=get_param(availableStateAccessorBlks(i),'Handle');
        stateAccessorBlkNames{i}=[parentPath,'/',get_param(availableStateAccessorBlks(i),'Name')];
    end
end





function html=getRWBlksHTML(RWBlks,RWBlksHandle,getStateReadBlks)
    if getStateReadBlks
        blkType='State Reader';
    else
        blkType='State Writer';
    end

    correspondingBlocks=DAStudio.message(...
    'Simulink:dialog:OtherStateAccessorBlocks',blkType);
    refreshBlockList=DAStudio.message('Simulink:dialog:DsmRwGuiRefresh');

    html=[...
'<html><body padding="0" spacing="0">'...
    ,'<table width="100%" cellpadding="0" cellspacing="0">'...
    ,'<tr><td align="left"><b>',correspondingBlocks,'</b></td>'...
    ,'<td align="right"><a href="ddgrefresh:eval('''')">'...
    ,refreshBlockList,'</a></td></tr>'...
    ];

    if~isempty(RWBlks)
        for i=1:numel(RWBlks)
            bHdlStr=sprintf('%15.14f',RWBlksHandle{i});
            html=[html,'<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'...
            ,'<a href="matlab:eval(''StateAccessor_ddg_cb(str2num(''''',bHdlStr,'''''), ''''hilite'''', str2num(''''',bHdlStr,'''''));'')">',RWBlks{i},'</a>'...
            ,'</td><td></td></tr>'];
        end
    end
    html=[html,'</table></body></html>'];
end

