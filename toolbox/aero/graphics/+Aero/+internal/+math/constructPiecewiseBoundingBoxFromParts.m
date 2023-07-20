function[boundingbox,groups]=constructPiecewiseBoundingBoxFromParts(bottom,right,top,left)






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





    if isempty(bottom)
        bottom=[
        nan,-inf
        nan,-inf
        ];
    elseif isscalar(bottom)
        bottom=[
        nan,bottom;
        nan,bottom;
        ];
    end


    if isempty(right)
        right=[
        inf,nan;
        inf,nan;
        ];
    elseif isscalar(right)
        right=[
        right,nan;
        right,nan;
        ];
    end


    if isempty(top)
        top=[
        nan,inf;
        nan,inf;
        ];
    elseif isscalar(top)
        top=[
        nan,top;
        nan,top;
        ];
    end


    if isempty(left)
        left=[
        -inf,nan;
        -inf,nan;
        ];
    elseif isscalar(left)
        left=[
        left,nan;
        left,nan;
        ];
    end


    box=[
    bottom;
    right;
    top;
    left;
    ];


    box=circshift(box,1);
    [boundingbox,I]=fillmissing(box,"nearest");


    boundingbox=circshift(boundingbox,-1);
    I=circshift(I,-1);
    groups=double(all(isfinite(boundingbox)|I,2));




    n=1;
    for i=2:numel(groups)
        if(groups(i)==0)&&(groups(i-1)~=0)

            n=n+1;
        elseif groups(i)~=0
            groups(i)=n;
        end
    end
end