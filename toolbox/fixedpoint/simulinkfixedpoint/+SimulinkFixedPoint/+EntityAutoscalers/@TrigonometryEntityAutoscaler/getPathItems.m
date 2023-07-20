function pathItems=getPathItems(~,blkObj)








    operator=blkObj.Operator;
    switch operator
    case 'sincos'
        pathItems={'sin','cos'};
    case 'cos + jsin'
        pathItems{1}='cexp';
    case{'sin','cos','atan2'}
        pathItems{1}=operator;
    otherwise
        pathItems{1}='1';
    end
end


