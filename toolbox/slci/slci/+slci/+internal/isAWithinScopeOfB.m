












function out=isAWithinScopeOfB(aPath,bPath)
    aPathCell=strsplit(aPath,'/');
    bPathCell=strsplit(bPath,'/');
    out=numel(aPathCell)>=numel(bPathCell)&&...
    all(strcmp(aPathCell(1:numel(bPathCell)-1),...
    bPathCell(1:end-1)));
end