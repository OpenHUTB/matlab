classdef(Hidden)LiveUberTaskBase<matlab.task.LiveTask








    properties(Hidden,Constant,Abstract)





        TaskSelectorMethod char







        TaskSelectorEventName char




        PluginGetterMethodName char



        DefaultLiveTaskKey char


        TaskSelectionText char
    end

    properties
Summary
State
    end


    properties(Access=public,Transient,Hidden)








TaskSelectorComponent
    end



    properties(Access=public,Transient,Hidden)



        CurrentContributor char





Contributors




TaskChangedListeners


Plugins
    end



    methods


        function summary=get.Summary(app)
            summary=app.getCurrentContributor().generateSummary();
        end


        function state=get.State(app)


            state=app.getCurrentContributor().getState();
            state.TaskSelection=app.TaskSelectorComponent.Value;
            state.CurrentContributor=app.CurrentContributor;
        end


        function set.State(app,state)

            if~strcmp(app.getCurrentPlugin().LiveTaskKeyValue,state.TaskSelection)
                hideCurrentContributor(app);

                app.CurrentContributor=state.CurrentContributor;%#ok<MCSUP>
                app.TaskSelectorComponent.Value=app.CurrentContributor;%#ok<MCSUP>
                createContributor(app);
            end


            app.getCurrentContributor().setState(state);
        end


        function reset(app)
            allContribs=app.Contributors.keys;

            for k=1:length(allContribs)

                kContrib=app.Contributors(allContribs{k});
                kContrib.reset();
            end
        end


        function[code,outputs]=generateCode(app)
            [code,outputs]=generateScript(app);
            visualizationCode=generateVisualizationScript(app);
            if~isempty(visualizationCode)
                code=[code,newline,newline,visualizationCode];
            end
        end

    end


    methods(Access=public)



        function outParent=getParent(app)
            outParent=app.Parent;
        end


        function delete(app)

            remove(app.TaskChangedListeners,keys(app.TaskChangedListeners));


            delete(app.TaskChangedListeners);


            delete@matlab.task.LiveTask(app);

        end



        function[code,outputs]=generateScript(app)
            [code,outputs]=app.getCurrentContributor().generateScript();
        end


        function code=generateVisualizationScript(app)
            code=app.getCurrentContributor().generateVisualizationScript();
        end



        function postExecutionUpdate(app,data)

            try
                app.getCurrentContributor().update(data);
            catch ME_UPDATE
                throwAsCaller(ME_UPDATE);
            end
        end


        function appNotifyChanged(app)

            if~isvalid(app)
                return
            end

            notify(app,'StateChanged');
        end


        function throwChangedEvent(app,~,~)
            appNotifyChanged(app);
        end


        function hideCurrentContributor(app)

            contributor=app.getCurrentContributor();
            contributor.MainGrid.Visible='off';
            contributor.MainGrid.Parent=[];
        end


        function setCurrentContributor(app,contributor)
            app.Contributors(app.CurrentContributor)=contributor;
        end


        function createContributor(app)



            drawnow nocallbacks
            if~isKey(app.Contributors,app.CurrentContributor)
                try

                    activeContributorFcnH=getCurrentPlugin(app).getContributor();
                    app.Contributors(app.CurrentContributor)=activeContributorFcnH(app.LayoutManager);
                    app.TaskChangedListeners(app.CurrentContributor)=...
                    addlistener(app.getCurrentContributor(),'StateChanged',@app.throwChangedEvent);

                catch ME
                    rethrow(ME);
                end
            else

                app.getCurrentContributor().MainGrid.Parent=app.LayoutManager;
                app.getCurrentContributor().MainGrid.Visible='on';
            end
        end
    end



    methods(Hidden)


        function initializePlugins(app)
            app.Plugins=getPlugins(app);
        end


        function initializeContributor(app)
            app.Contributors=containers.Map;
        end


        function initializeCurrentContributor(app)
            app.CurrentContributor=app.DefaultLiveTaskKey;
        end


        function initializeTaskChangedListeners(app)
            app.TaskChangedListeners=containers.Map;
        end

        function updateLayoutManager(app)




            app.LayoutManager.RowHeight={'fit','fit'};
            app.LayoutManager.ColumnWidth={'fit'};
            app.LayoutManager.RowSpacing=0;
        end


        function activeContributor=getCurrentContributor(app)
            activeContributor=app.Contributors(app.CurrentContributor);
        end


        function activePlugin=getCurrentPlugin(app)

            pluginIdx=find(strcmp({app.Plugins(:).LiveTaskKeyValue},app.CurrentContributor)==1);
            activePlugin=app.Plugins(pluginIdx);
        end


        function createTaskSelector(app)

            accordion=matlab.ui.container.internal.Accordion('Parent',app.LayoutManager);
            accordionPanel=matlab.ui.container.internal.AccordionPanel('Parent',accordion);
            accordionPanel.Title=app.TaskSelectionText;

            selectGrid=uigridlayout(accordionPanel,[1,1],...
            'RowHeight',{'fit'},'ColumnWidth',{'fit'});
            fcnH=str2func(app.TaskSelectorMethod);
            app.TaskSelectorComponent=fcnH(selectGrid,...
            app.TaskSelectorEventName,@(o,e)app.onTaskSelectionChanged);

        end


        function onTaskSelectionChanged(app,~,~)
            idx=find(strcmp({app.Plugins(:).LiveTaskKeyValue},app.TaskSelectorComponent.Value)==1);

            hideCurrentContributor(app);


            app.CurrentContributor=app.Plugins(idx).LiveTaskKeyValue;
            createContributor(app);
            appNotifyChanged(app);
        end


        function plugins=getPlugins(app)
            funcH=str2func(app.PluginGetterMethodName);
            plugins=funcH();
        end

    end


    methods(Access=protected)


        function setup(app)

            updateLayoutManager(app);

            initializePlugins(app);
            initializeContributor(app);
            initializeCurrentContributor(app);
            initializeTaskChangedListeners(app);
            createTaskSelector(app);
        end
    end

end
