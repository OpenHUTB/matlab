function copyExampleSim3dProject(varargin)


    projectName="AutoVrtlEnv";

    parser=inputParser();

    parser.addRequired("Destination",@(Destination)~isfolder(fullfile(Destination,projectName)));
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
    assert(~isfolder(pluginDestination));

    CopyProject(fullfile(source,"project",projectName),fullfile(destination,projectName),verboseOutput);
    CreatePluginsDir(pluginDestination,verboseOutput);
    CopyPlugins(source,pluginDestination,verboseOutput);
    EnablePlugins(pluginDestination,fullfile(destination,projectName,projectName+".uproject"),verboseOutput);
end

function CopyProject(root,destination,verboseOutput)
    CopyWithLog(root,destination,verboseOutput);
end

function CreatePluginsDir(pluginsDir,verboseOutput)
    if verboseOutput
        fprintf("Creating %s\n",pluginsDir);
    end
    mkdir(pluginsDir);
end

function CopyPlugins(root,destination,verboseOutput)
    plugins=GetSourcePluginDirectories(root);
    for i=1:length(plugins)
        plugin=plugins(i);
        [~,pluginName]=fileparts(plugin);
        CopyWithLog(plugin,fullfile(destination,pluginName),verboseOutput);
    end
end

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

function pluginDirectories=GetSourcePluginDirectories(root)
    files=dir(fullfile(root,"plugins","*","*"));
    mask=cellfun(@(file)~ismember(file,{'.','..'}),{files.name});
    files=files(mask);
    subdirectories=files([files.isdir]);
    pluginDirectories=string(arrayfun(@(s)fullfile(s.folder,s.name),subdirectories,UniformOutput=false));
end

function status=CopyWithLog(source,destination,verboseOutput)
    if verboseOutput
        fprintf("Copying %s to %s\n",source,destination);
    end
    status=copyfile(source,destination);
end
