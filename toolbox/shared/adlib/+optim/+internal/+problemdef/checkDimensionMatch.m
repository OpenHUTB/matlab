function checkDimensionMatch(Left,Right)









    LeftSize=size(Left);
    RightSize=size(Right);




    dimensionMismatch=(~isscalar(Left)&&~isscalar(Right)&&...
    (numel(LeftSize)~=numel(RightSize)||any(LeftSize~=RightSize)));


    if dimensionMismatch
        LeftSizeStr=sprintf('%d-by-',LeftSize);
        LeftSizeStr=LeftSizeStr(1:end-4);
        RightSizeStr=sprintf('%d-by-',RightSize);
        RightSizeStr=RightSizeStr(1:end-4);
        throwAsCaller(MException(message('shared_adlib:checkDimensionMatch:DimensionsMustMatch',...
        LeftSizeStr,RightSizeStr)));
    end
