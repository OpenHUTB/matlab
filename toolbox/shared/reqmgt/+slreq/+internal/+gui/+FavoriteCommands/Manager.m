


classdef Manager<dig.FavoriteCommands.Manager
    properties(Access='protected')
        DefaultGalleryCategory;
    end

    properties(Constant)
        ConfigName='slreqEditor';
        PrefFile='requirementsfavoriteprefs.txt';
        QABClassName='slreq.internal.gui.EditorQABManager';
        CommandEditorHelpArgs={fullfile(docroot,'slrequirements','helptargets.map'),'slreqFavoriteCommands'};

        Namespace='simulinkFavoriteCommandsGalleryPopup';
        RefreshEvent='FavoriteCommandsRefresh';
        CustomRefreshEvent='CustomFavoriteCommandsRefresh';
        DefaultCategory=struct(...
        'label',DAStudio.message('simulink_ui:studio:resources:simulinkFavoriteCommandsDefaultCategoryLabel'),...
        'tag','simulinkFavoriteCommandsGalleryCategory_0'...
        );
    end

    methods(Static)
        function ret=get()
            ret=dig.FavoriteCommands.Manager.get('slreq.internal.gui.FavoriteCommands.Manager');
        end
    end

    methods
        function this=Manager()
            this.restorePreferences();
        end

        function delete(this)
            this.savePreferences(this.getPrefFile());
        end
    end

    methods(Access='protected')
        function widget=createGalleryPopup(this)
            widget=dig.GeneratedWidget(this.Namespace,'EditableGalleryPopup');
            widget.Widget.FooterName='simulinkFavoriteCommandsGalleryPopupFooter';
            widget.Widget.FavoritesEnabled=false;
            widget.Widget.ReorderCategory=true;
            widget.Widget.DisplayState='list_view';
            widget.Widget.ListViewDisplayDensity='compact';
            widget.Widget.ActionId='simulinkEditFavoriteCommandAction';
            widget.Widget.QabEligible=false;
        end


        function setDefaultIcons(this)
            iconDir=[matlabroot,'/toolbox/shared/reqmgt/editorPlugin/resources/icons/favorites/'];

            this.DefaultIcons={...
            SampleActionBuilder(DAStudio.message('Slvnv:slreq:slreqFavoriteCommandIconFavoriteText'),[iconDir,'favoriteCommand_16.png'],'favorite_command'),...
            SampleActionBuilder(DAStudio.message('Slvnv:slreq:slreqFavoriteCommandIconMATLABText'),[iconDir,'matlabFavorite_16.png'],'matlab_favorite'),...
            SampleActionBuilder(DAStudio.message('Slvnv:slreq:slreqFavoriteCommandIconSimulinkText'),[iconDir,'requirementsFavorite_16.png'],'simulink_favorite'),...
            SampleActionBuilder(DAStudio.message('Slvnv:slreq:slreqFavoriteCommandIconHelpText'),[iconDir,'helpFavorite_16.png'],'help_favorite'),...
            };

            this.SpecifyCustomIcon=SampleActionBuilder(DAStudio.message('Slvnv:slreq:slreqFavoriteCommandIconCustomText'),[iconDir,'favoriteCategory_16.png'],'custom');
        end
    end
end
