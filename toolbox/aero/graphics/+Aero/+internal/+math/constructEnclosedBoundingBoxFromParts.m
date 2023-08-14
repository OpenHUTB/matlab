function[boundingbox,groups]=constructEnclosedBoundingBoxFromParts(bottom,right,top,left)








...
...
...
...
...
...
...
...
...
...
...





    basebox=[

    -inf,-inf;
    inf,-inf;
    inf,inf;
    -inf,inf;
    ];

    bottombox=basebox;
    rightbox=basebox;
    topbox=basebox;
    leftbox=basebox;

    if isscalar(bottom)
        bottombox([1,2],2)=bottom;
    elseif~isempty(bottom)
        connector1=[-inf,bottom(1,2)];
        connector2=[inf,bottom(end,2)];
        bottombox=[connector1;bottom;connector2;bottombox([3,4],:)];
    end

    if isscalar(right)
        rightbox([2,3],1)=right;
    elseif~isempty(right)
        connector1=[right(1,1),-inf];
        connector2=[right(end,1),inf];
        rightbox=[rightbox(1,:);connector1;right;connector2;rightbox(4,:)];
    end

    if isscalar(top)
        topbox([3,4],2)=top;
    elseif~isempty(top)
        connector1=[inf,top(1,2)];
        connector2=[-inf,top(end,2)];
        topbox=[topbox([1,2],:);connector1;top;connector2];
    end

    if isscalar(left)
        leftbox([1,4],1)=left;
    elseif~isempty(left)
        connector1=[left(1,1),inf];
        connector2=[left(end,1),-inf];
        leftbox=[connector1;left;connector2;leftbox([2,3],:)];
    end

    boundingbox={bottombox,rightbox,topbox,leftbox};
    groups=[];

end
