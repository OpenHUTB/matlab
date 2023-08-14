function backlinksData=findBacklinks(this)







    if~isempty(this.backlinks)

        if this.hDoc.Saved&&this.matchTimestamp()

            backlinksData=this.backlinks;
            return;
        end
    end

    backlinksData=[];
    allHyperlinks=this.hDoc.Hyperlinks;
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


        linkData.doc=this.sFile;
        linkData.index=i;
        anchor=shape.Anchor;
        linkData.range=[anchor.Start,anchor.End];

        linkData.address=address;
        linkData.command=mwCmd;
        linkData.mwSource=mwArgs.artifact;
        linkData.mwId=mwArgs.id;


        if isempty(backlinksData)
            backlinksData=linkData;
        else
            backlinksData(end+1)=linkData;%#ok<AGROW>
        end
    end
    this.backlinks=backlinksData;

end

