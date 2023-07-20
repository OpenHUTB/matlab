function numIters_dbl=cordic_check_and_parse_niters(niters,fcnStr)






    numIters_dbl=inf;

    if~isempty(niters)
        doErrorHandling(...
        ~(isscalar(niters)&&isnumeric(niters)&&isreal(niters)),fcnStr);

        if isfinite(niters)

            doErrorHandling(...
            ~(isequal(floor(niters),niters)&&(niters>0)),fcnStr);


            numIters_dbl=double(niters);
        else

            doErrorHandling(isnan(niters),fcnStr);
        end
    end


    function doErrorHandling(doThrowError,fcnStr)
        if doThrowError
            msgID=message('fixed:cordic:invalidNiters',fcnStr);
            error(msgID);
        end

