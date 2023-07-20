function content=reqDetailsToTable(dXML,linkType,docPath,id,details_level,docUrl)





    prefixStr=getString(message('Slvnv:RptgenRMI:ReqTable:execute:DetailsFrom'));

    [depths,items]=linkType.DetailsFcn(docPath,id,details_level);

    if isempty(items)
        content=[prefixStr,' ',getString(message('Slvnv:RptgenRMI:ReqTable:execute:NotAvailable'))];

    else

        content=dXML.createElement('simplelist');
        content.setAttribute('type','vert');
        content.setAttribute('rows',sprintf('%d',length(depths)+1));


        item=RptgenRMI.filterChars(items{1});
        if linkType.isFile
            [~,fName,fExt]=fileparts(docPath);
            docName=[fName,fExt];
        else
            docName=docPath;
        end
        separatorString=['------- ',prefixStr,' ',docName,':',' -------'];
        linkToDocument=dXML.makeLink(docUrl,separatorString,'ulink');
        content.appendChild(dXML.createElement('member',linkToDocument));
        content.appendChild(dXML.createElement('member',append_depths_prefix(item,depths(1))));


        for j=2:length(depths)
            if ischar(items{j})
                item=strtrim(RptgenRMI.filterChars(items{j}));
            else
                item=items{j};
            end

            if isempty(item)
                continue;
            end

            if iscell(item)

                m=dXML.createElement('simplelist');
                m.setAttribute('type','horiz');
                m.setAttribute('columns',sprintf('%d',size(item,2)));
                for row=1:size(item,1)
                    for col=1:size(item,2)
                        element=RptgenRMI.filterChars(item{row,col});
                        m.appendChild(dXML.createElement('member',element));
                    end
                end
                content.appendChild(dXML.createElement('member',m));
            else

                content.appendChild(dXML.createElement('member',append_depths_prefix(item,depths(j))));
            end
        end
    end
end

function str=append_depths_prefix(str,depth)


    if depth>0
        str=sprintf('%s %s',char(double('*')*ones(1,depth)),str);
    end
end
