function matchingIndex=getRowIndexForId(this,id)




    matchingIndex=-1;
    if~isempty(this.TableData)&&~isempty(id)
        matchingIndex=find(strcmpi(this.TableData.Row,id)==1);
        if isempty(matchingIndex)
            matchingIndex=-1;
        end
    end
end
