function out=execute(c,d,varargin)






    out='';

    mdlName=get(rptgen_sl.appdata_sl,'CurrentModel');
    if isempty(mdlName)
        c.status('No model found for change log',2);
        return;
    end

    try
        mdlHistory=get_param(mdlName,'ModifiedHistory');
    catch
        c.status(getString(message('RptgenSL:rsl_csl_mdl_changelog:cannotGetHistoryLabel')),2);
        return;
    end

    if isempty(mdlHistory)
        c.status(getString(message('RptgenSL:rsl_csl_mdl_changelog:historyEmptyLabel')),2);
        return;
    end

    histInfo=c.parseHistory(mdlHistory);

    if~isempty(histInfo)

        headerCells={getString(message('RptgenSL:rsl_csl_mdl_changelog:verLabel')),getString(message('RptgenSL:rsl_csl_mdl_changelog:nameLabel')),getString(message('RptgenSL:rsl_csl_mdl_changelog:dateLabel')),getString(message('RptgenSL:rsl_csl_mdl_changelog:descriptionLabel'))};

        colWid=[1,2,3,5];
        hCells=[headerCells;histInfo];

        whichCol=find([c.isVersion,c.isAuthor,c.isDate,c.isComment]);
        if isempty(whichCol)
            c.status(getString(message('RptgenSL:rsl_csl_mdl_changelog:noSelectedColumnsLabel')),2);
            whichCol=4;
        end

        tm=makeNodeTable(d,...
        hCells(:,whichCol),...
        0,...
        true,...
        0);

        tm.setColWidths(colWid(whichCol));
        tm.setTitle(rptgen.parseExpressionText(c.TableTitle));
        tm.setBorder(c.isBorder);
        tm.setPageWide(true);
        tm.setNumHeadRows(1);
        tm.setNumFootRows(0);

        out=tm.createTable;
    else
        c.status(getString(message('RptgenSL:rsl_csl_mdl_changelog:cannotParseHistoryLabel')),2);
    end

