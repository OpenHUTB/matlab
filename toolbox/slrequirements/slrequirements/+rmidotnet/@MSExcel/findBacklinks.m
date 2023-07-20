function backlinksData=findBacklinks(this)







    if~isempty(this.backlinks)

        if this.hDoc.Saved&&this.matchTimestamp()

            backlinksData=this.backlinks;
            return;
        end
    end

    rmiref.ExcelUtil.insertions('reset');

    backlinksData=[];
    allHyperlinks=this.hSheet.Hyperlinks;
    for i=1:allHyperlinks.Count
        thisLink=allHyperlinks.Item(i);
        address=char(thisLink.Address);
        if isempty(address)
            continue;
        elseif~contains(address,'matlab/feval')
            continue;
        end



        [mwCmd,mwArgs]=slreq.uri.parseConnectorURL(address);
        if isempty(mwCmd)
            continue;
        end
        shape=thisLink.Shape;
        if isempty(shape)
            continue;
        end
        rowAndCol=rmidotnet.MSExcel.getRowAndColAddress(shape);
        if isempty(rowAndCol)
            continue;
        end
        linkData.cell=rowAndCol;
        linkData.doc=this.sFile;
        linkData.index=i;


        linkData.address=address;
        linkData.command=mwCmd;
        linkData.mwSource=mwArgs.artifact;
        linkData.mwId=mwArgs.id;

        if isempty(backlinksData)
            backlinksData=linkData;
        else
            backlinksData(end+1)=linkData;%#ok<AGROW>
        end




        rmiref.ExcelUtil.insertions('store',sprintf('r%dc%d',rowAndCol(1),rowAndCol(2)));
    end
    this.backlinks=backlinksData;
end

