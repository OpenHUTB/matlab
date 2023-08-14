






function out=isAAtParentLevelOfB(aPath,bPath)
    aPathCell=strsplit(aPath,'/');
    bPathCell=strsplit(bPath,'/');
    out=numel(aPathCell)+1==numel(bPathCell)&&...
    all(strcmp(aPathCell(1:end-1),bPathCell(...
    1:numel(aPathCell)-1)));
end
