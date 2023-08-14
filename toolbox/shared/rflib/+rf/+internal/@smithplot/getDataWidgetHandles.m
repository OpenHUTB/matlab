function h=getDataWidgetHandles(p)





    switch lower(p.Style)
    case 'line'
        h=p.hDataLine;


    otherwise
        error('Unrecognized style ''%s''.',p.Style);
    end
