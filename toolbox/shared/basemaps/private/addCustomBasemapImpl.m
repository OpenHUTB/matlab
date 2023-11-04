function addCustomBasemapImpl(basemapName,url,varargin)
    basemapGroup=parseInputs(basemapName,url,varargin);


    basemapGroup.AlternateURL=...
    map.internal.settings.findAlternateURL(basemapGroup.URL);


    addGroup(basemapGroup)



    validateGroup(basemapGroup)
end


function basemapGroup=parseInputs(basemapName,url,nameValueInputs)


    basemapGroup=matlab.internal.maps.BasemapSettingsGroup;
    basemapGroup.FunctionName='addCustomBasemap';
    paramNames=properties(basemapGroup);


    paramNames(contains(paramNames,["URL","BasemapName"]))=[];

    p=inputParser;
    addRequired(p,'basemapName',...
    @(x)validateBasemapSettings(basemapGroup,'BasemapName',x));




    value=convertCharsToStrings(url);
    validExtensions=".mbtiles";
    isFileInput=isstring(value)&&isscalar(value)...
    &&(isfile(value)||endsWith(value,validExtensions,"IgnoreCase",true));
    if isFileInput
        addRequired(p,'mbtilesFilename',...
        @(x)validateMBTilesFile(basemapGroup,x));
    else
        addRequired(p,'URL',...
        @(x)validateBasemapSettings(basemapGroup,'URL',x));
    end

    for k=1:length(paramNames)
        name=paramNames{k};
        addParameter(p,name,basemapGroup.(name),...
        @(x)validateBasemapSettings(basemapGroup,name,x));
    end

    parse(p,basemapName,url,nameValueInputs{:});
end


function validateBasemapSettings(basemapGroup,name,value)
    try
        basemapGroup.(name)=value;
    catch e
        throwAsCaller(e)
    end
end


function validateMBTilesFile(basemapGroup,value)
    try

        [status,msg]=builtin('license','checkout','MAP_Toolbox');
        if~status
            error('map:license:NoMapLicense','%s',msg);
        end



        info=map.internal.mbtilesinfo(value);
        basemapGroup.URL=info.Filename;
        basemapGroup.Attribution=info.Attribution;
        basemapGroup.MaxZoomLevel=info.MaxZoomLevel;
    catch e
        throwAsCaller(e)
    end
end
