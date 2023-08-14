classdef GeographicBubbleDataValidator...
    <matlab.graphics.chart.internal.maps.GeographicDataValidator










































    properties
        SizeVariable='sizedata';
        ColorVariable='colordata';
    end

    methods
        function obj=GeographicBubbleDataValidator(valueType)
            obj@matlab.graphics.chart.internal.maps.GeographicDataValidator(valueType)
            if valueType=="properties"
                obj.SizeVariable='SizeData';
                obj.ColorVariable='ColorData';
            end
        end


        function sizedata=validateSizeData(obj,sizedata)


            varname=obj.SizeVariable;
            try
                if isempty(sizedata)
                    validateattributes(sizedata,{'numeric'},...
                    {'real','nonsparse'},'',varname)
                else
                    validateattributes(sizedata,{'numeric'},...
                    {'real','vector','nonsparse'},'',varname)
                    sizedata=sizedata(:);
                end
            catch e
                throwAsCaller(e)
            end
        end


        function colordata=validateColorData(obj,colordata)

            varname=obj.ColorVariable;
            if isempty(colordata)&&isfloat(colordata)
                colordata=[];
            else
                try
                    if isempty(colordata)
                        validateattributes(colordata,{'categorical'},...
                        {},'',varname)
                    else
                        validateattributes(colordata,{'categorical'},...
                        {'vector'},'',varname)
                    end
                catch e
                    throwAsCaller(e)
                end
            end
        end


        function validateSizeConsistency(obj,lat,lon,sizedata,colordata)





            latvar=obj.LatitudeVariable;
            n=numel(lat);

            if(n~=numel(lon))
                error(message('MATLAB:graphics:geobubble:DataLengthMismatch',...
                obj.LongitudeVariable,latvar));
            end

            sizeDataMismatch=(numel(sizedata)~=n);
            if sizeDataMismatch
                ok=isempty(sizedata)||(isscalar(sizedata)&&(n>0));
                if~ok
                    error(message('MATLAB:graphics:geobubble:DataLengthMismatch',...
                    obj.SizeVariable,latvar));
                end
            end

            colorDataMismatch=(numel(colordata)~=n);
            if colorDataMismatch
                ok=isempty(colordata)||(isscalar(colordata)&&(n>0));
                if~ok
                    error(message('MATLAB:graphics:geobubble:DataLengthMismatch',...
                    obj.ColorVariable,latvar));
                end
            end
        end


        function dataargs=validateDataArguments(obj,lat,lon,sizedata,colordata)


            try
                lat=validateLatitude(obj,lat);
                lon=validateLongitude(obj,lon);
                sizedata=validateSizeData(obj,sizedata);
                colordata=validateColorData(obj,colordata);
                validateSizeConsistency(obj,lat,lon,sizedata,colordata)
                dataargs={};
                if~isempty(lat)
                    dataargs(end+1:end+2)={'LatitudeData',lat};
                end
                if~isempty(lon)
                    dataargs(end+1:end+2)={'LongitudeData',lon};
                end
                if~isempty(sizedata)
                    dataargs(end+1:end+2)={'SizeData',sizedata};
                end
                if~isempty(colordata)
                    dataargs(end+1:end+2)={'ColorData',colordata};
                end
            catch e
                throwAsCaller(e)
            end
        end
    end
end
