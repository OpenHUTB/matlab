classdef XMakefileConfiguration<linkfoundation.util.File




    events(Hidden=true)
ContextChange
    end


    properties(Constant=true,Hidden=true)


        XMakefileToolChainConfigurationSignature='XMAKEFILE_TOOL_CHAIN_CONFIGURATION';

        XMakefileConfigurationExtension='.m';


        SupportedFormatVersions={'1.0','2.0'};
        FormatVersion='2.0';


        ConfigurationFormat=[...
'%% NOTE: DO NOT REMOVE THIS LINE %s\n'...
        ,'function toolChainConfiguration = %s()\n'...
        ,'%%%s Defines a tool chain configuration\n'...
        ,'%%\n'...
        ,'%% Copyright %s The MathWorks, Inc.\n'...
        ,'%%\n'...
        ,'%% General\n'...
        ,'toolChainConfiguration.Configuration = ''%s'';\n'...
        ,'toolChainConfiguration.Version = ''%s'';\n'...
        ,'toolChainConfiguration.Description = ''%s'';\n'...
        ,'toolChainConfiguration.Operational = %s;\n'...
        ,'toolChainConfiguration.InstallPath = ''%s'';\n'...
        ,'toolChainConfiguration.CustomValidator = ''%s'';\n'...
        ,'toolChainConfiguration.Decorator = ''%s'';\n'...
        ,'%% Make\n'...
        ,'toolChainConfiguration.MakePath = ''%s'';\n'...
        ,'toolChainConfiguration.MakeFlags = ''%s'';\n'...
        ,'toolChainConfiguration.MakeInclude = ''%s'';\n'...
        ,'%% Compiler\n'...
        ,'toolChainConfiguration.CompilerPath = ''%s'';\n'...
        ,'toolChainConfiguration.CompilerFlags = ''%s'';\n'...
        ,'toolChainConfiguration.SourceExtensions = ''%s'';\n'...
        ,'toolChainConfiguration.HeaderExtensions = ''%s'';\n'...
        ,'toolChainConfiguration.ObjectExtension = ''%s'';\n'...
        ,'%% Linker\n'...
        ,'toolChainConfiguration.LinkerPath = ''%s'';\n'...
        ,'toolChainConfiguration.LinkerFlags = ''%s'';\n'...
        ,'toolChainConfiguration.LibraryExtensions = ''%s'';\n'...
        ,'toolChainConfiguration.TargetExtension = ''%s'';\n'...
        ,'toolChainConfiguration.TargetNamePrefix = ''%s'';\n'...
        ,'toolChainConfiguration.TargetNamePostfix = ''%s'';\n'...
        ,'%% Archiver\n'...
        ,'toolChainConfiguration.ArchiverPath = ''%s'';\n'...
        ,'toolChainConfiguration.ArchiverFlags = ''%s'';\n'...
        ,'toolChainConfiguration.ArchiveExtension = ''%s'';\n'...
        ,'toolChainConfiguration.ArchiveNamePrefix = ''%s'';\n'...
        ,'toolChainConfiguration.ArchiveNamePostfix = ''%s'';\n'...
        ,'%% Pre-build\n'...
        ,'toolChainConfiguration.PrebuildEnable = %s;\n'...
        ,'toolChainConfiguration.PrebuildToolPath = ''%s'';\n'...
        ,'toolChainConfiguration.PrebuildFlags = ''%s'';\n'...
        ,'%% Post-build\n'...
        ,'toolChainConfiguration.PostbuildEnable = %s;\n'...
        ,'toolChainConfiguration.PostbuildToolPath = ''%s'';\n'...
        ,'toolChainConfiguration.PostbuildFlags = ''%s'';\n'...
        ,'%% Execute\n'...
        ,'toolChainConfiguration.ExecuteDefault = %s;\n'...
        ,'toolChainConfiguration.ExecuteToolPath = ''%s'';\n'...
        ,'toolChainConfiguration.ExecuteFlags = ''%s'';\n'...
        ,'%% Directories\n'...
        ,'toolChainConfiguration.DerivedPath = ''%s'';\n'...
        ,'toolChainConfiguration.OutputPath = ''%s'';\n'...
        ,'%% Custom\n'...
        ,'toolChainConfiguration.Custom1 = ''%s'';\n'...
        ,'toolChainConfiguration.Custom2 = ''%s'';\n'...
        ,'toolChainConfiguration.Custom3 = ''%s'';\n'...
        ,'toolChainConfiguration.Custom4 = ''%s'';\n'...
        ,'toolChainConfiguration.Custom5 = ''%s'';\n'...
        ,'end\n'];



        ConfigurationFields=struct(...
        'Value',...
        {{...
        'Configuration',...
        'Description',...
        'InstallPath',...
        'CustomValidator',...
        'OperationalReason',...
        'Version',...
        'Decorator',...
        'MakePath','MakeFlags','MakeInclude',...
        'CompilerPath','CompilerFlags',...
        'SourceExtensions','HeaderExtensions','ObjectExtension',...
        'LinkerPath','LinkerFlags','LibraryExtensions',...
        'TargetExtension','TargetNamePrefix','TargetNamePostfix',...
        'ArchiverPath','ArchiverFlags',...
        'ArchiveExtension','ArchiveNamePrefix','ArchiveNamePostfix',...
        'PrebuildToolPath','PrebuildFlags',...
        'PostbuildToolPath','PostbuildFlags',...
        'ExecuteToolPath','ExecuteFlags',...
        'OutputPath','DerivedPath',...
        'Custom1','Custom2','Custom3','Custom4','Custom5'...
        }},...
        'Logical',...
        {{...
        'Operational',...
        'PrebuildEnable',...
        'PostbuildEnable',...
'ExecuteDefault'...
        }},...
        'Private',...
        {{...
        'PrivateData',...
        }},...
        'Override',...
        {{...
        'SourceFilesOverride',...
        'HeaderFilesOverride',...
        'LibraryFilesOverride',...
        'SkippedFilesOverride',...
        'CodeGenCompilerFlagsOverride',...
        'CodeGenLinkerFlagsOverride',...
        }},...
        'LineOverride',...
        {{...
        'PrebuildLineOverride',...
        'CompilerLineOverride',...
        'LinkerLineOverride',...
        'PostbuildLineOverride',...
'ExecuteLineOverride'...
        }});
    end

    properties(GetAccess='public',SetAccess='private')
        IsSystemDefined=false;
    end

    properties(Dependent=true,Hidden=true,GetAccess='public',SetAccess='private')
MemoryContents
FileContents
    end

    properties(Dependent=true,GetAccess='public',SetAccess='private')
Version
    end


    properties(Dependent=true,Access='public')

Configuration
Description
InstallPath
CustomValidator
Operational
OperationalReason
Decorator
PrivateData
Tag

MakePath
MakeFlags
MakeInclude

CompilerPath
CompilerFlags
SourceExtensions
HeaderExtensions
ObjectExtension

LinkerPath
LinkerFlags
LibraryExtensions
TargetExtension
TargetNamePrefix
TargetNamePostfix

ArchiverPath
ArchiverFlags
ArchiveExtension
ArchiveNamePrefix
ArchiveNamePostfix

PrebuildEnable
PrebuildToolPath
PrebuildFlags

PostbuildEnable
PostbuildToolPath
PostbuildFlags

ExecuteDefault
ExecuteToolPath
ExecuteFlags

Custom1
Custom2
Custom3
Custom4
Custom5

OutputPath
DerivedPath
    end


    properties(Dependent=true,Hidden=true,Access='public')
SourceFilesOverride
HeaderFilesOverride
LibraryFilesOverride
SkippedFilesOverride
CodeGenCompilerFlagsOverride
CodeGenLinkerFlagsOverride
PrebuildLineOverride
CompilerLineOverride
LinkerLineOverride
PostbuildLineOverride
ExecuteLineOverride
    end

    properties(Access='private')
        TCCfgData;
    end

    methods(Access='private')




        function normalizeSettings(h)
            h.initializeSettings();
        end





        function initializeSettings(h)
            cellfun(@initializeValueSetting,h.ConfigurationFields.Value);
            cellfun(@initializeLogicalSetting,h.ConfigurationFields.Logical);
            cellfun(@initializeObjectSetting,h.ConfigurationFields.Private);
            cellfun(@initializeObjectSetting,h.ConfigurationFields.Override);
            cellfun(@initializeObjectSetting,h.ConfigurationFields.LineOverride);


            function initializeValueSetting(dataField)
                if(~isfield(h.TCCfgData,dataField))
                    h.TCCfgData.(dataField)='';
                end
            end
            function initializeLogicalSetting(dataField)
                if(~isfield(h.TCCfgData,dataField))
                    h.TCCfgData.(dataField)=false;
                end
            end
            function initializeObjectSetting(dataField)
                if(~isfield(h.TCCfgData,dataField))
                    h.TCCfgData.(dataField)=[];
                end
            end
        end





        function result=loadFromDifferentVersion(h,data)
            result=false;
            try
                switch(data.Version)
                case '1.0'



                    if strcmpi(data.Decorator,'linkfoundation.xmakefile.decorator.ccsDecorator')
                        if~isempty(regexp(data.CompilerPath,'cl2000','once'))
                            data.Decorator='linkfoundation.xmakefile.decorator.c2000CCSDecorator';
                        elseif~isempty(regexp(data.CompilerPath,'cl55','once'))
                            data.Decorator='linkfoundation.xmakefile.decorator.c5500CCSDecorator';
                        elseif~isempty(regexp(data.CompilerPath,'cl6x','once'))&&...
                            isempty(regexp(data.PrebuildToolPath,'tconf','once'))
                            data.Decorator='linkfoundation.xmakefile.decorator.c6000CCSDecorator';
                        end
                    end

                    result=h.loadFromValidVersion(data);
                otherwise
                    disp('Attempting to load a different version of configuration file!');
                    disp(data);
                end
            catch ex
                linkfoundation.xmakefile.raiseException('XMakefileConfiguration','loadFromDifferentVersion','',ex,h.Version);
            end
        end





        function result=loadSettings(h,data)
            result=false;
            try
                if(~strcmpi(data.Version,linkfoundation.xmakefile.XMakefileConfiguration.FormatVersion))
                    result=h.loadFromDifferentVersion(data);
                else
                    result=h.loadFromValidVersion(data);
                end
            catch ex
                linkfoundation.xmakefile.raiseException('XMakefileConfiguration','loadSettings','',ex);
            end
        end





        function result=loadFromValidVersion(h,data)
            try


                if(isfield(data,'Decorator')&&~isempty(data.Decorator))
                    decorator=str2func(data.Decorator);
                    data=decorator(data);
                end
                h.TCCfgData=data;

                if(isfield(data,'OnContextChangeCallback')&&isa(data.('OnContextChangeCallback'),'function_handle'))
                    h.addlistener('ContextChange',data.('OnContextChangeCallback'));
                end
                h.normalizeSettings();
                result=true;
            catch ex
                linkfoundation.xmakefile.raiseException('XMakefileConfiguration','loadSettings','',ex);
            end
        end




        function test=containsConfigurationSignature(h)
            test=false;
            try
                fid=fopen(h.FullPathName);
                if(0>fid)
                    return;
                end
                header=fgetl(fid);
                if(regexp(header,linkfoundation.xmakefile.XMakefileConfiguration.XMakefileToolChainConfigurationSignature,'once'))
                    test=true;
                end
                fclose(fid);
            catch
                fclose(fid);
            end
        end








        function pass=validate(h)
            title=DAStudio.message('ERRORHANDLER:xmakefile:xmk_validatetitle');
            msg=DAStudio.message('ERRORHANDLER:xmakefile:xmk_waitmessage');
            waitbarHandle=waitbar(0,msg,'Name',title);
            waitbarOnCleanup=onCleanup(@()waitbarHandle.delete());
            h.reloadSettings(linkfoundation.xmakefile.XMakefileConfigurationEvent.VALIDATE_REQUIRED_ENVIRONMENT,'');
            pass=h.isOperational();
        end




        function value=getCfgValue(h,field)
            if(isa(field,'function_handle'))
                value=field(h);
            else
                value=field;
            end
        end
    end

    methods(Access='public')









        function h=XMakefileConfiguration(name)
            args={};
            if(0~=nargin)
                args{1}=name;
            end


            h=h@linkfoundation.util.File(args{:});

            h.initializeSettings();
            factoryConfigs=linkfoundation.xmakefile.XMakefileConfiguration.getFilteredFactoryConfigsForRegisteredAdaptors();
            for i=1:numel(factoryConfigs)
                factoryConfigs{i}=linkfoundation.util.Location(factoryConfigs{i});
            end
            if(0~=nargin)
                try
                    currentDirectory=linkfoundation.util.Location(pwd);
                    if(h.exists())


                        if(h.containsConfigurationSignature())


                            if(currentDirectory~=h)
                                cd(h.Path);
                            end
                            cfg=str2func(h.Name);
                            data=cfg();
                            if(~isempty(data)&&isfield(data,'Version'))
                                h.loadSettings(data);



                                userDir=linkfoundation.xmakefile.XMakefileConfiguration.getUserConfigurationLocation();
                                if(userDir~=h)&&any(cellfun(@(x)(x==h),factoryConfigs))
                                    h.IsSystemDefined=true;
                                else
                                    h.IsSystemDefined=false;
                                end
                            end
                        else





                        end
                    else





                        h.IsSystemDefined=false;
                        h.TCCfgData.Configuration=h.Name;
                        h.TCCfgData.Version=linkfoundation.xmakefile.XMakefileConfiguration.FormatVersion;
                    end
                    if(currentDirectory~=linkfoundation.util.Location(pwd)),cd(currentDirectory.Path);end
                catch ex
                    if(currentDirectory~=linkfoundation.util.Location(pwd)),cd(currentDirectory.Path);end
                    if(isa(name,'linkfoundation.util.File'))
                        if(isempty(name.FullPathName))
                            info=DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_none');
                        else
                            info=name.EscapedFullPathName;
                        end
                        linkfoundation.xmakefile.raiseException('XMakefileConfiguration','XMakefileConfiguration','',ex,info);
                    else
                        linkfoundation.xmakefile.raiseException('XMakefileConfiguration','XMakefileConfiguration','',ex,name);
                    end
                end
            else





                h.IsSystemDefined=false;
                h.TCCfgData.Version=linkfoundation.xmakefile.XMakefileConfiguration.FormatVersion;
            end
        end





        function saved=save(h)
            if(h.IsSystemDefined)
                MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileConfiguration_readonly',h.Configuration).reportAsWarning;
                return;
            end
            try
                saved=false;
                if(h.isValid())





                    if(h.exists())
                        clear(h.Configuration);
                    end







                    userDir=linkfoundation.xmakefile.XMakefilePreferences.getUserConfigurationLocation();
                    h.Path=userDir.Path;
                    h.Name=h.Configuration;
                    h.Extension=linkfoundation.xmakefile.XMakefileConfiguration.XMakefileConfigurationExtension;
                    h.TCCfgData.Version=linkfoundation.xmakefile.XMakefileConfiguration.FormatVersion;
                    prebuildEnable='false';
                    if(h.PrebuildEnable)
                        prebuildEnable='true';
                    end
                    postbuildEnable='false';
                    if(h.PostbuildEnable)
                        postbuildEnable='true';
                    end
                    executeDefault='false';
                    if(h.ExecuteDefault)
                        executeDefault='true';
                    end
                    operational='false';
                    if(h.Operational)
                        operational='true';
                    end
                    currentDate=date;
                    currentYear=currentDate(end-3:end);
                    configSignature=linkfoundation.xmakefile.XMakefileConfiguration.XMakefileToolChainConfigurationSignature;
















                    fid=fopen(h.FullPathName,'wt');
                    fprintf(fid,'%% NOTE: DO NOT REMOVE THIS LINE %s\n',configSignature);
                    fprintf(fid,'function toolChainConfiguration = %s()\n',h.Configuration);
                    fprintf(fid,'%%%s Defines a tool chain configuration.\n',upper(h.Configuration));
                    fprintf(fid,'%%\n');
                    fprintf(fid,'%% Copyright %s The MathWorks, Inc.\n',currentYear);
                    fprintf(fid,'%%\n');
                    fprintf(fid,'%% General\n');
                    fprintf(fid,'toolChainConfiguration.Configuration   = ''%s'';\n',h.Configuration);
                    fprintf(fid,'toolChainConfiguration.Version         = ''%s'';\n',h.Version);
                    fprintf(fid,'toolChainConfiguration.Description     = ''%s'';\n',h.Description);
                    fprintf(fid,'toolChainConfiguration.Operational     = %s;\n',operational);
                    fprintf(fid,'toolChainConfiguration.InstallPath     = ''%s'';\n',h.InstallPath);
                    fprintf(fid,'toolChainConfiguration.CustomValidator     = ''%s'';\n',h.CustomValidator);
                    fprintf(fid,'toolChainConfiguration.Decorator       = ''%s'';\n',h.Decorator);
                    fprintf(fid,'%% Make\n');
                    fprintf(fid,'toolChainConfiguration.MakePath        = ''%s'';\n',h.MakePath);
                    fprintf(fid,'toolChainConfiguration.MakeFlags       = ''%s'';\n',h.MakeFlags);
                    fprintf(fid,'toolChainConfiguration.MakeInclude     = ''%s'';\n',h.MakeInclude);
                    fprintf(fid,'%% Compiler\n');
                    fprintf(fid,'toolChainConfiguration.CompilerPath     = ''%s'';\n',h.CompilerPath);
                    fprintf(fid,'toolChainConfiguration.CompilerFlags    = ''%s'';\n',h.CompilerFlags);
                    fprintf(fid,'toolChainConfiguration.SourceExtensions = ''%s'';\n',h.SourceExtensions);
                    fprintf(fid,'toolChainConfiguration.HeaderExtensions = ''%s'';\n',h.HeaderExtensions);
                    fprintf(fid,'toolChainConfiguration.ObjectExtension  = ''%s'';\n',h.ObjectExtension);
                    fprintf(fid,'%% Linker\n');
                    fprintf(fid,'toolChainConfiguration.LinkerPath        = ''%s'';\n',h.LinkerPath);
                    fprintf(fid,'toolChainConfiguration.LinkerFlags       = ''%s'';\n',h.LinkerFlags);
                    fprintf(fid,'toolChainConfiguration.LibraryExtensions = ''%s'';\n',h.LibraryExtensions);
                    fprintf(fid,'toolChainConfiguration.TargetExtension   = ''%s'';\n',h.TargetExtension);
                    fprintf(fid,'toolChainConfiguration.TargetNamePrefix  = ''%s'';\n',h.TargetNamePrefix);
                    fprintf(fid,'toolChainConfiguration.TargetNamePostfix = ''%s'';\n',h.TargetNamePostfix);
                    fprintf(fid,'%% Archiver\n');
                    fprintf(fid,'toolChainConfiguration.ArchiverPath      = ''%s'';\n',h.ArchiverPath);
                    fprintf(fid,'toolChainConfiguration.ArchiverFlags     = ''%s'';\n',h.ArchiverFlags);
                    fprintf(fid,'toolChainConfiguration.ArchiveExtension  = ''%s'';\n',h.ArchiveExtension);
                    fprintf(fid,'toolChainConfiguration.ArchiveNamePrefix = ''%s'';\n',h.ArchiveNamePrefix);
                    fprintf(fid,'toolChainConfiguration.ArchiveNamePostfix= ''%s'';\n',h.ArchiveNamePostfix);
                    fprintf(fid,'%% Pre-build\n');
                    fprintf(fid,'toolChainConfiguration.PrebuildEnable   = %s;\n',prebuildEnable);
                    fprintf(fid,'toolChainConfiguration.PrebuildToolPath = ''%s'';\n',h.PrebuildToolPath);
                    fprintf(fid,'toolChainConfiguration.PrebuildFlags    = ''%s'';\n',h.PrebuildFlags);
                    fprintf(fid,'%% Post-build\n');
                    fprintf(fid,'toolChainConfiguration.PostbuildEnable   = %s;\n',postbuildEnable);
                    fprintf(fid,'toolChainConfiguration.PostbuildToolPath = ''%s'';\n',h.PostbuildToolPath);
                    fprintf(fid,'toolChainConfiguration.PostbuildFlags    = ''%s'';\n',h.PostbuildFlags);
                    fprintf(fid,'%% Execute\n');
                    fprintf(fid,'toolChainConfiguration.ExecuteDefault  = %s;\n',executeDefault);
                    fprintf(fid,'toolChainConfiguration.ExecuteToolPath = ''%s'';\n',h.ExecuteToolPath);
                    fprintf(fid,'toolChainConfiguration.ExecuteFlags    = ''%s'';\n',h.ExecuteFlags);
                    fprintf(fid,'%% Directories\n');
                    fprintf(fid,'toolChainConfiguration.DerivedPath     = ''%s'';\n',h.DerivedPath);
                    fprintf(fid,'toolChainConfiguration.OutputPath      = ''%s'';\n',h.OutputPath);
                    fprintf(fid,'%% Custom\n');
                    fprintf(fid,'toolChainConfiguration.Custom1         = ''%s'';\n',h.Custom1);
                    fprintf(fid,'toolChainConfiguration.Custom2         = ''%s'';\n',h.Custom2);
                    fprintf(fid,'toolChainConfiguration.Custom3         = ''%s'';\n',h.Custom3);
                    fprintf(fid,'toolChainConfiguration.Custom4         = ''%s'';\n',h.Custom4);
                    fprintf(fid,'toolChainConfiguration.Custom5         = ''%s'';\n',h.Custom5);
                    fprintf(fid,'end\n');
                    fclose(fid);
                    saved=true;
                    configurations=linkfoundation.xmakefile.XMakefileConfiguration.getConfigurations(saved);%#ok
                else


                    if(isempty(h.Configuration))
                        name=DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_none');
                    else
                        name=h.Configuration;
                    end
                    MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileConfiguration_save',name).reportAsWarning;
                end
            catch ex
                linkfoundation.xmakefile.raiseException('XMakefileConfiguration','save','',ex);
            end
        end





        function active=setActive(h)
            active=false;
            if(h.isValid())
                active=linkfoundation.xmakefile.XMakefileConfiguration.setActiveConfiguration(h.Name);
            end
        end








        function pass=isValid(h,suppress)
            if(1==nargin)
                suppress=false;
            end
            pass=false;

            if(isempty(h.Version))
                if(~suppress)
                    MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileConfiguration_isValid_version').reportAsWarning;
                end
                return;
            end


            if(~any(strcmpi(h.Version,linkfoundation.xmakefile.XMakefileConfiguration.SupportedFormatVersions)))
                if(~suppress)
                    MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileConfiguration_isValid_format_version',...
                    h.Version,separateWithComma(linkfoundation.xmakefile.XMakefileConfiguration.SupportedFormatVersions)).reportAsWarning;
                end
                return;
            end

            if(isempty(h.Configuration))
                if(~suppress)
                    MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileConfiguration_isValid_configuration').reportAsWarning;
                end
                return;
            end

            if(~isvarname(h.Configuration))
                if(~suppress)
                    MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileConfiguration_isValid_identifier',h.Configuration).reportAsWarning;
                end
                return;
            end
            pass=true;

            function out=separateWithComma(in)
                if ischar(in)
                    out=in;
                    return;
                end
                if iscellstr(in)
                    if numel(in)==0
                        out='';
                        return;
                    elseif numel(in)==1
                        out=in{1};
                        return;
                    else
                        out=in{1};
                        for i=2:numel(in)
                            out=[out,', ',in{i}];%#ok<AGROW>
                        end
                    end
                end
            end
        end












        function pass=isOperational(h,suppress)
            if(1==nargin)
                suppress=false;
            end
            pass=false;
            if(~h.isValid(suppress))
                return;
            end




            if(~h.Operational)
                if(~suppress)
                    if(~isempty(h.OperationalReason))
                        MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileConfiguration_isOperational_operational_info',h.Configuration,h.OperationalReason).reportAsWarning;
                    else
                        MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileConfiguration_isOperational_operational',h.Configuration).reportAsWarning;
                    end
                end
                return;
            end

            if(isempty(h.SourceExtensions)||isempty(h.HeaderExtensions)||isempty(h.LibraryExtensions))
                if(~suppress)
                    MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileConfiguration_isOperational_extensions',h.Configuration).reportAsWarning;
                end
                return;
            end



            if(isempty(h.MakePath))
                if(~suppress)
                    MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileConfiguration_isOperational_makeUtility',h.Configuration).reportAsWarning;
                end
                return;
            end
            pass=true;
        end







        function clone(h,source)
            if(~isa(source,'linkfoundation.xmakefile.XMakefileConfiguration'))
                if(isa(source,'linkfondation.util.File'))
                    source=linkfoundation.xmakefile.XMakefileConfiguration(source);
                else


                    source=linkfoundation.xmakefile.XMakefileConfiguration.getConfiguration(source);
                end
            end



            fields=horzcat(h.ConfigurationFields.Value,h.ConfigurationFields.Logical);

            fields=setxor(fields,{'Configuration','Version','Operational','OperationalReason'});
            cellfun(@cloneField,fields);

            function cloneField(field)
                h.(field)=source.(field);
            end
        end




        function disp(h)
            fields=horzcat(h.ConfigurationFields.Value,h.ConfigurationFields.Logical);
            cellfun(@displayField,fields);

            function displayField(field)
                if(~isfield(h.TCCfgData,field))
                    return;
                end
                if(islogical(h.(field)))
                    if(h.(field)),
                        value=DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_true');
                    else
                        value=DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_false');
                    end
                else
                    value=h.(field);
                end
                disp([field,' = ',value]);
            end
        end




        function reloadSettings(h,context,buildConfiguration)
            h.notify('ContextChange',linkfoundation.xmakefile.XMakefileConfigurationEvent(context,buildConfiguration));
        end
    end





    methods(Static=true,Access='public')



        function[tcount,ucount,scount]=getConfigurationCounts()
            configurations=linkfoundation.xmakefile.XMakefileConfiguration.getConfigurations();
            ucount=uint32(0);
            scount=uint32(0);
            tcount=uint32(0);%#ok
            v=configurations.values;
            for index=1:length(v)
                configuration=v{index};
                if(configuration.IsSystemDefined)
                    scount=scount+1;
                else
                    ucount=ucount+1;
                end
            end
            tcount=ucount+scount;
        end






        function configuration=getActiveConfiguration()
            configuration=linkfoundation.xmakefile.XMakefilePreferences.getActiveConfiguration();
        end




        function configuration=getConfiguration(name)
            configuration=[];


            configurations=linkfoundation.xmakefile.XMakefileConfiguration.getConfigurations();


            key=linkfoundation.xmakefile.XMakefileConfiguration.mapKey(name);
            if(configurations.isKey(key))
                configuration=configurations(key);
            end
        end





        function active=setActiveConfiguration(name)
            active=false;
            if(linkfoundation.xmakefile.XMakefileConfiguration.isConfiguration(name))
                activeConfiguration=linkfoundation.xmakefile.XMakefileConfiguration.getConfiguration(name);
                if(activeConfiguration.isOperational(true))
                    linkfoundation.xmakefile.XMakefilePreferences.setActiveConfiguration(activeConfiguration.Configuration);
                    active=true;
                else
                    if(activeConfiguration.validate())
                        linkfoundation.xmakefile.XMakefilePreferences.setActiveConfiguration(activeConfiguration.Configuration);
                        active=true;
                    end
                end
            else
                MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileConfiguration_setActiveConfiguration',name).reportAsWarning;
            end
        end





        function test=isConfiguration(name)
            test=false;
            configurations=linkfoundation.xmakefile.XMakefileConfiguration.getConfigurations();
            key=linkfoundation.xmakefile.XMakefileConfiguration.mapKey(name);
            if(configurations.isKey(key))
                test=true;
            end
        end




        function reload()
            linkfoundation.xmakefile.XMakefileConfiguration.getUserConfigurationLocation(true);
            linkfoundation.xmakefile.XMakefileConfiguration.getConfigurations(true);
        end




        function configurations=getConfigurations(reload)
            persistent repository;
            if(0==nargin)
                reload=false;
            end
            if(~isa(repository,'containers.Map')||reload)
                repository=containers.Map;






                linkfoundation.xmakefile.XMakefileConfiguration.loadConfigurations(repository);



                activeConfiguration=linkfoundation.xmakefile.XMakefileConfiguration.getActiveConfiguration();

                if((isempty(activeConfiguration)||~linkfoundation.xmakefile.XMakefileConfiguration.isConfiguration(activeConfiguration))&&~isempty(repository))
                    v=repository.values;
                    for index=1:length(v)
                        if(v{index}.isOperational(true)&&...
                            linkfoundation.xmakefile.XMakefileConfiguration.setActiveConfiguration(v{index}.Configuration))
                            break;
                        end
                    end
                end
            end
            configurations=repository;
        end




        function displayConfigurations()
            configurations=linkfoundation.xmakefile.XMakefileConfiguration.getConfigurations();
            if(isempty(configurations))
                fprintf('%s\n',DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_XMakefileConfiguration_displayConfigurations_empty'));
                return;
            end
            values=configurations.values;
            fprintf('%s\n',DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_XMakefileConfiguration_displayConfigurations_header'));
            for index=1:length(values)
                configuration=values{index};
                systemStr=DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_false');
                if(configuration.IsSystemDefined)
                    systemStr=DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_true');
                end
                operationalStr=DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_false');
                if(configuration.isOperational(true))
                    operationalStr=DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_true');
                end
                fprintf('%s -- %s -- %s\n',configuration.Configuration,...
                systemStr,operationalStr,configuration.FullPathName);
            end
        end




        function removeAll()
            reload=false;
            activeName=linkfoundation.xmakefile.XMakefileConfiguration.getActiveConfiguration();
            configurations=linkfoundation.xmakefile.XMakefileConfiguration.getConfigurations();
            v=configurations.values;
            for index=1:length(v)
                configuration=v{index};
                if(~configuration.IsSystemDefined)


                    delete(configuration.FullPathName);
                    if(strcmpi(activeName,configuration.Configuration))



                        linkfoundation.xmakefile.XMakefileConfiguration.resetActiveConfiguration();
                    end
                    reload=true;
                end
            end

            if(reload),
                linkfoundation.xmakefile.XMakefileConfiguration.reload();
            end
        end





        function removeConfiguration(name)
            reload=false;
            configurations=linkfoundation.xmakefile.XMakefileConfiguration.getConfigurations();
            key=linkfoundation.xmakefile.XMakefileConfiguration.mapKey(name);
            if(configurations.isKey(key))
                configuration=configurations(key);
                if(configuration.IsSystemDefined)
                    MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileConfiguration_readonly',name).reportAsWarning;
                else
                    activeName=linkfoundation.xmakefile.XMakefileConfiguration.getActiveConfiguration();
                    delete(configuration.FullPathName);
                    if(strcmpi(activeName,configuration.Configuration))



                        linkfoundation.xmakefile.XMakefileConfiguration.resetActiveConfiguration();
                    end
                    reload=true;
                end
            end

            if(reload),linkfoundation.xmakefile.XMakefileConfiguration.reload();end
        end
    end





    methods(Static=true,Access='private')














        function factoryConfigs=getFactoryConfigsForRegisteredAdaptors()


            desktopTgts={...
            fullfile(idelinkdir('eclipseide'),'registry','xmakefilecfg','desktop')};
            embeddedTgts={
            fullfile(idelinkdir('eclipseide'),'registry','xmakefilecfg','embedded'),...
            fullfile(idelinkdir('ticcs'),'registry','xmakefilecfg')};



            configs=linkfoundation.util.getSupportPackageInfo('XMakefileConfigFolder');
            for i=1:numel(configs)
                cfg=configs{i};
                if isfield(cfg,'desktop')&&~isempty(cfg.desktop)
                    desktopTgts{end+1}=cfg.desktop;%#ok<AGROW>
                end
                if isfield(cfg,'embedded')&&~isempty(cfg.embedded)
                    embeddedTgts{end+1}=cfg.embedded;%#ok<AGROW>
                end
            end




            desktopTgts=unique(desktopTgts,'stable');
            embeddedTgts=unique(embeddedTgts,'stable');

            factoryConfigs=struct('DesktopTargets',{desktopTgts},'EmbeddedTgts',{embeddedTgts});
        end






        function key=mapKey(value)
            if(~ischar(value))
                key=lower(char(value));
            else
                key=lower(value);
            end
        end




        function resetActiveConfiguration()
            linkfoundation.xmakefile.XMakefilePreferences.setActiveConfiguration('');
        end




        function location=getUserConfigurationLocation(reload)
            persistent userLocation;
            if(0==nargin)
                reload=false;
            end
            if(~isa(userLocation,'linkfoundation.util.Location')||reload)
                userLocation=linkfoundation.xmakefile.XMakefilePreferences.getUserConfigurationLocation();
            end
            location=userLocation;
        end





        function factoryConfigs=getFilteredFactoryConfigsForRegisteredAdaptors()
            allConfigFolders=linkfoundation.xmakefile.XMakefileConfiguration.getFactoryConfigsForRegisteredAdaptors();
            factoryConfigs={};
            if license('test','MATLAB_Coder')||license('test','Real-Time_Workshop')
                factoryConfigs=horzcat(factoryConfigs,allConfigFolders.DesktopTargets);
            end
            if license('test','RTW_Embedded_Coder')
                factoryConfigs=horzcat(factoryConfigs,allConfigFolders.EmbeddedTgts);
            end


            factoryConfigs=unique(factoryConfigs,'stable');
        end







        function loadConfigurations(map)

            factoryConfigs=linkfoundation.xmakefile.XMakefileConfiguration.getFilteredFactoryConfigsForRegisteredAdaptors();


            warnstate=warning('off','MATLAB:UIW_DOSUNC');

            for i=1:numel(factoryConfigs)
                configurationDir=linkfoundation.util.Location(factoryConfigs{i});
                linkfoundation.xmakefile.XMakefileConfiguration.loadConfigurationsFromLocation(map,configurationDir);
            end

            configurationDir=linkfoundation.xmakefile.XMakefilePreferences.getUserConfigurationLocation();
            linkfoundation.xmakefile.XMakefileConfiguration.loadConfigurationsFromLocation(map,configurationDir);

            warning(warnstate);
        end





        function loadConfigurationsFromLocation(map,location)
            if(isempty(location.Path)||~location.exists())
                return;
            end

            currentLocation=linkfoundation.util.Location(pwd);

            files=location.files(['*',linkfoundation.xmakefile.XMakefileConfiguration.XMakefileConfigurationExtension]);

            if(~isempty(files))
                cd(location.Path);
            end


            for index=1:length(files)
                try

                    configuration=linkfoundation.xmakefile.XMakefileConfiguration(files{index});

                    if(~configuration.isValid(true))
                        continue;
                    end

                    key=linkfoundation.xmakefile.XMakefileConfiguration.mapKey(configuration.Configuration);
                    if(map.isKey(key))
                        existing=map(key);
                        MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileConfiguration_loadConfigurationsFromLocation_duplicate',...
                        char(configuration.Configuration),configuration.FullPathName,existing.FullPathName).reportAsWarning;
                        continue;
                    end


                    map(key)=configuration;
                catch ex
                    exMessage=ex.message;
                    while(~isempty(ex.cause))
                        ex=ex.cause{1};
                        exMessage=sprintf('%s\n%s',exMessage,ex.message);
                    end
                    MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileConfiguration_loadConfigurationsFromLocation',...
                    files{index}.Name,exMessage).reportAsWarning;
                end
            end

            if(currentLocation~=linkfoundation.util.Location(pwd))
                cd(currentLocation.Path);
            end
        end





        function normalized=normalizeExtensionList(list)
            normalized='';
            if(isempty(list))
                return;
            end
            tokens=textscan(list,'%s','Delimiter',', ','MultipleDelimsAsOne',1);
            extensions=tokens{1,1};
            for index=1:length(extensions)
                extension=strtrim(extensions{index});
                if('.'==extension(1))
                    if(isempty(normalized)),
                        normalized=sprintf('%s',extension);
                    else
                        normalized=sprintf('%s,%s',normalized,extension);
                    end
                else
                    if(isempty(normalized)),
                        normalized=sprintf('.%s',extension);
                    else
                        normalized=sprintf('%s,.%s',normalized,extension);
                    end
                end
            end
        end
    end





    methods
        function value=get.Version(h)
            value=h.getCfgValue(h.TCCfgData.Version);
        end
        function value=get.Configuration(h)
            value=h.getCfgValue(h.TCCfgData.Configuration);
        end
        function set.Configuration(h,value)
            h.TCCfgData.Configuration=value;
        end
        function value=get.Operational(h)
            value=h.getCfgValue(h.TCCfgData.Operational);
        end
        function set.Operational(h,value)
            h.TCCfgData.Operational=value;
        end
        function value=get.OperationalReason(h)
            value=h.getCfgValue(h.TCCfgData.OperationalReason);
        end
        function set.OperationalReason(h,value)
            h.TCCfgData.OperationalReason=value;
        end
        function value=get.Description(h)
            value=h.getCfgValue(h.TCCfgData.Description);
        end
        function set.Description(h,value)
            h.TCCfgData.Description=value;
        end
        function value=get.Decorator(h)
            value=h.getCfgValue(h.TCCfgData.Decorator);
        end
        function set.Decorator(h,value)
            h.TCCfgData.Decorator=value;
        end
        function value=get.Tag(h)
            value=h.getCfgValue(h.TCCfgData.Tag);
        end
        function value=get.PrivateData(h)
            value=h.getCfgValue(h.TCCfgData.PrivateData);
        end
        function set.PrivateData(h,value)
            h.TCCfgData.PrivateData=value;
        end
        function value=get.OutputPath(h)
            value=h.getCfgValue(h.TCCfgData.OutputPath);
        end
        function set.OutputPath(h,value)
            h.TCCfgData.OutputPath=value;
        end
        function value=get.DerivedPath(h)
            value=h.getCfgValue(h.TCCfgData.DerivedPath);
        end
        function set.DerivedPath(h,value)
            h.TCCfgData.DerivedPath=value;
        end
        function value=get.MakePath(h)
            value=h.getCfgValue(h.TCCfgData.MakePath);
        end
        function set.MakePath(h,value)
            h.TCCfgData.MakePath=value;
        end
        function value=get.MakeFlags(h)
            value=h.getCfgValue(h.TCCfgData.MakeFlags);
        end
        function set.MakeFlags(h,value)
            h.TCCfgData.MakeFlags=value;
        end
        function value=get.MakeInclude(h)
            value=h.getCfgValue(h.TCCfgData.MakeInclude);
        end
        function set.MakeInclude(h,value)
            h.TCCfgData.MakeInclude=value;
        end


        function value=get.InstallPath(h)
            value=h.getCfgValue(h.TCCfgData.InstallPath);
        end
        function set.InstallPath(h,value)
            h.TCCfgData.InstallPath=value;
        end

        function value=get.CustomValidator(h)
            value=h.getCfgValue(h.TCCfgData.CustomValidator);
        end
        function set.CustomValidator(h,value)
            h.TCCfgData.CustomValidator=value;
        end


        function value=get.CompilerPath(h)
            value=h.getCfgValue(h.TCCfgData.CompilerPath);
        end
        function set.CompilerPath(h,value)
            h.TCCfgData.CompilerPath=value;
        end
        function value=get.CompilerFlags(h)
            value=h.getCfgValue(h.TCCfgData.CompilerFlags);
        end
        function set.CompilerFlags(h,value)
            h.TCCfgData.CompilerFlags=value;
        end
        function value=get.SourceExtensions(h)
            value=linkfoundation.xmakefile.XMakefileConfiguration.normalizeExtensionList(h.getCfgValue(h.TCCfgData.SourceExtensions));
        end
        function set.SourceExtensions(h,value)
            h.TCCfgData.SourceExtensions=value;
        end
        function value=get.HeaderExtensions(h)
            value=linkfoundation.xmakefile.XMakefileConfiguration.normalizeExtensionList(h.getCfgValue(h.TCCfgData.HeaderExtensions));
        end
        function set.HeaderExtensions(h,value)
            h.TCCfgData.HeaderExtensions=value;
        end
        function value=get.LibraryExtensions(h)
            value=linkfoundation.xmakefile.XMakefileConfiguration.normalizeExtensionList(h.getCfgValue(h.TCCfgData.LibraryExtensions));
        end
        function set.LibraryExtensions(h,value)
            h.TCCfgData.LibraryExtensions=value;
        end
        function value=get.ObjectExtension(h)
            value=linkfoundation.xmakefile.XMakefileConfiguration.normalizeExtensionList(h.getCfgValue(h.TCCfgData.ObjectExtension));
        end
        function set.ObjectExtension(h,value)
            h.TCCfgData.ObjectExtension=value;
        end
        function value=get.TargetExtension(h)
            value=linkfoundation.xmakefile.XMakefileConfiguration.normalizeExtensionList(h.getCfgValue(h.TCCfgData.TargetExtension));
        end
        function set.TargetExtension(h,value)
            h.TCCfgData.TargetExtension=value;
        end
        function value=get.TargetNamePrefix(h)
            value=h.getCfgValue(h.TCCfgData.TargetNamePrefix);
        end
        function set.TargetNamePrefix(h,value)
            h.TCCfgData.TargetNamePrefix=value;
        end
        function value=get.TargetNamePostfix(h)
            value=h.getCfgValue(h.TCCfgData.TargetNamePostfix);
        end
        function set.TargetNamePostfix(h,value)
            h.TCCfgData.TargetNamePostfix=value;
        end
        function value=get.LinkerPath(h)
            value=h.getCfgValue(h.TCCfgData.LinkerPath);
        end
        function set.LinkerPath(h,value)
            h.TCCfgData.LinkerPath=value;
        end
        function value=get.LinkerFlags(h)
            value=h.getCfgValue(h.TCCfgData.LinkerFlags);
        end
        function set.LinkerFlags(h,value)
            h.TCCfgData.LinkerFlags=value;
        end
        function value=get.ArchiveExtension(h)
            value=linkfoundation.xmakefile.XMakefileConfiguration.normalizeExtensionList(h.getCfgValue(h.TCCfgData.ArchiveExtension));
        end
        function set.ArchiveExtension(h,value)
            h.TCCfgData.ArchiveExtension=value;
        end
        function value=get.ArchiveNamePrefix(h)
            value=h.getCfgValue(h.TCCfgData.ArchiveNamePrefix);
        end
        function set.ArchiveNamePrefix(h,value)
            h.TCCfgData.ArchiveNamePrefix=value;
        end
        function value=get.ArchiveNamePostfix(h)
            value=h.getCfgValue(h.TCCfgData.ArchiveNamePostfix);
        end
        function set.ArchiveNamePostfix(h,value)
            h.TCCfgData.ArchiveNamePostfix=value;
        end
        function value=get.ArchiverPath(h)
            value=h.getCfgValue(h.TCCfgData.ArchiverPath);
        end
        function set.ArchiverPath(h,value)
            h.TCCfgData.ArchiverPath=value;
        end
        function value=get.ArchiverFlags(h)
            value=h.getCfgValue(h.TCCfgData.ArchiverFlags);
        end
        function set.ArchiverFlags(h,value)
            h.TCCfgData.ArchiverFlags=value;
        end
        function set.PrebuildEnable(h,value)
            h.TCCfgData.PrebuildEnable=value;
        end
        function value=get.PrebuildEnable(h)
            value=h.getCfgValue(h.TCCfgData.PrebuildEnable);
        end
        function value=get.PrebuildToolPath(h)
            value=h.getCfgValue(h.TCCfgData.PrebuildToolPath);
        end
        function set.PrebuildToolPath(h,value)
            h.TCCfgData.PrebuildToolPath=value;
        end
        function set.PrebuildFlags(h,value)
            h.TCCfgData.PrebuildFlags=value;
        end
        function value=get.PrebuildFlags(h)
            value=h.getCfgValue(h.TCCfgData.PrebuildFlags);
        end
        function value=get.PostbuildEnable(h)
            value=h.getCfgValue(h.TCCfgData.PostbuildEnable);
        end
        function set.PostbuildEnable(h,value)
            h.TCCfgData.PostbuildEnable=value;
        end
        function value=get.PostbuildToolPath(h)
            value=h.getCfgValue(h.TCCfgData.PostbuildToolPath);
        end
        function set.PostbuildToolPath(h,value)
            h.TCCfgData.PostbuildToolPath=value;
        end
        function value=get.PostbuildFlags(h)
            value=h.getCfgValue(h.TCCfgData.PostbuildFlags);
        end
        function set.PostbuildFlags(h,value)
            h.TCCfgData.PostbuildFlags=value;
        end
        function value=get.ExecuteDefault(h)
            value=h.getCfgValue(h.TCCfgData.ExecuteDefault);
        end
        function set.ExecuteDefault(h,value)
            h.TCCfgData.ExecuteDefault=value;
        end
        function value=get.ExecuteToolPath(h)
            value=h.getCfgValue(h.TCCfgData.ExecuteToolPath);
        end
        function set.ExecuteToolPath(h,value)
            h.TCCfgData.ExecuteToolPath=value;
        end
        function value=get.ExecuteFlags(h)
            value=h.getCfgValue(h.TCCfgData.ExecuteFlags);
        end
        function set.ExecuteFlags(h,value)
            h.TCCfgData.ExecuteFlags=value;
        end
        function value=get.Custom1(h)
            value=h.getCfgValue(h.TCCfgData.Custom1);
        end
        function set.Custom1(h,value)
            h.TCCfgData.Custom1=value;
        end
        function value=get.Custom2(h)
            value=h.getCfgValue(h.TCCfgData.Custom2);
        end
        function set.Custom2(h,value)
            h.TCCfgData.Custom2=value;
        end
        function value=get.Custom3(h)
            value=h.getCfgValue(h.TCCfgData.Custom3);
        end
        function set.Custom3(h,value)
            h.TCCfgData.Custom3=value;
        end
        function value=get.Custom4(h)
            value=h.getCfgValue(h.TCCfgData.Custom4);
        end
        function set.Custom4(h,value)
            h.TCCfgData.Custom4=value;
        end
        function value=get.Custom5(h)
            value=h.getCfgValue(h.TCCfgData.Custom5);
        end
        function set.Custom5(h,value)
            h.TCCfgData.Custom5=value;
        end





        function value=get.SourceFilesOverride(h)
            value=h.TCCfgData.SourceFilesOverride;
        end
        function set.SourceFilesOverride(h,value)
            h.TCCfgData.SourceFilesOverride=value;
        end
        function value=get.HeaderFilesOverride(h)
            value=h.TCCfgData.HeaderFilesOverride;
        end
        function set.HeaderFilesOverride(h,value)
            h.TCCfgData.HeaderFilesOverride=value;
        end
        function value=get.LibraryFilesOverride(h)
            value=h.TCCfgData.LibraryFilesOverride;
        end
        function set.LibraryFilesOverride(h,value)
            h.TCCfgData.LibraryFilesOverride=value;
        end
        function value=get.SkippedFilesOverride(h)
            value=h.TCCfgData.SkippedFilesOverride;
        end
        function set.SkippedFilesOverride(h,value)
            h.TCCfgData.SkippedFilesOverride=value;
        end
        function value=get.CodeGenCompilerFlagsOverride(h)
            value=h.TCCfgData.CodeGenCompilerFlagsOverride;
        end
        function set.CodeGenCompilerFlagsOverride(h,value)
            h.TCCfgData.CodeGenCompilerFlagsOverride=value;
        end
        function value=get.CodeGenLinkerFlagsOverride(h)
            value=h.TCCfgData.CodeGenLinkerFlagsOverride;
        end
        function set.CodeGenLinkerFlagsOverride(h,value)
            h.TCCfgData.CodeGenLinkerFlagsOverride=value;
        end
        function set.PrebuildLineOverride(h,value)
            h.TCCfgData.PrebuildLineOverride=value;
        end
        function value=get.PrebuildLineOverride(h)
            value=h.TCCfgData.PrebuildLineOverride;
        end
        function set.CompilerLineOverride(h,value)
            h.TCCfgData.CompilerLineOverride=value;
        end
        function value=get.CompilerLineOverride(h)
            value=h.TCCfgData.CompilerLineOverride;
        end
        function set.LinkerLineOverride(h,value)
            h.TCCfgData.LinkerLineOverride=value;
        end
        function value=get.LinkerLineOverride(h)
            value=h.TCCfgData.LinkerLineOverride;
        end
        function set.PostbuildLineOverride(h,value)
            h.TCCfgData.PostbuildLineOverride=value;
        end
        function value=get.PostbuildLineOverride(h)
            value=h.TCCfgData.PostbuildLineOverride;
        end
        function set.ExecuteLineOverride(h,value)
            h.TCCfgData.ExecuteLineOverride=value;
        end
        function value=get.ExecuteLineOverride(h)
            value=h.TCCfgData.ExecuteLineOverride;
        end




        function value=get.MemoryContents(h)
            value='';
            fields=horzcat(...
            h.ConfigurationFields.Value,...
            h.ConfigurationFields.Logical,...
            h.ConfigurationFields.LineOverride);
            cellfun(@addField,fields);

            function addField(field)
                fieldValue='';
                if(islogical(field))
                    if(h.(field)),
                        fieldValue=DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_true');
                    else
                        fieldValue=DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_false');
                    end
                elseif(ischar(field))
                    if(~isempty(h.(field))),
                        fieldValue=h.(field);
                    end
                else
                    fieldValue=class(h.(field));
                end
                value=sprintf('%s%s = %s\n',value,field,fieldValue);
            end
        end




        function value=get.FileContents(h)
            value='';
            if(h.exists())
                value=fileread(h.FullPathName);
            end
        end
    end





    methods



        function result=eq(h,other)
            result=false;


            if(strcmpi(h.Version,other.Version)&&...
                strcmpi(h.SourceExtensions,other.SourceExtensions)&&...
                strcmpi(h.HeaderExtensions,other.HeaderExtensions)&&...
                strcmpi(h.LibraryExtensions,other.LibraryExtensions)&&...
                strcmpi(h.ObjectExtension,other.ObjectExtension)&&...
                strcmpi(h.TargetExtension,other.TargetExtension)&&...
                strcmpi(h.TargetNamePrefix,other.TargetNamePrefix)&&...
                strcmpi(h.TargetNamePostfix,other.TargetNamePostfix)&&...
                strcmpi(h.ArchiveExtension,other.ArchiveExtension)&&...
                strcmpi(h.ArchiveNamePrefix,other.ArchiveNamePrefix)&&...
                strcmpi(h.ArchiveNamePostfix,other.ArchiveNamePostfix)&&...
                (h.PrebuildEnable==other.PrebuildEnable)&&...
                strcmpi(h.PrebuildFlags,other.PrebuildFlags)&&...
                (h.PostbuildEnable==other.PostbuildEnable)&&...
                strcmpi(h.PostbuildFlags,other.PostbuildFlags)&&...
                (h.ExecuteDefault==other.ExecuteDefault)&&...
                strcmpi(h.ExecuteFlags,other.ExecuteFlags)&&...
                strcmpi(h.CompilerFlags,other.CompilerFlags)&&...
                strcmpi(h.LinkerFlags,other.LinkerFlags)&&...
                strcmpi(h.ArchiverFlags,other.ArchiverFlags)&&...
                strcmpi(h.MakeFlags,other.MakeFlags))
                if(ispc())
                    if(strcmpi(h.MakePath,other.MakePath)&&...
                        strcmpi(h.MakeInclude,other.MakeInclude)&&...
                        strcmpi(h.CompilerPath,other.CompilerPath)&&...
                        strcmpi(h.ExecuteToolPath,other.ExecuteToolPath)&&...
                        strcmpi(h.LinkerPath,other.LinkerPath)&&...
                        strcmpi(h.ArchiverPath,other.ArchiverPath)&&...
                        strcmpi(h.PrebuildToolPath,other.PrebuildToolPath)&&...
                        strcmpi(h.PostbuildToolPath,other.PostbuildToolPath)&&...
                        strcmpi(h.InstallPath,other.InstallPath))
                        result=true;
                    end
                elseif(strcmp(h.MakePath,other.MakePath)&&...
                    strcmp(h.MakeInclude,other.MakeInclude)&&...
                    strcmp(h.CompilerPath,other.CompilerPath)&&...
                    strcmp(h.ExecuteToolPath,other.ExecuteToolPath)&&...
                    strcmp(h.LinkerPath,other.LinkerPath)&&...
                    strcmp(h.ArchiverPath,other.ArchiverPath)&&...
                    strcmp(h.PrebuildToolPath,other.PrebuildToolPath)&&...
                    strcmp(h.PostbuildToolPath,other.PostbuildToolPath)&&...
                    strcmp(h.InstallPath,other.InstallPath))
                    result=true;
                end
            end
        end

        function result=ne(h,other)
            result=~(h==other);
        end
    end
end
