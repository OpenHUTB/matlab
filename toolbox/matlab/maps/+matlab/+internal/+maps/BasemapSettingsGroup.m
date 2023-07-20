classdef(Sealed)BasemapSettingsGroup<handle





























    properties(Dependent)





BasemapName






DisplayName












URL














AlternateURL










Attribution





MaxZoomLevel





IsDeployable






BasemapNames
    end


    properties(Hidden)






        TopLevelGroupName string="map"





        BasemapGroupName string="basemap"





        FunctionName char=''
    end

    properties(Access='protected')




        ValidationFcns(1,1)struct
    end

    properties(Access='private')
        pBasemapName(1,1)string=""
        pDisplayName(1,1)string=""
        pURL(1,1)string=""
        pAlternateURL string=""
        pAttribution string=string(message('MATLAB:maps:DefaultAttribution').getString())
        pMaxZoomLevel double=18
        pIsDeployable logical=false
    end


    properties(Access='private',Constant)
        DefaultTilePattern="/${z}/${x}/${y}.png";
        DefaultAttribution=string(message('MATLAB:maps:DefaultAttribution').getString())
    end


    methods
        function obj=BasemapSettingsGroup()
            if isappdata(groot,'BasemapSettingsGroup')
                obj.TopLevelGroupName=getappdata(groot,'BasemapSettingsGroup');
            end
            obj.ValidationFcns=struct(...
            'BasemapName',@matlab.internal.maps.BasemapSettingsGroup.validateBasemapName,...
            'DisplayName',@matlab.internal.maps.BasemapSettingsGroup.validateDisplayName,...
            'URL',@matlab.internal.maps.BasemapSettingsGroup.validateURL,...
            'AlternateURL',@matlab.internal.maps.BasemapSettingsGroup.validateAlternateURL,...
            'Attribution',@matlab.internal.maps.BasemapSettingsGroup.validateAttribution,...
            'MaxZoomLevel',@matlab.internal.maps.BasemapSettingsGroup.validateMaxZoomLevel,...
            'IsDeployable',@matlab.internal.maps.BasemapSettingsGroup.validateIsDeployable);
        end


        function addGroup(obj)








            basemapGroup=findGroup(obj);



            basemapName=obj.BasemapName;
            if~hasGroup(basemapGroup,basemapName)
                customGroup=addGroup(basemapGroup,basemapName);
            else
                customGroup=basemapGroup.(basemapName);
            end





            names=properties(obj);
            names(contains(names,"BasemapName"))=[];
            validationFcns=obj.ValidationFcns;
            for k=1:length(names)
                name=names{k};
                value=convertStringsToChars(obj.(name));
                if hasSetting(customGroup,name)
                    removeSetting(customGroup,name)
                end

                try





                    addSetting(customGroup,name,'PersonalValue',value,...
                    'ValidationFcn',validationFcns.(name));
                catch e
                    if strcmp(name,'AlternateURL')
                        value='';
                        addSetting(customGroup,name,'PersonalValue',value,...
                        'ValidationFcn',validationFcns.(name));
                    else
                        throwAsCaller(e)
                    end
                end
            end
        end


        function removeGroup(obj,basemapName)








            basemapNames=obj.BasemapNames;
            if isempty(basemapNames)
                error(message('MATLAB:maps:NoBasemapsExist'))
            else
                fcnname=obj.FunctionName;
                validateattributes(basemapName,{'string','char'},...
                {'scalartext','nonempty'},fcnname)
                basemapName=validatestring(basemapName,basemapNames,fcnname);
                basemapGroup=getBasemapSettingsGroup(obj);
                removeGroup(basemapGroup,basemapName);
            end
        end


        function tf=hasGroup(obj,basemapName)






            if hasBasemapSettingsGroup(obj)
                basemapGroup=getBasemapSettingsGroup(obj);
                tf=hasGroup(basemapGroup,basemapName);
            else
                tf=false;
            end
        end


        function validateGroup(obj)










            url=obj.URL;
            w=warning('off','backtrace');
            cleanObj=onCleanup(@()warning(w));
            zoomLevelStr="0";
            if~matlab.internal.maps.isTileSetFile(url)

                url=replace(url,["${z}","${x}","${y}"],zoomLevelStr);
                filename=tempname;
                reader=matlab.internal.asynchttpsave.AsyncHTTPContentFileWriter;
                reader.URL=url;
                reader.Filename=filename;
                try
                    writeContentToFilesAndBlock(reader);
                    imread(filename);
                catch e
                    warning(message('MATLAB:maps:UnableToReadMapTiles',obj.URL,e.message))
                end
                if exist(filename,"file")
                    delete(filename)
                end
            else

                try
                    blob=matlab.internal.maps.sqlBlobReader(url);
                    matlab.internal.imdecode(blob);
                catch
                    warning(message('MATLAB:maps:UnableToReadTileSetFile',zoomLevelStr))
                end
            end
        end


        function newobj=readGroup(obj)








            basemapNames=obj.BasemapNames;
            if isempty(basemapNames)
                newobj=matlab.internal.maps.BasemapSettingsGroup.empty;
            else
                basemapGroup=getBasemapSettingsGroup(obj);
                numBasemaps=length(basemapNames);
                newobj(numBasemaps)=matlab.internal.maps.BasemapSettingsGroup;
                for k=1:numBasemaps
                    basemapName=basemapNames{k};
                    newobj(k).BasemapName=basemapName;
                    group=basemapGroup.(basemapName);
                    assignPropertiesFromSettingsGroup(newobj(k),group);
                end
            end
        end



        function set.BasemapName(obj,name)
            obj.validateBasemapName(name,obj.FunctionName)
            obj.pBasemapName=name;
        end

        function basemapName=get.BasemapName(obj)
            basemapName=obj.pBasemapName;
        end


        function set.DisplayName(obj,name)
            obj.validateDisplayName(name,obj.FunctionName)
            obj.pDisplayName=name;
        end

        function displayName=get.DisplayName(obj)
            displayName=obj.pDisplayName;
        end


        function set.URL(obj,url)
            obj.validateURL(url,obj.FunctionName)

            if matlab.internal.maps.isTileSetFile(url)







                fid=fopen(url,"r");
                if fid~=-1
                    url=fopen(fid);
                    fclose(fid);
                end
            else


                url=updateURL(url,obj.DefaultTilePattern);
            end
            obj.pURL=url;
        end

        function url=get.URL(obj)
            url=obj.pURL;
        end


        function set.AlternateURL(obj,url)
            obj.validateAlternateURL(url,obj.FunctionName)
            url=convertCharsToStrings(url);
            for k=1:length(url)
                if strlength(url(k))>0
                    url(k)=updateURL(url(k),obj.DefaultTilePattern);
                end
            end
            obj.pAlternateURL=url;
        end

        function url=get.AlternateURL(obj)
            url=obj.pAlternateURL;
        end


        function set.Attribution(obj,attribution)
            obj.validateAttribution(attribution,obj.FunctionName)




            attribution=convertCharsToStrings(attribution);
            attribution=updateAttribution(attribution,...
            obj.URL,obj.FunctionName);
            obj.pAttribution=attribution;
        end

        function attribution=get.Attribution(obj)
            attribution=obj.pAttribution;

            if strcmp(attribution,obj.DefaultAttribution)

                if~matlab.internal.maps.isTileSetFile(obj.URL)
                    domainName=getDomainNameFromURL(obj.URL);
                    attribution=replace(attribution,'%s',domainName);
                else



                    attribution="";
                end
            end
        end


        function set.MaxZoomLevel(obj,maxZoomLevel)
            obj.validateMaxZoomLevel(maxZoomLevel,obj.FunctionName)
            obj.pMaxZoomLevel=maxZoomLevel;
        end

        function maxZoomLevel=get.MaxZoomLevel(obj)
            maxZoomLevel=obj.pMaxZoomLevel;
        end


        function set.IsDeployable(obj,tf)
            obj.validateIsDeployable(tf,obj.FunctionName)
            obj.pIsDeployable=tf;
        end

        function tf=get.IsDeployable(obj)
            tf=obj.pIsDeployable;
        end

        function names=get.BasemapNames(obj)
            if hasBasemapSettingsGroup(obj)
                basemapGroup=getBasemapSettingsGroup(obj);
                names=string(properties(basemapGroup));
            else
                names=string.empty;
            end
        end
    end


    methods(Access='protected')

        function tf=hasBasemapSettingsGroup(obj)






            s=settings;
            topLevelGroupName=obj.TopLevelGroupName;
            basemapGroupName=obj.BasemapGroupName;

            if hasGroup(s,topLevelGroupName)
                topLevelGroup=s.(topLevelGroupName);
                tf=hasGroup(topLevelGroup,basemapGroupName);
            else
                tf=false;
            end
        end


        function basemapGroup=getBasemapSettingsGroup(obj)






            s=settings;
            topLevelGroupName=obj.TopLevelGroupName;
            basemapGroupName=obj.BasemapGroupName;
            topLevelGroup=s.(topLevelGroupName);
            basemapGroup=topLevelGroup.(basemapGroupName);
        end


        function baseamapGroup=findGroup(obj)






            topLevelGroupName=obj.TopLevelGroupName;
            basemapGroupName=obj.BasemapGroupName;

            s=settings;
            if hasGroup(s,topLevelGroupName)
                topLevelGroup=s.(topLevelGroupName);
            else
                topLevelGroup=addGroup(s,topLevelGroupName,'Hidden',true);
            end

            if hasGroup(topLevelGroup,basemapGroupName)
                baseamapGroup=topLevelGroup.(basemapGroupName);
            else
                baseamapGroup=addGroup(topLevelGroup,basemapGroupName,'Hidden',true);
            end
        end


        function assignPropertiesFromSettingsGroup(obj,basemapNameGroup)











            basemapNameProps=properties(basemapNameGroup);
            for k=1:length(basemapNameProps)
                basemapNameProp=basemapNameProps{k};
                if isprop(obj,basemapNameProp)
                    value=basemapNameGroup.(basemapNameProp).ActiveValue;
                    obj.(basemapNameProp)=value;
                end
            end
        end
    end


    methods(Static)
        function validateBasemapName(varargin)










            [value,funcname]=parseInputs(varargin);
            validateattributes(value,{'string','char'},...
            {'scalartext','nonempty'},funcname)
            assert(isvarname(value),message('MATLAB:maps:InvalidBasemapName'))
        end


        function validateDisplayName(varargin)










            [value,funcname]=parseInputs(varargin);
            validateattributes(value,{'string','char'},{'scalartext'},funcname)
        end


        function validateURL(varargin)










            [value,funcname]=parseInputs(varargin);
            if~isa(value,'matlab.net.URI')
                validateattributes(value,{'string','char'},...
                {'scalartext','nonempty'},funcname)
            else
                validateattributes(value,{'string','char','matlab.net.URI'},...
                {'scalar','nonempty'},funcname)
            end
        end


        function validateAlternateURL(varargin)










            [url,funcname]=parseInputs(varargin);
            url=convertCharsToStrings(url);
            for k=1:length(url)
                validateattributes(url(k),{'string','char'},...
                {'scalartext'},funcname)
            end
        end


        function validateAttribution(varargin)










            [value,funcname]=parseInputs(varargin);
            value=convertCharsToStrings(value);
            validateattributes(value,{'string','char'},{},funcname)
        end


        function validateMaxZoomLevel(varargin)










            [value,funcname]=parseInputs(varargin);
            validateattributes(value,{'numeric'},...
            {'scalar','integer','nonnegative','<=',25},funcname)
        end


        function validateIsDeployable(varargin)










            [value,funcname]=parseInputs(varargin);
            if~(isequal(value,0)||isequal(value,1))
                validateattributes(value,{'logical'},{'scalar'},funcname)
            end
        end


        function validateSetting(settingsGroup,name,value)






            basemapGroup=matlab.internal.maps.BasemapSettingsGroup;
            try




                if strcmp(name,'Attribution')
                    url=settingsGroup.URL.ActiveValue;
                    attribution=value;
                    basemapGroup.URL=url;
                    basemapGroup.Attribution=attribution;
                else
                    basemapGroup.(name)=value;
                end
            catch e
                throwAsCaller(e)
            end
        end
    end
end


function url=updateURL(url,defaultTilePattern)









    url=strip(string(url));


    if~(startsWith(url,"http://")||startsWith(url,"https://"))
        url="https://"+url;
    end



    indices=["{x}","{y}","{z}"];
    for k=1:length(indices)
        withoutSign=indices(k);
        withSign="$"+withoutSign;
        if contains(url,withoutSign)&&~contains(url,withSign)
            url=replace(url,withoutSign,withSign);
        end
    end

    if~contains(url,indices)
        url=url+defaultTilePattern;
    end
    url=char(url);
end


function attribution=updateAttribution(attribution,url,fcnname)







    isAllSpace=all(strlength(strip(attribution))==0);


    isEmptyAttribution=isempty(char(attribution))||isAllSpace;
    attribution=string(attribution);

    if~isscalar(attribution)


        assert(~isAllSpace,message('MATLAB:maps:ExpectedNonwhitespace'))
        attribution=sprintf('%s\n',attribution);
        attribution(end)='';

    elseif isEmptyAttribution

        domainName=getDomainNameFromURL(url);
        if~strcmp(domainName,'localhost')
            allIP=all(isstrprop(replace(domainName,".",""),'digit'));
            if~allIP

                attribution=char(attribution);
                try
                    validateattributes(attribution,{'string','char'},...
                    {'nonempty'},fcnname,'Attribution');
                    assert(~isAllSpace,message('MATLAB:maps:ExpectedNonwhitespace'))
                catch e
                    throwAsCaller(e)
                end
            end
        end
    end
end


function domainName=getDomainNameFromURL(url)














    uri=matlab.net.URI(url);
    host=uri.Host;
    if isempty(host)

        domainName='';
    elseif all(isstrprop(replace(host,'.',''),'digit'))

        domainName=host;
    else
        domainName=host;
        parts=split(domainName,".");
        if length(parts)>2
            if strlength(parts(end-1))<=3



                parts=parts(end-2:end);
            else


                parts=parts(end-1:end);
            end
            domainName=join(parts,".");
        end
    end
    domainName=char(domainName);
end


function[value,funcname]=parseInputs(inputs)


    switch length(inputs)
    case 1
        value=inputs{1};
        funcname='';
    case 2
        value=inputs{1};
        funcname=inputs{2};
    case 3
        value=inputs{3};
        funcname='';
    end
end
