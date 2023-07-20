function plot_data_active(p)



    if isIntensityData(p)
        plot_data_intensity_active(p);
    else
        switch lower(p.Style)
        case 'line'
            plot_data_points_active(p);
        case 'filled'
            plot_data_polygon_active(p);
        case 'sectors'
            plot_data_sectors_active(p);
        otherwise
            error('Unrecognized style ''%s''.',p.Style);
        end
    end
