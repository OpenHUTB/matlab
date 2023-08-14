function out=points2pixels(UD,in)




    persistent conversion;
    if isempty(conversion)
        set(UD.dialog,'Units','Pixels');
        posPixels=get(UD.dialog,'Position');
        set(UD.dialog,'Units','Points');
        posPoints=get(UD.dialog,'Position');
        conversion=posPixels(3:4)./posPoints(3:4);
    end

    out=in.*conversion;