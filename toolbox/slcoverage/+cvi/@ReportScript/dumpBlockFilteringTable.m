function dumpBlockFilteringTable(this,blkEntry,options)




    if~SlCov.CoverageAPI.feature('justification')
        return;
    end

    if isfield(blkEntry,'depth')&&blkEntry.depth==0
        return;
    end
    ssid='';
    try
        ssid=cvi.TopModelCov.getSID(blkEntry.cvId);
    catch MEx %#ok<NASGU>
    end

    printIt(this,'<table>');
    isFiltered=cv('get',blkEntry.cvId,'.isDisabled');
    removeLink=isFiltered||cv('get',blkEntry.cvId,'.isJustified');
    rationaleStr='';
    refIdStr=sprintf('%d',blkEntry.cvId);
    if removeLink&&this.rationaleMap.isKey(refIdStr)
        if isFiltered
            filterStr=getString(message('Slvnv:simcoverage:cvhtml:Excluded'));
        else
            filterStr=getString(message('Slvnv:simcoverage:cvhtml:Justified'));
        end
        rationaleStr=cvi.ReportUtils.getFilterRationale(blkEntry.cvId);

        idxStr=this.rationaleMap(refIdStr);
        linkStr=sprintf('<a name="ref_rationale_source_%s"> </a> <a href="#ref_rationale_%s"><div title="%s"/> <b>%s</b> %s </a>',...
        refIdStr,...
        refIdStr,...
        getString(message('Slvnv:simcoverage:cvhtml:NavigateToJustification')),...
        filterStr,...
        idxStr);


    else
        filterStr=getString(message('Slvnv:simcoverage:cvhtml:JustifyOrExclude'));
        linkStr=this.getFilterLinkForAdd(ssid,0,[],'',[],filterStr,options);
    end

    printIt(this,...
    '<tr> <td> %s </td></tr>\n',...
    linkStr);

    if~isempty(rationaleStr)
        printIt(this,...
        '<tr> <td> %s </td></tr>\n',...
        rationaleStr);
    end
    printIt(this,'</table>\n');
