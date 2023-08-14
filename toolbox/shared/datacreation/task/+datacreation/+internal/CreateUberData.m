classdef(Hidden)CreateUberData<livetask.internal.LiveUberTaskBase







    methods(Static)


        function plugins=getDataCreationPlugins()

            aFactory=datacreation.internal.Factory.getInstance();


            aFactory.updateFactoryRegistry();


            plugins=aFactory.getAllContributors();
        end
    end


    properties(Hidden,Constant)
        TaskSelectorMethod='datacreation.internal.ToggleButtonGroup'
        TaskSelectorEventName='ValueChangedFcn'
        PluginGetterMethodName='datacreation.internal.CreateUberData.getDataCreationPlugins'
        DefaultLiveTaskKey=datacreation.plugin.NumericalPlugin.LiveTaskKeyValue;
        TaskSelectionText=message('datacreation:datacreation:selecttypeofdata').getString;
    end


    properties(Access=protected,Constant)
        UIFigureName=message('datacreation:datacreation:ueberdatacreation').getString;
        TaskCategoryKey=message('datacreation:datacreation:taskcategory').getString;

    end


    methods(Access=public)

        function reset(app)
            allContribs=app.Contributors.keys;

            for k=1:length(allContribs)

                kContrib=app.Contributors(allContribs{k});
                kContrib.reset();
            end

            app.TaskSelectorComponent.Value=app.DefaultLiveTaskKey;
            onTaskSelectionChanged(app,app.TaskSelectorComponent,[]);
        end
    end

    methods(Access=protected)




        function setup(app)

            setup@livetask.internal.LiveUberTaskBase(app);


            createContributor(app);
        end
    end


    methods(Hidden)


        function onTaskSelectionChanged(app,~,~)
            app.TaskSelectorComponent.setEnable('off');
            idx=find(strcmp({app.Plugins(:).LiveTaskKeyValue},app.TaskSelectorComponent.Value)==1);

            hideCurrentContributor(app);

            cacheContributor=app.CurrentContributor;


            app.CurrentContributor=app.Plugins(idx).LiveTaskKeyValue;

            try
                createContributor(app);
                appNotifyChanged(app);
            catch ME
                aDlg=errordlg(ME.message,message('datacreation:datacreation:taskerror').getString());
                aDlg.Tag='CreateDataTaskCreateFailed';
                app.CurrentContributor=cacheContributor;
                app.TaskSelectorComponent.Value=cacheContributor;
                onTaskSelectionChanged(app,app.TaskSelectorComponent,[]);
            end
            app.TaskSelectorComponent.setEnable('on');
        end
    end
end
