classdef PolygonOverlay<map.webmap.internal.KMLOverlay
    properties(Access='private',Transient)

LineFeature
    end

    methods
        function overlay=PolygonOverlay(canvas,varargin)
            overlay=overlay@map.webmap.internal.KMLOverlay(canvas,varargin{:});
            overlay.OverlayType='Polygon';
            overlay.FeatureType='Polygon';
            overlay.BaseFilename='polygon';
            if~isempty(varargin)&&isobject(varargin{1})
                overlay.KMLParseType='any';
            else
                overlay.KMLParseType='polygon';
            end
            overlay.ParameterNames={...
            'AutoFit','FeatureName','OverlayName','Description'...
            ,'FaceColor','FaceAlpha','EdgeColor','EdgeAlpha','LineWidth'};
        end
    end

    methods(Access='protected')

        function feature=validateFeature(overlay,feature)

            if isgeotable(feature)
                [feature,modifiedVarnames]=geotable2geoshape(feature);
                overlay.ModifiedVariableNames=modifiedVarnames;
            elseif istable(feature)
                error(message('map:validate:expectedGeographicTable'))
            else
                validateattributes(feature,{'geoshape','table'},...
                {'nonempty'},mfilename,overlay.FeatureVariableName);

                if~strcmpi(feature.Geometry,'polygon')
                    error(message('map:validate:expectedPolygonGeoshape','P'))
                end
            end
        end



        function index=clipFeature(overlay)
            p=overlay.Feature;
            n=length(p);

            index=false(1,n);

            clat=cell(1,n);
            clon=clat;
            calt=clat;

            lineFeature=p;
            lineFeature.Geometry='line';
            clinelat=clat;
            clinelon=clon;
            clinealt=clat;
            altitudeName=determineAltitudeName(overlay);
            latlim=overlay.LatitudeLimits;
            lonlim=overlay.LongitudeLimits;
            usingWebMercator=~usingGeographicCoordinateReferenceSystem(overlay);
            if usingWebMercator
                latlim=adjustLatitudeLimits(double(p.Latitude),latlim);
            end

            for k=1:n
                polylat=double(p(k).Latitude);
                polylon=double(p(k).Longitude);
                [lat,lon]=maptrimp(polylat,polylon,latlim,lonlim);

                if isempty(lat)||isempty(lon)

                    index(k)=true;
                else

                    if all(isnan([lat(end),lon(end)]))
                        lat(end)=[];
                        lon(end)=[];
                    end
                    [lat,lon]=closeNearlyClosedRings(lat,lon);

                    clat{k}=lat(:)';
                    clon{k}=lon(:)';
                    alt=zeros(1,length(lat));
                    alt(isnan(lat))=NaN;
                    calt{k}=alt;
                end

                if~index(k)
                    [lat,lon]=maptriml(polylat,polylon,latlim,lonlim);

                    clinelat{k}=lat(:)';
                    clinelon{k}=lon(:)';
                    alt=zeros(1,length(lat));
                    alt(isnan(lat))=NaN;
                    clinealt{k}=alt;
                end
            end

            p.(altitudeName)=calt;
            p.Latitude=clat;
            p.Longitude=clon;

            lineFeature.(altitudeName)=clinealt;
            lineFeature.Latitude=clinelat;
            lineFeature.Longitude=clinelon;


            p(index)=[];
            lineFeature(index)=[];


            overlay.Feature=p;
            overlay.LineFeature=lineFeature;
        end



        function addFeature(overlay)

            if~isscalar(overlay.Feature)
                sortFeature(overlay);
            end
            overlay.KMLDocument.UseMultipartName=false;


            document=overlay.KMLDocument;

            edgeLineProps=struct;

            emptyValue={' '};
            needsEdgeLine=hasPolygonEdgeProperties(overlay);
            if needsEdgeLine

                edgeProperties={'EdgeColor','LineWidth','EdgeAlpha'};
                lineProperties={'Color','Width','Alpha'};


                for k=1:length(lineProperties)
                    lineprop=lineProperties{k};
                    polyprop=edgeProperties{k};
                    edgeLineProps.(lineprop)=document.(polyprop);
                    document.(polyprop)=emptyValue;
                end

                if isequal(edgeLineProps.Color,emptyValue)
                    edgeLineProps.Color={'none'};
                end

            end

            document.EdgeColor={'none'};
            addFeature(document,overlay.Feature);


            if needsEdgeLine

                polyProperties={'EdgeColor','EdgeAlpha','FaceColor','FaceAlpha'};
                for k=1:length(polyProperties)
                    document.(polyProperties{k})=emptyValue;
                end

                edgeColorNoneIndex=strcmp('none',edgeLineProps.Color);
                if~all(edgeColorNoneIndex)
                    names=fieldnames(edgeLineProps);
                    for k=1:length(names)
                        document.(names{k})=edgeLineProps.(names{k});
                    end
                    if any(edgeColorNoneIndex)
                        overlay.LineFeature=removeFeatures(...
                        overlay,overlay.LineFeature,edgeColorNoneIndex);
                    end
                    addFeature(document,overlay.LineFeature);
                end
            end
        end



        function tf=hasPolygonEdgeProperties(overlay)


            defaultValue={' '};

            edgeProperties={'EdgeColor','LineWidth','EdgeAlpha'};
            tf=false;
            for k=1:length(edgeProperties)
                propname=edgeProperties{k};
                if~isequal(overlay.KMLDocument.(propname),defaultValue)
                    tf=true;
                    break
                end
            end
        end



        function sortFeature(overlay)
            A=geopolyarea(overlay);

            [~,index]=sort(A,2,'descend');
            overlay.Feature=overlay.Feature(index);
            overlay.LineFeature=overlay.LineFeature(index);

            document=overlay.KMLDocument;
            names=properties(document);
            numberOfFeatures=length(overlay.Feature);
            for k=1:length(names)
                name=names{k};
                value=document.(name);
                proplen=length(value);
                if proplen>1&&proplen==numberOfFeatures
                    overlay.KMLDocument.(name)=value(index);
                end
            end
        end



        function feature=removeFeatures(overlay,feature,index)
            names=properties(overlay.KMLDocument);
            numberOfFeatures=length(feature);
            for k=1:length(names)
                name=names{k};
                value=overlay.KMLDocument.(name);
                proplen=length(value);
                if proplen>1&&proplen==numberOfFeatures&&iscell(value)
                    value(index)=[];
                    overlay.KMLDocument.(name)=value;
                end
            end
            feature(index)=[];
        end
    end

    methods(Access='private')

        function A=geopolyarea(overlay)
            usingGCS=usingGeographicCoordinateReferenceSystem(overlay);
            A=zeros(1,length(overlay.Feature));
            for k=1:length(overlay.Feature)
                lat=overlay.Feature(k).Latitude;
                lon=overlay.Feature(k).Longitude;
                if usingGCS
                    x=lon;
                    y=lat;
                else
                    [x,y]=map.geodesy.internal.webmercfwd(lat,lon);
                end
                [first,last]=internal.map.findFirstLastNonNan(x);
                sumpart=0;
                for n=1:length(first)
                    xpart=x(first(n):last(n));
                    ypart=y(first(n):last(n));
                    a=polyarea(xpart,ypart);
                    if ispolycw(xpart,ypart)
                        sumpart=sumpart+a;
                    else
                        sumpart=sumpart-a;
                    end
                end
                A(k)=sumpart;
            end
        end
    end
end



function[x,y]=closeNearlyClosedRings(x,y)

    x=x(:);
    y=y(:);
    nanTerminated=(~isempty(x)&&isnan(x(end)));

    [first,last]=internal.map.findFirstLastNonNan(x);
    endPointsCoincide=(x(first)==x(last)&(y(first)==y(last)));
    replicateFirst=~endPointsCoincide;

    if any(replicateFirst)
        s=cumsum(replicateFirst);
        newlast=last+s;
        newfirst=[1;2+newlast(1:end-1)];
        newx=NaN+zeros(newlast(end),1);
        newy=NaN+zeros(newlast(end),1);
        for k=1:numel(first)
            if replicateFirst(k)
                newx(newfirst(k):(newlast(k)-1))=x(first(k):last(k));
                newy(newfirst(k):(newlast(k)-1))=y(first(k):last(k));
                newx(newlast(k))=x(first(k));
                newy(newlast(k))=y(first(k));
            else
                newx(newfirst(k):newlast(k))=x(first(k):last(k));
                newy(newfirst(k):newlast(k))=y(first(k):last(k));
            end
        end
        x=newx;
        y=newy;
    end


    if nanTerminated&&~isempty(x)&&~isnan(x(end))
        x(end+1,1)=NaN;
        y(end+1,1)=NaN;
    end
end



function latlim=adjustLatitudeLimits(lat,latlim)

    minlat=min(lat(:));
    if minlat<latlim(1)
        latlim(1)=mean([minlat,-90]);
    end

    maxlat=max(lat(:));
    if maxlat>latlim(2)
        latlim(2)=mean([maxlat,90]);
    end
end



function[S,modifiedVarnames]=geotable2geoshape(GT)

    shape=GT.Shape;
    if~isa(shape,'geopolyshape')
        error(message('map:validate:expectedGeoPolyTable'))
    end
    GT(hasNoCoordinateData(GT.Shape),:)=[];


    T=geotable2table(GT,["Latitude","Longitude"]);
    [TS,modifiedVarnames]=map.internal.tableToStuctAndModifiedNames(T);
    S=geoshape(T.Latitude,T.Longitude,convertContainedStringsToChars(TS));
    S.Geometry=char(shape.Geometry);
    S=convertOtherDatatypes(S,T,TS);
end



function S=convertOtherDatatypes(S,T,TS)

    fS=fieldnames(S);
    fTS=fieldnames(TS);
    fDiff=setdiff(fTS,fS);
    for k=1:length(fDiff)
        try
            name=fDiff{k};
            S.(name)=string(T.(name));
        catch
        end
    end
end
