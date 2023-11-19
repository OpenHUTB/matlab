classdef PluginManager<matlab.mixin.SetGet

    properties(SetAccess=private)
plugins
    end

    properties(SetAccess=private)
        plugin_name='wt_plugin'
    end

    properties(Access=private)
        showHidden=false;
    end
    methods(Static)
        function singleObj=getInstance(varargin)

            persistent localObj
            if isempty(localObj)
                localObj=wt.internal.hardware.PluginManager(varargin{:});
            end
            singleObj=localObj;
        end
    end
    methods(Access=private)
        function obj=PluginManager(varargin)
            obj.reset(varargin{:});
        end
        function loadPlugin(obj,pluginFile)
            [pluginFolder,pluginFilename,~]=fileparts(pluginFile);

            currentFolder=pwd;
            cd(pluginFolder);
            try
                plugin=feval(pluginFilename);
                if isfield(plugin,'DeviceName')
                    if obj.showHidden||~plugin.Hidden
                        obj.plugins(plugin.DeviceName)=plugin;
                    end
                end

                cd(currentFolder);
            catch ME
                warning(message("wt:radio:InvalidPlugin",obj.plugin_name,pluginFolder,ME.message()));
                cd(currentFolder);
            end

        end
        function loadPlugins(obj)
            pluginFiles=l_searchFileByName(obj.plugin_name);
            for n=1:numel(pluginFiles)
                loadPlugin(obj,pluginFiles{n});
            end

        end
    end
    methods
        function reset(obj,varargin)
            if nargin>1
                obj.showHidden=varargin{1};
            end
            obj.plugins=containers.Map;

            loadPlugins(obj);
        end

        function list=listPlugins(obj,varargin)
            list=obj.plugins.keys;
        end
        function plugin=getPlugin(obj,name)
            if(isKey(obj.plugins,name))
                plugin=obj.plugins(name);
            else
                plugin=[];
            end
        end
    end
end
function pluginFiles=l_searchFileByName(pluginName)

    pluginFiles=which(pluginName,'-ALL');


    for ii=1:length(pluginFiles)
        [folder,name,~]=fileparts(pluginFiles{ii});
        pluginFiles{ii}=fullfile(folder,name);
    end
    pluginFiles=unique(pluginFiles);
end
