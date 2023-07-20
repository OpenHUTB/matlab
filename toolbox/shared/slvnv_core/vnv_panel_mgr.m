function varargout=vnv_panel_mgr(method,blockH,varargin)




















    modelH=bdroot(blockH);
    if strncmp(method,'jcb',3)
        jPanel=varargin{1};
    end

    switch(method)
    case 'sbCreatePanel'
        if strcmp(get_param(modelH,'VnvDirty'),'on')
            vnv_assert_mgr('mdlReloadAsserts',modelH);
        end
        jPanel=jpanel_create(blockH);
        varargout{1}=jPanel;

    case 'sbUpdateReq'
        if nargin==2
            jPanel=sigb_get_jpanel(blockH);
            if~isempty(jPanel)
                sigb_refresh_requirements_extern(blockH,jPanel);
            end
        else
            baseIdx=varargin{1};
            newCnt=varargin{2};
            if nargin<5
                sigb_update_reqs(blockH,baseIdx,newCnt);
            else
                groupReqCnt=varargin{3};
                sigb_update_reqs(blockH,baseIdx,newCnt,groupReqCnt);
            end
        end

    case 'sbEnableRefresh'
        jPanel=sigb_get_jpanel(blockH);
        if~isempty(jPanel)
            jPanel.enableRefresh;
        end

    case 'sbForceRefresh'
        jPanel=sigb_get_jpanel(blockH);
        if~isempty(jPanel)
            if jPanel.verificationEnabled()
                jpanel_refresh_hierarchy(jPanel,blockH);
                jpanel_update_group(jPanel,blockH);
                jPanel.disableRefresh;
            end
            if rmidata.isExternal(rmisl.getmodelh(blockH))
                sigb_refresh_requirements_extern(blockH,jPanel);
            else
                blkInfo=sigb_get_info(blockH);
                sigb_refresh_requirements(blkInfo,jPanel);
            end
        end

    case 'jcbRefresh'
        if strcmp(get_param(modelH,'VnvDirty'),'on')
            vnv_assert_mgr('mdlReloadAsserts',modelH);
            vnv_assert_mgr('mdlForceRefresh',modelH);
        end

    case 'sbClosePanel'
        jPanel=varargin{1};
        if~isempty(jPanel)&&jPanel.verificationEnabled()
            jpanel_close(jPanel,blockH);
        end

    case 'sbGroupChange'
        jPanel=varargin{1};
        if~isempty(jPanel)
            if jPanel.verificationEnabled()
                if strcmp(get_param(modelH,'VnvDirty'),'on')


                    vnv_assert_mgr('mdlReloadAsserts',modelH);
                    vnv_assert_mgr('mdlForceRefresh',modelH);
                else
                    jpanel_update_group(jPanel,blockH);
                end
            end
            if rmidata.isExternal(rmisl.getmodelh(blockH))
                sigb_refresh_requirements_extern(blockH,jPanel);
            else
                blkInfo=sigb_get_info(blockH);
                sigb_refresh_requirements(blkInfo,jPanel);
            end
        end

    case 'jcbCheckUncheck'
        jNode=jPanel.selected_nodes;
        assertH=jNode(1).getHandle;
        vnv_assert_mgr('disableRefresh',blockH);
        vnv_assert_mgr('sbBlkEdit',blockH,assertH,jNode(1).isChecked);
        vnv_assert_mgr('enableRefresh',blockH);

    case 'jcbContext'
        jpanel_context_mgr(jPanel,varargin{2},blockH);

    case 'jcbReqCtxt'
        menuCmd=varargin{2};
        groupRelativeIdx=varargin{3};

        if data_needs_update(modelH)
            msgbox(getString(message('Slvnv:rmisl:menus_rmi_tools:UpdateDataBeforeUseMenu')));
            varargout{1}=[];
            return;
        end

        if rmidata.isExternal(rmisl.getmodelh(blockH))
            varargout{1}=jpanel_req_context_mgr_extern(jPanel,blockH,menuCmd,groupRelativeIdx);
        else
            varargout{1}=jpanel_req_context_mgr(jPanel,blockH,menuCmd,groupRelativeIdx);
        end

    case 'help'
        helpview([docroot,'/toolbox/simulink/helptargets.map'],'verification_manager');

    otherwise
        error(message('Slvnv:vnv_panel_mgr:UnknownMethod',method));
    end


    function hasData2Update=data_needs_update(modelH)

        hasData2Update=false;
        if~rmiut.isBuiltinNoRmi(modelH)&&~rmidata.storageModeCache('get',modelH)
            hasData2Update=rmisl.modelHasEmbeddedReqInfo(modelH);
        end


        function jPanel=jpanel_create(blockH)

            jPanel=slreq.sigbldr.SlVerifyPanel(blockH);
            jpanel_refresh_hierarchy(jPanel,blockH);
            jpanel_update_group(jPanel,blockH);
            modelH=rmisl.getmodelh(blockH);
            if rmidata.isExternal(modelH)
                if bdHasExternalData(modelH,true)
                    sigb_refresh_requirements_extern(blockH,jPanel);
                end
            else

                blkInfo=sigb_fix_groupReqCnt_corruption(blockH);
                sigb_refresh_requirements(blkInfo,jPanel);
            end
            jpanel_restore_view(jPanel,blockH);


            [rmiInstalled,rmiLicensed]=rmi.isInstalled();
            rmiAvailable=rmiInstalled&&rmiLicensed;

            if strcmpi(get_param(bdroot(blockH),'BlockDiagramType'),'library')
                jPanel.disableVerification(rmiAvailable);
            elseif~rmiAvailable
                jPanel.setReadOnlyReq;
            end

            function tf=bdIsHarness(modelH)
                tf=strcmpi(get_param(modelH,'IsHarness'),'on');

                function tf=bdHasExternalData(modelH,true)
                    tf=rmidata.bdHasExternalData(modelH,true);
                    if~tf&&bdIsHarness(modelH)
                        harnessName=get_param(modelH,'Name');
                        harnessInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(harnessName);
                        mainModelName=harnessInfo.model;
                        tf=rmidata.bdHasExternalData(mainModelName,true);
                    end

                    function jpanel_close(jPanel,blockH)
                        blkInfo=sigb_get_info(blockH);

                        activeDispMode=jPanel.getActiveDisplayMode+1;
                        activeListEnabled=jPanel.getActiveListEnabled;
                        reqDispPercnt=jPanel.getReqDispPrcnt;

                        needUpdate=0;

                        if~isequal(blkInfo.reqDispPrcnt,reqDispPercnt)
                            blkInfo.reqDispPrcnt=reqDispPercnt;
                            needUpdate=1;
                        end

                        if activeListEnabled
                            if~isequal(blkInfo.blkDispMode,activeDispMode)
                                blkInfo.blkDispMode=activeDispMode;
                                needUpdate=1;
                            end
                        else
                            if~isequal(blkInfo.blkDispMode,-activeDispMode)
                                blkInfo.blkDispMode=-activeDispMode;
                                needUpdate=1;
                            end
                        end

                        if needUpdate
                            preserve_dirty=Simulink.PreserveDirtyFlag(blkInfo.modelH,...
                            'blockDiagram');
                            sigb_write_info(blkInfo);
                            delete(preserve_dirty);
                        end

                        function jpanel_restore_view(jPanel,blockH)
                            blkInfo=sigb_get_info(blockH);

                            if isempty(blkInfo)||~isfield(blkInfo,'reqDispPrcnt')||isempty(blkInfo.reqDispPrcnt)
                                return;
                            end
                            activeDispMode=abs(blkInfo.blkDispMode);
                            listEnabled=(blkInfo.blkDispMode>0);
                            jPanel.update_display(activeDispMode-1,listEnabled,blkInfo.reqDispPrcnt);

                            function jpanel_refresh_hierarchy(jPanel,blockH)
                                [displayHierarchy,dispDepth,isLeaf]=...
                                vnv_assert_mgr('sbAssertHier',blockH);

                                if isempty(displayHierarchy)
                                    jNodes=jPanel.populate_tree([],[],[],[]);%#ok<NASGU>


                                    if~isempty(jPanel.verifyPane)&&~isempty(jPanel.verifyPane.handle.ContextMenu)
                                        jPanel.verifyPane.handle.ContextMenu=[];
                                    end
                                else
                                    iconIdx=ones(1,length(displayHierarchy));
                                    iconIdx(~isLeaf)=0;
                                    allnames=get_param(displayHierarchy,'Name');
                                    allnames=strrep(allnames,newline,' ');
                                    jNodes=jPanel.populate_tree(displayHierarchy,dispDepth+1,iconIdx,allnames);%#ok<NASGU>


                                    if~isempty(jPanel.verifyPane)&&~isempty(jPanel.verifyPopup)&&isempty(jPanel.verifyPane.handle.ContextMenu)
                                        jPanel.verifyPane.handle.ContextMenu=jPanel.verifyPopup.uicontxtmenu;
                                    end
                                end


                                function jpanel_update_group(jPanel,blockH)
                                    [dispRowIdx,staticEnabled,groupEnabled]=...
                                    vnv_assert_mgr('sbGroupValues',blockH);

                                    if~isempty(dispRowIdx)
                                        iconIdx=-1*ones(1,length(dispRowIdx));
                                        iconIdx(staticEnabled==1)=2;

                                        errmsg=jPanel.new_leaves_icon_checks(iconIdx,groupEnabled);
                                        if~isempty(errmsg)
                                            error(message('Slvnv:vnv_panel_mgr:JavaError',errmsg));
                                        end
                                    end


                                    function reqOffset=util_req_cnts_to_offset(reqCnts)
                                        reqOffset=[1,1+cumsum(reqCnts(1:(end-1)))];


                                        function varargout=jpanel_req_context_mgr(jPanel,blockH,menuCmd,groupRelativeIdx)
                                            varargout{1}=[];
                                            blkInfo=sigb_get_info(blockH);
                                            activeGroup=signalbuilder(blockH,'activegroup');
                                            if isempty(blkInfo.groupReqCnt)
                                                offset=-999;
                                            else
                                                reqCnts=blkInfo.groupReqCnt;
                                                allOffsets=util_req_cnts_to_offset(reqCnts);
                                                offset=allOffsets(activeGroup);
                                            end

                                            switch(menuCmd)
                                            case 'view'
                                                if(groupRelativeIdx>=0&&offset+groupRelativeIdx>0)
                                                    rmi('view',blockH,offset+groupRelativeIdx);
                                                end

                                            case 'addModify'
                                                if(offset<0)
                                                    varargout{1}=rmi('edit',blockH,[],1,0);
                                                else
                                                    if(groupRelativeIdx>=0)
                                                        selected=groupRelativeIdx+1;
                                                    else
                                                        selected=[];
                                                    end
                                                    varargout{1}=rmi('edit',blockH,selected,offset,reqCnts(activeGroup));
                                                end
                                                sigbuilder('cmdApi','requiopen',blockH,true);

                                            case 'delete'
                                                [rmiInstalled,rmiLicensed]=rmi.isInstalled();
                                                if rmiInstalled&&rmiLicensed&&~builtin('_license_checkout','Simulink_Requirements','quiet')
                                                    if groupRelativeIdx>=0&&offset+groupRelativeIdx>0
                                                        rmi.setReqs(blockH,[],offset+groupRelativeIdx,1);


                                                        blkInfo.groupReqCnt(activeGroup)=blkInfo.groupReqCnt(activeGroup)-1;
                                                        sigb_write_info(blkInfo);


                                                        sigb_refresh_requirements(blkInfo,jPanel);
                                                    end
                                                else
                                                    msgbox(...
                                                    getString(message('Slvnv:vnv_panel_mgr:DeleteReqLicenseRequired')),...
                                                    getString(message('Slvnv:vnv_panel_mgr:LicenseFailedTitle')));
                                                end
                                            case 'url'
                                                url=rmi.getURL(blockH);
                                                clipboard('copy',url);
                                            otherwise
                                            end


                                            function varargout=jpanel_req_context_mgr_extern(jPanel,blockH,menuCmd,groupRelativeIdx)
                                                varargout{1}=[];
                                                activeGroup=signalbuilder(blockH,'activegroup');
                                                [grpReqCnt,groupIdx]=slreq.getSigbGrpData(blockH);
                                                if isempty(grpReqCnt)||activeGroup>length(grpReqCnt)
                                                    activeGroupReqsCnt=0;
                                                else
                                                    activeGroupReqsCnt=grpReqCnt(activeGroup);
                                                end
                                                activeGroupReqsIdx=find(groupIdx==activeGroup);
                                                if groupRelativeIdx>=0
                                                    selected=groupRelativeIdx+1;
                                                else
                                                    selected=[];
                                                end
                                                switch(menuCmd)
                                                case 'view'
                                                    if~isempty(selected)&&selected<=activeGroupReqsCnt
                                                        rmi('view',blockH,activeGroupReqsIdx(selected));
                                                    end

                                                case 'addModify'
                                                    if isempty(activeGroupReqsIdx)
                                                        numReqsBeforeActiveGroup=length(find(groupIdx<activeGroup));
                                                        offset=numReqsBeforeActiveGroup+1;
                                                    else
                                                        offset=activeGroupReqsIdx(1);
                                                    end
                                                    varargout{1}=rmi('edit',blockH,selected,offset,activeGroupReqsCnt);
                                                    sigbuilder('cmdApi','requiopen',blockH,true);

                                                case 'delete'
                                                    [rmiInstalled,rmiLicensed]=rmi.isInstalled();
                                                    if rmiInstalled&&rmiLicensed&&~builtin('_license_checkout','Simulink_Requirements','quiet')
                                                        if~isempty(selected)&&selected<=activeGroupReqsCnt
                                                            rmi.setReqs(blockH,[],activeGroupReqsIdx(selected),1);
                                                            sigb_refresh_requirements_extern(blockH,jPanel);
                                                        end
                                                    else
                                                        msgbox(...
                                                        getString(message('Slvnv:vnv_panel_mgr:DeleteReqLicenseRequired')),...
                                                        getString(message('Slvnv:vnv_panel_mgr:LicenseFailedTitle')));
                                                    end
                                                case 'url'
                                                    [rmiInstalled,rmiLicensed]=rmi.isInstalled();
                                                    if rmiInstalled&&rmiLicensed
                                                        url=rmi.getURL(blockH);
                                                        clipboard('copy',url);
                                                    else
                                                        rmi.licenseErrorDlg()
                                                    end

                                                otherwise
                                                end

                                                function jpanel_context_mgr(jPanel,method,blockH)
                                                    assertBlockH=jPanel.selected_handles;
                                                    leafDescendents=jPanel.selected_leaf_descendent_handles;

                                                    switch(method)
                                                    case 'enable'
                                                        jpanel_context_mgr_set_enable(blockH,leafDescendents,'on');

                                                    case 'disable'
                                                        jpanel_context_mgr_set_enable(blockH,leafDescendents,'off');

                                                    case 'activate'
                                                        vnv_assert_mgr('disableRefresh',blockH);
                                                        for i=1:length(leafDescendents)
                                                            vnv_assert_mgr('sbBlkEdit',blockH,leafDescendents(i),1);
                                                        end
                                                        vnv_assert_mgr('enableRefresh',blockH);
                                                    case 'disactivate'
                                                        vnv_assert_mgr('disableRefresh',blockH);
                                                        for i=1:length(leafDescendents)
                                                            vnv_assert_mgr('sbBlkEdit',blockH,leafDescendents(i),0);
                                                        end
                                                        vnv_assert_mgr('enableRefresh',blockH);

                                                    case 'view'
                                                        set_param(bdroot(assertBlockH),'HiliteAncestors','none')
                                                        set_param(assertBlockH,'HiliteAncestors','find');
                                                        parent=get_param(assertBlockH,'Parent');
                                                        if isempty(parent)
                                                            open_system(bdroot(assertBlockH),'force');
                                                        else
                                                            open_system(parent,'force');
                                                        end

                                                    case 'props'
                                                        open_system(assertBlockH);

                                                    case 'req'

                                                    otherwise
                                                    end

                                                    function jpanel_context_mgr_set_enable(blockH,leafDescendents,value)

                                                        if any_open_dialog(leafDescendents)
                                                            title=getString(message('Slvnv:vnv_panel_mgr:ActionCanceledTitle'));
                                                            msg=getString(message('Slvnv:vnv_panel_mgr:ActionCanceledMsg'));
                                                            warndlg(msg,title);
                                                            modelH=bdroot(blockH);
                                                            vnv_assert_mgr('mdlForceRefresh',modelH);
                                                            return;
                                                        end

                                                        vnv_assert_mgr('disableRefresh',blockH);
                                                        try
                                                            for i=1:length(leafDescendents)
                                                                set_param(leafDescendents(i),'Enabled',value);
                                                            end
                                                        catch Mex %#ok<NASGU>
                                                        end
                                                        vnv_assert_mgr('enableRefresh',blockH)

                                                        modelH=bdroot(blockH);
                                                        mdlInfoStruct=get_param(modelH,'VnvToolData');
                                                        for blkH=mdlInfoStruct.sigbuildHandles
                                                            vnv_panel_mgr('sbForceRefresh',blkH);
                                                        end

                                                        function out=has_open_dialog(blockH)
                                                            blockObj=get_param(blockH,'Object');
                                                            dlgs=blockObj.getDialogSource.getOpenDialogs;
                                                            out=~isempty(dlgs);

                                                            function out=any_open_dialog(leafDescendents)
                                                                for i=1:length(leafDescendents)
                                                                    if has_open_dialog(leafDescendents(i))
                                                                        out=true;
                                                                        return;
                                                                    end
                                                                end
                                                                out=false;


                                                                function sigb_update_reqs(blockH,baseIdx,newCnt,groupReqCnt)
                                                                    blkInfo=sigb_get_info(blockH);
                                                                    if isempty(blkInfo)||isempty(blkInfo.groupCnt)
                                                                        vnv_assert_mgr('sbBlkCopy',blockH);
                                                                        blkInfo=sigb_get_info(blockH);
                                                                    end
                                                                    if nargin>3
                                                                        blkInfo.groupReqCnt=groupReqCnt;
                                                                    else
                                                                        activeGroup=signalbuilder(blockH,'activegroup');
                                                                        if(~isfield(blkInfo,'groupReqCnt')||isempty(blkInfo.groupReqCnt))

                                                                            blkInfo.groupReqCnt=zeros(1,blkInfo.groupCnt);
                                                                            blkInfo.groupReqCnt(activeGroup)=newCnt;
                                                                        else





                                                                            if baseIdx>0
                                                                                allOffsets=util_req_cnts_to_offset(blkInfo.groupReqCnt);
                                                                                possibleGroups=find(allOffsets==baseIdx);
                                                                                if~any(possibleGroups==activeGroup)
                                                                                    warning(message('Slvnv:vnv_panel_mgr:inconsistentSigbUpdate',activeGroup));
                                                                                end
                                                                            end
                                                                            blkInfo.groupReqCnt(activeGroup)=newCnt;
                                                                        end
                                                                    end
                                                                    sigb_write_info(blkInfo);
                                                                    sigb_refresh_requirements(blkInfo);


                                                                    function sigb_refresh_requirements(blkInfo,jPanel)

                                                                        if nargin<2
                                                                            jPanel=sigb_get_jpanel(blkInfo.blockH);
                                                                        end
                                                                        if isempty(jPanel)
                                                                            return;
                                                                        end
                                                                        activeGroup=signalbuilder(blkInfo.blockH,'activegroup');

                                                                        if isfield(blkInfo,'groupReqCnt')&&~isempty(blkInfo.groupReqCnt)&&length(blkInfo.groupReqCnt)<activeGroup

                                                                            blkInfo.groupReqCnt(end+1:activeGroup)=0;
                                                                            sigb_write_info(blkInfo);



                                                                        end
                                                                        if(~isfield(blkInfo,'groupReqCnt')||isempty(blkInfo.groupReqCnt)...
                                                                            ||blkInfo.groupReqCnt(activeGroup)==0)
                                                                            jPanel.setAllReqStrs({});
                                                                        else
                                                                            reqCnts=blkInfo.groupReqCnt;
                                                                            reqOffset=util_req_cnts_to_offset(reqCnts);
                                                                            reqStrs=rmi('descriptions',blkInfo.blockH,reqOffset(activeGroup),reqCnts(activeGroup));
                                                                            jPanel.setAllReqStrs(reqStrs);
                                                                        end

                                                                        function sigb_refresh_requirements_extern(blockH,jPanel)
                                                                            [~,grpIdx]=slreq.getSigbGrpData(blockH);
                                                                            if any(grpIdx==-1)


                                                                                jPanel.setAllReqStrs({});

                                                                                t=timer('TimerFcn',@delayed_sigb_refresh_requirements,'StartDelay',1);
                                                                                userData.blockH=blockH;
                                                                                t.UserData=userData;
                                                                                start(t);
                                                                                return;
                                                                            end
                                                                            activeGroup=signalbuilder(blockH,'activegroup');
                                                                            if any(grpIdx==activeGroup)
                                                                                reqStrs=rmi('descriptions',blockH,activeGroup);
                                                                                jPanel.setAllReqStrs(reqStrs);
                                                                            else
                                                                                jPanel.setAllReqStrs({});
                                                                            end

                                                                            function delayed_sigb_refresh_requirements(timerobj,varargin)
                                                                                userData=timerobj.UserData;
                                                                                blockH=userData.blockH;
                                                                                stop(timerobj);
                                                                                delete(timerobj);

                                                                                if ishandle(blockH)
                                                                                    vnv_panel_mgr('sbUpdateReq',blockH);
                                                                                end

                                                                                function blkInfo=sigb_fix_groupReqCnt_corruption(blockH)
                                                                                    blkInfo=sigb_get_info(blockH);
                                                                                    if(isfield(blkInfo,'groupReqCnt')&&~isempty(blkInfo.groupReqCnt))
                                                                                        reqCnts=blkInfo.groupReqCnt;
                                                                                        totalCnt=rmi('count',blkInfo.blockH);
                                                                                        if sum(reqCnts)>totalCnt


                                                                                            cs_cnts=cumsum(reqCnts);
                                                                                            newReqCnts=zeros(size(reqCnts));
                                                                                            newReqCnts(cs_cnts<totalCnt)=reqCnts(cs_cnts<totalCnt);
                                                                                            exceedIdx=find(cs_cnts>=totalCnt);
                                                                                            lastCnt=totalCnt-sum(newReqCnts);
                                                                                            newReqCnts(exceedIdx(1))=lastCnt;
                                                                                            blkInfo.groupReqCnt=newReqCnts;
                                                                                            sigb_write_info(blkInfo)



                                                                                            if totalCnt>0||rmipref('DuplicateOnCopy')
                                                                                                blockName=getfullname(blkInfo.blockH);
                                                                                                title=getString(message('Slvnv:vnv_panel_mgr:InconsistentTitle'));
                                                                                                msg=getString(message('Slvnv:vnv_panel_mgr:InconsistentCount',blockName));
                                                                                                msgbox(msg,title);
                                                                                            end
                                                                                        elseif sum(reqCnts)<totalCnt
                                                                                            blockName=getfullname(blkInfo.blockH);
                                                                                            title=getString(message('Slvnv:vnv_panel_mgr:InconsistentTitle'));
                                                                                            msg=getString(message('Slvnv:vnv_panel_mgr:UnmappedReqs',blockName));
                                                                                            warndlg(msg,title);
                                                                                        end
                                                                                    end


                                                                                    function jPanel=sigb_get_jpanel(blockH)
                                                                                        jPanel=[];
                                                                                        dialogH=get_param(blockH,'UserData');
                                                                                        if~isempty(dialogH)&&ishandle(dialogH)
                                                                                            UD=get(dialogH,'UserData');
                                                                                            if UD.current.isVerificationVisible
                                                                                                jPanel=UD.verify.jVerifyPanel;
                                                                                            end
                                                                                        end



                                                                                        function blkInfo=sigb_get_info(blkHandle)
                                                                                            fromWsH=find_system(blkHandle,'FollowLinks','on'...
                                                                                            ,'LookUnderMasks','all'...
                                                                                            ,'BlockType','FromWorkspace');
                                                                                            blkInfo=get_param(fromWsH,'VnvData');

                                                                                            if~isempty(blkInfo)
                                                                                                blkInfo.blockH=blkHandle;
                                                                                                blkInfo.modelH=bdroot(blkHandle);
                                                                                            end

                                                                                            function sigb_write_info(blkInfo)
                                                                                                fromWsH=find_system(blkInfo.blockH,'FollowLinks','on'...
                                                                                                ,'LookUnderMasks','all'...
                                                                                                ,'BlockType','FromWorkspace');

                                                                                                if~strcmp(get_param(fromWsH,'StaticLinkStatus'),'implicit')
                                                                                                    set_param(fromWsH,'VnvData',blkInfo);
                                                                                                end

