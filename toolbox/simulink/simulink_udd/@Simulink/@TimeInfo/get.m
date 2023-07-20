function out=get(h,varargin)




    if nargin>1
        prop=varargin{1};
        out=h.(prop);
    else
        out=struct('Units',{h.units},'UserData',{h.UserData},'Start',{h.start},...
        'End',{h.end},'Increment',{h.increment},'Length',{h.Length});
    end
