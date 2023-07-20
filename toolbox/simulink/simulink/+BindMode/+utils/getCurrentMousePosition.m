

function pos=getCurrentMousePosition(varargin)
























    if nargin>=2
        monitorPositions=varargin{1};
        pos=varargin{2};
    else
        monitorPositions=get(0,'MonitorPositions');
        pos=get(0,'PointerLocation');
    end
    pos(2)=monitorPositions(1,4)-pos(2);
end