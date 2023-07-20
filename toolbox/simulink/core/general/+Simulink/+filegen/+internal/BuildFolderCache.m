classdef BuildFolderCache<handle







    properties(Access=private)
        Mapping containers.Map;
    end

    methods




        function addFoldersFor(this,model,folders)
            this.Mapping(model)=folders;
        end




        function folders=getFoldersFor(this,model)

            model=Simulink.filegen.internal.Helpers.getDirectoryModelName(model);

            if this.Mapping.isKey(model)
                folders=this.Mapping(model);
            else
                folders=Simulink.filegen.internal.FolderConfiguration.empty();
            end
        end
    end

    methods(Access=private)


        function this=BuildFolderCache()

            this.Mapping=containers.Map('KeyType','char','ValueType','Any');
        end
    end

    methods(Static)


        function bfc=getInstance()
            persistent cache;
            if isempty(cache)
                cache=Simulink.filegen.internal.BuildFolderCache();
            end

            bfc=cache;
        end




        function setInstance(instance)
            cache=Simulink.filegen.internal.BuildFolderCache.getInstance();
            cache.Mapping=instance.Mapping;
        end



        function buildDir=getRelativeBuildDirFor(model)

            buildFolderCache=Simulink.filegen.internal.BuildFolderCache.getInstance();
            folders=buildFolderCache.getFoldersFor(model);
            buildDir=folders.CodeGeneration.ModelCode;
        end



        function clear(model)
            buildFolderCache=Simulink.filegen.internal.BuildFolderCache.getInstance();

            if nargin<1
                buildFolderCache.Mapping.remove(buildFolderCache.Mapping.keys);
            elseif buildFolderCache.Mapping.isKey(model)
                buildFolderCache.Mapping.remove(model);
            end
        end



        function inCache=contains(model)
            buildFolderCache=Simulink.filegen.internal.BuildFolderCache.getInstance();
            inCache=buildFolderCache.Mapping.isKey(model);
        end
    end
end


