% 将将三维仿真示例工程支持包文件拷贝到目的文件夹
function copyExampleSim3dProject(varargin)

    projectName="AutoVrtlEnv";

    parser=inputParser();

    parser.addRequired("Destination", @(Destination)~isfolder(fullfile(Destination,projectName)));
    parser.addParameter(...
        "Source",...
        fullfile(matlabshared.supportpkg.getSupportPackageRoot(),"toolbox","shared","sim3dprojects","spkg"),...
        @isfolder...
        );
    parser.addParameter("VerboseOutput",false,@islogical);
    parser.addParameter("PluginDestination","C:\Program Files\Epic Games\UE_4.26\Engine\Plugins\MathWorks");

    parser.parse(varargin{:});

    destination=parser.Results.Destination;
    source=parser.Results.Source;
    verboseOutput=parser.Results.VerboseOutput;
    pluginDestination=parser.Results.PluginDestination;
    % 要确保虚幻引擎中的插件目录没有，否则直接报错"断言失败"
    assert(~isfolder(pluginDestination));

    CopyProject(fullfile(source,"project",projectName),fullfile(destination,projectName),verboseOutput);
    CreatePluginsDir(pluginDestination,verboseOutput);
    CopyPlugins(source,pluginDestination,verboseOutput);
    EnablePlugins(pluginDestination,fullfile(destination,projectName,projectName+".uproject"),verboseOutput);
end


% 拷贝虚幻引擎工程
function CopyProject(root,destination,verboseOutput)
    CopyWithLog(root,destination,verboseOutput);
end


% 拷贝虚幻引擎的插件目录
function CreatePluginsDir(pluginsDir,verboseOutput)
    if verboseOutput
        fprintf("Creating %s\n",pluginsDir);
    end
    mkdir(pluginsDir);
end


% 拷贝插件
function CopyPlugins(root,destination,verboseOutput)
    plugins=GetSourcePluginDirectories(root);
    for i=1:length(plugins)
        plugin=plugins(i);
        [~,pluginName]=fileparts(plugin);
        CopyWithLog(plugin,fullfile(destination,pluginName),verboseOutput);
    end
end


% 使虚幻引擎插件生效
function EnablePlugins(pluginDestination,uprojectFile,verboseOutput)
    if verboseOutput
        fprintf("Ensuring %s is writable\n",uprojectFile);
    end
    fileattrib(uprojectFile,"+w");

    mathWorksPluginNames={dir(pluginDestination).name};

    jsonText=fileread(uprojectFile);
    json=jsondecode(jsonText);

    for i=1:length(json.Plugins)
        plugin=json.Plugins{i,1};

        if~ismember(plugin.Name,mathWorksPluginNames)
            continue
        end

        if verboseOutput
            fprintf("Enabling plugin %s in %s\n",plugin.Name,uprojectFile);
        end

        plugin.Enabled=true;
        json.Plugins{i,1}=plugin;
    end

    fid=fopen(uprojectFile,'w');
    fprintf(fid,"%s",jsonencode(json));
    fclose(fid);
end


% 获取原始插件的目录
function pluginDirectories = GetSourcePluginDirectories(root)
    files=dir(fullfile(root,"plugins","*","*"));
    mask=cellfun(@(file)~ismember(file,{'.','..'}),{files.name});
    files=files(mask);
    subdirectories=files([files.isdir]);
    pluginDirectories=string(arrayfun(@(s)fullfile(s.folder,s.name),subdirectories,UniformOutput=false));
end


% 在拷贝的时候输出拷贝过程的详细信息
function status=CopyWithLog(source,destination,verboseOutput)
    if verboseOutput
        fprintf("Copying %s to %s\n",source,destination);
    end
    status=copyfile(source,destination);
end
