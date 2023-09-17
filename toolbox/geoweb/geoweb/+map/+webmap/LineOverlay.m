classdef LineOverlay<map.webmap.internal.KMLOverlay
    methods
        function overlay=LineOverlay(canvas,varargin)
            overlay=overlay@map.webmap.internal.KMLOverlay(...
            canvas,varargin{:});

            overlay.OverlayType='Line';
            overlay.FeatureType='Line';
            overlay.BaseFilename='line';
            if~isempty(varargin)&&isobject(varargin{1})
                overlay.KMLParseType='any';
            else
                overlay.KMLParseType='line';
            end
            overlay.ParameterNames=[overlay.ParameterNames,{'LineWidth','Width','Alpha'}];
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
                validateattributes(feature,{'geoshape','geopoint','table'},...
                {'nonempty'},mfilename,overlay.FeatureVariableName);
                if isa(feature,'geopoint')
                    feature=geoshape(feature.Latitude,feature.Longitude);
                end
            end

            if~strcmpi('line',feature.Geometry)

                feature.Geometry='line';
            end
        end



        function index=clipFeature(overlay)
            p=overlay.Feature;
            n=length(p);
            index=false(1,n);
            clat=cell(1,n);
            clon=clat;
            calt=clat;

            latlim=overlay.LatitudeLimits;
            lonlim=overlay.LongitudeLimits;

            for k=1:n


                [lat,lon]=maptriml(...
                double(p(k).Latitude),double(p(k).Longitude),latlim,lonlim);


                if~isempty(lat)&&~isempty(lon)&&all(isnan([lat(end),lon(end)]))
                    lat(end)=[];
                    lon(end)=[];
                end

                clat{k}=lat(:)';
                clon{k}=lon(:)';
                alt=zeros(1,length(lat));
                alt(isnan(lat))=NaN;
                calt{k}=alt;
                if isempty(lat)||isempty(lon)
                    index(k)=true;
                end
            end
            altitudeName=determineAltitudeName(overlay);
            p.(altitudeName)=calt;
            p.Latitude=clat;
            p.Longitude=clon;

            p(index)=[];

            overlay.Feature=p;
        end



        function addFeature(overlay)
            overlay.KMLDocument.UseMultipartName=false;
            addFeature(overlay.KMLDocument,overlay.Feature);
        end
    end
end



function[S,modifiedVarnames]=geotable2geoshape(GT)


    shape=GT.Shape;
    if~isequal(shape.CoordinateSystemType,"geographic")
        error(message('map:validate:expectedGeographicTable'))
    end

    if~(any(class(shape)==["geopointshape","geolineshape","geopolyshape"]))
        error(message('map:validate:expectedHomogeneousTable'))
    end
    GT(hasNoCoordinateData(GT.Shape),:)=[];
    shape=GT.Shape;

    T=geotable2table(GT,["Latitude","Longitude"]);


    if isa(shape,'geopointshape')&&~any(ismultipoint(shape),"all")

        lat=T.Latitude;
        lon=T.Longitude;
        S=geoshape(lat,lon);
        modifiedVarnames=struct.empty;
    else
        [TS,modifiedVarnames]=map.internal.tableToStuctAndModifiedNames(T);
        S=geoshape(T.Latitude,T.Longitude,convertContainedStringsToChars(TS));
        S=convertOtherDatatypes(S,GT,TS);
    end
    S.Geometry=char(shape.Geometry);
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
