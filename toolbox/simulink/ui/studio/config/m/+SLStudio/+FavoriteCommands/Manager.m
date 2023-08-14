

classdef Manager<dig.FavoriteCommands.Manager
    properties(Access='protected')
        DefaultGalleryCategory;
    end

    properties(Constant)
        ConfigName='sl_toolstrip_plugins';
        PrefFile='slfavoriteprefs.txt';
        CommandEditorHelpArgs={'simulink','SimulinkFavoriteCommandEditor'};
        Namespace='simulinkFavoriteCommandsGalleryPopup';
        RefreshEvent='FavoriteCommandsRefresh';
        DefaultCategory=struct(...
        'label',DAStudio.message('simulink_ui:studio:resources:simulinkFavoriteCommandsDefaultCategoryLabel'),...
        'tag','simulinkFavoriteCommandsGalleryCategory_0'...
        );
        QABClassName='SLStudio.QABManager';
        SubclassName='SLStudio.FavoriteCommands.Manager';
        GalleryStateName='simulinkFavoriteCommandsGalleryPopup';
    end

    methods(Static)
        function obj=get()
            obj=dig.FavoriteCommands.Manager.get('SLStudio.FavoriteCommands.Manager');
        end
    end

    methods
        function this=Manager()
            this.restorePreferences();
        end

        function mergePreferences(this,prefFilePath)
            prefs=this.readPreferences(prefFilePath);

            if isempty(prefs.categories)

                return;
            end

            for i=1:length(prefs.categories)
                category=prefs.categories{i};

                if~isequal(category.tag,this.DefaultCategory.tag)

                    existingCategory=this.findByProperty(this.Categories,'label',prefs.categories{i}.label);
                else
                    existingCategory=this.findByTag(this.Categories,this.DefaultCategory.tag);
                end

                if isempty(existingCategory)

                    newIdx=length(this.Categories)+1;
                    this.Categories{newIdx}=category;
                    this.Categories{newIdx}.tag=this.generateCategoryTag(this.generateId());
                    existingCategory=this.Categories{newIdx};

                end

                commands=this.filterByProperty(prefs.commands,'category',category.tag);
                for j=1:length(commands)
                    commands{j}.category=existingCategory.tag;
                    commands{j}.addToQAB=false;
                    commands{j}.tag=this.generateCommandTag(this.generateId());
                    this.Commands{end+1}=commands{j};

                end
            end


            this.CustomIcons=this.mergeByProperty('Tag',this.CustomIcons,prefs.icons);


            this.savePreferences(this.getPrefFile());
            this.reset();
            this.createQABWidgets();
        end

        function clearSavedPrefs(this)
            clearSavedPrefs@dig.FavoriteCommands.Manager(this);
            this.clearGalleryStates();
        end

        function delete(this)
            this.savePreferences(this.getPrefFile());
        end

        function reorderCategoriesByGalleryState(this)
            model=dig.config.Model.getOrCreate(this.ConfigName);
            tsPrefs=model.Preferences.getOrCreateToolstripPrefs();
            galleryState=tsPrefs.getGalleryStateByName(this.GalleryStateName);
            galleryStateCategories=galleryState.getPropertyValue('Categories');

            if(~isempty(galleryStateCategories))

                len=length(this.Categories);
                indices=[];
                for i=1:galleryStateCategories.Size
                    gsCat=galleryStateCategories(i);
                    tag=gsCat{1};
                    [~,idx]=this.findCategoryByTag(tag);
                    if(idx>0)
                        indices=[indices,idx];
                    end
                end

                if(~isempty(indices))
                    reordered=this.Categories(indices);
                    if(len>length(galleryStateCategories))
                        extraCats=this.Categories(setdiff(1:len,indices));
                        reordered=[reordered,extraCats];
                    end

                    this.Categories=reordered;
                end
            end
        end

        function savePreferences(this,prefFilePath)
            this.reorderCategoriesByGalleryState();
            savePreferences@dig.FavoriteCommands.Manager(this,prefFilePath);
        end
    end

    methods(Access='private')
        function clearGalleryStates(this)
            model=dig.config.Model.getOrCreate(this.ConfigName);
            tsPrefs=model.Preferences.getOrCreateToolstripPrefs();
            tsPrefs.clearGalleryState(this.GalleryStateName);
        end
    end
end
