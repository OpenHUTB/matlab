function varargout=StateAccessor_ddg_cb(blkH,action,varargin)




    h=get_param(blkH,'object');


    stateRdBlkHdls=[];
    stateRdBlkNames={};


    stateWrBlkHdls=[];
    stateWrBlkNames={};

    if strcmp(h.BlockType,'StateReader')||strcmp(h.BlockType,'StateWriter')


        relatedStateReadBlocks=h.ComputedStateAccessorInfo.relatedStateReadBlocks;
        relatedStateWriteBlocks=h.ComputedStateAccessorInfo.relatedStateWriteBlocks;
        if~isempty(relatedStateReadBlocks)
            stateRdBlkHdls=[relatedStateReadBlocks(:).handle];
            stateRdBlkNames={relatedStateReadBlocks(:).name};
        end
        if~isempty(relatedStateWriteBlocks)
            stateWrBlkHdls=[relatedStateWriteBlocks(:).handle];
            stateWrBlkNames={relatedStateWriteBlocks(:).name};
        end
    else

    end

    [~,isLocked]=h.getDialogSource.isLibraryBlock(blkH);

    switch action

    case 'hilite'
        block=varargin{1};
        if slfeature('AccessingMultipleStatesBlocks')>=1&&ischar(block)&&~check_block_exists(block)
            [block,~]=fileparts(block);
        end


        unhiliteFcn=@()loc_unhiliteBlocks(block,blkH,stateRdBlkHdls,stateWrBlkHdls,h,isLocked);
        studioHighlight_cb('hilite',block,unhiliteFcn,varargin{2});

    case 'unhilite'

        if nargin>2
            stateRdBlkHdls=varargin{1};
        end
        hiliting=get_param(stateRdBlkHdls,'HiliteAncestors');
        ind=find(strncmp(hiliting,'find',4));
        if~isempty(ind)&&~isLocked
            for k=1:length(ind)
                set_param(stateRdBlkHdls(ind(k)),'HiliteAncestors','none');
            end
        end

    case 'doClose'
        dlg=varargin{1};
        StateAccessor_ddg_cb(blkH,'unhilite');
        refreshDlgAndSetValue(dlg)

    case 'getStateReadBlksHTML'
        varargout{1}=getRWBlksHTML(blkH,stateRdBlkNames,stateRdBlkHdls,true);

    case 'getStateWriteBlksHTML'
        varargout{1}=getRWBlksHTML(blkH,stateWrBlkNames,stateWrBlkHdls,false);

    case 'doRefresh'
        dlg=varargin{1};
        refreshDlgAndSetValue(dlg)
    case 'doPostApply'
        dlg=varargin{1};
        refreshDlgAndSetValue(dlg)
        varargout={true,''};
    case 'doPreApply'
        dlg=varargin{1};
        source=dlg.getDialogSource;

        if slfeature('ParameterWriteToGeneralBlocks')>=2
            [stateNotSet,selStateOwner]=checkOwnerNoSelectState(dlg);
            if stateNotSet
                errMsg=DAStudio.message('Simulink:blocks:StateReadWriteBlockStateNameNotSet',selStateOwner);
                varargout={false,errMsg};
                return;
            end
        end

        if slfeature('AccessingMultipleStatesBlocks')>=1
            exist_blk=check_block_exists(source.UDTSOSobj.SelectedStateOwner);
        else
            exist_blk=check_block_exists(source.UDTSOSobj.TreeSelectedItem);
        end
        if~exist_blk
            source.UDTerrSelectorTree=true;
        else
            try
                if slfeature('AccessingMultipleStatesBlocks')>=1
                    selStateOwner=source.UDTSOSobj.SelectedStateOwner;
                    selStateName=source.UDTSOSobj.SelectedOwnerState;
                    if(strcmp(get_param(selStateOwner,'BlockType'),'SecondOrderIntegrator')&&strlength(selStateName)>=10&&strcmp(selStateName(1:10),'Name state'))
                        dlg.enableApplyButton(false);
                        DAStudio.error('Simulink:blocks:StateUnnamedForMulStatesBlks',selStateOwner);
                        return;
                    end
                    if strcmp(selStateName,'<default>')
                        selStateName='';
                    end
                    set_param(blkH,'StateOwnerBlock',selStateOwner);
                    set_param(blkH,'AccessedStateName',selStateName);
                else
                    set_param(blkH,'StateOwnerBlock',source.UDTSOSobj.TreeSelectedItem);
                end
            catch ME
                varargout={false,ME.message};
                return;
            end
        end
        refreshDlgAndSetValue(dlg)

        if source.UDTerrSelectorTree==true
            varargout=getBlockDiagramChangedError();
        else
            [varargout{1},varargout{2}]=source.preApplyCallback(dlg);
        end

    case 'selectionTree'
        SOSobj=varargin{1};
        val=varargin{2};
        dlg=varargin{3};

        source=dlg.getDialogSource;
        source.UDTerrSelectorTree=false;



        if~(strcmp(SOSobj.TreeModel{1}.DisplayLabel,DAStudio.message('Simulink:blocks:StateReadWriteOwnSelectorTreeEmpty')))





            exist_blk=check_block_exists(val);
            if~exist_blk

                if slfeature('AccessingMultipleStatesBlocks')>=1
                    [val,stateName]=fileparts(val);
                    exist_blk=check_block_exists(val);
                    if~exist_blk
                        source.UDTerrSelectorTree=true;
                    else
                        if SOSobj.isValidStateOwnerBlock(get_param(val,'Object'))
                            SOSobj.TreeSelectedItem=varargin{2};
                            SOSobj.SelectedStateOwner=val;
                            SOSobj.SelectedOwnerState=stateName;
                        else





                            if~isempty(SOSobj.TreeSelectedItem)&&~check_block_exists(SOSobj.TreeSelectedItem)
                                source.UDTerrSelectorTree=true;
                            end
                        end
                    end
                else
                    source.UDTerrSelectorTree=true;
                end
            else
                if slfeature('AccessingMultipleStatesBlocks')==0
                    if SOSobj.isValidStateOwnerBlock(get_param(val,'Object'))
                        SOSobj.TreeSelectedItem=val;
                    else





                        if~isempty(SOSobj.TreeSelectedItem)&&~check_block_exists(SOSobj.TreeSelectedItem)
                            source.UDTerrSelectorTree=true;
                        end
                    end
                else
                    if(SOSobj.isValidStateOwnerBlock(get_param(val,'Object'))&&...
                        length(getBlockStateName(val))<2)
                        SOSobj.TreeSelectedItem=val;
                        SOSobj.SelectedStateOwner=val;
                        stateName=getBlockStateName(val);
                        SOSobj.SelectedOwnerState=stateName{1};
                    elseif~isempty(SOSobj.SelectedStateOwner)&&~check_block_exists(SOSobj.SelectedStateOwner)
                        source.UDTerrSelectorTree=true;
                    end
                end
            end

        end


        if~dlg.isStandAlone
            if slfeature('AccessingMultipleStatesBlocks')>=1
                exist_blk=check_block_exists(source.UDTSOSobj.SelectedStateOwner);
            else
                exist_blk=check_block_exists(source.UDTSOSobj.TreeSelectedItem);
            end
            if~exist_blk
                source.UDTerrSelectorTree=true;
            else
                try
                    if slfeature('AccessingMultipleStatesBlocks')>=1
                        selStateOwner=source.UDTSOSobj.SelectedStateOwner;
                        selStateName=source.UDTSOSobj.SelectedOwnerState;
                        if(strcmp(get_param(selStateOwner,'BlockType'),'SecondOrderIntegrator')&&strlength(selStateName)>=10&&strcmp(selStateName(1:10),'Name state'))
                            dlg.enableApplyButton(false);
                            DAStudio.error('Simulink:blocks:StateUnnamedForMulStatesBlks',selStateOwner);
                            return;
                        end
                        if strcmp(selStateName,'<default>')
                            selStateName='';
                        end
                        set_param(blkH,'StateOwnerBlock',selStateOwner);
                        set_param(blkH,'AccessedStateName',selStateName);
                    else
                        set_param(blkH,'StateOwnerBlock',source.UDTSOSobj.TreeSelectedItem);
                    end
                catch ME
                    varargout={false,ME.message};
                    return;
                end
            end
        end

        refreshDlgAndSetValue(dlg);

    case 'callMoreButton'

        buttonPushEvent=varargin{1};
        dlg=varargin{2};
        tag=varargin{3};
        source=dlg.getDialogSource;
        Simulink.DataTypePrmWidget.callbackDataTypeWidget(buttonPushEvent,dlg,tag);

        source.UDTSOSobj=Simulink.StateOwnerSelector(h.Handle,dlg,get_param(h.Handle,'StateOwnerBlock'));

        refreshDlgAndSetValue(dlg)
    case 'callRefreshButton'

        if isempty(varargin)
            dlg_Tag=[strrep(h.BlockType,' ',''),num2str(h.handle)];
            dlg=findDDGByTag(dlg_Tag);
        else
            dlg=varargin{1};
        end
        source=dlg.getDialogSource;


        source.UDTSOSobj=Simulink.StateOwnerSelector(h.Handle,dlg,get_param(h.Handle,'StateOwnerBlock'));
        source.UDTerrSelectorTree=false;

        refreshDlgAndSetValue(dlg)
    otherwise
        assert(false,'Unexpected action');
    end







    function loc_unhiliteBlocks(block,blkH,stateRdBlkHdls,stateWrBlkHdls,h,isLocked)
        isHilite=strcmp(get_param(block,'HiliteAncestors'),'find');
        StateAccessor_ddg_cb(blkH,'unhilite',[stateRdBlkHdls,get_param(block,'Handle')]);
        if~isHilite
            blk_name=h.getFullName;
            model=regexp(blk_name,'(^[^/]*)','tokens');
            model=model{1};


            all_blks=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'type','block','HiliteAncestors','find');
            if~isLocked
                for ii=1:length(all_blks)
                    set_param(all_blks{ii},'HiliteAncestors','none');
                end
            end
        end
        StateAccessor_ddg_cb(blkH,'unhilite',[stateWrBlkHdls,get_param(block,'Handle')]);



        function html=getRWBlksHTML(~,RWBlks,RWBlksHandle,getStateReadBlks)
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
                optBlockPathArgs=studioHighlight_cb('getBlockPathHandlesAsString',gcbp);

                for i=1:numel(RWBlks)
                    bHdlStr=studioHighlight_cb('getStringForHandle',RWBlksHandle(i));
                    evalCmd=['''StateAccessor_ddg_cb(str2num(''''',...
                    bHdlStr,...
                    '''''),''''hilite'''', str2num(''''',...
                    bHdlStr,...
'''''),'...
                    ,optBlockPathArgs,...
                    ');'''];

                    html=[html,'<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'...
                    ,'<a href="matlab:eval(',evalCmd,')">',rtwprivate('rtwhtmlescape',RWBlks{i}),'</a>'...
                    ,'</td><td></td></tr>'];%#ok<AGROW>
                end
            end
            html=[html,'</table></body></html>'];


            function refreshDlgAndSetValue(dlg)
                source=dlg.getDialogSource;
                dlg.refresh;
                if~isempty(findprop(source,'UDTSOSobj'))&&~isempty(source.UDTSOSobj)
                    if~isempty(source.UDTSOSobj.TreeSelectedItem)
                        if slfeature('ParameterWriteToGeneralBlocks')>=2&&strcmp(source.UDTSOSobj.SelectedOwnerState,'<default>')

                            source.UDTSOSobj.TreeSelectedItem=source.UDTSOSobj.SelectedStateOwner;
                            dlg.enableApplyButton(true);
                        end
                        dlg.setWidgetValue('tree_SystemHierarchy',source.UDTSOSobj.TreeSelectedItem);
                    elseif isempty(get_param(source.getBlock.Handle,'StateOwnerBlock'))

                        dlg.setWidgetValue('tree_SystemHierarchy',source.UDTSOSobj.TreeSelectedItem);
                        dlg.enableApplyButton(false);
                    end
                end

                function exist_blk=check_block_exists(blk)
                    exist_blk=0;
                    if~isempty(blk)
                        modelC=regexp(blk,'(^[^/]*)','tokens');
                        model=cell2mat(modelC{1});
                        all_blks=find_system(model,'LookUnderMasks','all','FollowLinks','on',...
                        'MatchFilter',@Simulink.match.allVariants);
                        exist_blk=~isempty(find(strcmp(all_blks,blk),1));
                    end

                    function[stateNotSet,selStateOwner]=checkOwnerNoSelectState(dlg)

                        source=dlg.getDialogSource;
                        selStateOwner=source.UDTSOSobj.SelectedStateOwner;
                        selStateName=source.UDTSOSobj.SelectedOwnerState;
                        if~isempty(selStateOwner)
                            stateNames=get_param(selStateOwner,'StateNameList');
                        end
                        stateNotSet=~isempty(selStateOwner)&&...
                        (isempty(selStateName)||...
                        (length(stateNames)>1&&strcmp(selStateName,'<default>')));

                        function ErrOutput=getBlockDiagramChangedError()
                            ErrOutput={false,...
                            [DAStudio.message('Simulink:blocks:StateReadWriteBlockDiagramChanged1'),...
                            ' ',DAStudio.message('Simulink:dialog:DsmRwGuiRefresh'),' ',...
                            DAStudio.message('Simulink:blocks:StateReadWriteBlockDiagramChanged2')]};

                            function stateNames=getBlockStateName(blk)
                                stateNames={};
                                blkObj=get_param(blk,'Object');
                                chartH=blkObj.find('-isa','Stateflow.Chart','-depth',1,'Name',blkObj.Name);
                                if isempty(chartH)||slfeature('StateflowStateReset')==0
                                    stateNames=get_param(blk,'StateNameList');
                                elseif chartH.StateAccess.Enabled&&slfeature('StateflowStateReset')==1
                                    sfunObj=blkObj.find('-isa','Simulink.SFunction','Path',chartH.Path);
                                    stateNames=get_param(sfunObj.Handle,'StateNameList');
                                elseif chartH.StateAccess.Enabled&&slfeature('StateflowStateReset')==2
                                    stateNames=get_param(blkObj.Handle,'StateNameList');
                                end



