function actions=getcontextactions(handle)




    persistent nodecontextactions;
    actions=[];
    if strcmp(class(handle),'TflDesigner.root')

        if isempty(nodecontextactions)
            nodecontextactions={};
            nodecontextactions{1}='FILE_TABLE';
            nodecontextactions{2}='FILE_IMPORT';
            nodecontextactions{3}='SEPARATOR';
            nodecontextactions{4}='EDIT_PASTE';
            nodecontextactions{5}='SEPARATOR';
            nodecontextactions{6}='EDIT_DELETE';
        end
        actions=nodecontextactions;
    end


