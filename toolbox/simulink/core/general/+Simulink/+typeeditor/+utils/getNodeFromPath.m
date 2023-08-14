function node=getNodeFromPath(rt,path,varargin)






    expand=false;
    if nargin>2
        expand=true;
    end
    node=rt;
    if isempty(path);return;end
    traversalNodes=split(path,'.');
    for idx=1:length(traversalNodes)
        node=Simulink.typeeditor.utils.getChildNode(node,traversalNodes{idx},expand);
    end