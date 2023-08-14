
function shortLabel=shortenLabel(fullLabel,maxTextLenInPixel)
    avgCharLenInPixel=9;
    numCharWithEllipsis=floor(maxTextLenInPixel/avgCharLenInPixel);

    fullLen=length(fullLabel);
    if fullLen<=numCharWithEllipsis
        shortLabel=fullLabel;
    else
        numCharWithoutEllipsis=numCharWithEllipsis-3;
        numCharWithoutEllipsis=min(fullLen,numCharWithoutEllipsis);
        shortLabel=[fullLabel(1:numCharWithoutEllipsis),'...'];
    end
