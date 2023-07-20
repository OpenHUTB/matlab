classdef LifetimeManagement<handle





    properties
        TopLevelDesign char
Designs
LoadedDesigns
ActiveConfigset
ConfigsetParameters
    end

    methods
        function obj=LifetimeManagement(design)

            obj.LoadedDesigns=get_param(Simulink.allBlockDiagrams(),'Name');
            obj.TopLevelDesign=design;

            obj.Designs=containers.Map('KeyType','char','ValueType','any');


            mdls=find_mdlrefs(design,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
            for ii=1:numel(mdls)
                [~,name,~]=fileparts(mdls{ii});
                mdl.name=name;
                load_system(mdl.name);

                mdl.prevDirty=get_param(mdl.name,'Dirty');
                mdl.prevOpCountCollection=get_param(mdl.name,'OpCountCollection');
                obj.Designs(name)=mdl;

                set_param(mdl.name,'OpCountCollection','on');
            end



            obj.ActiveConfigset=getActiveConfigSet(design);
            if isa(obj.ActiveConfigset,'Simulink.ConfigSetRef')
                obj.ActiveConfigset=obj.ActiveConfigset.getRefConfigSet;
            end
            obj.ConfigsetParameters.origGenCodeOnly=get_param(obj.ActiveConfigset,'GenCodeOnly');
            obj.ConfigsetParameters.origForceBuild=get_param(obj.ActiveConfigset,'UpdateModelReferenceTargets');
            set_param(obj.ActiveConfigset,'GenCodeOnly','on');
            set_param(obj.ActiveConfigset,'UpdateModelReferenceTargets','Force');
        end

        function restoreDesigns(obj)

            set_param(obj.ActiveConfigset,'GenCodeOnly',obj.ConfigsetParameters.origGenCodeOnly);
            set_param(obj.ActiveConfigset,'UpdateModelReferenceTargets',obj.ConfigsetParameters.origForceBuild);

            for kk=keys(obj.Designs)
                mdl=obj.Designs(kk{1});
                set_param(mdl.name,'OpCountCollection',mdl.prevOpCountCollection);
                set_param(mdl.name,'Dirty',mdl.prevDirty);
            end

            currLoadedMdl=get_param(Simulink.allBlockDiagrams(),'Name');
            newLoadedMdl=setdiff(currLoadedMdl,obj.LoadedDesigns);
            if~isempty(newLoadedMdl)
                close_system(newLoadedMdl);
            end
        end
    end
end
