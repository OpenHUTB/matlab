function meta=readCustomTileSetMetadata(varargin)













    try
        group=matlab.internal.maps.BasemapSettingsGroup;
        if nargin==1
            group.TopLevelGroupName=varargin{1};
        end
        group=readGroup(group);
        numGroups=length(group);
        if numGroups==0
            meta=matlab.graphics.chart.internal.maps.TileSetMetadata.empty;
        else
            meta=matlab.graphics.chart.internal.maps.TileSetMetadata;
            meta(numGroups)=meta;
            for k=1:numGroups
                meta(k).TileSetName=group(k).BasemapName;
                url=group(k).URL;
                if matlab.internal.maps.isTileSetFile(url)

                    meta(k).MapTileLocation.ParameterizedLocation=url;
                else


                    meta(k).MapTileLocation=url;
                end
                meta(k).MapTileLocation.AlternateURL=group(k).AlternateURL;
                meta(k).Attribution=group(k).Attribution;
                meta(k).MaxZoomLevel=group(k).MaxZoomLevel;
            end

            if isdeployed

                meta=meta([group.IsDeployable]);
            end
        end
    catch
        meta=matlab.graphics.chart.internal.maps.TileSetMetadata.empty;
    end
end
