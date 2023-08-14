function varargout=removeChartChildren(varargin)







    varargout=cell(1,nargin);
    for a=1:nargin
        handles=varargin{a};
        keep=false(size(handles));
        for h=1:numel(handles)
            keep(h)=isempty(ancestor(handles(h),'matlab.graphics.chart.HeatmapChart','node'));
        end
        varargout{a}=handles(keep);
    end
