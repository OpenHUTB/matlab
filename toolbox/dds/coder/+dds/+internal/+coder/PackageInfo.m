classdef PackageInfo





    properties
PackageName
Description
Version
SourceFiles
IncludeFiles
LibSourceFiles
LibIncludeFiles
IDLFiles
XMLFiles
LibFormat
IncludeDirectories
LibraryDirectories
Libraries
CppFlags
LinkerFlags
CMakeOptions
    end


    methods
        function h=set.PackageName(h,value)
            validateattributes(value,{'char','string'},{'nonempty'});
            if~isvarname(value)
                error(message('dds:util:NotValidName',value));
            end
            h.PackageName=convertStringsToChars(value);
        end
        function h=set.Description(h,value)
            validateattributes(value,{'char','string'},{'nonempty'});
            h.Description=convertStringsToChars(value);
        end
        function h=set.Version(h,value)
            validateattributes(value,{'char','string'},{'nonempty'});
            h.Version=convertStringsToChars(value);
        end
        function value=checkForFiles(~,value)
            value=value(~cellfun(@isempty,value));
            validateattributes(value,{'cell'},{'nonempty'});
            cellfun(@(x)validateattributes(x,{'char','string'},{'nonempty'}),value);
            for i=1:numel(value)
                if exist(value{i},'file')~=2
                    error(message('dds:util:FileDoesNotExist',value{i}));
                end
            end
            value=convertStringsToChars(value);
        end
        function h=set.SourceFiles(h,value)
            h.SourceFiles=checkForFiles(h,value);
        end
        function h=set.IncludeFiles(h,value)
            h.IncludeFiles=checkForFiles(h,value);
        end
        function h=set.LibSourceFiles(h,value)
            h.LibSourceFiles=checkForFiles(h,value);
        end
        function h=set.LibIncludeFiles(h,value)
            h.LibIncludeFiles=checkForFiles(h,value);
        end
        function h=set.IDLFiles(h,value)
            if~isempty(value)
                h.IDLFiles=checkForFiles(h,value);
            end
        end
        function h=set.XMLFiles(h,value)
            if~isempty(value)
                h.XMLFiles=checkForFiles(h,value);
            end
        end
        function h=set.LibFormat(h,value)
            validateattributes(value,{'char','string'},{'nonempty'});
            h.LibFormat=convertStringsToChars(value);
        end
        function h=set.IncludeDirectories(h,value)
            value=value(~cellfun(@isempty,value));
            validateattributes(value,{'cell'},{'nonempty'});
            cellfun(@(x)validateattributes(x,{'char','string'},{'nonempty'}),value);
            h.IncludeDirectories=value;
        end
        function h=set.LibraryDirectories(h,value)
            value=value(~cellfun(@isempty,value));
            validateattributes(value,{'cell'},{'nonempty'});
            cellfun(@(x)validateattributes(x,{'char','string'},{'nonempty'}),value);
            h.LibraryDirectories=value;
        end
        function h=set.Libraries(h,value)
            value=value(~cellfun(@isempty,value));
            validateattributes(value,{'cell'},{'nonempty'});
            cellfun(@(x)validateattributes(x,{'char','string'},{'nonempty'}),value);
            h.Libraries=value;
        end
        function h=set.CppFlags(h,value)
            validateattributes(value,{'char','string'},{'nonempty'});
            h.CppFlags=convertStringsToChars(value);
        end
        function h=set.LinkerFlags(h,value)
            validateattributes(value,{'char','string'},{'nonempty'});
            h.LinkerFlags=convertStringsToChars(value);
        end
        function h=set.CMakeOptions(h,value)
            value=value(~cellfun(@isempty,value));
            validateattributes(value,{'cell'},{'nonempty'});
            cellfun(@(x)validateattributes(x,{'char','string'},{'nonempty'}),value);
            h.CMakeOptions=value;
        end
    end


    methods(Hidden,Static,Access={?dds.internal.coder.BuilderCore})
        function addParamsToParser(parser)



            parser.addRequired('packageName',@(x)validateattributes(x,{'char','string','dds.internal.coder.PackageInfo'},{'nonempty'}));
            parser.addParameter('description','TODO',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
            parser.addParameter('version','0.0.0',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
            parser.addParameter('sourceFiles','',@(x)(cellfun(@(y)validateattributes(y,{'char','string'},{'nonempty'}),x)));
            parser.addParameter('includeFiles','',@(x)(cellfun(@(y)validateattributes(y,{'char','string'},{'nonempty'}),x)));
            parser.addParameter('libSourceFiles','',@(x)(cellfun(@(y)validateattributes(y,{'char','string'},{'nonempty'}),x)));
            parser.addParameter('libIncludeFiles','',@(x)(cellfun(@(y)validateattributes(y,{'char','string'},{'nonempty'}),x)));
            parser.addParameter('idlFiles','',@(x)(cellfun(@(y)validateattributes(y,{'char','string'},{'nonempty'}),x)));
            parser.addParameter('xmlFiles','',@(x)(cellfun(@(y)validateattributes(y,{'char','string'},{'nonempty'}),x)));
            parser.addParameter('libFormat','',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
            parser.addParameter('includeDirs','',@(x)(cellfun(@(y)validateattributes(y,{'char','string'},{'nonempty'}),x)));
            parser.addParameter('libDirs','',@(x)(cellfun(@(y)validateattributes(y,{'char','string'},{'nonempty'}),x)));
            parser.addParameter('libs','',@(x)(cellfun(@(y)validateattributes(y,{'char','string'},{'nonempty'}),x)));
            parser.addParameter('cppFlags','',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
            parser.addParameter('linkerFlags','',@(x)validateattributes(x,{'char','string'},{'nonempty'}));
            parser.addParameter('cmakeOptions','',@(x)(cellfun(@(y)validateattributes(y,{'char','string'},{'nonempty'}),x)));
        end
    end


    methods
        function h=PackageInfo(varargin)







            narginchk(1,nargin);
            parser=varargin{1};
            if~isa(parser,'inputParser')
                parser=inputParser;
                parser.FunctionName='PackageInfo';
                dds.internal.coder.PackageInfo.addParamsToParser(parser);
                parser.parse(varargin{:});
            end

            if isa(parser.Results.packageName,'dds.internal.coder.PackageInfo')
                h=parser.Results.packageName;
                return;
            end

            h.PackageName=parser.Results.packageName;
            if~isempty(parser.Results.description)
                h.Description=parser.Results.description;
            end
            if~isempty(parser.Results.version)
                h.Version=parser.Results.version;
            end
            if~isempty(parser.Results.sourceFiles)
                h.SourceFiles=parser.Results.sourceFiles;
            end
            if~isempty(parser.Results.includeFiles)
                h.IncludeFiles=parser.Results.includeFiles;
            end
            if~isempty(parser.Results.libSourceFiles)
                h.LibSourceFiles=parser.Results.sourceFiles;
            end
            if~isempty(parser.Results.libIncludeFiles)
                h.LibIncludeFiles=parser.Results.includeFiles;
            end
            if~isempty(parser.Results.idlFiles)
                h.IDLFiles=parser.Results.idlFiles;
            end
            if~isempty(parser.Results.xmlFiles)
                h.XMLFiles=parser.Results.xmlFiles;
            end
            if~isempty(parser.Results.libFormat)
                h.LibFormat=parser.Results.libFormat;
            end
            if~isempty(parser.Results.includeDirs)
                h.IncludeDirectories=parser.Results.includeDirs;
            end
            if~isempty(parser.Results.libDirs)
                h.LibraryDirectories=parser.Results.libDirs;
            end
            if~isempty(parser.Results.libs)
                h.Libraries=parser.Results.libs;
            end
            if~isempty(parser.Results.cppFlags)
                h.CppFlags=parser.Results.cppFlags;
            end
            if~isempty(parser.Results.linkerFlags)
                h.LinkerFlags=parser.Results.linkerFlags;
            end
            if~isempty(parser.Results.cmakeOptions)
                h.IncludeDirectories=parser.Results.includeDirs;
            end
        end

    end
end
