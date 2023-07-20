classdef GeographicDataValidator




























    properties
        MaxLatitude=90;


        LatitudeVariable='lat';
        LongitudeVariable='lon';
    end

    methods
        function obj=GeographicDataValidator(valueType)
            if valueType=="properties"
                obj.LatitudeVariable='LatitudeData';
                obj.LongitudeVariable='LongitudeData';
            end
        end


        function lat=validateLatitude(obj,lat)




            varname=obj.LatitudeVariable;
            try
                if isempty(lat)
                    validateattributes(lat,{'double','single'},...
                    {'real','nonsparse'},'',varname)
                else
                    validateattributes(lat,{'double','single'},...
                    {'real','vector','nonsparse'},'',varname)
                    latmax=obj.MaxLatitude;



                    if any(isinf(lat))

                        validateattributes(lat,{'double','single'},...
                        {'vector','finite'},'',varname)
                    else

                        filtered=lat;
                        filtered(~isfinite(lat))=0;
                        validateattributes(filtered,{'double','single'},...
                        {'vector','>=',-latmax,'<=',latmax},'',varname)
                    end
                    lat=lat(:);
                end
            catch e
                throwAsCaller(e)
            end
        end


        function lon=validateLongitude(obj,lon)



            varname=obj.LongitudeVariable;
            try
                if isempty(lon)
                    validateattributes(lon,{'double','single'},...
                    {'real','nonsparse'},'',varname)
                else





                    validateattributes(lon,{'double','single'},...
                    {'real','vector','nonsparse'},'',varname)
                    if any(isinf(lon))

                        validateattributes(lon,...
                        {'double','single'},{'vector','finite'},'',varname)
                    end
                    lon=lon(:);
                end
            catch e
                throwAsCaller(e)
            end
        end


        function validateSizeConsistency(obj,lat,lon)


            latvar=obj.LatitudeVariable;
            n=numel(lat);

            if(n~=numel(lon))
                error(message('MATLAB:graphics:geobubble:DataLengthMismatch',...
                obj.LongitudeVariable,latvar));
            end
        end
    end
end
