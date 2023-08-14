function highlightSLStudio(blocks,ports,whole)































    narginchk(1,3);

    if nargin>1
        assert(numel(blocks)==numel(ports));
    end

    if nargin<3
        whole=false;
    end



    handles=l_handles(blocks);



    diagramh=bdroot(handles(1));

    if whole
        handles=handles(cellfun(@isempty,ports));
    end




    if strcmp(get_param(diagramh,'Shown'),'off')
        open_system(diagramh);
    end

    if nargin>1

        for i=1:numel(ports)
            if isempty(ports{i})

                continue;
            end

            porth=gl.sli.getPortHandle(blocks{i},ports{i});
            if porth>0
                lineh=get_param(porth,'Line');
                if lineh>0
                    handles=[handles,lineh];%#ok<AGROW>
                    if whole
                        extrah=builtin('_connection_line_tracing',lineh);
                        extrahIsLine=strcmp(get_param(extrah,'Type'),'line');
                        handles=[handles,extrah(extrahIsLine)];%#ok<AGROW>
                    end
                end
            end

        end
    end


    handles=unique(handles);













    isblock=strcmp(get_param(handles,'Type'),'block');
    handles0=handles(isblock);
    handles=handles(~isblock);
    parents0=l_cell_param(handles0,'Parent');
    levs0=cellfun(@l_level,parents0);
    if isempty(levs0)
        maxlev=0;
    else
        maxlev=max(levs0);
    end


    currenth=handles0(levs0==maxlev);
    allparenth=l_handles(get_param(handles,'Parent'));

    for lev=maxlev:-1:1
        handles=[handles,currenth];%#ok<AGROW>
        parenth=l_handles(get_param(currenth,'Parent'));
        allparenth=[allparenth,parenth];%#ok<AGROW>
        currenth=unique([parenth,handles0(levs0==lev-1)]);

        if numel(currenth)<=1
            pm_assert(numel(currenth)==1);
            break;
        else
            pm_assert(lev>1);
        end
    end


    [subsystems,~,ic]=unique(allparenth);


    hilightInfo.graphHighlightMap=cell(numel(subsystems),2);
    for i=1:numel(subsystems)
        hilightInfo.graphHighlightMap(i,:)={subsystems(i),handles(ic==i)};
    end


    SLStudio.HighlightSignal.removeHighlighting(diagramh);


    SLStudio.HighlightSignal.highlight(hilightInfo,diagramh);




    open_system(allparenth(end),'force');

    function blkprms=l_cell_param(blks,prm)
        blkprms=get_param(blks,prm);
        if~iscell(blkprms)
            blkprms={blkprms};
        end

        function hdls=l_handles(blks)
            hdls=get_param(blks,'Handle');
            if iscell(hdls)
                hdls=cell2mat(hdls);
            end
            hdls=(hdls(:))';

            function lev=l_level(parent)







                parent=strrep(parent,'//','');
                if isempty(parent)
                    lev=0;
                else
                    lev=1+numel(strfind(parent,'/'));
                end
