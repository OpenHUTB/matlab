function varargout=slfind(varargin)









    Action=varargin{1};
    args=varargin(2:end);

    switch(Action)

    case 'RegisterObjects'
        varargout{1}=i_RegisterObjects;

    case 'RegisterProperties'
        varargout{1}=i_RegisterProperties;

    case 'FindObjects'
        varargout{1}=i_FindObjects(args{:});

    case 'SelectObjects'
        i_SelectObjects(args{1});

    case 'DeselectObjects'
        i_DeselectObjects(args{1});

    case 'OpenObjects'
        i_OpenObjects(args{1});

    case 'ContextMenu'
        i_ExecuteContextMenu(args{1},args{2});

    end


    function objList=i_RegisterObjects


        objList={'Simulink objects',...
        'Annotations',...
        'Blocks',...
        'Signals'};


        function propList=i_RegisterProperties


            propList={'Name',...
            'Tag',...
            'BlockDialogParams',...
            'Description',...
            'BlockDescription',...
            'MaskDescription',...
            'BlockType',...
            'MaskType',...
            'LinkStatus',...
            'TestPoint'};


            function i_SelectObjects(H);


                switch(get_param(H,'Type'))
                case{'annotation','block'}
                    set_param(H,'Selected','on','HiliteAncestors','find');
                    Simulink.scrollToVisible(H,'ensureFit','off','panMode','minimal');
                case 'port'
                    LineH=get_param(H,'line');
                    set_param(LineH,'Selected','on','HiliteAncestors','find');
                    Simulink.scrollToVisible(LineH,'ensureFit','off','panMode','minimal');
                end


                function i_DeselectObjects(H);


                    switch(get_param(H,'Type'))
                    case 'annotation'
                        set_param(H,'Selected','off','HiliteAncestors','none');
                    case 'block'
                        set_param(H,'Selected','off','HiliteAncestors','none');
                    case 'port'
                        LineH=get_param(H,'line');
                        set_param(LineH,'Selected','off','HiliteAncestors','none');
                    end



                    function i_OpenObjects(H);


                        switch(get_param(H,'Type'))
                        case 'annotation'
                            open_system(get_param(H,'Parent'),'force');

                        case 'block'
                            open_system(get_param(H,'Parent'),'force');

                        case 'port'
                            parentBlock=get_param(H,'Parent');
                            open_system(get_param(parentBlock,'Parent'),'force');

                        end


                        function i_ExecuteContextMenu(H,type)


                            switch(get_param(H,'Type'))
                            case 'block'

                                if strncmpi(type,'Prop',4)
                                    open_system(H,'property');
                                elseif strncmpi(type,'Param',5)&&...
                                    isempty(get_param(H,'OpenFcn'))&&...
                                    ~hasmaskdlg(H)
                                    open_system(H,'parameter');
                                else
                                    open_system(H);
                                end

                            case 'port'
                                dlgH=i_FindOpenDDGDialog(H);
                                if isempty(dlgH)
                                    portObj=get_param(H,'Object');
                                    DAStudio.Dialog(portObj);
                                else
                                    awtinvoke(dlgH,'show()');
                                    dlgH.showNormal;
                                end

                            end





                            function dlgH=i_FindOpenDDGDialog(PortHandle)

                                dlgH=[];

                                if~ishandle(PortHandle)
                                    return;
                                end




                                dialogTag=strcat('Port Properties: ',num2str(PortHandle,16));

                                try
                                    tr=DAStudio.ToolRoot;
                                    dlgList=tr.getOpenDialogs;
                                    for i=1:length(dlgList)
                                        dlg=dlgList(i);
                                        if strcmp(dlg.dialogTag,dialogTag)

                                            dlgH=dlg;
                                            break;
                                        end
                                    end
                                catch
                                    dlgH=[];
                                end


                                function results=i_FindObjects(varargin)


                                    results=[];


                                    selections=varargin{1};
                                    f_SL=selections(1);
                                    f_ANNO=selections(2);
                                    f_BLKS=selections(3);
                                    f_SIG=selections(4);


                                    findArgs=varargin(2:end);


                                    simpleLoc=10;
                                    simpleSearch=strncmp(findArgs{simpleLoc},'Simple',6);
                                    searchBlockParameters=strcmp(findArgs{simpleLoc},'SimpleAndParams');

                                    if simpleSearch
                                        findArgs{simpleLoc}='Name';

                                        if isempty(findArgs{simpleLoc+1})
                                            findArgs(simpleLoc:simpleLoc+1)=[];
                                            simpleSearch=0;
                                            searchBlockParameters=0;
                                        end
                                    end

                                    annoH=[];blkH=[];portH=[];


                                    if(f_SL||f_ANNO)
                                        if simpleSearch
                                            findArgs{simpleLoc}='Text';
                                        end
                                        annoH=find_system(findArgs{1},...
                                        'MatchFilter',@Simulink.match.allVariants,...
                                        'IncludeCommented','on',...
                                        findArgs{2:end},...
                                        'Type','annotation');
                                        if simpleSearch
                                            findArgs{simpleLoc}='Name';
                                        end
                                    end

                                    if(f_SL||f_BLKS)
                                        blks=find_system(findArgs{1},...
                                        'MatchFilter',@Simulink.match.allVariants,...
                                        'IncludeCommented','on',...
                                        findArgs{2:end},...
                                        'Type','block');
                                        blkH=get_param(blks,'Handle');
                                        if iscell(blkH)
                                            blkH=[blkH{:}]';
                                        end


                                        if searchBlockParameters
                                            findArgs{simpleLoc}='BlockDialogParams';
                                            blks_more=find_system(findArgs{1},...
                                            'MatchFilter',@Simulink.match.allVariants,...
                                            'IncludeCommented','on',...
                                            findArgs{2:end},...
                                            'Type','block');
                                            blkH_more=get_param(blks_more,'Handle');
                                            if iscell(blkH_more)
                                                blkH_more=[blkH_more{:}]';
                                            end


                                            blkH=unique([blkH;blkH_more]);


                                            findArgs{simpleLoc}='Name';
                                        end

                                    end



                                    blkType=get_param(blkH,'Type');
                                    blkdiag_idx=find(strcmpi(blkType,'block_diagram'));
                                    if~isempty(blkdiag_idx)
                                        blkH(blkdiag_idx)=[];
                                    end


                                    if(f_SL||f_SIG)
                                        portH=find_system(findArgs{1},'findall','on',...
                                        'MatchFilter',@Simulink.match.allVariants,...
                                        'IncludeCommented','on',...
                                        findArgs{2:end},...
                                        'Type','port','PortType','outport');


                                        lineH=get_param(portH,'Line');
                                        if iscell(lineH)
                                            portH=portH(ishandle([lineH{:}]'));
                                        else
                                            portH=portH(ishandle(lineH(:)));
                                        end

                                    end


                                    H=[annoH;blkH;portH];




                                    parents=get_param(H,'Parent');
                                    if~iscell(parents)
                                        parents={parents};
                                    end

                                    nonSFparent=strcmp(parents,bdroot(findArgs{1}));

                                    candidateIdx=find(nonSFparent==0);

                                    if~isempty(candidateIdx)

                                        candidateIdx(find(slprivate('is_stateflow_based_block',parents(candidateIdx))))=[];


                                        nonSFparent(candidateIdx)=1;
                                        H=H(nonSFparent);
                                    end







                                    types=get_param(H,'Type');
                                    if ischar(types)
                                        types={types};
                                    end
                                    types=strrep(types,'annotation','Annotation');
                                    types=strrep(types,'block','Block');
                                    types=strrep(types,'port','Signal');


                                    names=get_param(H,'Name');
                                    if ischar(names)
                                        names={names};
                                    end


                                    parents=get_param(H,'Parent');
                                    if ischar(parents)
                                        parents={parents};
                                    end


                                    sources=cell(size(types));
                                    if~isempty(sources)
                                        [sources{:}]=deal('');
                                    end
                                    dest=sources;


                                    sigIdx=find(strcmp(types,'Signal'));
                                    for i=sigIdx'
                                        lineH=get_param(H(i),'Line');

                                        sources{i}=get_param(get_param(H(i),'Parent'),'Name');
                                        if ishandle(lineH)
                                            dstBlocks=get_param(lineH,'DstBlockHandle');

                                            dstH=dstBlocks(1);
                                            if ishandle(dstH)
                                                dest{i}=get_param(dstH,'Name');
                                            end
                                        end
                                    end


                                    names=strrep(names,sprintf('\n'),' ');
                                    parents=strrep(parents,sprintf('\n'),' ');
                                    sources=strrep(sources,sprintf('\n'),' ');
                                    dest=strrep(dest,sprintf('\n'),' ');


                                    for i=1:length(H)
                                        results(i).Handle=H(i);
                                        results(i).Type=types{i};
                                        results(i).Name=names{i};
                                        results(i).Parent=parents{i};
                                        results(i).Source=sources{i};
                                        results(i).Dest=dest{i};
                                    end
