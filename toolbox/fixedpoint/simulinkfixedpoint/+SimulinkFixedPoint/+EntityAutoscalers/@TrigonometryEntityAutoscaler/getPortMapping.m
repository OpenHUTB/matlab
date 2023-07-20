function pathItems=getPortMapping(~,blkObj,~,outportNum)










    operator=blkObj.Operator;
    switch operator
    case 'sincos'
        allPathItems={'sin','cos'};
        pathItems=allPathItems(outportNum);
    case 'cos + jsin'
        pathItems{1}='cexp';
    case{'sin','cos','atan2'}
        pathItems{1}=operator;
    otherwise
        pathItems{1}='1';
    end
end


