function A=set(A,varargin)







    if nargin==3
        switch varargin{1}
        case{'MinX','MaxX'}
            A=LUpdatePosition(A,'x');
        case{'MinY','MaxY'}
            A=LUpdatePosition(A,'y');
        case 'LowerChild'
            A.LowerChild=varargin{2};
            if isa(A.LowerChild,'framerect')
                set(A.LowerChild,'MaxLine',get(A,'MyHandle'));
            end
        case 'UpperChild'
            A.UpperChild=varargin{2};
            if isa(A.UpperChild,'framerect')
                set(A.UpperChild,'MaxLine',get(A,'MyHandle'));
            end
        otherwise
            axischildObj=A.axischild;
            A.axischild=set(axischildObj,varargin{:});
        end
    else
        axischildObj=A.axischild;
        A.axischild=set(axischildObj,varargin{:});
    end




    function A=LUpdatePosition(A,dim)
        myFrame=get(A,'MyBin');
        framePos=get(myFrame,'Position');

        switch dim
        case 'x'
            if strcmp(A.Orientation,'horizontal')
                A=set(A,'XData',[framePos(1),framePos(1)+framePos(3)]);
            end
        case 'y'
            if strcmp(A.Orientation,'vertical')
                A=set(A,'YData',[framePos(2),framePos(2)+framePos(4)]);
            end
        end

