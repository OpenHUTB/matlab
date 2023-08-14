function h=getDataWidgetHandles(p)





    if isIntensityData(p)
        h=p.hIntensitySurf;
    else
        switch lower(p.Style)
        case 'line'
            h=p.hDataLine;
        case{'filled','sectors'}
            h=p.hDataPatch;
        otherwise
            error('Unrecognized style ''%s''.',p.Style);
        end
    end
