function htLink=linkToRawExport(htmFile,icon)

    rawFile=strrep(htmFile,'.htm','_raw.htm');
    if ispc
        rawFile=strrep(htmFile,'\','/');
    end

    if nargin==1
        htLink=['[<a href="file://',rawFile,'" target=_blank>raw export</a>]'];
    else
        img=['<img src="file://',icon,'">'];
        htLink=['&nbsp;<a href="file://',rawFile,'" target=_blank>',img,'</a>'];
    end
end
