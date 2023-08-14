classdef OpenLayersScript<map.webmap.internal.WebMapScript















































    properties(Access=private,Hidden=true)




ApiFilename





BaseLayerIndex
    end

    properties(Access=private)



        InitializingMap=false
    end

    methods

        function script=OpenLayersScript(varargin)








            script=script@map.webmap.internal.WebMapScript(varargin{:});


            script.ScriptBase='OpenLayers';
            script.ApiVersion='2.12';
            script.ApiLibrary=...
            ['http://dev.openlayers.org/releases/OpenLayers-',script.ApiVersion,'/lib/OpenLayers.js'];
            script.ApiProvider='OpenLayers';
            script.ZoomLevel=0;


            assignLayerConfigurationProperties(script);


            script.BaseLayerIndex=0;
        end
    end

    methods(Access='protected')

        function js=createTiledMapServiceMapScript(script,layers,projCodes)










            layersInit='var layers = [];';
            if nargin>1



                js=createWebMapServiceLayerScript(script,layers,projCodes);
                containsLayersInit=contains(string(js),layersInit);
                appendScript(script,js);
            else
                containsLayersInit=false;
            end

            js=createTiledMapServiceLayerScript(script);
            if contains(string(js),layersInit)&&containsLayersInit

                s=erase(string(js),layersInit);
                js={char(s)};
            end


            appendScript(script,js);


            createMapScript(script);


            latlim=[-85,85];
            lonlim=[-360,360];
            js=replaceLimits(script.RestrictLimits,latlim,lonlim);
            appendScript(script,js);
            js=script.WebScript;
        end



        function js=createWebMapServiceMapScript(script,layer)








            if~isempty(script.BaseLayerConfiguration.WMSLayer)

                js=createWebMapServiceLayerScript(script,[]);


                appendScript(script,js);
            end

            if~isempty(layer)

                js=createWebMapServiceLayerScript(script,layer);


                appendScript(script,js);
            end

            if~isempty(script.OverlayLayerConfiguration.WMSLayer)

                js=createWebMapServiceOverlayLayersScript(script,'geographic');


                appendScript(script,js);
            end


            js=createMapScript(script);



            tf=false(1,length(layer));
            for k=1:length(layer)
                tf(k)=abs(diff(layer(k).Latlim))>=180...
                &&abs(diff(layer(k).Lonlim))>=360;
            end
            tf=all(tf);
            if tf
                latlim=[-90,90];
                lonlim=[-360,360];
                js=replaceLimits(script.RestrictLimits,latlim,lonlim);
                appendScript(script,js);
                js=script.WebScript;
            end
        end



        function js=createMapScript(script)








            appendScript(script,script.EndOfCreateLayersScript);



            js=script.CreateWebMap;
            appendScript(script,js);



            script.InitializingMap=true;
            js=createSetMapExtentScript(script);
            script.InitializingMap=false;
            script.WebScript=js;




            js=createSetDefaultLayerScript(script,script.BaseLayerName);
            script.WebScript=js;

            if script.UsingPublish

                appendScript(script,script.PanZoomBarScript)
                js=script.WebScript;
            end
        end



        function js=createTiledMapServiceLayerScript(script)









            wrapJs=wrapDateLine(script.WrapAroundVar,script.WrapAround);




            js=script.CreateTiledMapServiceLayer;
            js={[wrapJs{:},js{:}]};


            config=script.BaseLayerConfiguration.XYZLayer;



            serverURLs={config.ServerURL};
            varString='var serverURLs = [ " "';
            js=modifyJavaScriptServerURLs(js,serverURLs,varString);




            S(1:2)=struct('Values','','VarString','');
            S(1).Values={config.LayerName};
            S(2).Values={config.Attribution};
            S(1).VarString='var layerNames = [ " "';
            S(2).VarString='var attributions = [ " "';

            js=modifyJavaScriptArrayVariables(js,S);
            tiledBaseLayersJs=js;



            js=script.CreateTiledMapServiceOverlayLayers;


            config=script.OverlayLayerConfiguration.XYZLayer;
            if~isempty(config)


                serverURLs={config.ServerURL};
                varString='var overlayServerURLs = [ " "';
                js=modifyJavaScriptServerURLs(js,serverURLs,varString);




                S(1).Values={config.LayerName};
                S(2).Values={config.Attribution};
                S(1).VarString='var overlayLayerNames = [ " "';
                S(2).VarString='var overlayAttributions = [ " "';

                js=modifyJavaScriptArrayVariables(js,S);
                tiledOverlayLayersJs=js;
            else
                tiledOverlayLayersJs={};
            end


            js=createWebMapServiceOverlayLayersScript(script,'tiled');


            js={[tiledBaseLayersJs{:},tiledOverlayLayersJs{:},js{:}]};
        end



        function js=createWebMapServiceOverlayLayersScript(script,type)









            js=script.CreateWebMapServiceOverlayLayers;


            config=script.OverlayLayerConfiguration.WMSLayer;
            if~isempty(config)
                projections={config.Projection};
                index1=strcmp('EPSG:4326',projections);
                index2=strcmp('CRS:84',projections);
                index=index1|index2;
                if strcmp(type,'geographic')

                    config=config(index);
                else

                    config=config(~index);
                end

                if~isempty(config)



                    serverURLs={config.ServerURL};
                    varString='var wmsServerURLs = [ " "';
                    js=modifyJavaScriptServerURLs(js,serverURLs,varString);




                    S(1).Values={config.LayerName};
                    S(2).Values={config.Attribution};
                    S(3).Values={config.OverlayName};
                    S(4).Values={config.Projection};
                    S(5).Values={config.Version};

                    S(1).VarString='var wmsLayerNames = [ " "';
                    S(2).VarString='var wmsAttributions = [ " "';
                    S(3).VarString='var wmsLayerTitles = [ " "';
                    S(4).VarString='var wmsProjections = [ " "';
                    S(5).VarString='var wmsVersions = [ " "';

                    js=modifyJavaScriptArrayVariables(js,S);
                else
                    js={};
                end
            else
                js={};
            end
        end



        function js=createSetDefaultLayerScript(script,baseLayerName)







            namedLayers=script.BaseLayerNames;
            baseLayerIndex=find(strcmp(baseLayerName,namedLayers))-1;
            currentIndex=num2str(script.BaseLayerIndex);
            if~isempty(baseLayerIndex)
                script.BaseLayerName=baseLayerName;
                script.BaseLayerIndex=baseLayerIndex;
                js=strrep(script.WebScript,...
                ['baseLayerNumber = ',currentIndex],...
                ['baseLayerNumber = ',num2str(baseLayerIndex)]);
            end
        end



        function js=createKmlLayerScript(script,filename,overlayName)








            js=script.CreateKmlLayer;
            js=strrep(js,'FILENAME_TOKEN',filename);
            js=strrep(js,'"KML"',['"',overlayName,'"']);
        end



        function js=createWebMapServiceLayerScript(script,layers,projCodes)







            if~isempty(layers)


                n=length(layers);


                serverURLs=cell(1,n);
                layerTitles=cell(1,n);
                layerNames=cell(1,n);
                versions=cell(1,n);
                formats=cell(1,n);
                projections=cell(1,n);


                useProjCode=exist('projCodes','var');
                nationalmap='nationalmap.gov/ArcGIS';
                for k=1:n
                    layer=layers(k);
                    request=WMSMapRequest(layer);
                    layer=validateLayer(layer,request.ImageFormat);

                    version=request.Layer.Details.Version;
                    if strcmp(request.CoordRefSysCode,'EPSG:4326')
                        if any(strcmp('CRS:84',layer.CoordRefSysCodes))
                            request.CoordRefSysCode='CRS:84';
                        elseif strcmp(version,'1.3.0')
                            version='1.1.1';
                        end
                    end


                    serverURL=strrep(layer.ServerURL,nationalmap,lower(nationalmap));
                    serverURLs{k}=serverURL;
                    layerTitles{k}=layer.LayerTitle;
                    layerNames{k}=layer.LayerName;
                    versions{k}=version;
                    formats{k}=request.ImageFormat;
                    if useProjCode
                        request.CoordRefSysCode=projCodes{k};
                    end
                    projections{k}=request.CoordRefSysCode;
                end

                singleTile=layerRequiresSingleTileAccess(layers);



                script.CenterLatitude=[];
                script.CenterLongitude=[];
                script.LatitudeLimits=layers(1).Latlim;
                script.LongitudeLimits=layers(1).Lonlim;
            else

                config=script.BaseLayerConfiguration.WMSLayer;
                serverURLs={config.ServerURL};
                layerTitles={config.OverlayName};
                layerNames={config.LayerName};
                versions={config.Version};
                projections={config.Projection};
                formats=cell(1,length(config));
                [formats{1:length(formats)}]=deal('image/jpeg');
                singleTile=cell(1,length(config));
                [singleTile{1:length(singleTile)}]=deal('false');
            end


            wrapJs=wrapDateLine(script.WrapAroundVar,script.WrapAround);



            js=script.CreateWebMapServiceLayer;
            js={[wrapJs{:},js{:}]};


            js=modifyWebMapServiceLayerVariables(js,serverURLs,...
            layerTitles,layerNames,versions,formats,projections,...
            singleTile);
        end



        function js=createSetCenterScript(script,centerLat,centerLon,zoomLevel)











            if nargin<4

                zoomLevelValue=replace(strip(script.GetZoom),';','');
            else
                zoomLevelValue=num2str(zoomLevel);
            end


            if~script.InitializingMap
                js=script.SetCenter;
                centerLatOld='centerLat';
                centerLatNew=num2str(centerLat);
                centerLonOld='centerLon';
                centerLonNew=num2str(centerLon);
                zoomLevelOld='zoomLevel';
                zoomLevelNew=zoomLevelValue;
            else
                js=script.WebScript;
                centerLatOld='centerLat = 0';
                centerLatNew=['centerLat = ',num2str(centerLat)];
                centerLonOld='centerLon = 0';
                centerLonNew=['centerLon = ',num2str(centerLon)];
                zoomLevelOld='zoomLevel = 0';
                zoomLevelNew=['zoomLevel = ',zoomLevelValue];
            end


            js=replace(js,centerLatOld,centerLatNew);
            js=replace(js,centerLonOld,centerLonNew);


            js=replace(js,zoomLevelOld,zoomLevelNew);
        end



        function js=createSetZoomScript(script,zoomLevel)








            js=script.SetZoom;


            js=strrep(js,'zoomLevel',num2str(zoomLevel));
        end



        function js=createSetLimitsScript(script,latlim,lonlim)






            if~script.InitializingMap
                js=script.SetLimits;
            else
                js=[script.WebScript;script.SetLimits];
            end
            js=replaceLimits(js,latlim,lonlim);
        end



        function js_extent=createSetMapExtentScript(script)







            zoomLevel=script.ZoomLevel;
            if isempty(script.CenterLatitude)||isempty(script.CenterLongitude)
                latlim=script.LatitudeLimits;
                lonlim=script.LongitudeLimits;
                js_extent=script.createSetLimitsScript(latlim,lonlim);
            else
                centerLat=script.CenterLatitude;
                centerLon=script.CenterLongitude;
                js_extent=script.createSetCenterScript(centerLat,centerLon,zoomLevel);
            end
        end
    end
end



function wrapAroundVar=wrapDateLine(wrapAroundVar,wrapDateLineFlag)






    if~wrapDateLineFlag
        wrapAroundVar=strrep(wrapAroundVar,...
        'wrapDateLine = true','wrapDateLine = false');
    end
    wrapAroundVar={wrapAroundVar};
end



function js=modifyJavaScriptServerURLs(js,serverURLs,varString)




    output='';
    for k=1:length(serverURLs)
        serverURL=serverURLs{k};


        if k==length(serverURLs)
            endChar='';
        else
            endChar=',';
        end



        index=strfind(serverURL,'http://');
        if isempty(index)
            index=strfind(serverURL,'https://');
        end

        for n=1:length(index)
            startIndex=index(n);
            if n<length(index)
                endIndex=index(n+1)-1;
            else
                endIndex=length(serverURL);
            end

            v=serverURL(startIndex:endIndex);
            if~isscalar(index)
                if startIndex==index(1)
                    url=sprintf('%s%s%s%s\n','      ["',v,'"',endChar);
                elseif startIndex==index(end)
                    url=sprintf('%s%s%s%s\n','      "',v,'"]',endChar);
                else
                    url=sprintf('%s%s%s%s\n','      "',v,'"',endChar);
                end
            else
                url=serverURL(startIndex:endIndex);
                url=sprintf('%s%s%s%s\n','      "',url,'"',endChar);
            end
            output=sprintf('%s%s',output,url);
        end
    end


    output(end)=[];


    js=updateVariableString(js,varString,output);
end



function js=modifyJavaScriptArrayVariables(js,S)




    for k=1:length(S)
        values=S(k).Values;
        varString=S(k).VarString;
        js=modifyJavaScriptArrayVariable(js,values,varString);
    end
end



function js=modifyJavaScriptArrayVariable(js,values,varString)




    output='';
    for k=1:length(values)
        value=values{k};

        if k==length(values)
            endChar='';
        else
            endChar=',';
        end


        value=sprintf('%s%s%s%s\n','      ''',value,'''',endChar);
        output=sprintf('%s%s',output,value);
    end


    output(end)=[];


    js=updateVariableString(js,varString,output);
end



function js=updateVariableString(js,varString,newValues)








    jsString=varString(1:strfind(varString,'['));


    updatedJsString=sprintf('%s\n%s',jsString,newValues);


    js=strrep(js,varString,updatedJsString);
end



function js=modifyWebMapServiceLayerVariables(js,serverURLs,...
    layerTitles,layerNames,versions,formats,projections,singleTile)





    S(1).Values=serverURLs;
    S(2).Values=layerTitles;
    S(3).Values=layerNames;
    S(4).Values=versions;
    S(5).Values=formats;
    S(6).Values=projections;
    S(7).Values=singleTile;

    S(1).VarString='var serverURLs = [ " "';
    S(2).VarString='var layerTitles = [ " "';
    S(3).VarString='var layerNames = [ " "';
    S(4).VarString='var versions = [ " "';
    S(5).VarString='var formats = [ " "';
    S(6).VarString='var projections = [ " "';
    S(7).VarString='var singleTiles = [ " "';

    js=modifyJavaScriptArrayVariables(js,S);


    js=strrep(js,'''false''','false');
    js=strrep(js,'''true''','true');

end



function js=replaceLimits(js,latlim,lonlim)



    js=strrep(js,'xmin',num2str(lonlim(1)));
    js=strrep(js,'xmax',num2str(lonlim(2)));
    js=strrep(js,'ymin',num2str(latlim(1)));
    js=strrep(js,'ymax',num2str(latlim(2)));
end



function layer=validateLayer(layer,imageFormat)





    fixedWidth=layer.Details.Attributes.FixedWidth;
    fixedHeight=layer.Details.Attributes.FixedHeight;
    if(~isempty(fixedWidth)&&(fixedWidth>0))||...
        (~isempty(fixedHeight)&&(fixedHeight>0))
        error(message('map:webmap:fixedAttributesNotPermitted',...
        layer.LayerName,'Details.Attributes.FixedWidth','Details.Attributes.FixedHeight'));
    end


    if strcmp(imageFormat,'image/bil')
        error(message('map:webmap:unsupportedImageFormat',layer.LayerName,'image/bil'));
    end


    latlim=layer.Latlim;
    if latlim(1)>latlim(2)
        layer.Latlim=[latlim(2),latlim(1)];
    end

    if latlim(2)>90
        layer.Latlim(2)=90;
    end

    if latlim(1)<-90
        layer.Latlim(1)=-90;
    end


    lonlim=layer.Lonlim;
    if lonlim(1)>lonlim(2)
        layer.Lonlim=[lonlim(2),lonlim(1)];
    end

    if lonlim(2)>180
        warningState=warning('query','backtrace');
        warning('backtrace','off')
        warning(message('map:webmap:unsupportedLongitudeLimits',layer.LayerName));
        warning(warningState);
    end

    if lonlim(1)<-180
        layer.Lonlim(1)=-180;
    end

    if lonlim(2)>360
        layer.Lonlim(2)=360;
    end
end



function singleTile=layerRequiresSingleTileAccess(layer)




    singleTileServers={...
    'http://webapps.datafed.net',...
    'http://wms.mapsavvy.com'};



    tf=false(1,length(layer));
    singleTile=cell(1,length(layer));
    for k=1:length(layer)
        isSingleTileServer=regexp(layer(k).ServerURL,singleTileServers);
        tf(k)=any(~cellfun(@isempty,isSingleTileServer));
    end


    singleTile(tf)={'true'};
    singleTile(~tf)={'false'};
end

