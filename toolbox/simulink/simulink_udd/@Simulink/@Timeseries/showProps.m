function out=showProps(h,varargin)




    if nargin>1
        prop=varargin{1};
        out=h.prop;
    else
        if~isempty(h.findvar('Data'))&&~isempty(h.findvar('Time'))
            out=struct('Name',{h.Name},'BlockPath',{h.BlockPath},'PortIndex',{h.PortIndex},...
            'SignalName',{h.signalname},'ParentName',{h.parentname},'events',{h.events},'timeInfo',{h.TimeInfo},...
            'Time',{h.Time},'Data',{h.Data},'ValueDimensions',{h.ValueDimensions});
        else
            out=struct('Name',{h.Name},'BlockPath',{h.BlockPath},'PortIndex',{h.PortIndex},...
            'SignalName',{h.signalname},'ParentName',{h.parentname},'events',{h.events},'timeInfo',{h.TimeInfo});
        end
    end