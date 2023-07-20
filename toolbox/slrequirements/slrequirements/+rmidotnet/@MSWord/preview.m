function[html,cacheFile]=preview(this,items)




    html='';


    this.updateScratchCopy();


    totalParags=length(this.iLevels);
    includedParags=zeros(1,totalParags);
    for i=1:length(items)
        startParag=items(i).parags(1);
        includedParags(startParag)=i;
    end


    includedIdx=find(includedParags>0);
    lastParag=0;
    tableData=cell(0,3);
    searchIconFile=[matlabroot,'/toolbox/slrequirements/slrequirements/resources/icons/search_16.png'];
    totalIncluded=length(includedIdx);
    for idx=1:totalIncluded

        paragIdx=includedIdx(idx);
        myItem=items(includedParags(paragIdx));
        firstParag=myItem.parags(1);
        if lastParag>0
            missedParags=lastParag+1:firstParag-1;
            if~isempty(missedParags)&&~all(strcmp(this.sLabels(missedParags),''))
                label=sprintf('%d-%d',missedParags(1),missedParags(end));
                [gray,htmFile]=this.paragsToHtml(label,missedParags(1),missedParags(end));
                tableData{end+1,1}=num2str(missedParags(1));%#ok<AGROW>
                tableData{end,2}='<font color="red">excluded</font>';
                tableData{end,2}=[tableData{end,2},slreq.import.html.linkToRawExport(htmFile,searchIconFile)];
                tableData{end,3}=['<font color="lightgray">',gray,'</font>'];
            end
        end

        lastParag=myItem.parags(end);

        if strcmp(myItem.type,'parag')
            if this.iEnds(lastParag)-this.iStarts(firstParag)<20
                continue;
            else

                label=sprintf('%d',firstParag);

                [myHtml,htmFile]=this.paragsToHtml(label,firstParag,lastParag);
            end
        else

            [myHtml,htmFile]=this.paragsToHtml(myItem.label,firstParag,lastParag);
        end
        tableData{end+1,1}=num2str(firstParag);%#ok<AGROW>
        tableData{end,2}=strrep(rmidotnet.typeToLabel(myItem.type,myItem.parags(1),this.iParents,includedParags),' ','&nbsp;');
        if any(strcmp(myItem.type,{'bookmark','match'}))
            tableData{end,2}=[tableData{end,2},'<br/>',slreq.import.html.linkToDocument(this.sFile,myItem.type,myItem.label)...
            ,slreq.import.html.linkToRawExport(htmFile,searchIconFile)];
        else
            tableData{end,2}=[tableData{end,2},'<br/>'...
            ,myItem.label,slreq.import.html.linkToRawExport(htmFile,searchIconFile)];
        end
        anchor=['<a name="',slreq.import.html.makeAnchorStr(myItem.label),'"></a>'];
        tableData{end,3}=[anchor,newline,myHtml];


        if mod(idx,5)==0&&slreq.import.wizard.ImportDlg.isProcessing()
            rmiut.progressBarFcn('set',i/totalIncluded,sprintf('%d items processed ..',idx));
        end
    end

    if lastParag<totalParags
        label=sprintf('%d-%d',lastParag+1,totalParags);
        [gray,htmFile]=this.paragsToHtml(label,lastParag+1,totalParags);
        tableData{end+1,1}=num2str(lastParag+1);
        tableData{end,2}='<font color="red">excluded</font>';
        tableData{end,2}=[tableData{end,2},slreq.import.html.linkToRawExport(htmFile,searchIconFile)];
        tableData{end,3}=['<font color="lightgray">',gray,'</font>'];
    end


    this.discardScratchCopy();


    if~isempty(tableData)
        headers={'#','Rule/Identifier','Content'};
        html=slreq.import.html.table(headers,tableData);
    end






    cacheFile=fullfile(tempdir,'RMI','MSWORD','preview.html');
    fid=fopen(cacheFile,'w');
    fwrite(fid,html,'char*1');
    fclose(fid);

end




