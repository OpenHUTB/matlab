classdef(Sealed)Summary<matlab.mixin.CustomDisplay&handle




























    properties(SetAccess=immutable)
        Success logical=false
        Date char=''
        OutputFile char=''
        Processor char=''
        Version char=''
        Toolchain char=''
        BuildConfiguration char=''
        ToolboxLicenses string
    end

    methods(Access=?codergui.internal.CodegenInfoBuilder)
        function obj=Summary(success,date,outputFile,processor,...
            version,toolchain,buildConfig,toolboxLicenses)
            if nargin==0
                return
            end
            narginchk(8,8);
            obj.Success=success;
            obj.Date=date;
            obj.OutputFile=outputFile;
            obj.Processor=processor;
            obj.Version=version;
            obj.Toolchain=toolchain;
            obj.BuildConfiguration=buildConfig;
            obj.ToolboxLicenses=toolboxLicenses;
        end
    end

    methods(Access=protected)
        function propgrp=getPropertyGroups(obj)
            if~isscalar(obj)
                propgrp=getPropertyGroups@matlab.mixin.CustomDisplay(obj);
            else
                propList=struct('Success',coder.SuccessType(obj.Success),...
                'Date',obj.Date,...
                'OutputFile',obj.OutputFile,...
                'Processor',obj.Processor,...
                'Version',obj.Version,...
                'ToolboxLicenses',obj.ToolboxLicenses);
                if~isempty(obj.Toolchain)
                    propList.Toolchain=obj.Toolchain;
                end
                if~isempty(obj.BuildConfiguration)
                    propList.BuildConfiguration=obj.BuildConfiguration;
                end
                propgrp=matlab.mixin.util.PropertyGroup(propList);
            end
        end
    end
end