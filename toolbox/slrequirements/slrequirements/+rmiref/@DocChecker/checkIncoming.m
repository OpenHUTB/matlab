


function result=checkIncoming(this)
    result=0;
    totalLinks=length(this.links);
    this.isOneWay=false(1,totalLinks);
    for i=1:totalLinks
        if~isempty(this.skipped{i})
            continue;
        end
        oneLink=this.links(i);
        if~oneLink.hasIncoming()
            this.isOneWay(i)=true;
            result=result+1;
        end
    end
end

