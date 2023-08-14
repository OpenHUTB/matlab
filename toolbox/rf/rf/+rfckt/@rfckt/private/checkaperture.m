function aperture=checkaperture(~,freq,aperture)




    if isempty(aperture)
        return
    end

    m=numel(freq);
    aperture=squeeze(aperture);

    if~isnumeric(aperture)
        error(message('rf:rfckt:rfckt:checkaperture:NotNumeric'));
    end

    if any(isnan(aperture))
        error(message('rf:rfckt:rfckt:checkaperture:IsNaN'));
    end

    if any(aperture<=0)
        error(message('rf:rfckt:rfckt:checkaperture:NotPositive'));
    end

    if any(isinf(aperture))
        error(message('rf:rfckt:rfckt:checkaperture:IsInf'));
    end

    if~isvector(aperture)||((numel(aperture)~=1)&&(numel(aperture)~=m))
        error(message('rf:rfckt:rfckt:checkaperture:WrongInput'));
    end


    if numel(aperture)==m
        aperture=reshape(aperture,[m,1]);
    else
        aperture=aperture*ones(m,1);
    end