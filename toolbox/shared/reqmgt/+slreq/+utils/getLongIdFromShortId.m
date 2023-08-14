





function out=getLongIdFromShortId(parentId,shortId)

    if isnumeric(shortId)
        error('Invalid argument');
    end





    if~isempty(shortId)&&shortId(1)=='@'
        shortId(1)=[];
    end



    if~isempty(parentId)&&~contains(shortId,'~')
        out=[parentId,'~',shortId];
    else
        out=shortId;
    end

end