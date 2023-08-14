function h=Timeseries(varargin)














    h=Simulink.Timeseries;
    if nargin==1&&isa(varargin{1},'timeseries')
        h.tsValue=varargin{1};
    elseif nargin==1&&isa(varargin{1},'Simulink.Timeseries')
        h.tsValue=varargin{1}.tsValue;
    else
        h.tsValue=SimTimeseries(varargin{:});
    end
