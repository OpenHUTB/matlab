function checkColumnSpacing(obj,varargin)
    tempSize=obj.Size;
    if isempty(tempSize)
        tempSize=[];
    else
        tempSize=tempSize(2);
    end
    if nargin>1
        checkspacingdims(obj,varargin{1},tempSize,'ColumnSpacing');
    else
        checkspacingdims(obj,obj.ColumnSpacing,tempSize,'ColumnSpacing');
    end
end