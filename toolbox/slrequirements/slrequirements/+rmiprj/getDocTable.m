function result=getDocTable(linkSource)




    col1='#';
    col2=getString(message('Slvnv:RptgenRMI:ReqTable:execute:Document'));
    col3=getString(message('Slvnv:RptgenRMI:ReqTable:execute:Type'));
    col4=getString(message('Slvnv:RptgenRMI:NoReqDoc:execute:LastModified'));
    col5=getString(message('Slvnv:RptgenRMI:NoReqDoc:execute:NumberOfLinks'));

    headers={col1,col2,col3,col4,col5};
    srcDir=fileparts(linkSource);
    [docs,items,reqsys]=rmidata.getLinkedItems(linkSource,true);
    result=[headers;cell(length(docs),5)];
    for i=1:length(docs)
        try
            lastModified=rmiprj.getDocDate(docs{i},srcDir,reqsys{i});
        catch ME %#ok<NASGU>
            lastModified=getString(message('Slvnv:RptgenRMI:NoReqDoc:execute:FileNotFound'));
        end
        numLinks=countLinks(items{i});
        result(i+1,:)={num2str(i),docs{i},reqsys{i},lastModified,num2str(numLinks)};
    end

end

function numLinks=countLinks(linkData)
    numLinks=0;
    for i=1:size(linkData,1)
        numLinks=numLinks+linkData{i,2};
    end
end