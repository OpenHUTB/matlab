function varargout=sigbuilder_block(method,varargin)






    persistent fastRestartObj;

    if nargin==1&&strcmp(method,'clipboard')
        return;
    end

    switch(nargin)
    case 1
        block=gcb;
        blockH=get_param(block,'Handle');
        modelH=bdroot(blockH);
    case 2
    end

    switch(method)
    case 'create'
        dialog=varargin{1};
        names=varargin{2};
        handleStruct=create(dialog,names,varargin{3:end});
        varargout{1}=handleStruct;

        fastRestartObj=sigbldrblock.fastRestartListeners.setup(handleStruct.modelH);

    case 'open'
        block=gcb;
        if nargin>1
            gui_pos=varargin{1};
        else
            gui_pos=[];
        end

        dialog=open_gui(block,gui_pos);

        modelH=bdroot(block);
        fastRestartObj=sigbldrblock.fastRestartListeners.setup(modelH);


        blockH=get_param(block,'Handle');
        modelObject=get_param(modelH,'object');
        id=matlab.lang.makeValidName(getfullname(blockH));

        if~modelObject.hasCallback('PreClose',id)
            Simulink.addBlockDiagramCallback(modelH,'PreClose',id,@()preCloseCallback(dialog,[]));
        end

    case 'load'
        block=gcb;
        blockH=get_param(block,'Handle');
        linkStatus=get_param(blockH,'LinkStatus');
        tuvarInitMaskWS(blockH);
        set_param(block,'MaskHideContents','on')
        vnv_notify('sbBlkLoad',blockH);
        update=~strcmpi(linkStatus,'implicit');




        blockType=get_param(bdroot(blockH),'BlockDiagramType');
        is_a_user_library=0;
        throwWarning=0;
        if strcmpi(blockType,'library')
            libName=get_param(bdroot(blockH),'Name');
            if~(strcmpi(libName,'simulink3')||...
                strcmpi(libName,'simulink')||...
                strcmpi(libName,'simgens'))

                is_a_user_library=1;







                fromWsH=find_system(blockH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks','on','LookUnderMasks','all','BlockType','FromWorkspace');
                savedUD=get_param(fromWsH,'SigBuilderData');


                if~isfield(savedUD,'sbobj')

                    throwWarning=1;
                else

                    if iscell(savedUD.sbobj.Groups)
                        throwWarning=1;
                    else

                        [~,modified]=update_sbobj_fields(savedUD);
                        if modified
                            throwWarning=1;
                        end
                    end
                end

                if isempty(get_param(blockH,'pauseFcn'))
                    throwWarning=1;
                end





                dispCmd=['plot(0, 0, 100, 100,[2, 2, 32, 32, 2], [68, 8, 8, 68, 68],'...
                ,'[32, 2], [38, 38], [32, 19, 2],[53, 60, 44], [32, 17, 17, 2],[16, 16, 31, 31]);'...
                ,'txt = getActiveGroup(gcbh);text(2, 100, txt,''verticalAlignment'', ''top'');'];
                if~strcmp(get_param(blockH,'MaskDisplay'),dispCmd)
                    throwWarning=1;
                end
            end
        else




            fromWsH=find_system(blockH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks','on','LookUnderMasks','all','BlockType','FromWorkspace');
            UD=get_param(fromWsH,'SigBuilderData');
            if isempty(get_param(blockH,'MaskType'))



                set_param(blockH,'MaskType','Sigbuilder block');
            end
            linkStatus=get_param(blockH,'LinkStatus');

            if(strcmp(linkStatus,'resolved')&&exist('UD','var')&&~isempty(UD)&&~isfield(UD,'sbobj'))

                set_param(blockH,'LinkStatus','inactive');
            end

            [~,throwWarning]=update_sbobj(blockH,~update);

            if update

                if isempty(get_param(blockH,'pauseFcn'))


                    set_param(blockH,'pauseFcn','sigbuilder_block(''pause'')');
                    set_param(blockH,'continueFcn','sigbuilder_block(''continue'')');
                    throwWarning=1;
                end





                dispCmd=['plot(0, 0, 100, 100,[2, 2, 32, 32, 2], [68, 8, 8, 68, 68],'...
                ,'[32, 2], [38, 38], [32, 19, 2],[53, 60, 44], [32, 17, 17, 2],[16, 16, 31, 31]);'...
                ,'txt = getActiveGroup(gcbh);text(2, 100, txt,''verticalAlignment'', ''top'');'];
                if~strcmp(get_param(blockH,'MaskDisplay'),dispCmd)
                    set_param(blockH,'MaskDisplay',dispCmd);
                    throwWarning=1;
                end
            end
            refBlk=get_param(blockH,'ReferenceBlock');
            if isempty(refBlk)
                libName='';
            else
                libName=bdroot(refBlk);
            end

            fastRestartObj=sigbldrblock.fastRestartListeners.setup(bdroot(blockH));
        end

        if(throwWarning&&is_a_user_library)||(~update)
            warndlg(getString(message('sigbldr_blk:sigbuilder_block:UpdateLibrary',libName)),...
            getString(message('sigbldr_blk:sigbuilder_block:UpdateLibWarnTitle')),'modal');
        end

        if nargin>1



            bd=get_param(bdroot(blockH),'Object');
            id=genvarname(getfullname(blockH));
            gui_pos=varargin{1};
            bd.addCallback('PreShow',id,@()open_gui(blockH,gui_pos));


            id=matlab.lang.makeValidName(getfullname(blockH));

            if~bd.hasCallback('PreClose',id)
                bd.addCallback('PreClose',id,@()preCloseCallback(get_param(blockH,'UserData'),[]));
            end
        end

    case{'close','modelClose'}
        blockUD=get_param(blockH,'UserData');
        if~isempty(blockUD)&&ishghandle(blockUD,'figure')
            sigBuilderClose(blockUD);
        end
        if~isempty(fastRestartObj)

            fastRestartObj.cleanup(modelH);
        end

    case 'delete'
        blockUD=get_param(blockH,'UserData');
        if~isempty(blockUD)&&ishghandle(blockUD,'figure')
            sigBuilderClose(blockUD);
        else


            modelObject=get_param(modelH,'object');
            id=matlab.lang.makeValidName(getfullname(blockH));

            if modelObject.hasCallback('PreClose',id)
                modelObject.removeCallback('PreClose',id);
            end
        end
        if strcmp(get_param(modelH,'IsDestroying'),'off')


            vnv_notify('sbBlkDelete',blockH);
        end
        if~isempty(fastRestartObj)
            fastRestartObj.cleanup(modelH);
        end

    case 'destroy'
    case 'preSave'
        blockUD=get_param(blockH,'UserData');
        if~model_is_a_library(modelH)
            if~isempty(blockUD)&&ishghandle(blockUD,'figure')
                sigBuilderwriteToSl(blockUD);
                if strcmp(get(blockUD,'visible'),'on')
                    set_param(blockH,'LoadFcn',block_cmd_with_pos('load',blockUD));
                else
                    set_param(blockH,'LoadFcn','sigbuilder_block(''load'');');
                end
            else



                bd=get_param(bdroot(blockH),'Object');
                if~is_a_link(blockH)&&~bd.hasCallback('PreShow',genvarname(getfullname(blockH)))
                    set_param(blockH,'LoadFcn','sigbuilder_block(''load'');');
                end


            end

            if~is_a_link(blockH)










                fromWsH=find_system(blockH,'FollowLinks','on','LookUnderMasks','all',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'BlockType','FromWorkspace');
                savedUD=get_param(fromWsH,'SigBuilderData');

                if isfield(savedUD,'axes')
                    if isfield(savedUD.axes,'labelH')
                        savedUD.axes=rmfield(savedUD.axes,'labelH');
                    end
                    if isfield(savedUD.axes,'labelPatch')
                        savedUD.axes=rmfield(savedUD.axes,'labelPatch');
                    end
                end
                tuvarInitMaskWS(blockH);
                set_param(fromWsH,'SigBuilderData',savedUD);

            end
        else



            if isempty(get_param(blockH,'MaskType'))
                set_param(blockH,'MaskType','Sigbuilder block');
            end

            if~isempty(blockUD)&&ishghandle(blockUD,'figure')
                sigBuilderwriteToSl(blockUD);
            end





            dispCmd=['plot(0, 0, 100, 100,[2, 2, 32, 32, 2], [68, 8, 8, 68, 68],'...
            ,'[32, 2], [38, 38], [32, 19, 2],[53, 60, 44], [32, 17, 17, 2],[16, 16, 31, 31]);'...
            ,'txt = getActiveGroup(gcbh);text(2, 100, txt,''verticalAlignment'', ''top'');'];
            if~strcmp(get_param(blockH,'MaskDisplay'),dispCmd)
                modelH=bdroot(blockH);
                if model_is_locked(modelH)
                    set_param(modelH,'lock','off');
                end
                set_param(blockH,'MaskDisplay',dispCmd);
            end

            if isempty(get_param(blockH,'pauseFcn'))


                modelH=bdroot(blockH);
                if model_is_locked(modelH)
                    set_param(modelH,'lock','off');
                end
                set_param(blockH,'pauseFcn','sigbuilder_block(''pause'')');
                set_param(blockH,'continueFcn','sigbuilder_block(''continue'')');
            end
        end

    case{'start','continue'}
        blockUD=get_param(blockH,'UserData');
        if~isempty(blockUD)&&ishghandle(blockUD,'figure')

            sigBuilderSimStart(blockUD);
        end

    case 'stop'
        if nargin>1

            blockH=get_param(varargin{1},'Handle');
        end
        blockUD=get_param(blockH,'UserData');
        if~isempty(blockUD)&&ishghandle(blockUD,'figure')
            sigBuilderSimStop(blockUD);
        end

    case 'pause'
        blockUD=get_param(blockH,'UserData');
        if~isempty(blockUD)&&ishghandle(blockUD,'figure')
            sigBuilderSimPause(blockUD);
        end

    case 'updateIceState'



        blockH=varargin{1};
        blockUD=get_param(blockH,'UserData');
        if~isempty(blockUD)&&ishghandle(blockUD,'figure')
            sigBuilderUpdateIcedStateForHarness(blockUD,varargin{2});
        end

    case 'namechange'
        blockUD=get_param(blockH,'UserData');
        if~isempty(blockUD)&&ishghandle(blockUD,'figure')
            sigBuilderBlockRename(blockUD);
        end

    case 'clipboard'
    case 'maskInit'
        varargout{1}=sigbuilder('tuVar',blockH,modelH);




        fromWsH=find_system(blockH,'FollowLinks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all','BlockType','FromWorkspace');
        set_param(fromWsH,'UserData',fromWsH);

    case 'copy'
        blockUD=get_param(blockH,'UserData');
        if~isempty(blockUD)&&ishghandle(blockUD,'figure')


            sigBuilderwriteToSl(blockUD);
            oldUD=get(blockUD,'UserData');


            oldFromWsH=oldUD.simulink.fromWsH;




            newfromWsH=find_system(blockH,'FollowLinks','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookUnderMasks','all','BlockType','FromWorkspace');







            if isfield(get_param(oldFromWsH,'SigBuilderData'),'sbobj')
                newData=get_param(oldFromWsH,'SigBuilderData');
                if iscell(newData.sbobj.Groups)
                    newData.sbobj=convertFrom2008a(newData);
                end
                newData.sbobj=newData.sbobj.copyObj;

                tuvarInitMaskWS(blockH);



                set_param(newfromWsH,'SigBuilderData',newData);
            else


                tuvarInitMaskWS(blockH);

                set_param(newfromWsH,'SigBuilderData',...
                get_param(oldFromWsH,'SigBuilderData'));
            end
        else







            newfromWsH=find_system(blockH,'FollowLinks','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookUnderMasks','all','BlockType','FromWorkspace');



            oldFromWsH=get_param(newfromWsH,'UserData');


            UD=get_param(newfromWsH,'SigBuilderData');



            if isempty(UD)&&~isempty(oldFromWsH)

                if isfield(get_param(oldFromWsH,'SigBuilderData'),'sbobj')
                    newData=get_param(oldFromWsH,'SigBuilderData');
                    if iscell(newData.sbobj.Groups)
                        newData.sbobj=convertFrom2008a(newData);
                    end
                    newData.sbobj=newData.sbobj.copyObj;

                    tuvarInitMaskWS(blockH);


                    set_param(newfromWsH,'SigBuilderData',newData);
                else


                    tuvarInitMaskWS(blockH);

                    set_param(newfromWsH,'SigBuilderData',...
                    get_param(oldFromWsH,'SigBuilderData'));
                end
            end
        end
        refBlk=get_param(blockH,'ReferenceBlock');
        linkStatus=get_param(blockH,'LinkStatus');
        if~isempty(refBlk)&&~strcmp(linkStatus,'implicit')
            if(strcmpi(bdroot(refBlk),'simulink3')||strcmpi(bdroot(refBlk),'simulink')||strcmpi(bdroot(refBlk),'simgens'))
                set_param(blockH,'LinkStatus','none','MaskIconRotate','on');
            elseif(strcmp(linkStatus,'resolved')&&exist('UD','var')&&~isempty(UD)&&~isfield(UD,'sbobj'))

                set_param(blockH,'LinkStatus','inactive');
            end
        end






        if exist('UD','var')&&~isempty(UD)&&isfield(UD,'sbobj')
            if iscell(UD.sbobj.Groups)
                UD.sbobj=convertFrom2008a(UD);
            end
            UD.sbobj=UD.sbobj.copyObj;
            tuvarInitMaskWS(blockH);
            set_param(newfromWsH,'SigBuilderData',UD);
        end



        b=get_param(newfromWsH,'SigBuilderData');
        if~isfield(b,'sbobj')
            sbobj=SigSuite(b);
            b.sbobj=sbobj;
            tuvarInitMaskWS(blockH);
            set_param(newfromWsH,'SigBuilderData',b);
        else
            if iscell(b.sbobj.Groups)
                b.sbobj=convertFrom2008a(b);
            end
        end



        if any(isfield(b.channels,{'allXData','allYData'}))
            b.channels=rmfield(b.channels,{'allXData','allYData'});
        end

        set_param(blockH,'UserData',-1);
        vnv_notify('sbBlkCopy',blockH);


        fastRestartObj=sigbldrblock.fastRestartListeners.setup(bdroot(blockH));

    case 'add_outport'
        hStruct=varargin{1};
        if nargin<4
            index=length(hStruct.outPortH)+1;
            portName=varargin{2};
        else
            index=varargin{2};
            portName=varargin{3};
        end
        hStruct=add_outport(hStruct,index,portName);
        varargout{1}=hStruct;

    case 'delete_outport'
        hStruct=varargin{1};
        index=varargin{2};
        hStruct=delete_outport(hStruct,index);
        varargout{1}=hStruct;

    case 'rename_outport'
        hStruct=varargin{1};
        index=varargin{2};
        portName=varargin{3};
        hStruct=rename_outport(hStruct,index,portName);
        varargout{1}=hStruct;

    case 'move_port'
        hStruct=varargin{1};
        oldIndex=varargin{2};
        newIndex=varargin{3};
        hStruct=move_port(hStruct,oldIndex,newIndex);
        varargout{1}=hStruct;

    case 'figClose'
        hStruct=varargin{1};
        dirtyFlag=get_param(hStruct.modelH,'dirty');
        figH=get_param(hStruct.subsysH,'UserData');


        if~isempty(figH)&&ishghandle(figH,'figure')&&strcmp(get(figH,'visible'),'on')&&~model_is_locked(hStruct.modelH)
            set_param(hStruct.subsysH,'OpenFcn',block_cmd_with_pos('open',figH));
            set_param(hStruct.modelH,'dirty',dirtyFlag);
        end

        if model_is_locked(hStruct.modelH)&&Simulink.harness.internal.hasActiveHarness(hStruct.modelH)


            Simulink.harness.internal.setBDLock(hStruct.modelH,false);
            set_param(hStruct.subsysH,'UserData',[]);
            Simulink.harness.internal.setBDLock(hStruct.modelH,true);
        elseif model_is_locked(hStruct.modelH)&&model_is_a_library(hStruct.modelH)
            set_param(hStruct.modelH,'lock','off');
            set_param(hStruct.subsysH,'UserData',[]);
            set_param(hStruct.modelH,'lock','on');
        else
            set_param(hStruct.subsysH,'UserData',[]);
        end

    case 'output_FlatBus'
        hStruct=varargin{1};
        hStruct=output_FlatBus(hStruct);
        varargout{1}=hStruct;

    case 'output_Ports'
        hStruct=varargin{1};
        hStruct=output_Ports(hStruct);
        varargout{1}=hStruct;

    case 'create_handleStruct'
        blockH=varargin{1};
        hStruct=create_handleStruct(blockH);
        varargout{1}=hStruct;

    end



    function sigBuilderClose(dialog)

        UD=get(dialog,'UserData');
        close_internal(UD);


        function sigBuilderBlockRename(dialog)

            UD=get(dialog,'UserData');
            update_titleStr(UD);
            set_dirty_flag(UD);


            function sigBuilderwriteToSl(dialog)

                UD=get(dialog,'UserData');
                UD=save_session(UD);
                set(dialog,'UserData',UD);

                if vnv_enabled&&isfield(UD,'verify')&&isfield(UD.verify,'jVerifyPanel')&&...
                    ~isempty(UD.verify.jVerifyPanel)
                    vnv_panel_mgr('sbClosePanel',UD.simulink.subsysH,UD.verify.jVerifyPanel);
                end


                function sigBuilderSimStart(dialog)



                    UD=get(dialog,'UserData');

                    UD=enter_iced_state_l(UD);

                    enableHgObjs=[UD.toolbar.stop,UD.toolbar.pause];
                    disableHgObjs=[UD.toolbar.start,UD.toolbar.playall];
                    set(enableHgObjs,'Enable','on');
                    set(disableHgObjs,'Enable','off');

                    set(UD.dialog,'Pointer','arrow');
                    renderBlockGraphics();


                    function sigBuilderSimPause(dialog)




                        UD=get(dialog,'UserData');

                        set(UD.toolbar.pause,'Enable','off');
                        set(UD.toolbar.start,'Enable','on');

                        set(UD.dialog,'Pointer','arrow');
                        renderBlockGraphics();


                        function sigBuilderSimStop(dialog)



                            UD=get(dialog,'UserData');

                            if~is_fastRestart_l(bdroot(gcbh))

                                UD=enter_idle_state_l(UD);
                            else
                                UD=enter_idle_state_l(UD);
                                UD=enter_iced_state_fastRestart(UD);
                            end

                            hgObjs=[UD.toolbar.stop,UD.toolbar.pause];
                            set(hgObjs,'Enable','off');
                            set(UD.toolbar.start,'Enable','on');
                            if strcmp(get_param(bdroot(gcbh),'InitializeInteractiveRuns'),'off')

                                set(UD.toolbar.playall,'Enable','on');
                            end
                            renderBlockGraphics();


                            function sigBuilderUpdateIcedStateForHarness(dialog,state)






                                if~ishghandle(dialog,'figure')
                                    return;
                                end

                                UD=get(dialog,'UserData');

                                if strcmp(state,'on')
                                    UD=enter_iced_state_l(UD);

                                    disableHgObjs=[UD.toolbar.start,UD.toolbar.pause,UD.toolbar.stop...
                                    ,UD.toolbar.playall];
                                    set(disableHgObjs,'Enable','off');

                                    set(UD.dialog,'Pointer','arrow');
                                    renderBlockGraphics();
                                else


                                    sigBuilderSimStop(dialog);

                                    set(UD.dialog,'Pointer','arrow');
                                end


                                function figHandle=open_gui(block,guiPos)
                                    global gSigBuildOpenInvisibleBlockH;

                                    model=bdroot(block);
                                    blockH=get_param(block,'Handle');
                                    modelH=get_param(model,'Handle');
                                    blockUD=get_param(block,'UserData');
                                    figHandle=-1;



                                    bd=get_param(modelH,'Object');
                                    if bd.hasCallback('PreShow',genvarname(getfullname(blockH)))
                                        bd.removeCallback('PreShow',genvarname(getfullname(blockH)));
                                    end

                                    if~isempty(gSigBuildOpenInvisibleBlockH)
                                        if(gSigBuildOpenInvisibleBlockH==blockH)
                                            evalin('base','clear(''global'',''gSigBuildOpenInvisibleBlockH'')');
                                            makeVisible=false;
                                        end
                                    else
                                        evalin('base','clear(''global'',''gSigBuildOpenInvisibleBlockH'')');
                                        makeVisible=true;
                                    end


                                    if(model_is_a_library(modelH)&&model_is_locked(modelH))


                                        use_model_message=strcmpi(model,'simulink3')||strcmpi(model,'simulink');
                                        if~use_model_message
                                            refBlk=get_param(blockH,'ReferenceBlock');
                                            if~isempty(refBlk)
                                                use_model_message=strcmpi(bdroot(refBlk),'simgens');
                                            end
                                        end
                                        if use_model_message
                                            errordlg(getString(message('sigbldr_blk:sigbuilder_block:BlockInModel')));
                                        else
                                            errordlg(getString(message('sigbldr_blk:sigbuilder_block:UnlockLibrary')));
                                        end
                                        return;
                                    end

                                    handleStruct=create_handleStruct(blockH);

                                    if is_a_reference(blockH)
                                        errordlg(getString(message('sigbldr_blk:sigbuilder_block:LinkedBlock')));
                                        return
                                    else
                                        if~isempty(blockUD)&&ishghandle(blockUD,'figure')
                                            if strcmp(get(blockUD,'Visible'),'off')
                                                set(blockUD,'Visible','on');
                                            end
                                            figure(blockUD);
                                            figHandle=blockUD;
                                            return;
                                        else

                                            figHandle=sigbuilder('SlBlockOpen',handleStruct,[]);

                                            disableSignalOutputMenu(figHandle,handleStruct);

                                            if model_is_locked(modelH)&&Simulink.harness.internal.hasActiveHarness(modelH)


                                                Simulink.harness.internal.setBDLock(modelH,false);
                                                set_param(blockH,'UserData',figHandle);
                                                Simulink.harness.internal.setBDLock(modelH,true);
                                            elseif model_is_a_library(modelH)&&model_is_locked(modelH)
                                                set_param(modelH,'lock','off');
                                                set_param(blockH,'UserData',figHandle);
                                                set_param(modelH,'lock','on');
                                            else
                                                set_param(blockH,'UserData',figHandle);
                                            end
                                        end
                                    end

                                    if~isempty(guiPos)&&~strcmp(get(figHandle,'WindowStyle'),'docked')
                                        set(figHandle,'Position',guiPos);
                                    end


                                    outerGuiPos=get(figHandle,'OuterPosition');
                                    setNeeded=false;

                                    screenUnits=get(0,'Units');
                                    set(0,'Units','Points');
                                    screenPos=get(0,'ScreenSize');
                                    set(0,'Units',screenUnits);

                                    if(abs(outerGuiPos(1))+abs(outerGuiPos(3)))>screenPos(3)
                                        outerGuiPos(1)=max(0,screenPos(3)-outerGuiPos(3));
                                        outerGuiPos(3)=min(outerGuiPos(3),screenPos(3));
                                        setNeeded=true;
                                    end

                                    if(abs(outerGuiPos(2))+abs(outerGuiPos(4)))>screenPos(4)
                                        outerGuiPos(2)=max(0,screenPos(4)-outerGuiPos(4));
                                        outerGuiPos(4)=min(outerGuiPos(4),screenPos(4));
                                        setNeeded=true;
                                    end

                                    if setNeeded
                                        set(figHandle,'OuterPosition',outerGuiPos);
                                    end

                                    if makeVisible
                                        set(figHandle,'Visible','on');
                                    end


                                    if model_is_locked(modelH)&&Simulink.harness.internal.hasActiveHarness(modelH)
                                        sigBuilderUpdateIcedStateForHarness(figHandle,'on');
                                    end



                                    function cmdStr=block_cmd_with_pos(command,dialogH)

                                        try
                                            pos=get(dialogH,'Position');
                                            posStr=['[',sprintf('%g ',pos),']'];
                                            cmdStr=['sigbuilder_block(''',command,''',',posStr,');'];
                                        catch %#ok<CTCH>
                                            cmdStr=['sigbuilder_block(''',command,''');'];
                                        end


                                        function handleStruct=create(dialog,nameCell,openModel,blckPath,blckPos)


                                            keep_hidden=~openModel;

                                            if nargin<5
                                                blckPos=[235,110,320,150];
                                            end

                                            if nargin<4
                                                modelH=new_system;
                                                model=get_param(modelH,'Name');
                                                blckPath=[model,'/Signal Builder'];
                                            else
                                                modelH=get_param(strtok(blckPath,'/'),'Handle');
                                            end




                                            dispCmd=['plot(0, 0, 100, 100,[2, 2, 32, 32, 2], [68, 8, 8, 68, 68],'...
                                            ,'[32, 2], [38, 38], [32, 19, 2],[53, 60, 44], [32, 17, 17, 2],[16, 16, 31, 31]);'...
                                            ,'txt = getActiveGroup(gcbh);text(2, 100, txt,''verticalAlignment'', ''top'');'];



                                            blckPos=range_check_position(blckPos);


                                            subsysH=add_block('built-in/Subsystem',blckPath,...
                                            'UserData',dialog,...
                                            'Position',blckPos,...
                                            'MaskType','Sigbuilder block',...
                                            'MaskDisplay',dispCmd,...
                                            'MaskIconOpaque','off',...
                                            'Tag','STV Subsys'...
                                            );


                                            set_param(subsysH,'CopyFcn','sigbuilder_block(''copy'');');


                                            p=Simulink.Mask.get(subsysH);
                                            p.addParameter('Name','tuvar','Value','[0:10]','Visible','off');




                                            fromWsH=add_block('built-in/FromWorkspace',[blckPath,'/FromWs'],...
                                            'Position',[30,300,115,350],...
                                            'Tag','STV FromWs',...
                                            'SampleTime','0',...
                                            'VariableName','tuvar');

                                            set_param(fromWsH,'UserData',fromWsH);




                                            portSpacing=20;







                                            if length(nameCell)*portSpacing>getMaxSupportedSignals


                                                portSpacing=getMaxSupportedSignals/length(nameCell);

                                            end

                                            try
                                                demuxH=add_block('built-in/Demux',[blckPath,'/Demux'],...
                                                'Position',[150,0,160,length(nameCell)*portSpacing],...
                                                'Tag','STV Demux',...
                                                'Outputs',num2str(length(nameCell)));

                                                add_line(blckPath,'FromWs/1','Demux/1');

                                                outPortH(length(nameCell))=0;

                                                for i=1:length(nameCell)
                                                    nameCell{i}=strrep(nameCell{i},'/','//');


                                                    if isequal(mod(i,2),1)
                                                        startXPos=250;
                                                    else
                                                        startXPos=350;
                                                    end


                                                    outPortH(i)=add_block(...
                                                    'built-in/Outport',[blckPath,'/',nameCell{i}],...
                                                    'Position',[startXPos,portSpacing*i,startXPos+portSpacing,portSpacing*i+10],...
                                                    'Tag','STV Outport',...
                                                    'Port',num2str(i));

                                                    add_line(blckPath,['Demux/',num2str(i)],[nameCell{i},'/1']);
                                                end
                                            catch addBlockError

                                                set(0,'ShowHiddenHandles','on');
                                                close(findobj('Tag','SignalBuilderGUI','Name','Signal Builder'));
                                                set(0,'ShowHiddenHandles','off');
                                                newExc=MException('sigbldr_blk:sigbuilder_block:tooManySignals',...
                                                getString(message('sigbldr_blk:sigbuilder_block:TooManySignals')));


                                                throw(newExc);
                                            end

                                            handleStruct.modelH=modelH;
                                            handleStruct.subsysH=subsysH;
                                            handleStruct.fromWsH=fromWsH;
                                            handleStruct.demuxH=demuxH;
                                            handleStruct.outPortH=outPortH;


                                            handleStruct.busCreatorH=[];
                                            handleStruct.outPortParentH=[];
                                            handleStruct.subsysChildH=[];


                                            disableSignalOutputMenu(dialog,handleStruct);

                                            if~keep_hidden
                                                open_system(modelH);
                                            end

                                            initCmd=['if ~strcmp(get_param(bdroot(gcb),''SimulationStatus''),''stopped''),'...
                                            ,'tuvar = sigbuilder_block(''maskInit''); end'];

                                            set_param(subsysH,...
                                            'OpenFcn','sigbuilder_block(''open'');',...
                                            'LoadFcn','sigbuilder_block(''load'');',...
                                            'CloseFcn','sigbuilder_block(''close'');',...
                                            'DeleteFcn','sigbuilder_block(''delete'');',...
                                            'ModelCloseFcn','sigbuilder_block(''modelClose'');',...
                                            'PreSaveFcn','sigbuilder_block(''preSave'');',...
                                            'StartFcn','sigbuilder_block(''start'');',...
                                            'StopFcn','sigbuilder_block(''stop'');',...
                                            'PauseFcn','sigbuilder_block(''pause'');',...
                                            'ContinueFcn','sigbuilder_block(''continue'');',...
                                            'NameChangeFcn','sigbuilder_block(''namechange'');',...
                                            'ClipboardFcn','sigbuilder_block(''clipboard'');',...
                                            'MaskIconRotate','on',...
                                            'MaskInitialization',initCmd,...
                                            'MaskHideContents','on',...
                                            'maskRunInitForIconRedraw','on');


                                            vnv_notify('sbBlkCopy',subsysH);


                                            function isRef=is_a_reference(blockH)


                                                if isempty(get_param(blockH,'ReferenceBlock'))
                                                    isRef=0;
                                                else
                                                    isRef=1;
                                                end


                                                function isLink=is_a_link(blockH)


                                                    if strcmpi(get_param(blockH,'LinkStatus'),'None')
                                                        isLink=0;
                                                    else
                                                        isLink=1;
                                                    end


                                                    function result=model_is_a_library(modelH)

                                                        if strcmpi(get_param(modelH,'BlockDiagramType'),'library'),result=1;
                                                        else
                                                            result=0;
                                                        end


                                                        function result=model_is_locked(modelH)



                                                            result=strcmpi(get_param(modelH,'lock'),'on');


                                                            function hStruct=delete_outport(hStruct,index)



                                                                BUS=(isfield(hStruct,'busCreatorH')&&~isempty(hStruct.busCreatorH));


                                                                origCnt=length(hStruct.outPortH);
                                                                for i=index:origCnt
                                                                    remove_out_line(hStruct.demuxH,i);
                                                                    if BUS
                                                                        remove_out_line(hStruct.subsysChildH,i);
                                                                    end
                                                                end

                                                                delete_block(hStruct.outPortH(index));
                                                                hStruct.outPortH(index)=[];

                                                                set_param(hStruct.demuxH,'Outputs',num2str(origCnt-1));

                                                                for i=index:(origCnt-1)
                                                                    addline(hStruct.demuxH,i,hStruct.outPortH(i),1);
                                                                end

                                                                position_ports(hStruct);


                                                                type=get_param(hStruct.subsysH,'IOType');
                                                                if(strcmp(type,'siggen'))
                                                                    sigs=get_param(hStruct.subsysH,'IOSignals');
                                                                    new_sigs=cell(length(sigs)-1,1);
                                                                    for i=1:index-1
                                                                        new_sigs{i}=sigs{i};
                                                                    end
                                                                    for i=index:length(new_sigs)
                                                                        new_sigs{i}=sigs{i+1};
                                                                    end
                                                                    set_param(hStruct.subsysH,'IOSignals',new_sigs);
                                                                end

                                                                if BUS
                                                                    updateSubSysPortNames(hStruct.subsysChildH,hStruct.outPortH);


                                                                    set_param(hStruct.busCreatorH,'Inputs',num2str(origCnt-1));
                                                                    for i=index:(origCnt-1)
                                                                        addline(hStruct.subsysChildH,i,hStruct.busCreatorH,i);
                                                                    end
                                                                end


                                                                function hStruct=add_outport(hStruct,index,name)

                                                                    BUS=(isfield(hStruct,'busCreatorH')&&~isempty(hStruct.busCreatorH));





                                                                    isSiggen=false;
                                                                    type=get_param(hStruct.subsysH,'IOType');
                                                                    if(strcmp(type,'siggen'))
                                                                        isSiggen=true;
                                                                        sigs=get_param(hStruct.subsysH,'IOSignals');
                                                                    end


                                                                    origCnt=length(hStruct.outPortH);
                                                                    for i=index:origCnt
                                                                        remove_out_line(hStruct.demuxH,i);
                                                                        if BUS
                                                                            remove_out_line(hStruct.subsysChildH,i);
                                                                        end
                                                                    end

                                                                    set_param(hStruct.demuxH,'Outputs',num2str(origCnt+1));
                                                                    if BUS
                                                                        sysName=getfullname(hStruct.subsysChildH);
                                                                    else
                                                                        sysName=getfullname(hStruct.subsysH);
                                                                    end


                                                                    hStruct.outPortH((index:end)+1)=hStruct.outPortH(index:end);

                                                                    name=strrep(name,'/','//');

                                                                    hStruct.outPortH(index)=add_block(...
                                                                    'built-in/Outport',[sysName,'/',name],...
                                                                    'Position',[320,30,340,40],...
                                                                    'Tag','STV Outport',...
                                                                    'Port',num2str(index));

                                                                    for i=index:(origCnt+1)
                                                                        addline(hStruct.demuxH,i,hStruct.outPortH(i),1);
                                                                    end

                                                                    try
                                                                        position_ports(hStruct);
                                                                    catch addBlockError
                                                                        newExc=MException('sigbldr_blk:sigbuilder_block:tooManySignals',...
                                                                        getString(message('sigbldr_blk:sigbuilder_block:TooManySignals')));


                                                                        throw(newExc);
                                                                    end



                                                                    if isSiggen==true

                                                                        new_sigs=cell(length(sigs)+1,1);
                                                                        for i=1:index-1
                                                                            new_sigs{i}=sigs{i};
                                                                        end
                                                                        new_sigs{index}=struct('Handle',-1,'RelativePath','');
                                                                        for i=index:length(sigs)
                                                                            new_sigs{i+1}=sigs{i};
                                                                        end
                                                                        set_param(hStruct.subsysH,'IOSignals',new_sigs);

                                                                    end

                                                                    if BUS
                                                                        updateSubSysPortNames(hStruct.subsysChildH,hStruct.outPortH);


                                                                        set_param(hStruct.busCreatorH,'Inputs',num2str(origCnt+1));
                                                                        for i=index:(origCnt+1)
                                                                            addline(hStruct.subsysChildH,i,hStruct.busCreatorH,i);
                                                                        end
                                                                    end


                                                                    function hStruct=rename_outport(hStruct,index,name)
                                                                        set_param(hStruct.outPortH(index),'Name',name);


                                                                        if(isfield(hStruct,'busCreatorH')&&~isempty(hStruct.busCreatorH))
                                                                            updateSubSysPortNames(hStruct.subsysChildH,hStruct.outPortH);
                                                                        end


                                                                        type=get_param(hStruct.subsysH,'IOType');
                                                                        if(strcmp(type,'siggen'))
                                                                            sigs=get_param(hStruct.subsysH,'IOSignals');
                                                                            set_param(hStruct.subsysH,'IOSignals',sigs);
                                                                        end


                                                                        function hStruct=move_port(hStruct,oldIdx,newIdx)


                                                                            portCnt=length(hStruct.outPortH);
                                                                            for i=1:portCnt
                                                                                remove_out_line(hStruct.demuxH,i);
                                                                            end

                                                                            if oldIdx>newIdx
                                                                                old2newIdx=[1:(newIdx-1),(newIdx+1):oldIdx,newIdx,(oldIdx+1):portCnt];
                                                                            else
                                                                                old2newIdx=[1:(oldIdx-1),newIdx,oldIdx:(newIdx-1),(newIdx+1):portCnt];
                                                                            end

                                                                            hStruct.outPortH=hStruct.outPortH(old2newIdx);

                                                                            for i=1:portCnt
                                                                                addline(hStruct.demuxH,i,hStruct.outPortH(i),1);
                                                                            end

                                                                            number_ports(hStruct)
                                                                            position_ports(hStruct);


                                                                            type=get_param(hStruct.subsysH,'IOType');
                                                                            if(strcmp(type,'siggen'))
                                                                                sigs=get_param(hStruct.subsysH,'IOSignals');
                                                                                temp=sigs{oldIdx};
                                                                                sigs{oldIdx}=sigs{newIdx};
                                                                                sigs{newIdx}=temp;
                                                                                set_param(hStruct.subsysH,'IOSignals',sigs);
                                                                            end

                                                                            if(isfield(hStruct,'busCreatorH')&&~isempty(hStruct.busCreatorH))
                                                                                for i=1:portCnt
                                                                                    remove_out_line(hStruct.subsysChildH,i);
                                                                                end


                                                                                for i=1:portCnt
                                                                                    addline(hStruct.subsysChildH,i,hStruct.busCreatorH,i);
                                                                                end
                                                                            end


                                                                            function hStruct=output_FlatBus(hStruct)


                                                                                if(isfield(hStruct,'busCreatorH')&&~isempty(hStruct.busCreatorH))
                                                                                    return;
                                                                                end


                                                                                blckPath=getfullname(hStruct.subsysH);
                                                                                blckPathChild=[blckPath,'/Subsystem'];
                                                                                posvect=[150,200,200,600];
                                                                                subsysChildH=add_block('built-in/Subsystem',blckPathChild,...
                                                                                'Position',posvect);


                                                                                demuxH=add_block(hStruct.demuxH,[blckPathChild,'/Demux']);
                                                                                nSignals=length(hStruct.outPortH);
                                                                                outPortH=zeros(nSignals,1);
                                                                                for k=1:nSignals
                                                                                    name=get_param(hStruct.outPortH(k),'Name');
                                                                                    outPortH(k)=add_block(hStruct.outPortH(k),[blckPathChild,'/',name]);
                                                                                    addline(demuxH,k,outPortH(k),1);
                                                                                end
                                                                                inputH=add_block('built-in/Inport',[blckPathChild,'/In1'],...
                                                                                'Position',[posvect(1)-100,posvect(2)+120,posvect(3)-130,posvect(4)-270]);
                                                                                addline(inputH,1,demuxH,1);


                                                                                updateSubSysPortNames(subsysChildH,outPortH);


                                                                                remove_out_line(hStruct.fromWsH,1);
                                                                                addline(hStruct.fromWsH,1,subsysChildH,1);


                                                                                busCreatorH=add_block('built-in/BusCreator',[blckPath,'/Bus Creator'],...
                                                                                'Position',[posvect(1)+150,posvect(2),posvect(3)+120,posvect(4)],...
                                                                                'Tag','Bus Creator',...
                                                                                'Inputs',num2str(nSignals));


                                                                                for i=1:nSignals
                                                                                    remove_out_line(hStruct.demuxH,i);
                                                                                    addline(subsysChildH,i,busCreatorH,i);
                                                                                end



                                                                                for i=1:length(hStruct.outPortH)
                                                                                    delete_block(hStruct.outPortH(i));
                                                                                end
                                                                                delete_block(hStruct.demuxH);


                                                                                outPortParentH=add_block('built-in/Outport',[blckPath,'/Bus'],'Position',...
                                                                                [posvect(1)+230,posvect(2)+180,posvect(3)+200,posvect(4)-210]);
                                                                                add_line(blckPath,'Bus Creator/1','Bus/1');


                                                                                hStruct.busCreatorH=busCreatorH;
                                                                                hStruct.subsysChildH=subsysChildH;
                                                                                hStruct.outPortParentH=outPortParentH;
                                                                                hStruct.outPortH=outPortH;
                                                                                hStruct.demuxH=demuxH;


                                                                                function hStruct=output_Ports(hStruct)
                                                                                    if(~isfield(hStruct,'busCreatorH')||isempty(hStruct.busCreatorH))
                                                                                        return;
                                                                                    end

                                                                                    nSignals=length(hStruct.outPortH);
                                                                                    for i=1:nSignals
                                                                                        remove_out_line(hStruct.subsysChildH,i);
                                                                                    end
                                                                                    remove_out_line(hStruct.busCreatorH,1);
                                                                                    delete_block(hStruct.busCreatorH);
                                                                                    delete_block(hStruct.outPortParentH);
                                                                                    hStruct.busCreatorH=[];
                                                                                    hStruct.outPortParentH=[];


                                                                                    blckPath=getfullname(hStruct.subsysH);
                                                                                    demuxH=add_block(hStruct.demuxH,[blckPath,'/Demux']);
                                                                                    outPortH=zeros(nSignals,1);
                                                                                    for k=1:nSignals
                                                                                        name=get_param(hStruct.outPortH(k),'Name');
                                                                                        outPortH(k)=add_block(hStruct.outPortH(k),[blckPath,'/',name]);
                                                                                        addline(demuxH,k,outPortH(k),1);
                                                                                    end
                                                                                    remove_out_line(hStruct.fromWsH,1);
                                                                                    addline(hStruct.fromWsH,1,demuxH,1);
                                                                                    hStruct.demuxH=demuxH;
                                                                                    hStruct.outPortH=outPortH;


                                                                                    delete_block(hStruct.subsysChildH);
                                                                                    hStruct.subsysChildH=[];


                                                                                    function updateSubSysPortNames(subsysH,outPortH)


                                                                                        subsysPortH=get_param(subsysH,'PortHandles');
                                                                                        for k=1:length(outPortH)
                                                                                            set_param(subsysPortH.('Outport')(k),'Name',get_param(outPortH(k),'Name'));
                                                                                        end


                                                                                        function position_ports(hStruct)
                                                                                            num_outports=length(hStruct.outPortH);

                                                                                            if num_outports>getMaxSupportedSignals

                                                                                                newExc=MException('sigbldr_blk:sigbuilder_block:tooManySignals',...
                                                                                                getString(message('sigbldr_blk:sigbuilder_block:TooManySignals')));


                                                                                                throw(newExc);
                                                                                            end

                                                                                            if(30*num_outports)<getMaxSupportedSignals
                                                                                                space_between_ports=30;
                                                                                            else
                                                                                                space_between_ports=floor(getMaxSupportedSignals/num_outports);
                                                                                            end
                                                                                            for i=1:length(num_outports)
                                                                                                set_param(hStruct.outPortH(i),'Position',[280,...
                                                                                                space_between_ports*i,...
                                                                                                300,...
                                                                                                space_between_ports*i+10]);
                                                                                            end


                                                                                            function number_ports(hStruct)
                                                                                                for i=1:length(hStruct.outPortH)
                                                                                                    set_param(hStruct.outPortH(i),'Port',num2str(i));
                                                                                                end


                                                                                                function remove_out_line(blockH,index)

                                                                                                    portHandles=get_param(blockH,'PortHandles');
                                                                                                    thisPort=portHandles.Outport(index);
                                                                                                    try
                                                                                                        hL=get_param(thisPort,'Line');
                                                                                                        delete_line(hL);
                                                                                                    catch %#ok<CTCH>
                                                                                                    end


                                                                                                    function addline(srcH,srcIdx,dstH,dstIdx)



                                                                                                        parentStr=get_param(srcH,'Parent');
                                                                                                        srcName=strrep(get_param(srcH,'Name'),'/','//');
                                                                                                        srcStr=[srcName,'/',num2str(srcIdx)];
                                                                                                        destName=strrep(get_param(dstH,'Name'),'/','//');
                                                                                                        destStr=[destName,'/',num2str(dstIdx)];

                                                                                                        add_line(parentStr,srcStr,destStr);


                                                                                                        function disableSignalOutputMenu(figHandle,handleStruct)



                                                                                                            type=get_param(handleStruct.subsysH,'IOType');
                                                                                                            UD=get(figHandle,'UserData');
                                                                                                            figmenu=UD.menus.figmenu;
                                                                                                            if(strcmp(type,'siggen'))
                                                                                                                set(figmenu.SignalMenuOutput,'Visible','off');
                                                                                                            end


                                                                                                            if isempty(handleStruct.busCreatorH)
                                                                                                                set(figmenu.SignalMenuOutputPorts,'Enable','off');
                                                                                                            else
                                                                                                                set(figmenu.SignalMenuOutputFlatBus,'Enable','off');
                                                                                                            end


                                                                                                            function handleStruct=create_handleStruct(blockH)

                                                                                                                handleStruct.subsysH=blockH;
                                                                                                                handleStruct.modelH=bdroot(blockH);


                                                                                                                handleStruct.fromWsH=find_system(blockH,'FollowLinks','on',...
                                                                                                                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                                                                                'LookUnderMasks','all','BlockType','FromWorkspace');
                                                                                                                handleStruct.demuxH=find_system(blockH,'FollowLinks','on',...
                                                                                                                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                                                                                'LookUnderMasks','all','BlockType','Demux');
                                                                                                                handleStruct.busCreatorH=find_system(blockH,'FollowLinks','on',...
                                                                                                                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                                                                                'LookUnderMasks','all','BlockType','BusCreator');


                                                                                                                if isempty(handleStruct.busCreatorH)


                                                                                                                    outports=find_system(blockH,'FollowLinks','on','LookUnderMasks','all',...
                                                                                                                    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                                                                                    'BlockType','Outport');
                                                                                                                    handleStruct.outPortParentH=[];
                                                                                                                    handleStruct.subsysChildH=[];
                                                                                                                else
                                                                                                                    subsysHandles=find_system(blockH,'FollowLinks','on',...
                                                                                                                    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                                                                                    'LookUnderMasks','all','BlockType','SubSystem');
                                                                                                                    handleStruct.subsysChildH=subsysHandles(subsysHandles~=blockH);
                                                                                                                    handleStruct.outPortParentH=find_system(blockH,'SearchDepth',1,'FollowLinks','on','LookUnderMasks',...
                                                                                                                    'all','BlockType','Outport');
                                                                                                                    outports=find_system(handleStruct.subsysChildH,'FollowLinks','on','LookUnderMasks','all',...
                                                                                                                    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                                                                                    'BlockType','Outport');
                                                                                                                end


                                                                                                                portNums=get_param(outports,'Port');
                                                                                                                if iscell(portNums)
                                                                                                                    portNums=str2double(portNums);
                                                                                                                    [~,sortIdx]=sort(portNums);
                                                                                                                    handleStruct.outPortH=outports(sortIdx);
                                                                                                                else
                                                                                                                    handleStruct.outPortH=outports;
                                                                                                                end


                                                                                                                function renderBlockGraphics()



                                                                                                                    SLM3I.SLDomain.refreshBlockGraphics();


                                                                                                                    function pos=range_check_position(blckPos)




                                                                                                                        pos=min(blckPos,32767);

                                                                                                                        if pos(1)>pos(3)
                                                                                                                            pos(1)=pos(3);
                                                                                                                        end

                                                                                                                        if pos(2)>pos(4)
                                                                                                                            pos(2)=pos(4);
                                                                                                                        end


                                                                                                                        function tuvarInitMaskWS(blockH)

                                                                                                                            linkStatus=get_param(blockH,'LinkStatus');
                                                                                                                            p=Simulink.Mask.get(blockH);
                                                                                                                            tuvarInMaskWS=p.getParameter('tuvar');
                                                                                                                            if isempty(tuvarInMaskWS)&&strcmp(linkStatus,'none')
                                                                                                                                p.addParameter('Name','tuvar','Value','[0:10]','Visible','off');
                                                                                                                            elseif~isempty(tuvarInMaskWS)&&strcmpi(tuvarInMaskWS.Visible,'on')&&strcmp(linkStatus,'none')

                                                                                                                                tuvarInMaskWS.Visible='off';
                                                                                                                            end


