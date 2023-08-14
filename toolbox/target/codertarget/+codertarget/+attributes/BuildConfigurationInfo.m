classdef(Sealed=true)BuildConfigurationInfo<codertarget.Info&matlab.mixin.Copyable






    properties
        DefinitionFileName='';

        AssemblyFlags='';
        CompileFlags='';
        CPPCompileFlags='';
        CPPLinkFlags='';
        Defines={};
        IncludePaths={};
        LinkFlags='';
        LinkObjects={};
        Libraries={};
        IncludeFiles={};
        Name='';
        PathsToRemove={};
        SourceFiles={};
        SourceFilesToSkip={};
        SupportedOperatingSystems={'all'};
        SupportedToolchains={'all'};
    end

    methods(Access='public')
        function h=BuildConfigurationInfo(arg)
            if(nargin==1)
                if ischar(arg)
                    filePathName=arg;
                    h.DefinitionFileName=filePathName;
                    h.deserialize();
                elseif isa(arg,'codertarget.attributes.BuildConfigurationInfo')
                    h=copy(arg);
                else
                    assert(false,['codertarget.attributesBuildConfiguration cannot be constructed with arguments of type',class(arg)]);
                end
            end
        end
    end
    methods(Access='public',Hidden)
        function ret=getShortDefinitionFileName(h)
            [~,name,ext]=fileparts(h.DefinitionFileName);
            ret=[name,ext];
        end
        function bcObj=getEquivalentBuildConfiguration(h)
            bcObj=matlabshared.targetsdk.BuildConfiguration(h.Name);
            bcObj.AssemblerFlags=h.AssemblyFlags;
            bcObj.CompilerFlags=h.CompileFlags;
            bcObj.LinkerFlags=h.LinkFlags;
            bcObj.CPPCompilerFlags=h.CPPCompileFlags;
            bcObj.CPPLinkerFlags=h.CPPLinkFlags;
            bcObj.Defines={};
            if~iscell(h.Defines)
                h.Defines={h.Defines};
            end
            for k=1:numel(h.Defines)
                bcObj.Defines{k}=h.Defines{k};
            end
            bcObj.IncludePaths=h.IncludePaths;
            bcObj.LinkObjects=h.LinkObjects;
            bcObj.SourceFiles=h.SourceFiles;
            bcObj.SourceFilesToRemove=h.SourceFilesToSkip;
            bcObj.IncludePathsToRemove=h.PathsToRemove;
            bcObj.SupportedOperatingSystems=h.SupportedOperatingSystems;
            bcObj.SupportedToolchains=h.SupportedToolchains;
        end
    end
    methods
        function h=set(h,inValue)

            assert(numel(inValue)==numel(h),'set method of codertarget.attributes.BuildConfigurationInfo cannot take arrays as an input');
            for ii=1:numel(h)
                if isa(inValue,'matlabshared.targetsdk.BuildConfiguration')
                    h.Name=inValue.Name;
                    h.AssemblyFlags=inValue.AssemblerFlags;
                    h.CompileFlags=inValue.CompilerFlags;
                    h.LinkFlags=inValue.LinkerFlags;
                    h.CPPCompileFlags=inValue.CPPCompilerFlags;
                    h.CPPLinkFlags=inValue.CPPLinkerFlags;
                    h.Defines=inValue.Defines;
                    h.IncludePaths=inValue.IncludePaths;
                    h.LinkObjects=inValue.LinkObjects;
                    h.SourceFiles=inValue.SourceFiles;
                    h.SourceFilesToSkip=inValue.SourceFilesToRemove;
                    h.PathsToRemove=inValue.IncludePathsToRemove;
                    h.SupportedOperatingSystems=inValue.SupportedOperatingSystems;
                    h.SupportedToolchains=inValue.SupportedToolchains;
                elseif isa(inValue,'codertarget.attributes.BuildConfigurationInfo')
                    h(ii)=copy(inValue(ii));
                else
                    fieldNames=fields(inValue(ii));
                    for i=1:numel(fieldNames)
                        fName=fieldNames{i};
                        if ismember(fName,properties('codertarget.attributes.BuildConfigurationInfo'))
                            h(ii).(fName)=inValue(ii).(fName);
                        end
                    end
                end
            end
        end
        function outValue=get(h)

            prop_names=properties('codertarget.attributes.BuildConfigurationInfo');
            prop_names=prop_names(~ismember(prop_names,'DefinitionFileName'));

            entries=[prop_names(:)';repmat({cell(numel(h),1)},1,numel(prop_names))];
            outValue=struct(entries{:});
            for ii=1:numel(h)
                hElem=h(ii);
                for i=1:numel(prop_names)
                    outValue(ii).(prop_names{i})=hElem.(prop_names{i});
                end
            end
        end
        function serialize(hIn)
            for ii=1:numel(hIn)
                h=hIn(ii);
                docObj=h.createDocument('productinfo');
                docObj.item(0).setAttribute('version','3.0');
                h.setElement(docObj,'name',h.Name);
                h.setElement(docObj,'buildconfigurationinfo',h.get);
                fileName=codertarget.utils.replacePathSep(h.DefinitionFileName);
                h.write(fileName,docObj);
            end
        end
        function deserialize(hIn)
            for ii=1:numel(hIn)
                h=hIn(ii);
                docObj=h.read(h.DefinitionFileName);
                prodInfoList=docObj.getElementsByTagName('productinfo');
                rootItem=prodInfoList.item(0);
                h.set(h.getElement(rootItem,'buildconfigurationinfo','struct'));
            end
        end
    end
    methods
        function set.SourceFiles(obj,val)
            if~iscell(val)&&~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidCellProperty','SourceFiles');
            elseif ischar(val)
                val=cellstr(val);
            end
            obj.SourceFiles=val;
        end
        function set.SourceFilesToSkip(obj,val)
            if~iscell(val)&&~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidCellProperty','SourceFilesToSkip');
            elseif ischar(val)
                val=cellstr(val);
            end
            obj.SourceFilesToSkip=val;
        end
        function set.Defines(obj,val)
            if~iscell(val)&&~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidCellProperty','Defines');
            elseif ischar(val)
                val=cellstr(val);
            end
            obj.Defines=val;
        end
        function set.LinkObjects(obj,val)
            if~iscell(val)
                val={val};
            end
            obj.LinkObjects=val;
        end
        function set.IncludePaths(obj,val)
            if~iscell(val)&&~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidCellProperty','IncludePaths');
            elseif ischar(val)
                val=cellstr(val);
            end
            obj.IncludePaths=val;
        end
        function set.Libraries(obj,val)
            if~iscell(val)&&~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidCellProperty','Libraries');
            elseif ischar(val)
                val=cellstr(val);
            end
            obj.Libraries=val;
        end
        function set.PathsToRemove(obj,val)
            if~iscell(val)&&~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidCellProperty','PathsToRemove');
            elseif ischar(val)
                val=cellstr(val);
            end
            obj.PathsToRemove=val;
        end
        function set.SupportedOperatingSystems(obj,val)
            if~iscell(val)&&~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidCellProperty','SupportedOperatingSystems');
            elseif ischar(val)
                val=cellstr(val);
            end
            obj.SupportedOperatingSystems=val;
        end
        function set.SupportedToolchains(obj,val)
            if~iscell(val)&&~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidCellProperty','SupportedToolchains');
            elseif ischar(val)
                val=cellstr(val);
            end
            obj.SupportedToolchains=val;
        end
        function set.IncludeFiles(obj,val)
            if~iscell(val)&&~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidCellProperty','IncludeFiles');
            elseif ischar(val)
                val=cellstr(val);
            end
            obj.IncludeFiles=val;
        end
    end
end



