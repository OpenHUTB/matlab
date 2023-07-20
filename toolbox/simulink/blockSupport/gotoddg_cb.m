function varargout=gotoddg_cb(src,action,varargin)



    if isnumeric(src)&&ishandle(src)
        h=get_param(src,'Object');
        blkH=src;
    else
        h=src.getBlock;
        blkH=h.Handle;
    end

    if strcmp(h.BlockType,'Goto')
        fromBlks=h.FromBlocks;
        blockHandles=[fromBlks(:).handle];
        tagVBlk=h.TagVisibilityBlock;
        isGoto=true;
    else
        blockHandles=h.GotoBlock.handle;
        tagVBlk=get_param(blockHandles,'TagVisibilityBlock');
        isGoto=false;
    end
    if~isempty(tagVBlk)
        blockHandles(end+1)=get_param(tagVBlk,'handle');
    end

    switch action
    case 'hilite'
        block=varargin{1};
        studioHighlight_cb('hilite',block,...
        @()gotoddg_cb(blkH,'unhilite'),...
        varargin{2});

    case 'unhilite'
        hiliting=char(get_param(blockHandles,'HiliteAncestors'));
        ind=strmatch('find',hiliting);
        if~isempty(ind)
            set_param(blockHandles(ind),'HiliteAncestors','none');
        end
        if(strcmp(h.BlockType,'From')&&~isempty(varargin))
            dlg=varargin{1};
            closeProgressBar(h,dlg);
        end
    case 'refresh'
        if~isGoto
            refreshFrom(get_param(h.GotoBlock.handle,'Object'));
        end
    case 'postApply'
        varargout{1}=true;
        varargout{2}='';
        if isGoto
            refreshGoto(src);
        end

    case 'doGotoTagSelection'
        dlg=varargin{1};

        if(strcmp(dlg.getWidgetValue('GotoTag'),getMoreTagsString))
            entries=updateTags(blkH,dlg);
            dlg.setWidgetValue('GotoTag',entries{1})
        end
    case 'doGotoTagSelection_Slim'
        dlg=varargin{1};

        if(strcmp(dlg.getWidgetValue('GotoTag'),getMoreTagsString))
            entries=updateTags(blkH,dlg);
            dlg.setWidgetValue('GotoTag',entries{1})
        else
            dlg=varargin{1};
            [varargout{1},varargout{2}]=src.preApplyCallback(dlg);
            dlg.refresh;
        end
    case 'refreshTags'
        dlg=varargin{1};
        currentSelectedTag=dlg.getWidgetValue('GotoTag');
        updateTags(blkH,dlg);
        dlg.setWidgetValue('GotoTag',currentSelectedTag);

    case 'getFromHTML'
        varargout{1}=getFromHTML(blkH,tagVBlk,{fromBlks(:).name},{fromBlks(:).handle});

    case 'getGotoTagEntries'
        varargout{1}=getGotoTagEntries(blkH,varargin{1});

    case 'getGotoURL'
        goto=get_param(blkH,'GotoBlock');
        varargout{1}=goto.name;
        varargout{2}={goto.handle};
        varargout{2}{2}=studioHighlight_cb('getBlockPathHandles',gcbp);

    case 'handleGotoTag'




    case 'doPreApply'
        dlg=varargin{1};
        [varargout{1},varargout{2}]=src.preApplyCallback(dlg);
        dlg.refresh;

    otherwise
        MSLDiagnostic('Simulink:blocks:GotoUnknownAction',mfilename).reportAsWarning;
    end



    function html=getFromHTML(blkH,tagVBlk,fromBlks,fromBlksHanlde)

        Str=DAStudio.message('Simulink:dialog:GotoBlockRefresh');
        Str1=DAStudio.message('Simulink:dialog:GotoBlockCorrespondingBlocks');
        html=[...
'<html><body padding="0" spacing="0">'...
        ,'<table width="100%" cellpadding="0" cellspacing="0">'...
        ,'<tr><td align="left"><b>',Str1,'</b></td>'...
        ,'<td align="right"><a href="ddgrefresh:eval('''')">',Str,'</a></td></tr>'...
        ];

        optBlockPathArgs=studioHighlight_cb('getBlockPathHandlesAsString',gcbp);

        if~isempty(tagVBlk)
            blkHString=studioHighlight_cb('getStringForHandle',blkH);
            tagVBlkHandle=get_param(tagVBlk,'handle');
            tagVBlkHandleString=studioHighlight_cb('getStringForHandle',tagVBlkHandle);


            exprString=['''gotoddg_cb(str2num('''''...
            ,blkHString...
            ,'''''),''''hilite'''', str2num('''''...
            ,tagVBlkHandleString...
            ,'''''), ',optBlockPathArgs,')'''];
            html=[html,'<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'...
            ,DAStudio.message('Simulink:blkprm_prompts:GotoTagVis'),' '...
            ,'<a href="matlab:eval(',exprString,')">',rtwprivate('rtwhtmlescape',tagVBlk),'</a>'...
            ,'</td><td></td></tr>'];
        end

        fromBlockHandleString=cell(1,length(fromBlks));
        for i=1:length(fromBlks)
            fromBlockHandleString{i}=studioHighlight_cb('getStringForHandle',fromBlksHanlde{i});


            exprString=['''f_nz=get_param(str2num('''''...
            ,fromBlockHandleString{i}...
            ,'''''),''''GotoBlock'''');gotoddg_cb(f_nz.handle,''''hilite'''', str2num('''''...
            ,fromBlockHandleString{i}...
            ,'''''), ',optBlockPathArgs,');clear(''''f_nz'''')'''];
            html=[html,'<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'...
            ,'<a href="matlab:eval(',exprString,')">',rtwprivate('rtwhtmlescape',fromBlks{i}),'</a>'...
            ,'</td><td></td></tr>'];%#ok<AGROW>
        end
        html=[html,'</table></body></html>'];

        function refreshFrom(h)
            r=DAStudio.ToolRoot;
            dlgs=r.getOpenDialogs;
            for i=1:length(dlgs)
                if isa(dlgs(i).getDialogSource,'Simulink.DDGSource')
                    if strcmp(dlgs(i).getDialogSource.getBlock.BlockType,'Goto')
                        dlgs(i).refresh;
                    end
                end
            end



            function refreshGoto(h)


                dlgs=DAStudio.ToolRoot.getOpenDialogs(h);
                for i=1:length(dlgs)
                    dlgs(i).refresh;
                end


                function entries=getGotoTagEntries(blkH,h)

                    tagList=get_param(blkH,'GotoTagList');



                    if(~isempty(tagList)&&iscell(tagList))
                        entries=tagList;
                        return;
                    end

                    dlgs=h.getDialogSource.getOpenDialogs;
                    thisDialog=[];
                    for i=1:length(dlgs)
                        if isa(dlgs{i}.getDialogSource,'Simulink.DDGSource')
                            if(dlgs{i}.getDialogSource.getBlock.Handle==blkH)
                                thisDialog=dlgs{i};
                                break;
                            end
                        end
                    end

                    followLinks=get_param(bdroot(blkH),'FollowLinksWhenOpeningFromGotoBlocks');
                    entries=getTagList(blkH,thisDialog,followLinks);


                    function entries=getTagList(blkH,thisDialog,followLinks)
                        entries=getGotoTagsList(blkH,followLinks);
                        if(strcmp(followLinks,'off'))
                            entries=addMoreTagsToList(entries,thisDialog);
                        end

                        if(strcmp(get_param(bdroot(blkH),'Lock'),'off'))
                            set_param(blkH,'GotoTagList',entries);
                        end

                        function entries=addMoreTagsToList(entries,thisDialog)





                            if(length(entries)==1&&isempty(entries{1}))
                                entries{1}=getMoreTagsString;
                            else
                                entries{1+end,1}=getMoreTagsString;
                            end


                            function entries=updateTags(blkH,dlg)

                                userDataFromOpenDialog.ProgressBarHandle=createProgressBar(blkH,dlg);
                                dlg.setUserData('fromRefresh',userDataFromOpenDialog);


                                dlg.setEnabled('fromRefresh',0)
                                dlg.setEnabled('GotoTag',0)
                                entries=getTagList(blkH,dlg,'on');

                                dlg.refresh;
                                if ishghandle(userDataFromOpenDialog.ProgressBarHandle)
                                    for i=75:100
                                        waitbar(i/100,userDataFromOpenDialog.ProgressBarHandle)
                                    end
                                    close(userDataFromOpenDialog.ProgressBarHandle);
                                end

                                dlg.setEnabled('fromRefresh',1);
                                dlg.setEnabled('GotoTag',1);

                                dlg.setUserData('fromRefresh',userDataFromOpenDialog);


                                function out=getMoreTagsString()
                                    out='<More Tags...>';


                                    function closeProgressBar(h,dlg)%#ok<INUSL>

                                        userDataFromOpenDialog=dlg.getUserData('fromRefresh');
                                        if~isempty(userDataFromOpenDialog)&&~isempty(userDataFromOpenDialog.ProgressBarHandle)
                                            if ishghandle(userDataFromOpenDialog.ProgressBarHandle)
                                                close(userDataFromOpenDialog.ProgressBarHandle);
                                            end
                                            userDataFromOpenDialog.ProgressBarHandle=[];
                                        end


                                        function progressBar=createProgressBar(blkH,dlg)

                                            progressBar=waitbar(0,DAStudio.message('Simulink:blocks:GotoBlockWaitbar'));
                                            for i=1:75
                                                if ishghandle(progressBar);waitbar(i/100,progressBar);end
                                            end



