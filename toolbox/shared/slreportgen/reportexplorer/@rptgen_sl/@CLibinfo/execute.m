function out=execute(this,d,varargin)






    adSL=rptgen_sl.appdata_sl;
    currContext=adSL.Context;
    switch lower(currContext)
    case ''
        iLib=libinfo(get_param(find_system(0,'SearchDepth',1,'BlockDiagramType','model'),'Name'));
    case 'model'
        iLib=libinfo(adSL.ReportedSystemList,...
        'SearchDepth',1,...
        'LookUnderMasks','all');
    case 'system'
        iLib=libinfo(adSL.CurrentSystem,...
        'SearchDepth',1,...
        'LookUnderMasks','all');
    case 'block'
        iLib=libinfo(adSL.CurrentBlock,...
        'SearchDepth',0,...
        'LookUnderMasks','all');
    otherwise
        errMsg=sprintf(getString(message('RptgenSL:rsl_CLibInfo:invalidForContextMsg')),currContext);
        out=d.createComment(errMsg);
        this.status(errMsg,2);
        return;
    end

    if isempty(iLib)
        out=d.createComment('rptgen_sl.CLibinfo - no libraries found');
        return;
    end


    allBlock={iLib(:).Block};
    [allVals,uniqIdx,sortIdx]=unique(get_param(allBlock(:),'Name'));
    iLib=iLib(uniqIdx);

    if~strcmp(this.Sort,'Block')
        allVals={iLib(:).(this.Sort)};

        if this.MergeRows
            [allVals,uniqIdx,sortIdx]=unique(allVals);
            uniqLength=length(uniqIdx);
            for i=uniqLength:-1:1
                memberIdx{i}=find(sortIdx==i);
            end
        else
            [allVals,sortIdx]=sort(allVals);
            uniqLength=length(iLib);
            memberIdx=num2cell(sortIdx);
        end
    else
        uniqLength=length(iLib);
        memberIdx=num2cell(sortIdx(uniqIdx));
    end

    psSL=rptgen_sl.propsrc_sl;

    tCells=cell(uniqLength+1,0);
    rowCount=0;
    colWid=[];


    if this.isBlock||(~this.isLibrary&&~this.isReferenceBlock&&~this.isLinkStatus)
        rowCount=rowCount+1;
        tCells{1,rowCount}=getString(message('RptgenSL:rsl_CLibInfo:blockLabel'));
        colWid(end+1)=3;
        for i=1:uniqLength

            tCells{i+1,rowCount}=psSL.makeLink({iLib(memberIdx{i}).Block}','block','link',d);
        end
    end

    if this.isLibrary
        rowCount=rowCount+1;
        tCells{1,rowCount}=getString(message('RptgenSL:rsl_CLibInfo:libraryLabel'));
        colWid(end+1)=2;
        for i=1:uniqLength
            allLib=unique({iLib(memberIdx{i}).Library}');
            tCells{i+1,rowCount}=psSL.makeLink(allLib,'model','link',d);
        end
    end

    if this.isReferenceBlock
        rowCount=rowCount+1;
        tCells{1,rowCount}=getString(message('RptgenSL:rsl_CLibInfo:refBlockLabel'));
        colWid(end+1)=3;
        for i=1:uniqLength
            allRefBlk=unique({iLib(memberIdx{i}).ReferenceBlock}');
            tCells{i+1,rowCount}=psSL.makeLink(allRefBlk,'block','link',d);
        end
    end

    if this.isLinkStatus
        rowCount=rowCount+1;
        tCells{1,rowCount}=getString(message('RptgenSL:rsl_CLibInfo:linkStatusLabel'));
        colWid(end+1)=1;

        if this.MergeRows
            for i=1:uniqLength
                tCells{i+1,rowCount}=unique({iLib(memberIdx{i}).LinkStatus}');
            end
        else
            tCells(2:uniqLength+1,rowCount)={iLib(:).LinkStatus}';
        end
    end

    tTitle=rptgen.parseExpressionText(this.Title);

    tm=makeNodeTable(d,...
    tCells,...
    0,...
    true);
    tm.setColWidths(colWid);
    tm.setTitle(tTitle);
    tm.setBorder(true);
    tm.setPageWide(true);
    tm.setNumHeadRows(1);
    tm.setNumFootRows(0);

    out=tm.createTable;