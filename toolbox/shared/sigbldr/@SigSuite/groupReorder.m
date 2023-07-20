





function groupReorder(this,neworder,varargin)
    if(isempty(neworder)||~isnumeric(neworder)||...
        numel(neworder)~=this.NumGroups)
        DAStudio.error('Sigbldr:sigsuite:InvalidNewOrder',this.Name,'Groups');
    end
    this.Groups=this.Groups(neworder);
end
