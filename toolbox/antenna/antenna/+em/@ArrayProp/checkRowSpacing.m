function checkRowSpacing(obj,varargin)
    tempSize=obj.Size;
    if isempty(tempSize)
        tempSize=[];
    else
        tempSize=tempSize(1);
    end
    if nargin>1
        checkspacingdims(obj,varargin{1},tempSize,'RowSpacing');
    else
        checkspacingdims(obj,obj.RowSpacing,tempSize,'RowSpacing');
    end
end