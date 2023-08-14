function val=get(A,varargin)





    axistextObj=A.axistext;

    if nargin==2
        switch varargin{1}
        case 'FontSize'
            val=A.FontSize;
        case 'Position'
            val=get(axistextObj,'Extent');
        otherwise
            val=get(axistextObj,varargin{:});
        end
    else
        val=get(axistextObj,varargin{:});
    end
