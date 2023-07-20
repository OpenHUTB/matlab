



function dumpShortSummary(this,shortSummBlocks,options)
    if isempty(shortSummBlocks)
        return
    end
    [tableInfo,tableTemplate]=getShortSummBlocksTemplate(options);
    tableStr=cvprivate('html_table',shortSummBlocks,tableTemplate,tableInfo);

    msgId='Slvnv:simcoverage:cvhtml:FullCoverage';
    htmlTag=cvi.ReportScript.convertNameToHtmlTag(msgId);
    printIt(this,'<a name="%s"></a><h4>&#160; &#160;%s</h4>',htmlTag,getString(message(msgId)));


    printIt(this,'<table> <tr> <td width="25"> </td> <td>\n');
    printIt(this,'%s',tableStr);
    printIt(this,'</td> </tr> </table>\n');
    printIt(this,'<br/>\n');


    function[tableInfo,tableTemplate]=getShortSummBlocksTemplate(options)

        tableInfo.table='border="0" cellpadding="5" ';
        tableInfo.cols=struct('align','"left"','width',300);
        tableInfo.imageDir=options.imageSubDirectory;
        tableTemplate={['$<b> ',getString(message('Slvnv:simcoverage:cvhtml:ModelObject')),' </b>'],...
        ['$<b> ',getString(message('Slvnv:simcoverage:cvhtml:Metric')),' </b>'],'\n'};

        tableTemplate=[tableTemplate...
        ,{{'ForEach','#.',...
        {'Cat','#namedlink'},...
        {'Cat','#rationale'},...
        '\n',...
        }}];


