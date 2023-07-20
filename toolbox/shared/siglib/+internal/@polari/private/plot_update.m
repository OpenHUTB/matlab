function plot_update(p,varargin)








    parseData(p,varargin);
    updateTransformedData(p);
    if~isempty(p.pData)
        switch lower(p.Style)
        case 'line'

            plot_data_points_update(p);
        case 'filled'
            plot_data_polygon(p);
        case 'sectors'
            plot_data_sectors(p);
        otherwise
            error('Unrecognized style ''%s''.',p.Style);
        end
    end
