classdef KMLOverlay<handle







    properties(Access='public',Hidden,Transient)




Canvas






        AutoFit=true





        OverlayNumber=1





        KMLFileNumber=0
    end

    properties(GetAccess='public',SetAccess='protected',Hidden,Transient)





Feature
    end

    properties(Access='public',Dependent,Hidden)




OverlayName




FeatureName
    end

    properties(Access='protected')





        ModifiedVariableNames=struct.empty
    end

    properties(Access='protected',Dependent)





Color





Filename





InstallFilename






LatitudeLimits
    end

    properties(Access='protected',Constant)





        LongitudeLimits=[-180,180]
    end

    properties(Access='protected',Transient)





        BaseFilename='overlay'




Script




KMLDocument





        KMLParseType='any'






        ParameterNames={'AutoFit','FeatureName','OverlayName',...
        'Description','Color'};





        OverlayType=''





OverlayScript





        FeatureType='KML'





        FeatureVariableName='P'





NumberOfFeatures




        DefaultColor=[0,0,0]




        UsingConnectorBrowserInterface=false


pOverlayName
pFeatureName
pFilename
    end

    properties(Access='protected',Constant)

        DefaultPropertyValue=' '
    end

    properties(Access='private',Transient)





KMLNameValuePairs
    end

    methods
        function overlay=KMLOverlay(canvas,varargin)









            overlay.Canvas=canvas;
            overlay.Script=canvas.Script;


            overlay.KMLDocument=map.internal.KMLDocument;


            [options,inputs]=parseOverlayOptions(varargin);


            setOverlayProperties(overlay,options);




            overlay.KMLNameValuePairs=inputs;


            overlay.UsingConnectorBrowserInterface=...
            canvas.UsingConnectorBrowserInterface;
        end

        function delete(overlay)



            if~isempty(overlay)&&~isempty(overlay.Script)...
                &&exist(overlay.InstallFilename,'file')
                try
                    warnState=warning;
                    warnObj=onCleanup(@()warning(warnState));
                    warning('off','MATLAB:DELETE:Permission');
                    warning('off','MATLAB:DELETE:FileNotFound')
                    delete(overlay.InstallFilename)
                catch
                end
            end
        end



        function set.AutoFit(overlay,value)
            validateattributes(value,{'numeric','logical'},...
            {'nonempty','finite'},mfilename,'AutoFit');
            value=logical(value);
            overlay.AutoFit=value;
        end

        function set.OverlayName(overlay,name)
            if(iscellstr(name)||isstring(name))&&isscalar(name)
                name=name{1};
            end
            name=convertStringsToChars(name);
            validateattributes(name,{'char','string'},...
            {'nonempty','scalartext'},mfilename,'OverlayName');
            overlay.pOverlayName=name;
        end

        function v=get.OverlayName(overlay)
            if isempty(overlay.pOverlayName)
                v=[overlay.OverlayType,' Overlay ',sprintf('%d',overlay.OverlayNumber)];
            else
                v=overlay.pOverlayName;
            end
        end

        function set.FeatureName(overlay,name)
            if iscell(name)&&isscalar(name)
                name=name{1};
            end
            name=convertStringsToChars(name);
            validateattributes(name,{'char','string','cell'},...
            {'nonempty','vector'},mfilename,'FeatureName');
            if iscolumn(name)
                name=name';
            end
            overlay.pFeatureName=name;
        end

        function v=get.FeatureName(overlay)
            if isempty(overlay.pFeatureName)
                n=overlay.NumberOfFeatures;
                if isempty(n)||n==0
                    v='';
                else
                    v=cell([1,n]);
                    name=overlay.OverlayName;
                    featureType=overlay.FeatureType;
                    for k=1:n
                        v{k}=[name,' : ',featureType,' ',sprintf('%d',k)];
                    end
                end
            else
                if ischar(overlay.pFeatureName)
                    v={overlay.pFeatureName};
                else
                    v=overlay.pFeatureName;
                end
            end
        end

        function set.OverlayNumber(overlay,value)
            validateattributes(value,{'numeric'},{'nonempty','integer','scalar'},...
            mfilename,'OverlayNumber');
            overlay.OverlayNumber=value;
        end

        function set.Script(overlay,value)
            validateattributes(value,{'map.webmap.internal.WebMapScript'},...
            {'nonempty','scalar'},mfilename,'Script');
            overlay.Script=value;
        end

        function set.Canvas(overlay,value)
            validateattributes(value,{'map.webmap.Canvas'},...
            {'nonempty','scalar'},mfilename,'Canvas');
            overlay.Canvas=value;
        end

        function set.BaseFilename(overlay,value)
            value=convertStringsToChars(value);
            validateattributes(value,{'char','string'},...
            {'nonempty','scalartext'},mfilename,'BaseFilename');
            overlay.BaseFilename=value;
        end

        function v=get.Filename(overlay)
            prefix=[overlay.BaseFilename,sprintf('%d',overlay.KMLFileNumber)];
            if isempty(overlay.pFilename)||~contains(overlay.pFilename,prefix)
                if overlay.UsingConnectorBrowserInterface
                    [~,suffix]=fileparts(tempname);
                    v=[prefix,'_',suffix,'.xml'];
                else
                    v=[prefix,'.xml'];
                end
                overlay.pFilename=v;
            else
                v=overlay.pFilename;
            end
        end

        function v=get.InstallFilename(overlay)
            if~isempty(overlay.Script)
                v=fullfile(overlay.Script.InstallFolder,overlay.Filename);
            else
                v=overlay.Filename;
            end
        end

        function set.Color(overlay,value)




            n=size(value,1);
            c=cell(1,n);
            for k=1:n
                c{k}=rgbToKML(value(k,:));
            end
            overlay.KMLDocument.Color=c;
        end

        function v=get.Color(overlay)
            c=overlay.KMLDocument.Color;
            if~isEmptyKMLProperty(overlay,'Color')
                for k=1:length(c)
                    c{k}=kmlToRGB(c{k});
                end
            end
            v=c;
        end

        function latlim=get.LatitudeLimits(overlay)





            if usingGeographicCoordinateReferenceSystem(overlay)
                latlim=[-90,90];
            else
                latlim=[-85,85];
            end
        end
    end

    methods(Access='public',Hidden)

        function addOverlay(overlay)




            script=overlay.Script;
            if~isempty(script)




                [overlay.Feature,options]=parseKML(overlay);


                index=clipFeature(overlay);


                names=fieldnames(options);
                for k=1:length(names)
                    name=names{k};
                    value=options.(name);
                    if iscell(value)&&~isscalar(value)
                        value(index)=[];
                        options.(name)=value;
                    end
                end


                if~isempty(overlay.FeatureName)
                    value=overlay.FeatureName;
                    value(index)=[];
                    overlay.FeatureName=value;
                end


                overlay.NumberOfFeatures=length(overlay.Feature);


                setKMLProperties(overlay,options);

                if~isempty(overlay.Feature)


                    install(overlay);




                    overlay.OverlayScript=addKmlOverlay(script,...
                    overlay.Filename,overlay.OverlayName);
                end
            end
        end



        function removeOverlay(overlay,layerNumber)





            removeKmlOverlay(overlay.Script,overlay.OverlayScript,layerNumber);
        end
    end

    methods(Access='protected')

        function tf=isEmptyKMLProperty(overlay,name)





            v=overlay.KMLDocument.(name);
            if all(strcmp(v,overlay.DefaultPropertyValue))||isempty(v)
                tf=true;
            else
                tf=false;
            end
        end



        function setKMLProperties(overlay,options)











            map.internal.setProperties(overlay.KMLDocument,options);



            if isEmptyKMLProperty(overlay,'Description')
                overlay.KMLDocument.Description={'<html></html>'};
            end


            if isEmptyKMLProperty(overlay,'Color')
                overlay.Color=overlay.DefaultColor;
            end


            validateNumberOfCellElements(overlay.FeatureName,...
            'FeatureName',overlay.NumberOfFeatures);


            overlay.KMLDocument.Name=overlay.FeatureName;
        end



        function feature=validateFeature(overlay,feature)


            feature=validateattributes(feature,...
            {'geoshape','geopoint'},{'nonempty'},...
            mfilename,overlay.FeatureVariableName);
        end



        function index=clipFeature(overlay)






            n=length(overlay.Feature);
            index=false(1,n);
        end



        function altitudeName=determineAltitudeName(overlay)



            altitudeNames={'Altitude','Elevation','Height'};
            names=fieldnames(overlay.Feature);
            index=find(ismember(altitudeNames,names),1);
            if isempty(index)



                altitudeName='Latitude';
            else
                altitudeName=altitudeNames{index};
            end
        end



        function addFeature(overlay)


            addFeature(overlay.KMLDocument,overlay.Feature);
        end



        function tf=usingGeographicCoordinateReferenceSystem(overlay)



            crs=overlay.Script.CoordinateReferenceSystem;
            tf=any(strcmp(crs,{'CRS:84','EPSG:4326'}));
        end
    end

    methods(Access='private')

        function install(overlay)



            addFeature(overlay);



            if~overlay.Script.PublishingActiveWebMap
                write(overlay.KMLDocument,overlay.InstallFilename);
            end
        end



        function setOverlayProperties(overlay,inputs)







            names=fieldnames(inputs);
            for k=1:length(names)
                name=names{k};
                value=inputs.(name);
                if~isempty(value)
                    overlay.(name)=value;
                end
            end
        end



        function checkParameterNames(overlay,inputs)







            numDataArgs=internal.map.getNumberOfDataArgs(inputs{:});
            inputs(1:numDataArgs)=[];

            if~isempty(inputs)
                names=overlay.ParameterNames;
                parameterNames=inputs(1:2:end);
                for k=1:length(parameterNames)
                    validatestring(parameterNames{k},names);
                end
            end
        end



        function[feature,options]=parseKML(overlay)



            inputs=overlay.KMLNameValuePairs;
            if isempty(inputs)
                error(message('MATLAB:narginchk:notEnoughInputs'))
            elseif isobject(inputs{1})
                inputs{1}=overlay.validateFeature(inputs{1});
            else
                validateDataArgs(inputs);
            end



            checkParameterNames(overlay,inputs);


            w=warning();
            obj=onCleanup(@()warning(w));
            warning('off','map:validate:ignoringAttribute');





            filename=strrep(overlay.Filename,'.xml','.kml');
            inputs=[{filename},inputs];


            type=overlay.KMLParseType;


            id='backtrace';
            warnState=warning('query',id);
            cleanObj=onCleanup(@()warning(warnState));
            warning('off',id);

            if isobject(inputs{2})&&isempty(inputs{2})





                options=struct;
                feature=inputs{2};
            else
                if~isempty(overlay.ModifiedVariableNames)
                    type="table:"+type;
                    inputs=[inputs,{overlay.ModifiedVariableNames}];
                end

                [~,feature,options]=...
                map.internal.kmlparse(mfilename,type,inputs{:});
            end
        end
    end
end



function kmlColor=rgbToKML(rgb)




    kmlColor=sprintf('%02x',round(255*[1,rgb(1,[3,2,1])]));
end



function rgb=kmlToRGB(kml)




    chex=kml(3:end);
    rgb(3)=hex2dec(chex(1:2));
    rgb(2)=hex2dec(chex(3:4));
    rgb(1)=hex2dec(chex(5:6));
    rgb=rgb./255;
end



function[options,inputs]=parseOverlayOptions(inputs)


    parameterNames={'AutoFit','OverlayName','FeatureName'};
    defaultValues={[],'',''};
    options=cell2struct(defaultValues,parameterNames,2);


    numDataArgs=internal.map.getNumberOfDataArgs(inputs{:});

    if numDataArgs<length(inputs)

        pvpairs=inputs(numDataArgs+1:end);

        if~isempty(inputs)
            internal.map.checkNameValuePairs(pvpairs{:})
            for k=1:length(parameterNames)
                name=parameterNames{k};
                value=defaultValues{k};
                [value,pvpairs]=map.internal.findNameValuePair(...
                name,value,pvpairs{:});
                options.(name)=value;
            end
        end
        inputs=[inputs(1:numDataArgs),pvpairs];
    end
end



function validateDataArgs(inputs)



    numDataArgs=internal.map.getNumberOfDataArgs(inputs{:});



    if numDataArgs==0
        dataArgs=inputs;
    else
        dataArgs=inputs(1:numDataArgs);
    end

    if isscalar(dataArgs)
        error(message('MATLAB:narginchk:notEnoughInputs'))
    elseif length(dataArgs)>2
        error(message('MATLAB:narginchk:tooManyInputs'))
    end


    validateattributes(dataArgs{1},{'numeric'},{'nonempty'},...
    mfilename,'latitude coordinates');
    validateattributes(dataArgs{2},{'numeric'},...
    {'nonempty'},mfilename,'longitude coordinates');
end



function validateNumberOfCellElements(c,parameter,maxNumElements)


    validNumberOfCellElements=length(c)==[0,1,maxNumElements];
    if~any(validNumberOfCellElements)
        if maxNumElements==1


            validateattributes(c,{class(c)},{'scalar'},mfilename,parameter);
        else
            error(message('map:validate:mismatchNumberOfElements',...
            parameter,maxNumElements));
        end
    end
end
