
















classdef(Sealed)MapTileLocation
    properties(Dependent)





ParameterizedLocation
    end

    properties(SetAccess=private)




        IsMapTileURL logical
    end

    properties(Hidden)




        AlternateURL string=""

        TileRowPattern string="${tileRow}"
        TileColumnPattern string="${tileCol}"
        TileZoomLevelPattern string="${zoomLevel}"
    end

    properties(Hidden,Access=private)
pParameterizedLocation
    end

    properties(Hidden,Access=private,Constant)
        DefaultFileExtension='.png'
    end

    methods
        function mtile=MapTileLocation(varargin)






































            [location,fileExtension]=validateInputs(...
            pwd,mtile.DefaultFileExtension,varargin);


            mtile=assignPropertyValues(mtile,location,fileExtension);
        end

        function name=mapTileName(mtile,tileRow,tileCol,zoomLevel)








            if isempty(mtile.AlternateURL)||all(strlength(mtile.AlternateURL)==0)
                name=mtile.ParameterizedLocation;
            else


                url=[mtile.ParameterizedLocation;mtile.AlternateURL(:)];
                index=1+mod(tileRow+tileCol,length(url));
                name=url(index);
            end
            tileRow=string(tileRow);
            tileCol=string(tileCol);
            zoomLevel=string(zoomLevel);
            name=replace(name,mtile.TileRowPattern,tileRow);
            name=replace(name,mtile.TileColumnPattern,tileCol);
            name=replace(name,mtile.TileZoomLevelPattern,zoomLevel);
        end

        function mtile=set.ParameterizedLocation(mtile,location)
            location=string(location);
            mtile.IsMapTileURL=isURL(location);
            mtile.pParameterizedLocation=location;
        end

        function value=get.ParameterizedLocation(mtile)
            value=mtile.pParameterizedLocation;
        end
    end

    methods(Access=private)

        function mtile=assignPropertyValues(mtile,location,fileExtension)




            location=string(location);
            if~contains(location,"$")

                if isURL(location)
                    location=location+"/"+...
                    mtile.TileZoomLevelPattern+"/"+...
                    mtile.TileRowPattern+"/"+...
                    mtile.TileColumnPattern;
                else

                    if startsWith(location,"file://")

                        scheme="file://";
                        location=extractAfter(location,scheme);
                        location=scheme+fullfile(location,...
                        mtile.TileZoomLevelPattern,...
                        mtile.TileRowPattern,...
                        mtile.TileColumnPattern);
                    else
                        location=fullfile(location,...
                        mtile.TileZoomLevelPattern,...
                        mtile.TileRowPattern,...
                        mtile.TileColumnPattern);
                    end
                end
            else
                pattern='${x}';
                if contains(location,pattern)
                    mtile.TileColumnPattern=pattern;
                end

                pattern='${y}';
                if contains(location,pattern)
                    mtile.TileRowPattern=pattern;
                end

                pattern='${z}';
                if contains(location,pattern)
                    mtile.TileZoomLevelPattern=pattern;
                end
            end

            if~contains(location,fileExtension)


                location=location+fileExtension;
            end


            mtile.ParameterizedLocation=location;
        end
    end
end



function tf=isURL(name)


    if ischar(name)
        name=string(name(:)');
    end
    tf=~isempty(name)&&isstring(name)&&isscalar(name)...
    &&(startsWith(name,'http://')||startsWith(name,'https://'));
end




function tf=isFileSchema(name)



    if ischar(name)
        name=string(name(:)');
    end
    tf=~isempty(name)&&isstring(name)&&isscalar(name)...
    &&startsWith(name,'file://')&&contains(name,'$');
end



function[location,fileExtension]=validateInputs(...
    location,defaultFileExtension,inputs)



    if~isempty(inputs)
        if isscalar(inputs)


            location=inputs{1};
            if isURL(location)||isFileSchema(location)
                fileExtension="";
            else
                fileExtension=defaultFileExtension;
            end
        else

            location=inputs{1};
            fileExtension=inputs{2};
        end

        if ischar(location)
            location=string(location(:)');
        end

        if ischar(fileExtension)
            fileExtension=string(fileExtension(:)');
        end

        validateattributes(location,{'string'},{'scalar'})
        if~isempty(fileExtension)
            validateattributes(fileExtension,{'string'},{'scalar'})
        end

        if strlength(fileExtension)>0&&~startsWith(fileExtension,'.')
            fileExtension='.'+fileExtension;
        end
    else
        fileExtension=defaultFileExtension;
    end
end
