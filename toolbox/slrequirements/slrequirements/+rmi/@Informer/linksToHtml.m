function[html,docTable]=linksToHtml(srcId,docTable)



    html='';
    if nargin<2
        docTable=[];
    end

    [docs,locs,reqsys]=rmiml.getLinkedItems(srcId);

    if rmisl.isSidString(srcId)
        ref=strtok(srcId,':');
    else
        ref=fileparts(srcId);
    end

    for i=1:length(docs)

        [myHtml,docUrl,reqUrls]=rmi.Informer.linkInfoToHtml(docs{i},locs{i},reqsys{i},ref);


        html=[html,char(10),'<p>',myHtml,'</p>'];%#ok<AGROW>


        hyperlink=['<a href="',docUrl,'">',docs{i},'</a>'];
        docTable=rmiut.updateDocTable(docTable,{hyperlink,length(reqUrls)});
    end

end
