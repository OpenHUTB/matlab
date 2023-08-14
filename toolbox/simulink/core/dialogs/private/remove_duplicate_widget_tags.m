function items=remove_duplicate_widget_tags(items)




    items=l_remove_duplicate_tags(items,{});
end


function[items,tagList]=l_remove_duplicate_tags(items,tagList)
    for idx=1:length(items)
        thisItem=items{idx};
        if isfield(thisItem,'Tabs')

            [thisItem.Tabs,tagList]=l_remove_duplicate_tags(thisItem.Tabs,tagList);
        elseif isfield(thisItem,'Items')

            [thisItem.Items,tagList]=l_remove_duplicate_tags(thisItem.Items,tagList);
        elseif isfield(thisItem,'Tag')

            [thisItem.Tag,tagList]=l_get_unique_tag(thisItem.Tag,tagList);
        end
        items{idx}=thisItem;
    end
end


function[uniqueTag,tagList]=l_get_unique_tag(tag,tagList)


    counter=0;
    uniqueTag=tag;


    while ismember(uniqueTag,tagList)
        counter=counter+1;
        uniqueTag=[tag,num2str(counter)];
    end


    tagList{end+1,1}=uniqueTag;
end
