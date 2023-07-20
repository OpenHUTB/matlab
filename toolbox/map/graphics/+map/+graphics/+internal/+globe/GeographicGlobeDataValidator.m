classdef GeographicGlobeDataValidator...
    <matlab.graphics.chart.internal.maps.GeographicDataValidator


































    properties
        HeightVariable='height';
    end

    methods
        function obj=GeographicGlobeDataValidator(valueType)
            obj@matlab.graphics.chart.internal.maps.GeographicDataValidator(valueType)

            [status,msg]=builtin('license','checkout','MAP_Toolbox');
            if~status
                e=MException('map:license:NoMapLicense',msg);
                throwAsCaller(e)
            end

            if valueType=="properties"
                obj.HeightVariable='HeightData';
            end
        end


        function height=validateHeight(obj,height)



            varname=obj.HeightVariable;
            try
                if isempty(height)
                    validateattributes(height,{'numeric'},...
                    {'real','nonsparse'},'',varname)
                else





                    validateattributes(height,{'numeric'},...
                    {'real','vector','nonsparse'},'',varname)
                    if any(isinf(height))

                        validateattributes(height,...
                        {'numeric'},{'vector','finite'},'',varname)
                    end
                    height=height(:);
                end
            catch e
                throwAsCaller(e)
            end
        end

        function validateSizeConsistency(obj,lat,lon,height)





            latvar=obj.LatitudeVariable;
            n=numel(lat);

            if(n~=numel(lon))
                msg=getString(message('MATLAB:graphics:geobubble:DataLengthMismatch',...
                obj.LongitudeVariable,latvar));
                error('map:graphics:globe:DataLengthMismatch',msg)
            end

            heightDataMismatch=(numel(height)~=n);
            if heightDataMismatch
                ok=isempty(height)||(isscalar(height)&&(n>0));
                if~ok
                    msg=getString(message('MATLAB:graphics:geobubble:DataLengthMismatch',...
                    obj.HeightVariable,latvar));
                    error('map:graphics:globe:DataLengthMismatch',msg);
                end
            end
        end


        function dataargs=validateDataArguments(obj,lat,lon,height)


            try
                lat=validateLatitude(obj,lat);
                lon=validateLongitude(obj,lon);
                height=validateHeight(obj,height);
                validateSizeConsistency(obj,lat,lon,height)
                dataargs={};
                if~isempty(lat)
                    dataargs(end+1:end+2)={'LatitudeData',lat};
                end
                if~isempty(lon)
                    dataargs(end+1:end+2)={'LongitudeData',lon};
                end
                if~isempty(height)
                    dataargs(end+1:end+2)={'HeightData',height};
                end
            catch e
                throwAsCaller(e)
            end
        end
    end
end
