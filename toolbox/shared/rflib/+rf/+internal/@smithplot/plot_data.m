function plot_data(p)




    switch lower(p.Style)
    case 'line'
        plot_data_points(p);




    otherwise
        error('Unrecognized style ''%s''.',p.Style);
    end
