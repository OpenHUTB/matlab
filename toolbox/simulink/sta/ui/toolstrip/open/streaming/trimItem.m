function trimItem(item,downSelectStr)







    if isequal(downSelectStr,'all')
        return;
    else


        downSelectStr=squeeze(downSelectStr);

        for id=1:length(item.ListItems)
            aChildItem=item.ListItems{id};
            tobestreamed=false;
            for strId=1:length(downSelectStr)
                if isequal(aChildItem.Name,downSelectStr(strId).name)

                    tobestreamed=true;
                    break;

                end

            end

            if(tobestreamed)



                trimItem(item.ListItems{id},downSelectStr(strId).children);
            else

                item.ListItems{id}=[];
            end

        end

        cellEmpty=cellfun(@isempty,item.ListItems);
        item.ListItems(cellEmpty)=[];
    end

end