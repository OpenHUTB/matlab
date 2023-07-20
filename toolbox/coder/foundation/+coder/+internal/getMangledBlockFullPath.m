

function out=getMangledBlockFullPath(model,sidName)
    out=coder.internal.getBlockFullPath(model,sidName);
    out=strrep(out,newline,' ');
    out=strrep(out,'//*','//+');
    out=strrep(out,'*//','+//');
