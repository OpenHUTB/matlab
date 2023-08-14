function[out,convertOut]=pixels2points(dialog,in)




    persistent conversion;
    if isempty(conversion)
        set(dialog,'Units','Pixels');
        posPixels=get(dialog,'Position');
        set(dialog,'Units','Points');
        posPoints=get(dialog,'Position');
        conversion=posPoints(3:4)./posPixels(3:4);
    end

    out=in.*conversion;
    convertOut=conversion;