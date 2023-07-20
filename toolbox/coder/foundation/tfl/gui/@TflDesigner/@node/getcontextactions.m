function actions=getcontextactions(handle)




    if strcmp(handle.type,'TflTable')

        nodecontextactions={};
        nodecontextactions{1}='ADD_ENTRY';
        nodecontextactions{2}='SEPARATOR';
        nodecontextactions{3}='FILE_EXPORT';
        nodecontextactions{4}='SEPARATOR';
        nodecontextactions{5}='EDIT_CUT';
        nodecontextactions{6}='EDIT_COPY';
        nodecontextactions{7}='EDIT_PASTE';
        nodecontextactions{8}='SEPARATOR';
        nodecontextactions{9}='EDIT_DELETE';
        nodecontextactions{10}='SEPARATOR';
        nodecontextactions{11}='VALIDATE_TABLE';
        actions=nodecontextactions;



        y=TflDesigner.getselectedlistnodes;
        if(length(y)>1)
            actions=stripaction(actions,'FILE_EXPORT');
        end

    end

    function actions=stripaction(actions,act)

        idx=strcmp(act,actions);

        actions(idx)=[];


