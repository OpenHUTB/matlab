classdef EnumAbstractBuilder<handle




    methods(Abstract)

        addEnumeration(this,name,...
        literalNames,literalValues,...
        defaultValue,storageType,...
        addClassNameToEnumNames,description,...
        headerFile,dataScope);
    end

    methods(Access=public)
        function defineIntEnumType(this,name,...
            literalNames,literalValues,...
            varargin)



            argParser=inputParser;
            argParser.addRequired('this',@(x)isa(x,'autosar.simulink.enum.EnumAbstractBuilder'));
            argParser.addRequired('name',@(x)(ischar(x)&&~isempty(x)));
            argParser.addRequired('literalNames',@(x)(iscell(x)));
            argParser.addRequired('literalValues',@(x)(isvector(x)));
            argParser.addParameter('Description','',@()ischar(x));
            argParser.addParameter('DefaultValue','',@(x)ischar(x));
            argParser.addParameter('DataScope','Auto',...
            @(x)any(validatestring(x,{'Auto','Exported','Imported'})));
            argParser.addParameter('HeaderFile','',@(x)ischar(x));
            argParser.addParameter('StorageType','',@(x)ischar(x));
            argParser.addParameter('AddClassNameToEnumNames',false,@(x)islogical(x));
            argParser.parse(this,name,literalNames,literalValues,varargin{:});

            this.addEnumeration(name,literalNames,literalValues,...
            argParser.Results.DefaultValue,...
            argParser.Results.StorageType,...
            argParser.Results.AddClassNameToEnumNames,...
            argParser.Results.Description,...
            argParser.Results.HeaderFile,...
            argParser.Results.DataScope);

        end
    end

end
