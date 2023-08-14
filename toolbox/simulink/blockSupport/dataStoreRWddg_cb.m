
function varargout=dataStoreRWddg_cb(blkH,action,varargin)





    h=get_param(blkH,'object');

    blockHandles=[];
    blockNames={};

    if strcmp(h.BlockType,'DataStoreMemory')
        if~isempty(h.DSReadWriteBlocks)
            blockHandles=[h.DSReadWriteBlocks(:).handle];
            blockNames={h.DSReadWriteBlocks(:).name};
        end
    else
        if(slprivate('is_stateflow_based_block',h.handle)||slprivate('is_matlab_system_block',h.handle))
            blockHandles=[h.handle];
            blockNames={h.name};
        elseif~isempty(h.DSReadOrWriteSource)
            blockHandles=[h.DSReadOrWriteSource(:).handle];
            blockNames={h.DSReadOrWriteSource(:).name};
        end
    end

    [~,isLocked]=h.getDialogSource.isLibraryBlock(blkH);

    switch action
    case 'sync'
        source=varargin{1};
        dlg=varargin{2};
        widget=varargin{3};
        tag=varargin{4};
        if~isLocked
            set_param(blkH,'DataStoreNameInDialog',dlg.getWidgetValue(tag));
            try
                [~]=h.DSReadOrWriteSource;
            catch ME
                set_param(blkH,'DataStoreNameInDialog','');
                throwAsCaller(ME);
            end
        end
        slDialogUtil(source,'sync',dlg,widget,tag);
        dlg.refresh;

    case 'hilite'
        block=varargin{1};
        blockH=get_param(block,'Handle');
        unhiliteCB=@()dataStoreRWddg_cb(blkH,'unhilite',[blockHandles,blockH]);
        studioHighlight_cb('hilite',blockH,unhiliteCB,varargin{2});

    case 'unhilite'
        if nargin>2
            blockHandles=varargin{1};
        end
        hiliting=char(get_param(blockHandles,'HiliteAncestors'));
        found=strmatch('find',hiliting);
        if~isempty(found)&&~isLocked
            for idx=1:numel(found)
                ind=found(idx);
                set_param(blockHandles(ind),'HiliteAncestors','none');
            end
        end

    case 'doClose'
        dlg=varargin{1};
        source=dlg.getDialogSource;
        source.UserData=[];
        if~isLocked
            set_param(blkH,'DataStoreNameInDialog','');
        end
        dataStoreRWddg_cb(blkH,'unhilite');

    case 'getTreeItems'
        [varargout{1},varargout{2},varargout{3}]=getTreeItems(blkH);

    case 'getListItems'
        varargout{1}=getListItems(blkH,varargin{1});

    case 'getDSMemBlkEntries'
        varargout{1}=getDSMemBlkEntries(blkH);

    case 'getRWBlksHTML'
        varargout{1}=getRWBlksHTML(blkH,blockNames,blockHandles);

    case 'findMemBlk'
        dsmName=get_param(blkH,'DataStoreNameInDialog');
        if isempty(dsmName)
            dsmName=get_param(blkH,'DataStoreName');
        end
        dsmSrc=findMatchingDSMemBlock(blkH,dsmName);
        varargout{1}=strrep(dsmSrc,newline,' ');

    case 'doRefresh'
        dlg=varargin{1};
        dlg.refresh;

    case 'doTreeSelection'
        dlg=varargin{1};
        treePath=dlg.getWidgetValue(varargin{2});
        widgetToSet=varargin{3};
        doTreeSelection(dlg,treePath,widgetToSet);

    case 'doListSelection'
        dlg=varargin{1};
        listWidgetTag=varargin{2};
        doEnableDisableWidgets(dlg,listWidgetTag);

    case 'doMove'
        dlg=varargin{1};
        listWidgetTag=varargin{2};
        direction=varargin{3};
        source=dlg.getDialogSource;
        selectedIdx=dlg.getWidgetValue(listWidgetTag);
        assert(~isempty(selectedIdx));
        ud=dlg.getUserData(listWidgetTag);
        if strcmp(direction,'up')
            if min(selectedIdx)<=0


                return;
            end
            newSelectedIdx=selectedIdx-1;
            for idx=1:length(selectedIdx)
                sIdx=selectedIdx(idx)+1;
                ud([sIdx-1,sIdx])=ud([sIdx,sIdx-1]);
            end
        else
            if max(selectedIdx)>=length(ud)-1


                return;
            end
            newSelectedIdx=selectedIdx+1;
            for idx=1:length(selectedIdx)
                sIdx=selectedIdx(idx)+1;
                ud([sIdx,sIdx+1])=ud([sIdx+1,sIdx]);
            end
        end
        source.state.DataStoreElements=cellarr2str(ud);
        dlg.setUserData(listWidgetTag,ud);
        dlg.setWidgetValue(listWidgetTag,[]);
        dlg.refresh;
        dlg.setWidgetValue(listWidgetTag,newSelectedIdx);
        doEnableDisableWidgets(dlg,listWidgetTag);
    case 'doRemove'
        dlg=varargin{1};
        listWidgetTag=varargin{2};
        selectedIdx=dlg.getWidgetValue(listWidgetTag);
        if isempty(selectedIdx)


            return;
        end
        newSelectedIndex=selectedIdx;
        selectedIdx=selectedIdx+1;
        source=dlg.getDialogSource;
        ud=dlg.getUserData(listWidgetTag);
        ud(selectedIdx)=[];
        source.state.DataStoreElements=cellarr2str(ud);
        dlg.setUserData(listWidgetTag,ud);
        if~isempty(ud)
            for idx=1:length(newSelectedIndex)
                if(newSelectedIndex(idx)>length(ud)-1)
                    newSelectedIndex(idx)=length(ud)-1;
                end
            end
            dlg.setWidgetValue(listWidgetTag,unique(newSelectedIndex));
        end
        dlg.refresh;
        doEnableDisableWidgets(dlg,listWidgetTag);

    case 'addToOutputList'
        dlg=varargin{1};
        textWidgetTag=varargin{2};
        listWidgetTag=varargin{3};
        try
            addToOutputList(blkH,dlg,textWidgetTag,listWidgetTag);
        catch me
            throwAsCaller(me);
        end
        doEnableDisableWidgets(dlg,listWidgetTag);

    case 'doPreApply'
        dlg=varargin{1};
        source=dlg.getDialogSource;
        elementSignals=clean(str2cellarr(source.state.DataStoreElements));
        rwElements=cellarr2str(elementSignals);

        dlg.setWidgetValue('DataStoreElements',rwElements);

        if(slfeature('DynamicIndexingDataStore')>0)
            [varargout{1},varargout{2}]=indexingPreApplyCallback(source,dlg);
            if varargout{1}==0
                return;
            end
        end

        [varargout{1},varargout{2}]=source.preApplyCallback(dlg);

        dlg.refresh;
        if~isLocked
            try




                set_param(blkH,'DataStoreNameInDialog','');
            catch me
                varargout{1}=0;
                varargout{2}=me.message;
                return;
            end
        end

    case 'NumDimsCallback'
        dlg=varargin{1};
        source=dlg.getDialogSource;
        doNumDimsCallback(source,dlg,varargin{2});

    case 'IndexModeCallback'
        dlg=varargin{1};
        source=dlg.getDialogSource;
        doIndexModeCallback(source,dlg,varargin{2});

    case 'EnableIndexCallback'
        dlg=varargin{1};
        source=dlg.getDialogSource;
        doEnableIndexCallback(source,dlg,varargin{2});

    case 'CheckScopeDSMCallback'

        if slfeature('ScopedDSM')>0
            assert(strcmp(h.BlockType,'DataStoreMemory'));
            dlg=varargin{1};
            source=dlg.getDialogSource;
            tag=varargin{2};
            widgetVal=varargin{3};

            isDataStoreRef=(widgetVal==1);


            dlg.setEnabled('InitialValue',~isDataStoreRef);
            dlg.setEnabled('OutMin',~isDataStoreRef);
            dlg.setEnabled('OutMax',~isDataStoreRef);
            dlg.setEnabled('tab1',~isDataStoreRef);
            dlg.setEnabled('DiagTab',~isDataStoreRef);

            dlg.setVisible('InitialValue',~isDataStoreRef);
            dlg.setVisible('OutMin',~isDataStoreRef);
            dlg.setVisible('OutMax',~isDataStoreRef);
            dlg.setVisible('tab1',~isDataStoreRef);
            dlg.setVisible('DiagTab',~isDataStoreRef);

            slDDGUtil(source,'sync',dlg,'combobox',tag,widgetVal);
        end

    otherwise
        assert(false,'Unexpected action');
    end

    function doEnableDisableWidgets(dlg,listWidgetTag)

        selectedIdx=dlg.getWidgetValue(listWidgetTag);
        ud=dlg.getUserData(listWidgetTag);
        if isempty(selectedIdx)
            dlg.setEnabled('upButton',0);
            dlg.setEnabled('downButton',0);
            dlg.setEnabled('removeButton',0);
        else

            dlg.setEnabled('removeButton',1);
            selectedIdx=selectedIdx+1;

            down=true;
            up=true;
            if max(selectedIdx)==length(ud)
                down=false;
            end
            if min(selectedIdx)==1
                up=false;
            end
            dlg.setEnabled('downButton',down);
            dlg.setEnabled('upButton',up);
        end




        function html=getRWBlksHTML(blkH,RWBlks,RWBlksHandle)
            if strcmp(get_param(blkH,'BlockType'),'DataStoreRead')
                blkType='Data Store Write';
            elseif strcmp(get_param(blkH,'BlockType'),'DataStoreMemory')
                blkType='Data Store Read/Write';
            else
                blkType='Data Store Read';
            end
            correspondingBlocks=DAStudio.message('Simulink:dialog:DsmRwGuiCorrespondingBlocks',blkType);
            refreshBlockList=DAStudio.message('Simulink:dialog:DsmRwGuiRefresh');
            html=[...
'<html><body padding="0" spacing="0">'...
            ,'<table width="100%" cellpadding="0" cellspacing="0">'...
            ,'<tr><td align="left"><b>',correspondingBlocks,'</b></td>'...
            ,'<td align="right"><a href="ddgrefresh:eval('''')">'...
            ,refreshBlockList,'</a></td></tr>'...
            ];
            if~isempty(RWBlks)
                optBlockPathArgs=studioHighlight_cb('getBlockPathHandlesAsString',gcbp);

                for i=1:length(RWBlks)
                    bHdlStr=studioHighlight_cb('getStringForHandle',RWBlksHandle(i));
                    RWBlksHandleString{i}=bHdlStr;%#ok

                    exprString=['''dataStoreRWddg_cb(str2num(''''',...
                    bHdlStr,...
                    '''''),''''hilite'''', str2num(''''',...
                    bHdlStr,...
                    '''''), ',...
                    optBlockPathArgs,...
                    ');'''];

                    html=[html,'<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'...
                    ,'<a href="matlab:eval(',exprString,')">',rtwprivate('rtwhtmlescape',RWBlks{i}),'</a>'...
                    ,'</td><td></td></tr>'];%#ok
                end
            end
            html=[html,'</table></body></html>'];




            function entries=getDSMemBlkEntries(blkH)
                model=bdroot(blkH);


                dsBlks=find_system(model,'LookUnderMasks','on',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'FollowLinks','on','BlockType','DataStoreMemory');

                entries={};
                modelWS=get_param(model,'ModelWorkspace');

                if~isempty(modelWS)

                    allVarsInWks=modelWS.data;
                    for idx=1:length(allVarsInWks)
                        if isa(allVarsInWks(idx).Value,'Simulink.Signal')
                            entries{end+1}=allVarsInWks(idx).Name;%#ok
                        end
                    end
                end


                ddName=get_param(model,'DataDictionary');
                if isempty(ddName)
                    allVarsInWks=evalin('base','who');
                    for idx=1:length(allVarsInWks)
                        varName=allVarsInWks{idx};
                        if evalinGlobalScope(model,['isa(',varName,', ''Simulink.Signal'')'])
                            entries{end+1}=varName;%#ok
                        end
                    end
                else
                    try
                        dd=Simulink.dd.open(ddName);
                    catch E %#ok

                        dd=[];
                    end

                    if~isempty(dd)
                        entries=cat(2,entries,...
                        dd.getEntriesWithClass('Design_Data','Simulink.Signal')');


                        if slfeature('SLModelAllowedBaseWorkspaceAccess')>0&&...
                            strcmp(get_param(model,'HasAccessToBaseWorkspace'),'on')
                            allVarsInWks=evalin('base','who')';
                            for idx=length(allVarsInWks):-1:1
                                varName=allVarsInWks{idx};
                                if evalin('base',['~isa(',varName,', ''Simulink.Signal'')'])
                                    allVarsInWks(idx)=[];
                                end
                            end
                            entries=cat(2,entries,allVarsInWks);
                        end

                    end

                end
                entries=unique(entries);

                if isempty(dsBlks)
                    if isempty(entries)
                        entries={''};
                    end
                else
                    dsBlkNames={};
                    for idx=1:length(dsBlks)
                        dsBlkNames{end+1}=get_param(dsBlks(idx),'DataStoreName');%#ok
                    end
                    entries=[dsBlkNames,entries];
                end
                entries=unique(entries);



                function dsmBlk=findMatchingDSMemBlock(blk,dsName)
                    dsmBlk=find_system(get_param(blk,'Parent'),...
                    'SearchDepth',1,...
                    'BlockType','DataStoreMemory',...
                    'DataStoreName',dsName);
                    if~isempty(dsmBlk)
                        dsmBlk=dsmBlk{1};
                    else
                        blk=get_param(blk,'Parent');
                        if(~strcmp(get_param(blk,'Type'),'block_diagram'))
                            dsName=Simulink.mapDataStoreName(blk,dsName);
                            if~strcmp(bdroot(blk),blk)
                                dsmBlk=findMatchingDSMemBlock(blk,dsName);
                            end
                        end
                    end


                    function newTreePath=processTreePath(treePath)
                        treePath=regexprep(treePath,'\s\[-1\]','');
                        treePath=regexprep(treePath,'\s\[','(');
                        treePath=regexprep(treePath,'\]',')');
                        treePath=regexprep(treePath,'/','.');
                        treePath=regexprep(treePath,'/','.');
                        treePath=regexprep(treePath,'(\d+\s*),','$1,');

                        newTreePath='';
                        rs=regexp(treePath,'\.','split');
                        if~isempty(regexp(rs{end},'\(.*\)','once'))
                            tempSelection=rs{end}(regexp(rs{end},'\(.*\)'):end);
                            tempSelection=regexprep(tempSelection,'\d*',':');
                            rs{end}=regexprep(rs{end},'\(.*\)',tempSelection);
                            for idx=1:length(rs)
                                if idx==1
                                    newTreePath=rs{idx};
                                else
                                    newTreePath=[newTreePath,'.',rs{idx}];%#ok
                                end
                            end
                        else
                            newTreePath=treePath;
                        end


                        function doTreeSelection(dlg,treePath,widgetToSet)
                            if isempty(treePath)
                                dlg.setEnabled(widgetToSet,0);
                                dlg.setWidgetValue(widgetToSet,'');
                            else
                                dlg.setEnabled(widgetToSet,1);
                                newTreePath=treePath;
                                widgetValueToSet='';
                                for idx=1:length(treePath)
                                    newTreePath{idx}=processTreePath(treePath{idx});
                                    if idx==1
                                        widgetValueToSet=newTreePath{idx};
                                    else
                                        widgetValueToSet=[widgetValueToSet,getSeparator(),newTreePath{idx}];%#ok
                                    end
                                end
                                dlg.setWidgetValue(widgetToSet,widgetValueToSet);
                            end



                            function addToOutputList(blk,dlg,textWidget,listWidget)

                                widgetValue=dlg.getWidgetValue(textWidget);
                                if~isempty(widgetValue)
                                    [regionDesc,editedEntries,leafBusObjectNames]=slprivate('validateDataStoreRWElements',...
                                    blk,str2cellarr(widgetValue),true,getInvalidEntryPrefix());

                                    assert(iscell(regionDesc)&&iscell(editedEntries)&&iscell(leafBusObjectNames));
                                    assert(length(regionDesc)==length(editedEntries));
                                    assert(length(regionDesc)==length(leafBusObjectNames));
                                    source=dlg.getDialogSource;
                                    for idx=1:length(editedEntries)
                                        if~isempty(source.state.DataStoreElements)
                                            source.state.DataStoreElements=[source.state.DataStoreElements,getSeparator(),editedEntries{idx}];
                                        else
                                            source.state.DataStoreElements=editedEntries{idx};
                                        end
                                    end
                                    dlg.setUserData(listWidget,str2cellarr(source.state.DataStoreElements));
                                    dlg.refresh;
                                end


                                function[treeItems,treeData,unbounded]=getTreeItems(blk)

                                    treeData=get_param(blk,'DSMemoryLayout');

                                    source=get_param(blk,'Object').getDialogSource;
                                    if(isempty(treeData))
                                        treeData=source.state.DSMemoryLayout;
                                    else
                                        source.state.DSMemoryLayout=treeData;
                                    end

                                    assert(isstruct(treeData));
                                    [treeItems,unbounded]=getTreeItemsFromLayout(treeData);


                                    function entries=getListItems(blk,sourceState)

                                        entries=str2cellarr(sourceState);
                                        if~isempty(entries)
                                            [~,entries,~]=slprivate('validateDataStoreRWElements',blk,entries,true,getInvalidEntryPrefix());
                                        end


                                        function[treeItems,unbounded]=getTreeItemsFromLayout(memLayout)

                                            unbounded=false;
                                            childTreeItems={};
                                            rootTreeItems=memLayout.('Name');
                                            dims=memLayout.('Dimensions');
                                            if~isempty(dims)&&~isequal(dims,ones(1,length(dims)))
                                                for idx=length(dims)


                                                    if dims(idx)==intmax-1
                                                        unbounded=true;
                                                    end
                                                end
                                                if length(dims)>1
                                                    newItem=regexprep(mat2str(dims),' ',',');
                                                    newItem=regexprep(newItem,'\[',' \[');
                                                    rootTreeItems=[rootTreeItems,newItem];
                                                else
                                                    rootTreeItems=[rootTreeItems,' [',num2str(dims),']'];
                                                end
                                            end
                                            for idx=1:length(memLayout.('Children'))
                                                [childItems,childUnbounded]=...
                                                getTreeItemsFromLayout(memLayout.('Children')(idx));%#ok
                                                childTreeItems=[childTreeItems,childItems];%#ok
                                                if childUnbounded
                                                    unbounded=true;
                                                end
                                            end
                                            treeItems=[rootTreeItems,{childTreeItems}];

                                            function sep=getSeparator()

                                                sep='#';

                                                function prefix=getInvalidEntryPrefix()

                                                    prefix='??? ';



                                                    function cellarr=str2cellarr(str)
                                                        cellarr={};
                                                        [name,str]=strtok(str,getSeparator());
                                                        if~isempty(name)
                                                            cellarr{end+1}=name;
                                                        end
                                                        if~isempty(str)
                                                            cellarr=[cellarr,str2cellarr(str)];
                                                        end



                                                        function str=cellarr2str(signalArray)

                                                            str='';
                                                            if~isempty(signalArray)
                                                                sep='';
                                                                for i=1:length(signalArray)
                                                                    sig=char(signalArray{i});
                                                                    str=[str,sep,sig];%#ok
                                                                    sep=getSeparator();
                                                                end
                                                            end


                                                            function newStr=removeDimensionStr(str)
                                                                startposVec=findstr(str,'(');
                                                                endposVec=findstr(str,')');
                                                                numPairs=length(startposVec);
                                                                currIdx=1;
                                                                newStr='';
                                                                for i=1:numPairs
                                                                    newStr=[newStr,str(currIdx:startposVec(i)-1)];
                                                                    currIdx=endposVec(i)+1;
                                                                end
                                                                if currIdx<length(str)
                                                                    newStr=[newStr,str(currIdx:end)];
                                                                end


                                                                function result=isNumDimsValid(numDimsVal)

                                                                    result=~isnan(numDimsVal)&&...
                                                                    length(numDimsVal)==1&&...
                                                                    numDimsVal>0&&...
                                                                    floor(numDimsVal)==numDimsVal;

                                                                    function[status,errmsg]=indexingPreApplyCallback(source,dlg)





                                                                        block=source.getBlock;


                                                                        set_param_cmd='set_param(block.Handle';
                                                                        restore_param_cmd='set_param(block.Handle';
                                                                        numChanges=0;





                                                                        oldEnableIndex=get_param(block.Handle,'EnableIndexing');
                                                                        if source.UserData.EnableIndex==1
                                                                            newEnableIndex='on';
                                                                        else
                                                                            newEnableIndex='off';
                                                                        end


                                                                        if isequal(oldEnableIndex,'off')&&isequal(newEnableIndex,'off')
                                                                            status=1;
                                                                            errmsg='';
                                                                            return;
                                                                        end

                                                                        if~isequal(oldEnableIndex,newEnableIndex)
                                                                            set_param_cmd=[set_param_cmd,',''EnableIndexing'',''',newEnableIndex,''''];
                                                                            restore_param_cmd=[restore_param_cmd,',''EnableIndexing'',''',oldEnableIndex,''''];
                                                                            numChanges=numChanges+1;
                                                                        end







                                                                        if source.UserData.EnableIndex
                                                                            treeVal=dlg.getWidgetValue('memoryTree');
                                                                            if isempty(treeVal)
                                                                                status=0;
                                                                                errmsg=DAStudio.message('Simulink:blocks:DSMDataStoreElementNotSelected');
                                                                                return;
                                                                            end
                                                                            newDataStoreElements=processTreePath(treeVal);
                                                                            newDataStoreElements=removeDimensionStr(newDataStoreElements);
                                                                        else
                                                                            newDataStoreElements=source.state.DataStoreElements;
                                                                        end

                                                                        oldDataStoreElements=get_param(block.Handle,'DataStoreElements');
                                                                        if~isequal(oldDataStoreElements,newDataStoreElements)
                                                                            set_param_cmd=[set_param_cmd,',''DataStoreElements'',''',newDataStoreElements,''''];
                                                                            restore_param_cmd=[restore_param_cmd,',''DataStoreElements'',''',oldDataStoreElements,''''];
                                                                            numChanges=numChanges+1;
                                                                        end





                                                                        oldIndexModeVal=get_param(block.Handle,'IndexMode');
                                                                        newIndexModeVal=source.UserData.IndexMode;
                                                                        if~isequal(oldIndexModeVal,newIndexModeVal)
                                                                            set_param_cmd=[set_param_cmd,',''IndexMode'',''',newIndexModeVal,''''];
                                                                            restore_param_cmd=[restore_param_cmd,',''IndexMode'',''',oldIndexModeVal,''''];
                                                                            numChanges=numChanges+1;
                                                                        end





                                                                        newNumDims=num2str(source.UserData.NumDims);
                                                                        oldNumDims=get_param(block.Handle,'NumberOfDimensions');

                                                                        newNumDimsVal=str2double(newNumDims);
                                                                        oldNumDimsVal=str2double(oldNumDims);

                                                                        if~isequal(oldNumDims,newNumDims)
                                                                            set_param_cmd=[set_param_cmd,',''NumberOfDimensions'',''',newNumDims,''''];
                                                                            restore_param_cmd=[restore_param_cmd,',''NumberOfDimensions'',''',oldNumDims,''''];
                                                                            numChanges=numChanges+1;
                                                                        end





                                                                        if isNumDimsValid(newNumDimsVal)
                                                                            mxArrayParams={'IndexOptionArray','IndexParamArray','OutputSizeArray'};


                                                                            for col=1:length(mxArrayParams)
                                                                                oldTblData.(mxArrayParams{col})=get_param(block.Handle,mxArrayParams{col});
                                                                            end

                                                                            newTblData=struct;
                                                                            for col=1:length(mxArrayParams)
                                                                                newTblData.(mxArrayParams{col})=cell(1,newNumDimsVal);
                                                                                for row=1:newNumDimsVal
                                                                                    tblItem=source.UserData.DimPropTableData{row,col};
                                                                                    if col==1
                                                                                        switch(tblItem.Value)
                                                                                        case 0
                                                                                            strValue='Select all';
                                                                                        case 1
                                                                                            strValue='Index vector (dialog)';
                                                                                        case 2
                                                                                            strValue='Index vector (port)';
                                                                                        case 3
                                                                                            strValue='Starting index (dialog)';
                                                                                        case 4
                                                                                            strValue='Starting index (port)';
                                                                                        otherwise
                                                                                            strValue='Invalid Option';
                                                                                        end
                                                                                    else
                                                                                        strValue=tblItem.Value;
                                                                                    end

                                                                                    newTblData.(mxArrayParams{col}){row}=strValue;
                                                                                end
                                                                            end
                                                                            newTblData.IndexOptionArray=newTblData.IndexOptionArray';
                                                                            newTblData.IndexParamArray=newTblData.IndexParamArray';
                                                                            newTblData.OutputSizeArray=newTblData.OutputSizeArray';

                                                                            for col=1:length(mxArrayParams)
                                                                                if~isequal(oldTblData.(mxArrayParams{col})(1:oldNumDimsVal),...
                                                                                    newTblData.(mxArrayParams{col})(1:newNumDimsVal))
                                                                                    set_param_cmd=...
                                                                                    [set_param_cmd,',''',mxArrayParams{col},''', newTblData.'...
                                                                                    ,(mxArrayParams{col}),'(1:',newNumDims,')'];%#ok<AGROW>
                                                                                    restore_param_cmd=...
                                                                                    [restore_param_cmd,',''',mxArrayParams{col},''', oldTblData.'...
                                                                                    ,(mxArrayParams{col}),'(1:',oldNumDims,')'];%#ok<AGROW>
                                                                                    numChanges=numChanges+1;
                                                                                end
                                                                            end
                                                                        end

                                                                        set_param_cmd=[set_param_cmd,')'];
                                                                        restore_param_cmd=[restore_param_cmd,')'];

                                                                        status=1;
                                                                        errmsg='';
                                                                        if numChanges>0
                                                                            try

                                                                                eval(set_param_cmd);
                                                                                if source.UserData.EnableIndex
                                                                                    source.state.DataStoreElements=newDataStoreElements;
                                                                                end
                                                                            catch
                                                                                err=sllasterror;
                                                                                status=0;
                                                                                errmsg=err.Message;


                                                                                try
                                                                                    eval(restore_param_cmd);
                                                                                catch
                                                                                end
                                                                            end
                                                                        end


                                                                        function doNumDimsCallback(source,dlg,tag)



                                                                            block=source.getBlock;
                                                                            oldNumDims=source.UserData.LastValidNumDims;
                                                                            numDims=str2double(dlg.getWidgetValue(tag));

                                                                            source.UserData.NumDims=numDims;

                                                                            if isNumDimsValid(numDims)
                                                                                source.UserData.LastValidNumDims=numDims;

                                                                                refreshFlag=~isequal(oldNumDims,numDims);
                                                                            else
                                                                                refreshFlag=false;
                                                                            end

                                                                            if refreshFlag
                                                                                if numDims>oldNumDims
                                                                                    for i=oldNumDims+1:numDims



                                                                                        col1.Type='combobox';
                                                                                        col1.Entries=source.getBlock.getPropAllowedValues('IdxOptString');
                                                                                        col1.Value=1;
                                                                                        source.UserData.DimPropTableData{i,1}=col1;


                                                                                        col2.Type='edit';
                                                                                        col2.Alignment=6;
                                                                                        col2.Value='1';
                                                                                        col2.Enabled=~ismember(col1.Value,[0,2,4]);
                                                                                        source.UserData.DimPropTableData{i,2}=col2;


                                                                                        col3.Type='edit';
                                                                                        col3.Alignment=6;
                                                                                        col3.Value='1';
                                                                                        blockType=get_param(block.Handle,'BlockType');
                                                                                        if(isequal(blockType,'DataStoreRead'))

                                                                                            col3.Enabled=~ismember(col1.Value,[0,1,2]);
                                                                                        elseif(isequal(blockType,'DataStoreWrite'))

                                                                                            col3.Enabled=~ismember(col1.Value,[0,1,2,3,4]);
                                                                                        end
                                                                                        source.UserData.DimPropTableData{i,3}=col3;
                                                                                    end
                                                                                end

                                                                                dlg.refresh;
                                                                            end

                                                                            function doIndexModeCallback(source,dlg,tag)


                                                                                oldIndexModeVal=source.UserData.IndexMode;
                                                                                indexMode=dlg.getWidgetValue(tag);
                                                                                entries=source.getBlock.getPropAllowedValues('IndexMode');
                                                                                indexModeVal=entries{indexMode+1};


                                                                                refreshFlag=~isequal(oldIndexModeVal,indexModeVal);

                                                                                if refreshFlag
                                                                                    source.UserData.IndexMode=indexModeVal;
                                                                                    dlg.refresh;
                                                                                end

                                                                                function doEnableIndexCallback(source,dlg,tag)


                                                                                    oldEnableIndex=source.UserData.EnableIndex;
                                                                                    enableIndex=dlg.getWidgetValue(tag);


                                                                                    refreshFlag=~isequal(oldEnableIndex,enableIndex);

                                                                                    if refreshFlag
                                                                                        source.UserData.EnableIndex=enableIndex;
                                                                                        dlg.refresh;
                                                                                    end



                                                                                    function modArray=clean(inArray)


                                                                                        if isempty(inArray)
                                                                                            modArray=inArray;
                                                                                        else
                                                                                            modArray=strrep(inArray,'??? ','');
                                                                                        end


