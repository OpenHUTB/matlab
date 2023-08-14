






































classdef DynamicAttributionReader<handle

    properties(SetAccess=private)





        TileSetMetadata matlab.graphics.chart.internal.maps.TileSetMetadata
    end

    properties(Dependent)



BasemapName




BasemapURL





        StaticAttributionURL string





        DynamicAttributionURL string
    end

    properties









        MaxNumDaysInCache double=30





        CacheFolder string=string.empty
    end

    properties(Access=private,Dependent)




ContributorArray






ContributorArrayCacheFilename






StaticAttributionCacheFilename
    end

    properties(Access=private)





        StaticAttribution string=string.empty




        Options=weboptions('Timeout',15,'ContentType','json')


        pStaticAttributionURL string=string.empty


        pDynamicAttributionURL string=string.empty


        pContributorArray struct=struct.empty
    end

    methods
        function reader=DynamicAttributionReader(meta,topLevelFolder)













            reader.TileSetMetadata=meta;
            basemapURL=reader.BasemapURL;
            reader.StaticAttributionURL=extractStaticAttributionURL(basemapURL);
            reader.DynamicAttributionURL=extractDynamicAttributionURL(basemapURL);


            cacheLocation=meta.MapTileCacheLocation;
            if nargin==2&&~isempty(cacheLocation)&&startsWith(cacheLocation.ParameterizedLocation,'file://')
                folder=replace(cacheLocation.ParameterizedLocation,'file://','');
                folder=replace(folder,"maptiles","attributions");
                if contains(folder,"$")
                    folder=extractBefore(folder,"$");
                end
                reader.CacheFolder=fullfile(topLevelFolder,folder);
            end
        end


        function delete(reader)





            deleteExpiredAttributionCache(reader)
        end


        function attributionString=readStaticAttribution(reader)













            if isempty(reader.StaticAttribution)
                filename=reader.StaticAttributionCacheFilename;
                fileExists=exist(filename,'file');
                if~fileExists
                    try
                        url=reader.StaticAttributionURL;
                        json=webread(url,'f','pjson',reader.Options);
                        attributionString=string(json.copyrightText);
                        saveAttributeDataToCache(filename,attributionString)
                    catch
                        attributionString=reader.TileSetMetadata.Attribution;
                    end
                else
                    data=load(filename);
                    attributionString=data.attributionData;
                end
                reader.StaticAttribution=attributionString;
            else
                attributionString=reader.StaticAttribution;
            end
        end


        function attributionString=readDynamicAttribution(...
            reader,latlim,lonlim,zoomLevel)











            try
                url=reader.DynamicAttributionURL;
                validInputs=~isempty(url)&&isscalar(zoomLevel)...
                &&length(latlim)==2&&length(lonlim)==2;
                if validInputs
                    attributionString=findContributors(...
                    reader.ContributorArray,latlim,lonlim,zoomLevel);
                else
                    attributionString=readStaticAttribution(reader);
                end
            catch
                attributionString=readStaticAttribution(reader);
            end
        end


        function basemap=get.BasemapName(reader)
            basemap=reader.TileSetMetadata.TileSetName;
        end


        function url=get.BasemapURL(reader)
            meta=reader.TileSetMetadata;
            if meta.MapTileLocation.IsMapTileURL
                url=meta.MapTileLocation.ParameterizedLocation;
            else
                url=string.empty;
            end
        end


        function set.StaticAttributionURL(reader,url)
            reader.pStaticAttributionURL=url;
            reader.ContributorArray=struct.empty;
        end


        function url=get.StaticAttributionURL(reader)
            url=reader.pStaticAttributionURL;
        end


        function set.DynamicAttributionURL(reader,url)
            reader.pDynamicAttributionURL=url;
            reader.ContributorArray=struct.empty;
        end


        function url=get.DynamicAttributionURL(reader)
            url=reader.pDynamicAttributionURL;
        end


        function set.ContributorArray(reader,contributorArray)
            reader.pContributorArray=contributorArray;
        end


        function contributorArray=get.ContributorArray(reader)
            if isempty(reader.pContributorArray)
                filename=reader.ContributorArrayCacheFilename;
                fileExists=exist(filename,'file');
                if~fileExists
                    url=reader.DynamicAttributionURL;
                    contributorArray=readAttributionContributorArray(url,reader.Options);
                    saveAttributeDataToCache(filename,contributorArray)
                else
                    data=load(filename);
                    contributorArray=data.attributionData;
                end
                reader.ContributorArray=contributorArray;
            else
                contributorArray=reader.pContributorArray;
            end
        end


        function filename=get.ContributorArrayCacheFilename(reader)
            filename=fullfile(reader.CacheFolder,"contributors.mat");
            if isempty(filename)
                filename="";
            end
        end

        function filename=get.StaticAttributionCacheFilename(reader)
            filename=fullfile(reader.CacheFolder,"static_attribution.mat");
            if isempty(filename)
                filename="";
            end
        end
    end


    methods(Static=true)
        function attributionString=readStaticAttributionFromURL(basemapURL)















            try
                url=extractStaticAttributionURL(basemapURL);
                options=weboptions('Timeout',15,'ContentType','json');
                json=webread(url,'f','pjson',options);
                attributionString=string(json.copyrightText);
            catch
                attributionString="";
            end
        end
    end


    methods(Access=protected)
        function deleteExpiredAttributionCache(reader)






            folder=char(reader.CacheFolder);
            if~isempty(folder)
                files=dir(fullfile(folder,'*.mat'));
                if~isempty(files)
                    timeDiff=now-datenum([files.datenum]);
                    filesToDeleteIndex=timeDiff>=reader.MaxNumDaysInCache;
                    filesToDelete=files(filesToDeleteIndex);

                    for k=1:length(filesToDelete)
                        filename=fullfile(fullfile(folder,filesToDelete(k).name));
                        try
                            delete(filename)
                        catch
                        end
                    end
                end
            end
        end
    end
end

function url=extractStaticAttributionURL(basemapURL)














    url=extractBefore(basemapURL,"/tile");
    if ismissing(url)


        url=string.empty;
    end
end

function url=extractDynamicAttributionURL(basemapURL)

















    url=extractBefore(basemapURL,"/MapServer");
    url=replace(url,"ArcGIS/rest/services","attribution");
    url=replace(url,"server.arcgisonline.com","static.arcgis.com");
    if ismissing(url)


        url=string.empty;
    end
end


function contributorArray=readAttributionContributorArray(url,options)







    attributions=webread(url,options);
    n=length(attributions.contributors);

    contributorArray=struct(...
    'Attribution','',...
    'Score',[],...
    'LatitudeLimits',[],...
    'LongitudeLimits',[],...
    'MinZoom',[],...
    'MaxZoom',[]);
    contributorArray(n)=contributorArray(1);
    ac=0;
    for c=1:n
        contributor=attributions.contributors(c);

        for k=1:length(contributor.coverageAreas)
            coverageArea=contributor.coverageAreas(k);
            bbox=coverageArea.bbox;
            latlim=[bbox(1),bbox(3)];
            lonlim=[bbox(2),bbox(4)];
            ac=ac+1;
            contributorArray(ac).Attribution=string(contributor.attribution);
            contributorArray(ac).Score=coverageArea.score;
            contributorArray(ac).LatitudeLimits=latlim;
            contributorArray(ac).LongitudeLimits=lonlim;
            contributorArray(ac).MinZoom=coverageArea.zoomMin;
            contributorArray(ac).MaxZoom=coverageArea.zoomMax;
        end
    end
end


function contributorArray=findContributors(c,latlim,lonlim,zoom)






    minZoom=[c.MinZoom];
    maxZoom=[c.MaxZoom];




    zoom=min(floor(zoom),max(maxZoom));

    index=(zoom>=minZoom)&(zoom<=maxZoom);
    attrib=c(index);
    tf=false(1,length(attrib));
    for k=1:length(tf)
        tf(k)=~isempty(intersectgeoquad(latlim,lonlim,attrib(k).LatitudeLimits,attrib(k).LongitudeLimits));
    end
    attrib=attrib(tf);
    [~,index]=sort([attrib.Score],'descend');
    attrib=attrib(index);








    attributions=[attrib.Attribution];
    if~isempty(attributions)
        contributorArray=attributions(1);
        for k=2:length(attributions)
            attribution=attributions(k);
            if~contains(contributorArray,attribution)
                contributorArray=contributorArray+", "+attribution;
            end
        end
    else
        contributorArray="";
    end
end


function saveAttributeDataToCache(filename,attributionData)%#ok<INUSD>





    if strlength(filename)>0
        try
            folder=fileparts(filename);
            if~exist(folder,'dir')
                mkdir(folder)
            end
            save(filename,"attributionData")
        catch
        end
    end
end


function[latlim,lonlim]=intersectgeoquad(latlim1,lonlim1,latlim2,lonlim2)









    latlim=intersectlim(latlim1,latlim2);
    if isempty(latlim)
        lonlim=[];
    else
        lonlim=intersectlon(lonlim1,lonlim2);
        if isempty(lonlim)
            latlim=[];
        elseif size(lonlim,1)==2

            latlim=latlim([1,1],:);
        end
    end
end


function lim=intersectlim(lim1,lim2)
    if((lim2(2)<lim1(1))||(lim1(2)<lim2(1)))
        lim=[];
    else
        lim(2)=min(lim1(2),lim2(2));
        lim(1)=max(lim1(1),lim2(1));
    end
end


function lonlim=intersectlon(lonlim1,lonlim2)
    full1=abs(lonlim1(2)-lonlim1(1))==360;
    full2=abs(lonlim2(2)-lonlim2(1))==360;
    if full1&&full2

        lonlim=[-180,180];
    elseif full1


        lonlim=wrapTo180(lonlim2(:)');
    elseif full2


        lonlim=wrapTo180(lonlim1(:)');
    else

        lonlim1=wrapTo180(lonlim1);
        lonlim2=wrapTo180(lonlim2);
        w1=lonlim1(1);
        w2=lonlim2(1);
        e1=lonlim1(2);
        e2=lonlim2(2);
        wrap1=(e1<w1);
        wrap2=(e2<w2);
        if wrap1&&wrap2

            if(e1>w2)||(e2>w1)

                lonlim=[min(w1,w2),max(e1,e2);
                max(w1,w2),min(e1,e2)];
            else

                lonlim=[max(w1,w2),min(e1,e2)];
            end
        elseif wrap1

            lonlim=combinelim(...
            intersectlim(lonlim2,[-180,e1]),...
            intersectlim(lonlim2,[w1,180]));
        elseif wrap2

            lonlim=combinelim(...
            intersectlim(lonlim1,[-180,e2]),...
            intersectlim(lonlim1,[w2,180]));
        else

            lonlim=intersectlim(lonlim1,lonlim2);
        end
    end
end


function lim=combinelim(lim1,lim2)
    if~isempty(lim1)&&~isempty(lim2)
        lim=[lim1;lim2];
    elseif~isempty(lim1)
        lim=lim1;
    elseif~isempty(lim2)
        lim=lim2;
    else
        lim=[];
    end
end


function lon=wrapTo180(lon)
    q=(lon<-180)|(180<lon);
    lon(q)=wrapTo360(lon(q)+180)-180;
end


function lon=wrapTo360(lon)
    positiveInput=(lon>0);
    lon=mod(lon,360);
    lon((lon==0)&positiveInput)=360;
end
