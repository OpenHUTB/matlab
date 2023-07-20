function plot_data(p)




    if isIntensityData(p)
        plot_data_intensity(p);
    else
        switch lower(p.Style)
        case 'line'
            plot_data_points(p);
        case 'filled'
            plot_data_polygon(p);
        case 'sectors'
            plot_data_sectors(p);
        otherwise
            error('Unrecognized style ''%s''.',p.Style);
        end
    end
