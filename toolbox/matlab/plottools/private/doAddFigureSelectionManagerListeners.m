function doAddFigureSelectionManagerListeners(fig,selectionManager)






    if~isprop(fig,'PlotSelectionListener')
        p=addprop(fig,'PlotSelectionListener');
        p.Transient=true;
        p.Hidden=true;
    end

    sv=hg2gcv(fig);
    if isempty(fig.PlotSelectionListener)
        fig.PlotSelectionListener=event.listener(sv,'PostUpdate',...
        @(es,ed)localPostUpdate(es,ed,selectionManager,fig));
    end


    function localFigChildAdded(~,ed,selectionManager)



        axesList=handle(findobj(ed.Child,'type','axes'));
        for k=1:length(axesList)
            ax=handle(axesList(k));
            if isa(ax,'axes')
                if~isprop(ax,'PlotSelectionListener')
                    p=schema.prop(ax,'PlotSelectionListener','MATLAB array');
                    p.AccessFlags.Serialize='off';
                    set(p,'Visible','off');
                end

                if isempty(ax.PlotSelectionListener)
                    ax.PlotSelectionListener=handle.listener(ax,'ObjectChildRemoved',...
                    {@localAxesChildRemoved,selectionManager});
                end
            end
        end

        function localAxesChildRemoved(~,ed,selectionManager)


            childbean=java(ed.Child);
            if~isempty(childbean)
                selectionManager.purgeSelectedObjectArray(childbean);
            end

            function localFigChildRemoved(~,ed,selectionManager)

                if isa(ed.Child,'axes')
                    childbeans=java(handle(findobj(ed.Child)));
                    if~isempty(childbeans)
                        selectionManager.purgeSelectedObjectArray(childbeans);
                    end
                end

                function localPostUpdate(~,~,selectionManager,fig)



                    if~isvalid(fig)||...
                        fig.SelectionManager.getSelectedObjects.size==0||...
                        isequal(selectionManager.getSelectedObjects.get(0),java(fig))
                        return
                    end



                    selectedJavaObjects=fig.SelectionManager.getSelectedObjectArray;
                    validSelectedJavaObjects=gobjects(0,1);
                    invalidObjects=false;
                    for k=1:length(selectedJavaObjects)
                        if selectedJavaObjects(k).isValid
                            validSelectedJavaObjects=[validSelectedJavaObjects,handle(selectedJavaObjects(k))];%#ok<AGROW>
                        else
                            invalidObjects=true;
                        end
                    end
                    if invalidObjects
                        fig.SelectionManager.updateSelectedObjectArray(...
                        num2cell(findall(validSelectedJavaObjects,'-function',@(x)isa(x,'matlab.graphics.mixin.Selectable')||...
                        isa(x,'matlab.ui.internal.mixin.Selectable'))));
                    end
