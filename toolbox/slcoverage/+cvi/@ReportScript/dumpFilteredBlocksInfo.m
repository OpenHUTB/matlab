function res=dumpFilteredBlocksInfo(this,filterInfo,options)




    if isempty(filterInfo)
        return;
    end
    msgId='Slvnv:simcoverage:cvhtml:ObjectsFiltered';
    htmlTag=cvi.ReportScript.convertNameToHtmlTag(msgId);
    printIt(this,'<a name="%s"></a><h3>%s</h3>\n',htmlTag,getString(message(msgId)));

    appliedData=buildReportStruct(this,filterInfo);
    [tableInfo,tableTemplate]=getTemplate(options);
    [ftableInfo,ftableTemplate]=getFilterTemplate(options);
    tableStr='';
    for idx=1:numel(appliedData)
        tableStr=[tableStr,['<h4>',getString(message('Slvnv:simcoverage:cvhtml:FilterTitle')),' '],appliedData(idx).filterName,'</h4>'];
        tableStr=[tableStr,cvprivate('html_table',appliedData(idx),ftableTemplate,ftableInfo)];%#ok<*AGROW>
        tableStr=[tableStr,cvprivate('html_table',appliedData(idx),tableTemplate,tableInfo)];
    end
    printIt(this,'%s',tableStr);
    printIt(this,'<br/>\n');

    res=true;
end

function appliedData=buildReportStruct(this,filterInfo)
    allIds={filterInfo.uuid};
    allIds=unique(allIds);
    unappleedFilter=this.appliedFilters;
    for idx=1:numel(allIds)
        cId=allIds{idx};
        fidx=1;

        if~isempty(cId)
            fidx=find({this.appliedFilters.uuid}==string(cId));
        end

        fidx=fidx(1);
        filterDetails=this.appliedFilters(fidx);
        appliedData(idx).filterName=filterDetails.openLink;
        appliedData(idx).fileName=filterDetails.fileName;
        if isempty(filterDetails.descr)
            appliedData(idx).descr='N/A';
        else
            appliedData(idx).descr=filterDetails.descr;
        end
        appliedData(idx).filterEntry=filterInfo(string(cId)=={filterInfo.uuid});
    end
end


function[tableInfo,tableTemplate]=getFilterTemplate(options)

    tableInfo.table='border="0" cellpadding="5" ';
    tableInfo.cols=struct('align','"left"');
    tableInfo.imageDir=options.imageSubDirectory;

    tableTemplate=...
    {...
    {'Cat','$&#160; ',['$',getString(message('Slvnv:simcoverage:cvhtml:FilterFileShort'))]},...
    {'Cat','$&#160; ','#fileName'},'\n'...
    ,{'Cat','$&#160; ',['$',getString(message('Slvnv:simcoverage:cvhtml:FilterDescription'))]},...
    {'Cat','$&#160; ','#descr'},'\n'...
    };
end

function[tableInfo,tableTemplate]=getTemplate(options)

    tableInfo.table='border="1" cellpadding="5" ';
    tableInfo.cols=struct('align','"left"');
    tableInfo.imageDir=options.imageSubDirectory;

    ruleTitle={['$<b> ',getString(message('Slvnv:simcoverage:cvhtml:FilteredModelObject')),' </b>'],...
    ['$<b> ',getString(message('Slvnv:simcoverage:cvhtml:Rationale')),' </b>'],'\n'};

    tableTemplate=...
    {...
    {'ForEach','#.',...
    ruleTitle{:},...
    {'ForEach','#filterEntry',...
    {'Cat','#idx','$&#160;','#namedlink'},...
    {'Cat','#rationale'},...
    '\n',...
    }...
    }...
    };%#ok<CCAT>
end

