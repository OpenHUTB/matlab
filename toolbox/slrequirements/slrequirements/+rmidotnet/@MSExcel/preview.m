function[html,cacheFile]=preview(this,items)




    html='';

    usingScratchCopy=false;

    if usingScratchCopy

        this.updateScratchCopy();%#ok<UNRCH>
    end



    rowNumToIdx=[];
    for i=1:length(items)
        item=items(i);
        if strcmp(item.type,'match')
            rowNumToIdx(item.address(1))=i;%#ok<AGROW>
        elseif strcmp(item.type,'bookmark')
            firstRow=item.address(1);
            lastRow=item.address(1)+item.range(1)-1;
            rowNumToIdx(firstRow:lastRow)=i;
        elseif strcmp(item.type,'row')
            row=item.address(1);
            if row>length(rowNumToIdx)||rowNumToIdx(row)==0
                rowNumToIdx(row)=i;%#ok<AGROW>
            end
        else
            rows=item.address(1):item.address(1)+item.range(1)-1;
            if any(rows>length(rowNumToIdx))||all(rowNumToIdx(rows)==0)
                rowNumToIdx(rows)=i;%#ok<AGROW>
            end
        end
    end


    parents=this.iParents;
    row=1;
    tableData=cell(0,3);
    searchIconFile=[matlabroot,'/toolbox/slrequirements/slrequirements/resources/icons/search_16.png'];
    while row<=length(rowNumToIdx)
        if rowNumToIdx(row)==0


            row=row+1;
        else
            itemIdx=rowNumToIdx(row);
            item=items(itemIdx);

            address=this.makeAddress(item);
            navcmd=sprintf('rmi.navigate(''linktype_rmi_excel'',''%s'',''%s'');',this.sFile,address);
            mcURL=rmiut.cmdToUrl(navcmd);
            tableData{end+1,1}=sprintf('<a href="%s">%d</a>',mcURL,row);%#ok<AGROW>

            if any(strcmp(item.type,{'bookmark','match'}))
                tableData{end,2}=strrep(rmidotnet.typeToLabel(item.type),' ','&nbsp;');
                tableData{end,2}=[tableData{end,2},'<a name="',slreq.import.html.makeAnchorStr(item.label),'"></a>'];
                tableData{end,2}=[tableData{end,2},'<br/>',slreq.import.html.linkToDocument(this.sFile,item.type,item.label)];
            else
                tableData{end,2}=['<a name="',slreq.import.html.makeAnchorStr(item.label),'">',item.label,'</a>'];
            end
            hRange=this.itemToRange(item);
            [myHtml,htmFile]=this.rangeToHtml(item.label,hRange);
            tableData{end,2}=[tableData{end,2},'&nbsp;',slreq.import.html.linkToRawExport(htmFile,searchIconFile)];
            if length(parents)>=item.address(1)&&parents(item.address(1))>0
                tableData{end,2}=[tableData{end,2},'<br/>',sprintf('child of %d',parents(item.address(1)))];
            end


            if isfield(item,'attrNames')&&~isempty(item.attrNames)
                subTableData=[item.attrNames,item.attrValues];
                isEmptyValue=strcmp(subTableData(:,2),'');
                if any(isEmptyValue)
                    subTableData(isEmptyValue,:)=[];
                end
                subTableHtml=slreq.import.html.table({'',''},subTableData);
                myHtml=[myHtml,newline,subTableHtml];%#ok<AGROW>
            end

            tableData{end,3}=myHtml;


            row=item.address(1)+item.range(1);
        end
    end

    if usingScratchCopy

        this.discardScratchCopy();%#ok<UNRCH>
    end


    if~isempty(tableData)
        headers={'#','Rule/Identifier','Content'};
        html=slreq.import.html.table(headers,tableData);
    end






    cacheFile=fullfile(tempdir,'RMI','MSEXCEL','preview.html');
    fid=fopen(cacheFile,'w');
    fwrite(fid,html,'char*1');
    fclose(fid);
    disp(cacheFile);

end

