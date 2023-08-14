


function entry=findEntryInJavaCollection(collection,searchCondition)

    iterator=collection.iterator();

    entry=[];
    while(iterator.hasNext())


        element=iterator.next();
        if(searchCondition(element))

            entry=element;
            return;
        end

    end

end