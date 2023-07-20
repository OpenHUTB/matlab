function bVal=getLogAsSpecified(varargin)







    h=varargin{1};
    hNode=h.getBdOrTopMdlRefNode;
    val=hNode.logAsSpecifiedInMdl;
    bVal=strcmp(val,'checked');

end
