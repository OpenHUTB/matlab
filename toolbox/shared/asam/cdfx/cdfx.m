function cdfxObj=cdfx(file)











    try

        narginchk(1,1);


        file=convertCharsToStrings(file);


        validateattributes(file,{'string'},{'nonempty','row'});


        try
            cdfxObj=asam.CDFX(file);
        catch ME
            switch ME.identifier
            case 'MATLAB:structRefFromNonStruct'
                error(message('asam_cdfx:CDFX:MissingExpectedElement'));
            otherwise
                rethrow(ME);
            end
        end
    catch ME

        throwAsCaller(ME);
    end
end


