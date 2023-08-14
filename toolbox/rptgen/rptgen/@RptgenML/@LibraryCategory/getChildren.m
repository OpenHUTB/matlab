function c=getChildren(dao)




    c=getHierarchicalChildren(dao);


    if(length(dao.childSortOrder)~=length(c))

        sortNames=cell(1,length(c));
        for i=1:length(c)
            sortNames{i}=c(i).getDisplayLabel();
        end;

        [names,dao.childSortOrder]=sort(sortNames);

    end;

    c=c(dao.childSortOrder);
