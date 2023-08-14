function dumpFilteredAndReducedBlocksInfo(this,data,options,msgId)







    if isempty(data)
        return;
    end

    htmlTag=cvi.ReportScript.convertNameToHtmlTag(msgId);
    printIt(this,'<a name="%s"></a><h3>%s</h3>',htmlTag,getString(message(msgId)));

    [tableInfo,tableTemplate]=cvi.ReportScript.getElimantedBlocksTemplate(options);
    tableStr=cvprivate('html_table',data,tableTemplate,tableInfo);
    printIt(this,'%s',tableStr);
end
