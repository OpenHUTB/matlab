


classdef AvailablePluginList<handle



    properties

        PluginDirList={};
        PackagePathList={};

    end

    methods

        function obj=AvailablePluginList

            obj.setupPluginDirList;

        end

    end

    methods(Access=protected)

        function SupportedPlugin=getSupportedPluginList(obj)









            SupportedPlugin=[];

            for ii=1:length(obj.PluginDirList)
                pluginDir=obj.PluginDirList{ii};
                packagePath=obj.PackagePathList{ii};

                pluginPackages=dir(pluginDir);

                for jj=1:length(pluginPackages)
                    packageDir=pluginPackages(jj);
                    dirName=packageDir.name;
                    if packageDir.isdir&&~isempty(regexp(dirName,'^\+','once'))
                        t.pluginPath=fullfile(pluginDir,dirName);
                        packageName=dirName(2:end);
                        t.pluginPackage=sprintf('%s.%s',packagePath,packageName);
                        if isempty(SupportedPlugin)
                            SupportedPlugin=t;
                        else
                            SupportedPlugin(end+1)=t;%#ok<AGROW>
                        end
                    end
                end
            end
        end

    end

    methods(Abstract=true,Access=protected)


        setupPluginDirList(obj)

    end

end
