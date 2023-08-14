classdef MarkerOverlay<map.webmap.internal.KMLOverlay







    properties(Access='private',Transient)



IconFilename
    end

    properties(Access='private',Dependent)




Alpha
    end


    methods
        function overlay=MarkerOverlay(canvas,varargin)









            overlay=overlay@map.webmap.internal.KMLOverlay(...
            canvas,varargin{:});


            overlay.OverlayType='Marker';
            overlay.FeatureType='Point';
            overlay.BaseFilename='marker';
            if~isempty(varargin)&&isobject(varargin{1})
                overlay.KMLParseType='any';
            else
                overlay.KMLParseType='point';
            end



            overlay.ParameterNames=[...
            overlay.ParameterNames,{'Icon','IconScale','Alpha'}];


            red=[1,0,0];
            overlay.DefaultColor=red;
        end

        function alpha=get.Alpha(overlay)




            alpha=cell2mat(overlay.KMLDocument.Alpha);
            if ischar(alpha)

                alpha=1;
            end
        end



        function delete(overlay)





            delete@map.webmap.internal.KMLOverlay(overlay);
            icons=overlay.IconFilename;
            for k=1:length(icons)
                if exist(icons{k},'file')
                    delete(icons{k});
                end
            end
        end
    end

    methods(Access='protected')

        function setKMLProperties(overlay,options)








            setKMLProperties@map.webmap.internal.KMLOverlay(overlay,options);




            overlay.KMLDocument.UseMultipartName=false;


            if~isempty(overlay.Script)
                if isEmptyKMLProperty(overlay,'Icon')


                    updateIcon(overlay)
                else



                    copyIcon(overlay);
                end
            end
        end



        function feature=validateFeature(overlay,feature)





            if isgeotable(feature)
                latlim=overlay.LatitudeLimits;
                [feature,modifiedVarnames]=geotable2DynamicVector(feature,latlim);
                overlay.ModifiedVariableNames=modifiedVarnames;
            elseif istable(feature)
                error(message('map:validate:expectedGeographicTable'))
            else
                validateattributes(feature,{'geopoint','table'},{'nonempty'},...
                mfilename,overlay.FeatureVariableName);
            end
        end



        function index=clipFeature(overlay)












            p=overlay.Feature;
            if isa(p,'geoshape')


                index=false(1,length(p));
            else


                p.Latitude=double(p.Latitude);
                p.Longitude=double(p.Longitude);




                lat=p.Latitude;
                lon=p.Longitude;
                latlim=overlay.LatitudeLimits;
                index1=lat>latlim(2);
                index2=lat<latlim(1);


                index3=isnan(lat);
                index4=isnan(lon);


                index=index1|index2|index3|index4;
                p(index)=[];


                overlay.Feature=p;
            end
        end
    end

    methods(Access='private')

        function updateIcon(overlay)





            installDir=overlay.Script.InstallFolder;
            iconColors=overlay.Color;
            alphaValues=overlay.Alpha;





            n=overlay.NumberOfFeatures;
            useTempname=overlay.UsingConnectorBrowserInterface;
            if isscalar(iconColors)&&isscalar(alphaValues)


                iconColor=iconColors{1};
                alpha=alphaValues(1);
                [filename,fullFilename]=...
                createPushpinIcon(iconColor,alpha,installDir,useTempname);
                overlay.IconFilename{1}=fullFilename;
                overlay.KMLDocument.Icon=repmat({filename},1,n);
            else

                oneAlphaValue=isscalar(alphaValues);
                oneColorValue=isscalar(iconColors);
                for k=1:n
                    if oneColorValue
                        iconColor=iconColors{1};
                    else
                        iconColor=iconColors{k};
                    end
                    if oneAlphaValue
                        alpha=alphaValues(1);
                    else
                        alpha=alphaValues(k);
                    end

                    [filename,fullFilename]=...
                    createPushpinIcon(iconColor,alpha,installDir,useTempname);
                    overlay.IconFilename{k}=fullFilename;
                    overlay.KMLDocument.Icon{k}=filename;
                end
            end
        end

        function copyIcon(overlay)











            folder=overlay.Script.InstallFolder;
            icon=overlay.KMLDocument.Icon;
            alphaValues=overlay.Alpha;











            ext='.png';
            base='icon';
            useTempname=overlay.UsingConnectorBrowserInterface;
            for k=1:length(icon)
                iconfilename=icon{k};
                if isscalar(alphaValues)
                    alpha=alphaValues(1);
                else
                    alpha=alphaValues(k);
                end
                [RGB,mask]=imiconread(iconfilename,alpha);
                [filename,fullFilename]=uniquefile(folder,base,ext,useTempname);
                imwrite(RGB,fullFilename,'Alpha',mask);
                overlay.KMLDocument.Icon{k}=filename;
                overlay.IconFilename{k}=fullFilename;
            end
        end
    end
end



function[filename,fullFilename]=createPushpinIcon(color,alpha,installDir,useTempname)







    pushpin=fullfile(toolboxdir('geoweb'),...
    'geoweb','scripts','OpenLayers','pushpin.png');


    [X,~,mask]=imread(pushpin);


    mask=alpha*mask;


    r=X(:,:,1);
    g=X(:,:,2);
    b=X(:,:,3);


    color=map.internal.colorSpecToRGB(color);
    r(r>0)=color(1)*255;
    g(g>0)=color(2)*255;
    b(b>0)=color(3)*255;

    X(:,:,1)=r;
    X(:,:,2)=g;
    X(:,:,3)=b;


    base='pushpin';
    ext='.png';
    [filename,fullFilename]=uniquefile(installDir,base,ext,useTempname);


    imwrite(X,fullFilename,'Alpha',mask);
end



function[filename,fullFilename]=uniquefile(folder,base,ext,useTempname)



    basename=[base,'1'];
    filename=[basename,ext];
    d=dir(folder);
    names={d.name};


    k=1;
    while any(contains(names,basename))
        k=k+1;
        basename=[base,num2str(k)];
        filename=[basename,ext];
    end

    if useTempname
        [~,suffix]=fileparts(tempname);
        filename=[basename,'_',suffix,ext];
    end

    fullFilename=fullfile(folder,filename);
end



function[RGB,mask]=imiconread(filename,alpha)




    try
        [X,cmap,mask]=imread(filename);
    catch e
        if strcmp('MATLAB:imagesci:imread:fileFormat',e.identifier)
            error(message('map:webmap:unexpectedFileFormat',filename));
        elseif strcmp('MATLAB:imagesci:writepng:wrongImageDimensions',e.identifier)
            [X,cmap]=imread(filename);
            mask=[];
        else
            error(message('map:webmap:iconReadError',filename,e.message));
        end
    end


    if~isempty(cmap)
        X=ind2rgb(X,cmap);
    end


    if islogical(X)
        X=uint8(X)*255;
    end


    if ismatrix(X)
        RGB=X(:,:,[1,1,1]);
    elseif ndims(X)==3&&size(X,3)==3
        RGB=X;
    else
        error(message('map:webmap:unexpectedImageType',filename));
    end




    if isempty(mask)
        [m,n,~]=size(RGB);
        mask=ones(m,n,'like',RGB);
        if isinteger(RGB)
            mask=mask*intmax(class(RGB));
        end
    end


    mask=alpha*mask;
end



function[S,modifiedVarnames]=geotable2DynamicVector(GT,latlim)



    shape=GT.Shape;
    if~isa(shape,'geopointshape')
        error(message('map:validate:expectedGeoPointTable'))
    end


    if any(ismultipoint(shape),"all")
        GT.Shape=clipShape(shape,latlim);
    end


    hasNoCoordinates=(GT.Shape.NumPoints==0);
    GT(hasNoCoordinates(:),:)=[];
    shape=GT.Shape;


    T=geotable2table(GT,["Latitude","Longitude"]);
    [TS,modifiedVarnames]=map.internal.tableToStuctAndModifiedNames(T);


    TS=convertContainedStringsToChars(TS);

    geometry=lower(shape.Geometry);
    if~any(ismultipoint(shape),"all")||all(shape.NumPoints==0)
        S=geopoint(TS);
    else
        geometry="multipoint";
        S=geoshape(TS);
        S.Geometry="point";
    end
    S.Geometry=char(geometry);
    S=convertOtherDatatypes(S,GT,TS);
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

function shape=clipShape(shape,latlim)
    for k=1:length(shape)
        lat=shape(k).Latitude;
        lon=shape(k).Longitude;


        index1=lat>latlim(2);
        index2=lat<latlim(1);


        index=~(index1|index2);
        if~all(index)
            shape(k,1)=geopointshape({lat(index)},{lon(index)});
        end
    end
end
