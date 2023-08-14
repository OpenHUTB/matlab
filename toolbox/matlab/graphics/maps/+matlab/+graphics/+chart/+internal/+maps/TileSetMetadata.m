
























classdef(Sealed)TileSetMetadata
    properties




        TileSetName string="tileset"





        Version string="v1"





        Attribution string=""





        AttributionColor="black"





        Author string=""





        DateFormat string="dd-MM-uuuu"







        Date datetime






        MaxZoomLevel double=18





MapTileLocation





MapTileCacheLocation
    end

    properties(Hidden)





        MetadataSuffix string="_configuration"
    end

    properties(Dependent,Hidden)
ParameterizedLocation
    end

    properties(Access=private,Dependent)
StringDate
StringAttributionColor
ParameterizedCacheLocation
    end

    methods
        function meta=TileSetMetadata(varargin)









            meta.MapTileLocation=matlab.graphics.chart.internal.maps.MapTileLocation;
            meta.MapTileCacheLocation=matlab.graphics.chart.internal.maps.MapTileLocation.empty;
            meta.Date=datetime('today','Format',char(meta.DateFormat));
            meta=matlab.graphics.chart.internal.maps.checkAndSetNameValuePairs(...
            meta,varargin{:});
        end

        function writeMetadata(meta,folder)













            if nargin<2
                folder=pwd;
            elseif ischar(folder)
                folder=folder(:)';
            elseif isstring(folder)
                folder=char(folder);
            end
            if~exist(folder,'dir')
                mkdir(folder)
            end



            xmlnames=string(properties(meta));

            if isempty(meta.MapTileCacheLocation)

                xmlnames(contains(xmlnames,'MapTileCacheLocation'))=[];
                propnames=xmlnames;
            else


                propnames=strrep(xmlnames,'MapTileCacheLocation','ParameterizedCacheLocation');
            end



            propnames=strrep(propnames,'MapTileLocation','ParameterizedLocation');


            index=endsWith(propnames,'Date');
            propnames(index)=string('StringDate');



            propnames=strrep(propnames,'AttributionColor','StringAttributionColor');


            basename=meta.TileSetName+meta.MetadataSuffix+'.xml';
            filename=fullfile(char(folder),char(basename));
            root=string('metadata');
            writexml(filename,meta,propnames,xmlnames,root)
        end

        function meta=readMetadata(meta,folder)













            if nargin<2

                folder='';
            elseif ischar(folder)
                folder=folder(:)';
            elseif isstring(folder)
                if~isscalar(folder)
                    validateattributes(folder,{'string'},{'scalar'},'TileSetMetadata','FOLDER')
                else
                    folder=char(folder);
                end
            else
                validateattributes(folder,{'char','string'},{'row'},'TileSetMetadata','FOLDER')
            end


            basename=meta.TileSetName+meta.MetadataSuffix+'.xml';
            filename=fullfile(char(folder),char(basename));
            meta=readxml(meta,filename);


            location=meta.MapTileLocation;
            if~location.IsMapTileURL

                tilename=mapTileName(meta.MapTileLocation,0,0,0);
                if~(startsWith(tilename,'/')||startsWith(tilename,'\')||contains(tilename,':'))

                    location=meta.MapTileLocation.ParameterizedLocation;
                    if isempty(folder)

                        folder=fileparts(filename);
                    end
                    location=fullfile(char(folder),char(location));
                    meta.MapTileLocation.ParameterizedLocation=location;
                end
            end
        end

        function meta=set.MapTileLocation(meta,value)
            if ischar(value)||(isstring(value)&&isscalar(value))
                location=matlab.graphics.chart.internal.maps.MapTileLocation(value);
                meta.MapTileLocation=location;
            else
                validateattributes(value,...
                {'matlab.graphics.chart.internal.maps.MapTileLocation'},...
                {'scalar'},'TileSetMetadata','MapTileLocation');
                meta.MapTileLocation=value;
            end
        end

        function value=get.ParameterizedLocation(meta)
            value=meta.MapTileLocation.ParameterizedLocation;
        end

        function value=get.ParameterizedCacheLocation(meta)
            if isempty(meta.MapTileCacheLocation)
                value='';
            else
                value=meta.MapTileCacheLocation.ParameterizedLocation;
            end
        end

        function meta=set.MetadataSuffix(meta,value)
            validateattributes(value,{'string'},{'scalar'},...
            'TileSetMetadata','MetadataSuffix');
            meta.MetadataSuffix=value;
        end

        function meta=set.AttributionColor(meta,colorSpec)
            validateattributes(colorSpec,{'string','char','double'},...
            {'nonempty'},...
            'TileSetMetadata','AttributionColor')
            if isnumeric(colorSpec)
                validateattributes(colorSpec,{'double'},...
                {'>=',0,'<=',1,'numel',3},...
                'TileSetMetadata','AttributionColor')
                colorSpec=colorSpec(:)';
            else


                colorSpec=strtrim(colorSpec);





                index=strcmp(colorSpec,{'k','b'});
                if any(index)

                    completeNames={'black','blue'};
                    colorSpec=completeNames(index);
                else

                    colorSpecStrings={...
                    'red','green','blue','white','cyan','magenta','yellow','black'};




                    colorSpec=validatestring(colorSpec,colorSpecStrings,...
                    'TileSetMetadata','AttributionColor');
                end
                colorSpec=string(colorSpec);
            end
            meta.AttributionColor=colorSpec;
        end

        function value=get.Date(meta)
            value=meta.Date;
            value.Format=char(meta.DateFormat);
        end

        function value=get.StringDate(meta)
            d=meta.Date;
            value=string(d);
        end

        function value=get.StringAttributionColor(meta)



            value=join(string(meta.AttributionColor),',');
        end

        function meta=set.MaxZoomLevel(meta,value)
            validateattributes(value,{'numeric'},...
            {'integer','scalar','<',26,'>=',0},...
            'TileSetMetadata','MaxZoomLevel');
            meta.MaxZoomLevel=double(value);
        end

    end

    methods(Access=private)

        function meta=readxml(meta,filename)




            msg='';
            try

                [fid,msg]=fopen(filename,'r','native','utf-8');



                data=fread(fid);
                fclose(fid);


                data=string(native2unicode(data,'utf-8')');%#ok<N2UNI>


                propnames=properties(meta);
                for k=1:length(propnames)
                    propname=propnames{k};
                    value=findXMLValue(data,propname);
                    switch propname
                    case 'MapTileLocation'
                        if contains(value,{'https://','http://'})
                            location=matlab.graphics.chart.internal.maps.MapTileLocation(value);
                            meta.MapTileLocation=location;
                        else
                            meta.MapTileLocation.ParameterizedLocation=value;
                        end

                    case 'MapTileCacheLocation'
                        if~ismissing(value)
                            if~(startsWith(value,'/')||startsWith(value,'\')||contains(value,':'))


                                folder=matlab.graphics.chart.internal.maps.findMapTileCacheFolderRoot();
                                location=fullfile(folder,char(value));
                            else
                                location=value;
                            end
                            meta.MapTileCacheLocation=...
                            matlab.graphics.chart.internal.maps.MapTileLocation(location);
                        else
                            meta.MapTileCacheLocation=...
                            matlab.graphics.chart.internal.maps.MapTileLocation.empty;
                        end

                    case 'AttributionColor'


                        if contains(value,',')
                            value=str2double(split(value,','));
                        end
                        meta.AttributionColor=value;

                    case 'Date'
                        format=char(meta.DateFormat);
                        value=datetime(value,'Format',format);
                        meta.Date=value;

                    otherwise
                        if~ismissing(value)
                            meta.(propname)=value;
                        end
                    end
                end
            catch e
                if~isempty(msg)



                    e=addCause(e,MException('MATLAB:FileIO:UnableToOpenFile',msg));
                end
                throwAsCaller(e)
            end
        end
    end
end



function value=findXMLValue(data,entity)


    value=extractAfter(data,['<',entity,'>']);
    value=extractBefore(value,['</',entity,'>']);
end



function writexml(filename,S,names,xmlnames,root)







    lb=string('<');
    rb=string('>');
    slash=string('/');
    space=string('   ');

    fid=fopen(filename,'w','native','utf-8');
    header=string('<?xml version="1.0" encoding="utf-8"?>');
    fwrite(fid,header+newline,'char');


    fwrite(fid,lb+root+rb+newline,'char');

    for k=1:length(names)
        value=S.(char(names(k)));
        if isempty(value)
            value='';
        end
        name=xmlnames(k);

        data=space+lb+name+rb+value+lb+slash+name+rb+newline;
        data=unicode2native(char(data),'utf-8');
        fwrite(fid,data);
    end


    fwrite(fid,lb+slash+root+rb,'char');
    fclose(fid);
end
