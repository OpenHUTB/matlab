
function out=getEscapedString(str)
    out=char(slsvInternal('slsvEscapeServices','unicode2native',str,'US-ASCII'));
