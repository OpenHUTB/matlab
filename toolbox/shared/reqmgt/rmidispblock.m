function varargout=rmidispblock(method,varargin)




    h=varargin{1};
    switch(method)
    case 'updatesys'

        winH=get_SystemReq(h);
        if~isempty(winH)
            if length(varargin)>1
                refresh_display(winH,varargin{2});
            else
                refresh_display(winH,true);
            end
        end

    case 'updateall'
        modelH=varargin{1};
        if length(varargin)>1
            refresh_contents=varargin{2};
        else
            refresh_contents=false;
        end




        preserve_dirty=Simulink.PreserveDirtyFlag(modelH,'blockDiagram');%#ok<NASGU>

        modelObj=get_param(modelH,'Object');
        allSysReqBlocks=find(modelObj,'MaskType','System Requirements');
        if~isempty(allSysReqBlocks)
            for i=1:length(allSysReqBlocks)
                if isPostponed(allSysReqBlocks(i).Handle)
                    continue;
                end
                subsys=allSysReqBlocks(i).Parent;
                rmidispblock('updatesys',subsys,refresh_contents);
            end
        end

    case 'display'

        p=get_param(h,'Position');
        height=p(4)-p(2);
        width=p(3)-p(1);
        varargout{1}=width;
        varargout{2}=height;

    case 'create'



        if is_implicit_link(h)
            set_cache(h,[]);
            refresh_display(h);
            return;
        end


        sysH=get_param(h,'Parent');



        systemReqBlocks=find_system(sysH,'SearchDepth',1,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'MaskType','System Requirements');
        if length(systemReqBlocks)>1

            error_duplicate_block(h);
        elseif length(systemReqBlocks)==1&&isempty(get_param(h,'MaskType'))

            error_duplicate_block(h);
        else
            initialize_window(h);
            if Simulink.harness.isHarnessBD(bdroot(sysH))==false




                refresh_display(h);
            end
        end

    case 'copyReq'



        if is_locked(h)||is_implicit_link(h)
            return;
        end


        if repeated_index(h)
            error_duplicate_block(h);
        else



            if isempty(find_system(get_param(h,'Parent'),'SearchDepth',1,...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'MaskType','System Requirements'))
                convert_req_to_win(h);
            end
            refresh_display(h);
        end

    case 'title'
        if is_implicit_link(h)
            try
                get_param(get_param(h,'ReferenceBlock'),'Handle');
                out=get_param(h,'title');
            catch ex %#ok<NASGU>

                varargout{1}='<Disabled (inside link)>';
                return;
            end
        else
            out=get_param(h,'title');
        end


        sysReqBlkH=get_param(h,'Handle');
        if isPostponed(sysReqBlkH)
            isPostponed(sysReqBlkH,false);
            refresh_display(h);
        else

            curReqs=get_current_reqs(sysReqBlkH);
            boxZOrder=get_param(sysReqBlkH,'ZOrder');
            for i=1:length(curReqs)
                reqZOrder=get_param(curReqs(i),'ZOrder');
                if reqZOrder<boxZOrder
                    set_param(curReqs(i),'ZOrder',boxZOrder+i);
                end
            end
        end
        varargout{1}=out;

    case{'load','move'}
        refresh_display(h);

    case 'open'
        set_cache(h,[]);
        refresh_display(h);

    case 'openReq'

        if is_implicit_link(h)

            try
                mdlParent=get_param(h,'Parent');
                libParent=get_param(mdlParent,'ReferenceBlock');

                try
                    get_param(libParent,'Handle');
                catch ex %#ok<NASGU>
                    libName=strtok(libParent,'/');
                    load_system(libName);
                end
                rmi('view',libParent,str2double(get_param(h,'index')));
            catch ex %#ok<NASGU>
                warndlg('Please refer to the library block for requirements.','View Requirements','modal');
            end
        else
            rmi('view',get_param(h,'Parent'),str2double(get_param(h,'index')));
        end

    case{'close','delete'}



        if~is_locked(h)&&~is_link(h)&&~Simulink.harness.isHarnessBD(bdroot(h))
            if nargin>2

                set_param(h,'ModelCloseFcn','');
                set_param(h,'PreSaveFcn','');
                set_param(h,'DeleteFcn','');
                delete_block(h);
            else
                delete_req(h,h);
            end
        end

    case 'deleteReq'



        mySystem=get_param(h,'Parent');
        winH=get_SystemReq(mySystem);
        if~isempty(winH)&&~is_locked(winH)&&~is_link(winH)

            delete_req(h,h);
            rmidispblock('delete',winH,h);

            set_param(h,'ModelCloseFcn','');
            set_param(h,'PreSaveFcn','');
            set_param(h,'DeleteFcn','');
        end

    case 'label'

        index=h;
        parentH=get_param(gcbh,'Parent');
        winH=get_SystemReq(parentH);
        doColor=true;

        if is_link(gcbh)

            libBlock=get_param(parentH,'ReferenceBlock');
            doColor=false;
            try
                parentH=get_param(libBlock,'Handle');
            catch ex %#ok<NASGU>
                varargout{1}=[num2str(index),'. <???>'];
                set_cache(winH,[]);
                return;
            end
        end

        [allLabels,enabled]=rmi.getLinkLabels(parentH);

        if index>length(allLabels)
            label='';
            set_cache(winH,[]);
        else

            if doColor






                if~enabled(index)
                    set_param(gcbh,'ForegroundColor','gray');
                elseif strcmp(get_param(bdroot,'ReqHilite'),'on')
                    set_param(gcbh,'HiliteAncestors','off')
                    set_param(gcbh,'ForegroundColor','orange');
                else
                    set_param(gcbh,'ForegroundColor','blue');
                end
            end

            if isempty(allLabels{index})
                label=[num2str(index),'. ',getString(message('Slvnv:reqmgt:NoDescriptionEntered'))];
            else
                try
                    label=[num2str(index),'. ','"',allLabels{index},'"'];
                catch Mex %#ok<NASGU>
                    label='';
                    set_cache(winH,[]);
                end
            end
        end
        varargout{1}=label;

    otherwise
        error(message('Slvnv:reqmgt:rmidispblock:UnknownMethod',method));
    end

    function out=get_title_code(h,w)
        out=sprintf('text(%s/2,%s-4,rmidispblock(''title'',gcbh),''horizontalAlignment'',''center'',''verticalAlignment'',''top'')',w,h);

        function tf=isPostponed(varargin)
            persistent postponed
            if~isa(postponed,'containers.Map')
                postponed=containers.Map('KeyType','double','ValueType','logical');
            end
            tf=false;
            if nargin==2
                if isKey(postponed,varargin{1})
                    if varargin{2}

                    else
                        postponed(varargin{1})=false;
                    end
                else
                    postponed(varargin{1})=varargin{2};
                    tf=varargin{2};
                end
            elseif isKey(postponed,varargin{1})
                tf=postponed(varargin{1});
            end


            function refresh_display(curH,varargin)


                if is_SystemReq(curH)


                    parentModel=get_param(bdroot(curH),'Object');
                    parentSys=get_param(get_param(curH,'Parent'),'Object');
                    if strcmp(parentModel.Open,'off')&&strcmp(parentSys.Open,'off')
                        if isPostponed(curH,true)
                            return;
                        end
                    end
                end


                if isempty(curH)||is_locked(curH)||is_link(curH)
                    return;
                end

                if~isempty(varargin)
                    recreate=varargin{1};
                else
                    recreate=true;
                end

                if is_SystemReq(curH)
                    winH=curH;
                elseif is_SystemReqItem(curH)
                    window=get_param(curH,'Parent');
                    winH=get_SystemReq(window);
                else
                    return;
                end

                if isempty(winH)
                    convert_req_to_win(curH);
                    winH=curH;
                end


                if winH==curH



                    [oldWinWidth,oldWinHeight]=get_previous_size(winH);
                    [newWinWidth,newWinHeight]=rmidispblock('display',winH);
                    nCurReqs=length(get_current_reqs(winH));
                    nActReqs=rmi('count',get_param(winH,'Parent'));

                    if~recreate

                        update_labels(winH)

                    else

                        if oldWinHeight<0||oldWinWidth<0
                            title_code=get_title_code('h','w');
                        else
                            title_code=get_title_code(int2str(newWinHeight),int2str(newWinWidth));
                        end

                        if nActReqs==0


                            noReqCode='text(w/2,h/2,''<No Requirements in System>'',''horizontalAlignment'',''center'',''verticalAlignment'',''top'')';
                            set_param(winH,'MaskDisplay',sprintf('%s\n%s',title_code,noReqCode));

                            if nCurReqs>0

                                delete_req(winH);
                                curReq=zeros(1,0);
                                set_current_reqs(winH,curReq);
                            end

                        elseif nActReqs~=nCurReqs||...
                            newWinHeight~=oldWinHeight||...
                            newWinWidth~=oldWinWidth



                            fitReq=get_num_requirement_display(winH);


                            if fitReq<nActReqs
                                addReqCode='text(w/2,15,''\fontsize{20}\ldots'',''texmode'',''on'')';
                                set_param(winH,'MaskDisplay',sprintf('%s\n%s',title_code,addReqCode));


                            else
                                set_param(winH,'MaskDisplay',title_code);
                            end

                            recreate_reqs(winH,fitReq);
                            set_previous_size(winH,newWinHeight,newWinWidth);

                        else
                            move_reqs(winH,-1);
                        end
                    end


                else





                    winPos=get_new_window_position(curH);
                    set_param(winH,'MoveFcn','');
                    set_param(winH,'Position',winPos);
                    set_param(winH,'MoveFcn','rmidispblock(''move'',gcbh)');




                    curReqIndex=str2double(get_param(curH,'index'));
                    move_reqs(winH,curReqIndex);



                    actPosition=get_param(winH,'Position');
                    if winPos(1)<actPosition(1)||winPos(2)<actPosition(2)
                        fix_bad_move(winH,curReqIndex);
                    end
                end

                function update_labels(winH)
                    parentH=get_param(winH,'Parent');
                    sysPath=getfullname(parentH);
                    fitReq=get_num_requirement_display(winH);
                    for i=1:fitReq
                        childBlock=[sysPath,'/SLVnV Internal Requirement Sub Block Name ',num2str(i)];
                        try
                            reqH=get_param(childBlock,'Handle');
                            Simulink.Block.eval(reqH);
                        catch ex %#ok<NASGU>

                            isPostponed(winH,true);
                        end
                    end

                    function move_reqs(winH,curReqIndex)

                        reqPos=get_new_req_position(winH);
                        reqHeight=reqPos(4)-reqPos(2);
                        reqWidth=reqPos(3)-reqPos(1);
                        reqX1=reqPos(1);
                        reqY1=reqPos(2);


                        curReq=get_current_reqs(winH);

                        for i=1:length(curReq)
                            origMoveFcn=get_param(curReq(i),'MoveFcn');
                            set_param(curReq(i),'MoveFcn','');


                            if(i~=curReqIndex)
                                set_param(curReq(i),'Position',[reqX1,...
                                reqY1,...
                                reqX1+reqWidth,...
                                reqY1+reqHeight]);
                            end

                            set_param(curReq(i),'MoveFcn',origMoveFcn);
                            reqY1=reqY1+reqHeight;
                        end

                        function recreate_reqs(winH,fitReq)

                            reqPos=get_new_req_position(winH);
                            reqHeight=reqPos(4)-reqPos(2);
                            reqWidth=reqPos(3)-reqPos(1);
                            reqX1=reqPos(1);
                            reqY1=reqPos(2);


                            reqHeight=max(reqHeight,2);
                            reqWidth=max(reqWidth,2);

                            delete_req(winH);


                            if nargin==1
                                fitReq=get_num_requirement_display(winH);
                            end


                            load_system('reqmanage');
                            curReq=zeros(1,fitReq);
                            sysPath=getfullname(get_param(winH,'Parent'));
                            for i=1:fitReq

                                try
                                    curReq(i)=add_block('reqmanage/System Requirements/Subsystem',...
                                    [sysPath,'/SLVnV Internal Requirement Sub Block Name ',num2str(i)]);
                                catch Mex %#ok<NASGU>
                                    curReq(i)=add_block('reqmanage/System Requirements/Subsystem',...
                                    [sysPath,'/SLVnV Internal Requirement Sub Block Name ',num2str(i),' ']);
                                end

                                set_param(curReq(i),'LinkStatus','none');
                                set_param(curReq(i),'MoveFcn','');
                                set_param(curReq(i),'Position',[reqX1,...
                                reqY1,...
                                reqX1+reqWidth,...
                                reqY1+reqHeight]);
                                initialize_req(curReq(i));

                                if i~=str2double(get_param(curReq(i),'index'))
                                    set_param(curReq(i),'index',num2str(i));
                                else

                                    Simulink.Block.eval(curReq(i));
                                end

                                reqY1=reqY1+reqHeight;
                            end
                            set_current_reqs(winH,curReq);

                            function delete_req(h,doNotDelete)

                                if nargin==1
                                    doNotDelete=[];
                                end

                                winH=get_SystemReq(h);
                                curReqs=get_current_reqs(winH);

                                for i=1:length(curReqs)

                                    if~isequal(curReqs(i),doNotDelete)
                                        set_param(curReqs(i),'LinkStatus','none');
                                        set_param(curReqs(i),'DeleteFcn','');
                                        set_param(curReqs(i),'MoveFcn','');
                                        delete_block(curReqs(i));
                                    end
                                end
                                set_current_reqs(winH,[]);


                                function convert_req_to_win(reqH)

                                    set_param(reqH,'LinkStatus','none');


                                    set_param(reqH,'MoveFcn','');
                                    winPos=get_new_window_position(reqH);
                                    try
                                        set_param(reqH,'Position',winPos);
                                    catch Mex %#ok<NASGU>
                                    end

                                    load_system('reqmanage');
                                    libH=get_param('reqmanage/System Requirements','Handle');



                                    reqH=get_param(reqH,'Handle');
                                    aLibMask=Simulink.Mask.get(libH);
                                    aReqMask=Simulink.Mask.get(reqH);
                                    if isempty(aReqMask)
                                        aReqMask=Simulink.Mask.create(reqH);
                                    end
                                    aReqMask.copy(aLibMask);


                                    set_param(reqH,'Name','System Requirements');


                                    set_param(reqH,'ForegroundColor',get_param(libH,'ForegroundColor'));
                                    set_param(reqH,'BackgroundColor',get_param(libH,'BackgroundColor'));


                                    initialize_window(reqH);


                                    function newWinPos=get_new_window_position(reqH)

                                        winH=get_SystemReq(reqH);
                                        titleHeight=get_title_height(winH);
                                        reqHeight=get_requirement_height(winH);
                                        border=get_window_border;


                                        if~isempty(winH)
                                            winPos=get_param(winH,'Position');
                                        else
                                            load_system('reqmanage');
                                            winPos=get_param('reqmanage/System Requirements','Position');
                                        end
                                        origWinHeight=winPos(4)-winPos(2);


                                        curReqIndex=str2double(get_param(reqH,'index'));


                                        reqPos=get_param(reqH,'Position');
                                        reqWidth=reqPos(3)-reqPos(1);
                                        reqX1=reqPos(1);
                                        reqY1=reqPos(2)-(curReqIndex-1)*reqHeight;

                                        winX1=reqX1-border;
                                        winY1=reqY1-titleHeight;
                                        newWinPos=[winX1,...
                                        winY1,...
                                        winX1+reqWidth+2*border,...
                                        winY1+origWinHeight];

                                        function newReqPos=get_new_req_position(winH)

                                            titleHeight=get_title_height(winH);
                                            reqHeight=get_requirement_height(winH);
                                            border=get_window_border;


                                            winPos=get_param(winH,'Position');
                                            winWidth=winPos(3)-winPos(1);
                                            reqWidth=winWidth-2*border;


                                            reqX1=winPos(1)+border;
                                            reqY1=winPos(2)+titleHeight;
                                            newReqPos=[reqX1,...
                                            reqY1,...
                                            reqX1+reqWidth,...
                                            reqY1+reqHeight];

                                            function border=get_window_border

                                                border=5;

                                                function reqHeight=get_requirement_height(winH)

                                                    reqHeight=get_title_height(winH);

                                                    function titleHeight=get_title_height(winH)

                                                        pad=8;
                                                        fontSize=get_window_font_size(winH);
                                                        titleHeight=fontSize+pad;

                                                        function fitReq=get_num_requirement_display(winH)

                                                            winPos=get_param(winH,'Position');
                                                            reqHeight=get_requirement_height(winH);
                                                            titleHeight=get_title_height(winH);
                                                            reqHeightList=winPos(4)-winPos(2)-titleHeight;

                                                            numReq=rmi('count',get_param(winH,'Parent'));
                                                            fitReq=min(numReq,floor(reqHeightList/reqHeight));

                                                            function out=get_window_font_size(winH)

                                                                try
                                                                    out=get_param(winH,'FontSize');
                                                                    sysH=bdroot(winH);
                                                                catch Mex %#ok<NASGU>
                                                                    out=-1;
                                                                    sysH=bdroot(gcs);
                                                                end
                                                                if isempty(sysH)
                                                                    sysH=bdroot(gcs);
                                                                end

                                                                if isempty(out)||(out==-1)
                                                                    out=get_param(sysH,'DefaultBlockFontSize');
                                                                end


                                                                function error_duplicate_block(h)

                                                                    set_param(h,'LinkStatus','none');
                                                                    set_param(h,'DeleteFcn','');
                                                                    errH=errordlg(...
                                                                    getString(message('Slvnv:reqmgt:rmi:SysReqBlockExists')),...
                                                                    getString(message('Slvnv:reqmgt:rmi:SysReqBlockError')),'modal');
                                                                    set(errH,'UserData',h);
                                                                    set(errH,'CloseRequestFcn',@fig_delete_block);
                                                                    okH=findall(errH,'Tag','OKButton');
                                                                    set(okH,'Callback',@fig_delete_block);

                                                                    function fig_delete_block(varargin)

                                                                        try
                                                                            blockH=get(gcbf,'UserData');
                                                                            if ishandle(blockH)
                                                                                delete_block(blockH);
                                                                            end
                                                                            delete(gcbf);
                                                                        catch Mex %#ok<NASGU>
                                                                        end


                                                                        function out=is_locked(h)
                                                                            out=strcmpi(get_param(bdroot(h),'Lock'),'on');
                                                                            if out
                                                                                return;
                                                                            end
                                                                            out=0;
                                                                            parent=get_param(h,'parent');
                                                                            while(strcmpi(get_param(parent,'type'),'block'))
                                                                                if strcmpi(get_param(parent,'blocktype'),'SubSystem')&&...
                                                                                    strcmpi(get_param(parent,'Permissions'),'ReadOnly')
                                                                                    out=1;
                                                                                    break;
                                                                                end
                                                                                parent=get_param(parent,'parent');
                                                                            end


                                                                            function out=is_link(h)
                                                                                out=any(strcmpi(...
                                                                                {'implicit','resolved'},...
                                                                                get_param(h,'StaticLinkStatus')));

                                                                                function out=is_implicit_link(h)
                                                                                    out=strcmpi('implicit',get_param(h,'LinkStatus'));


                                                                                    function out=get_SystemReq(h)
                                                                                        if is_SystemReq(h)

                                                                                            out=h;
                                                                                        else
                                                                                            out=[];






                                                                                            try
                                                                                                if strcmp(get_param(h,'Type'),'block_diagram')
                                                                                                    parentH=get_param(h,'Handle');
                                                                                                elseif strcmp(get_param(h,'BlockType'),'SubSystem')

                                                                                                    openFcn=get_param(h,'OpenFcn');
                                                                                                    if strncmp(openFcn,'rmidispblock(',13)
                                                                                                        parentH=get_param(h,'Parent');
                                                                                                    else
                                                                                                        parentH=get_param(h,'Handle');
                                                                                                    end
                                                                                                else
                                                                                                    parentH=get_param(h,'Parent');
                                                                                                end



                                                                                                systemReqBlocks=find_system(parentH,'SearchDepth',1,...
                                                                                                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                                                                'MaskType','System Requirements');
                                                                                                if~isempty(systemReqBlocks)
                                                                                                    if iscell(systemReqBlocks)
                                                                                                        systemReqBlocks=systemReqBlocks{1};
                                                                                                    end
                                                                                                    out=get_param(systemReqBlocks,'Handle');
                                                                                                end
                                                                                                if is_SystemReq(out)
                                                                                                    return;
                                                                                                else
                                                                                                    out=[];
                                                                                                end
                                                                                            catch Mex %#ok<NASGU>

                                                                                                parentH=[];
                                                                                            end




                                                                                            systemReqBlocks=find_system(h,'SearchDepth',1,...
                                                                                            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                                                            'MaskType','System Requirements');
                                                                                            if isempty(systemReqBlocks)&&~isempty(parentH)

                                                                                                systemReqBlocks=find_system(parentH,'SearchDepth',1,...
                                                                                                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                                                                'MaskType','System Requirements');
                                                                                            end
                                                                                            if~isempty(systemReqBlocks)
                                                                                                if iscell(systemReqBlocks)
                                                                                                    systemReqBlocks=systemReqBlocks{1};
                                                                                                end
                                                                                                out=get_param(systemReqBlocks,'Handle');
                                                                                            end
                                                                                        end

                                                                                        function out=is_SystemReq(h)
                                                                                            out=false;
                                                                                            try
                                                                                                if strcmpi(get_param(h,'MaskType'),'System Requirements')
                                                                                                    out=true;
                                                                                                end
                                                                                            catch Mex %#ok<NASGU>
                                                                                            end

                                                                                            function out=is_SystemReqItem(h)
                                                                                                out=false;
                                                                                                try
                                                                                                    if strcmpi(get_param(h,'MaskType'),'System Requirement Item')
                                                                                                        out=true;
                                                                                                    end
                                                                                                catch Mex %#ok<NASGU>
                                                                                                end

                                                                                                function initialize_window(winH)
                                                                                                    set_param(winH,'LinkStatus','none');
                                                                                                    set_param(winH,'id','SystemReq');
                                                                                                    set_param(winH,'CopyFcn','rmidispblock(''create'',gcbh)');
                                                                                                    set_param(winH,'OpenFcn','rmidispblock(''open'',gcbh)');
                                                                                                    set_param(winH,'PostSaveFcn','rmidispblock(''open'',gcbh)');

                                                                                                    set_param(winH,'UndoDeleteFcn','');
                                                                                                    set_param(winH,'LoadFcn','rmidispblock(''load'',gcbh)');
                                                                                                    set_param(winH,'MoveFcn','rmidispblock(''move'',gcbh)');
                                                                                                    set_param(winH,'ModelCloseFcn','rmidispblock(''close'',gcbh)');
                                                                                                    set_param(winH,'PreSaveFcn','rmidispblock(''close'',gcbh)');
                                                                                                    set_param(winH,'DeleteFcn','rmidispblock(''delete'',gcbh)');
                                                                                                    set_param(winH,'MaskType','System Requirements');
                                                                                                    set_cache(winH,[]);

                                                                                                    function initialize_req(reqH)
                                                                                                        winH=get_SystemReq(reqH);
                                                                                                        fontSize=get_window_font_size(winH);
                                                                                                        set_param(reqH,'LinkStatus','none');
                                                                                                        set_param(reqH,'MoveFcn','rmidispblock(''move'',gcbh);');
                                                                                                        set_param(reqH,'DeleteFcn','rmidispblock(''deleteReq'',gcbh);');
                                                                                                        set_param(reqH,'CopyFcn','rmidispblock(''copyReq'',gcbh)');
                                                                                                        set_param(reqH,'OpenFcn','rmidispblock(''openReq'',gcbh)');
                                                                                                        set_param(reqH,'UndoDeleteFcn','');
                                                                                                        set_param(reqH,'FontSize',fontSize);
                                                                                                        set_param(reqH,'ShowName','off');
                                                                                                        set_param(reqH,'MaskType','System Requirement Item');
                                                                                                        set_param(reqH,'MaskIconUnits','Normalized');

                                                                                                        function out=get_current_reqs(winH)

                                                                                                            cache=get_cache(winH);
                                                                                                            curReq=cache.curReq;


                                                                                                            if~isempty(curReq)&&...
                                                                                                                (~any(ishandle(curReq))||~strcmpi(getfullname(bdroot(winH)),getfullname(bdroot(curReq(1)))))
                                                                                                                curReq=[];
                                                                                                            end


                                                                                                            if~isempty(winH)&&isempty(curReq)
                                                                                                                sysH=get_param(winH,'Parent');


                                                                                                                h=find_system(sysH,'RegExp','on','LookUnderMasks','on',...
                                                                                                                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                                                                                                                'SearchDepth',1,'Name','Requirement');

                                                                                                                curReq=zeros(1,length(h));
                                                                                                                actNReq=0;
                                                                                                                for i=1:length(h)
                                                                                                                    if~isempty(regexp(h{i},'SLVnV Internal Requirement Sub Block Name \d','once'))
                                                                                                                        try
                                                                                                                            get_param(h{i},'index');
                                                                                                                            actNReq=actNReq+1;
                                                                                                                            curReq(actNReq)=get_param(h{i},'Handle');
                                                                                                                        catch Mex %#ok<NASGU>
                                                                                                                            set_param(curReq(i),'DeleteFcn','');
                                                                                                                            delete_block(curReq(i));
                                                                                                                        end
                                                                                                                    end
                                                                                                                end
                                                                                                                curReq=curReq(1:actNReq);
                                                                                                                set_current_reqs(winH,curReq);
                                                                                                            end
                                                                                                            out=curReq;

                                                                                                            function set_current_reqs(winH,curReq)
                                                                                                                cache=get_cache(winH);
                                                                                                                cache.curReq=curReq;
                                                                                                                set_cache(winH,cache);


                                                                                                                function[width,height]=get_previous_size(winH)
                                                                                                                    cache=get_cache(winH);
                                                                                                                    height=cache.prevSize.height;
                                                                                                                    width=cache.prevSize.width;

                                                                                                                    function set_previous_size(winH,height,width)
                                                                                                                        cache=get_cache(winH);
                                                                                                                        cache.prevSize.height=height;
                                                                                                                        cache.prevSize.width=width;
                                                                                                                        set_cache(winH,cache);


                                                                                                                        function out=get_cache(winH)
                                                                                                                            if~isempty(winH)
                                                                                                                                cache=get_param(winH,'UserData');
                                                                                                                            else
                                                                                                                                cache=[];
                                                                                                                            end
                                                                                                                            if~isstruct(cache)
                                                                                                                                cache=struct('curReq',[],'prevSize',[]);
                                                                                                                                cache.curReq=[];
                                                                                                                                [width,height]=rmidispblock('display',winH);
                                                                                                                                cache.prevSize=struct('height',height,'width',width);
                                                                                                                            end
                                                                                                                            out=cache;

                                                                                                                            function set_cache(winH,cache)
                                                                                                                                if~is_locked(winH)
                                                                                                                                    set_param(winH,'UserData',cache);
                                                                                                                                end

                                                                                                                                function repeated=repeated_index(h)
                                                                                                                                    myValues=get_param(h,'MaskValues');
                                                                                                                                    myIndex=str2double(myValues{2});
                                                                                                                                    reqs=get_current_reqs(h);
                                                                                                                                    matched=false;
                                                                                                                                    repeated=false;
                                                                                                                                    for i=1:length(reqs)
                                                                                                                                        values=get_param(reqs(i),'MaskValues');
                                                                                                                                        index=str2double(values{2});
                                                                                                                                        if index==myIndex
                                                                                                                                            if matched
                                                                                                                                                repeated=true;
                                                                                                                                                break;
                                                                                                                                            else
                                                                                                                                                matched=true;
                                                                                                                                            end
                                                                                                                                        end
                                                                                                                                    end


                                                                                                                                    function fix_bad_move(winH,reqIndex)

                                                                                                                                        t=timer('TimerFcn',@delayed_move,'StartDelay',0.5);
                                                                                                                                        userData.winH=winH;
                                                                                                                                        userData.reqIndex=reqIndex;
                                                                                                                                        t.UserData=userData;
                                                                                                                                        start(t);

                                                                                                                                        function delayed_move(timerobj,varargin)
                                                                                                                                            userData=timerobj.UserData;
                                                                                                                                            winH=userData.winH;
                                                                                                                                            reqIndex=userData.reqIndex;
                                                                                                                                            stop(timerobj);
                                                                                                                                            delete(timerobj);

                                                                                                                                            if ishandle(winH)
                                                                                                                                                curReqs=get_current_reqs(winH);
                                                                                                                                                req=curReqs(reqIndex);
                                                                                                                                                firstReqPos=get_new_req_position(winH);
                                                                                                                                                reqHeight=firstReqPos(4)-firstReqPos(2);
                                                                                                                                                reqWidth=firstReqPos(3)-firstReqPos(1);
                                                                                                                                                reqX1=firstReqPos(1);
                                                                                                                                                reqY1=firstReqPos(2)+reqHeight*(reqIndex-1);
                                                                                                                                                origMoveFcn=get_param(req,'MoveFcn');
                                                                                                                                                set_param(req,'MoveFcn','');
                                                                                                                                                set_param(req,'Position',[reqX1,reqY1,reqX1+reqWidth,reqY1+reqHeight]);
                                                                                                                                                set_param(req,'MoveFcn',origMoveFcn);
                                                                                                                                            end




