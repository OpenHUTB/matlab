classdef AppWidgetFactory





    methods(Static)
        function appContainer=createAppContainer(appOptions)
            appOptions.CleanStart=true;

            appOptions.ShowSingleDocumentTab=false;
            appOptions.DocumentPlaceHolderText="";
            appOptions.OfferDocumentMaximizeButton=false;

            appContainer=matlab.ui.container.internal.AppContainer(appOptions);
        end

        function tab=createToolstripTab(parent,tabOptions)
            tabGroupTag=[tabOptions.Tag,'_TABGROUP'];
            tabGroup=parent.getTabGroup(tabGroupTag);
            if isempty(tabGroup)
                tabGroup=matlab.ui.internal.toolstrip.TabGroup();
                tabGroup.Tag=tabGroupTag;
                parent.add(tabGroup);
            end
            tab=matlab.ui.internal.toolstrip.Tab(tabOptions.Title);
            tab.Tag=tabOptions.Tag;
            tabGroup.add(tab);
        end

        function section=createToolstripSection(parent,sectionOptions)
            section=parent.addSection(sectionOptions.Title);
        end

        function button=createToolstripButton(parent,buttonOptions)
            column=parent.addColumn();
            button=matlab.ui.internal.toolstrip.Button(buttonOptions.Title);
            supportedOptions={'ButtonPushedFcn','Description','Enabled','Icon','Tag'};
            for i=1:numel(supportedOptions)
                if isfield(buttonOptions,supportedOptions{i})
                    button.(supportedOptions{i})=buttonOptions.(supportedOptions{i});
                end
            end
            column.add(button);
        end

        function panel=createFigurePanel(parent,panelOptions)
            panel=matlab.ui.internal.FigurePanel(panelOptions);
            parent.add(panel);
        end

        function docGroup=createFigureDocumentGroup(parent,docOptions)
            docGroup=matlab.ui.internal.FigureDocumentGroup(docOptions);
            parent.add(docGroup);
        end

        function doc=createFigureDocument(parent,docOptions)
            doc=matlab.ui.internal.FigureDocument(docOptions);
            parent.add(doc);
        end

        function helpButton=createQABHelpButton(appContainer)
            helpButton=matlab.ui.internal.toolstrip.qab.QABHelpButton();
            appContainer.add(helpButton);
        end

        function out=createBrowserGrid(parent)
            gridOptions.RowHeight={'1x'};
            gridOptions.ColumnWidth={'1x'};
            gridOptions.Padding=0;
            gridOptions.BackgroundColor='w';
            out=codertarget.peripherals.UIComponentFactory.createGridLayout(parent,gridOptions);
        end

        function tree=createTree(parent,treeOptions)
            tree=uitree(parent,treeOptions);
        end

        function node=createTreeNode(parent,nodeOptions)
            node=uitreenode(parent,nodeOptions);
        end

        function out=createTasksGrid(parent)
            gridOptions.RowHeight={'fit'};
            gridOptions.ColumnWidth={'fit'};
            gridOptions.BackgroundColor='w';
            gridOptions.Scrollable='on';
            out=codertarget.peripherals.UIComponentFactory.createGridLayout(parent,gridOptions);
        end

        function out=createTasksTable(parent,tableOptions)
            tableOptions.ColumnName={'Task','Event'};
            tableOptions.ColumnEditable=[false,true];
            tableOptions.RowName='';
            tableOptions.RowStriping='off';
            out=codertarget.peripherals.UIComponentFactory.createTable(parent,tableOptions);
        end

        function out=createPeripheralGrid(parent)
            gridOptions.RowHeight={};
            gridOptions.ColumnWidth={'fit','fit'};
            gridOptions.BackgroundColor='w';
            gridOptions.Scrollable='on';
            out=codertarget.peripherals.UIComponentFactory.createGridLayout(parent,gridOptions);
        end

        function out=createParameterWidget(parent,widgetOptions)
            parent.RowHeight{end+1}='fit';


            switch(widgetOptions.Type)
            case 'combobox'
                out(1)=codertarget.peripherals.UIComponentFactory.createLabel(parent,widgetOptions);
                out(2)=codertarget.peripherals.UIComponentFactory.createDropdown(parent,widgetOptions);
            case 'edit'
                out(1)=codertarget.peripherals.UIComponentFactory.createLabel(parent,widgetOptions);
                out(2)=codertarget.peripherals.UIComponentFactory.createEditText(parent,widgetOptions);
            case 'checkbox'
                widgetOptions.Column=[1,2];
                out=codertarget.peripherals.UIComponentFactory.createCheckbox(parent,widgetOptions);
            end
        end

        function out=createParameterTabGroup(parent,tabGroupOptions)
            out=uitabgroup(parent,tabGroupOptions);
            parent.RowHeight{out.Layout.Row}='1x';
            parent.Padding=0;
            out.Layout.Column=[1,3];
        end

        function out=createParameterTab(parent,tabOptions)

            out=uitab(parent,tabOptions);
        end

        function out=createParameterGrid(parent)
            gridOptions.RowHeight={};
            gridOptions.ColumnWidth={'fit','fit'};
            gridOptions.BackgroundColor='w';
            if isequal(parent.Type,'uitab')
                gridOptions.Scrollable='on';
            end
            out=codertarget.peripherals.UIComponentFactory.createGridLayout(parent,gridOptions);
        end

        function[group,grid]=createParameterGroup(parent,groupOptions)




            switch(groupOptions.Type)
            case 'panel'

                panel=codertarget.peripherals.UIComponentFactory.createPanel(parent,groupOptions);
                panel.Layout.Column=[1,2];
                panel.Visible=false;


                gridOptions.RowHeight={};
                gridOptions.ColumnWidth={'fit','fit'};
                gridOptions.BackgroundColor='w';

                grid=codertarget.peripherals.UIComponentFactory.createGridLayout(panel,gridOptions);
                group=panel;
            case 'collapsiblepanel'
                accordian=codertarget.peripherals.UIComponentFactory.createAccordian(parent);
                accordian.Layout.Column=[1,2];
                accordian.Visible=false;

                accordianPanel=codertarget.peripherals.UIComponentFactory.createAccordianPanel(accordian,groupOptions);

                gridOptions.RowHeight={};
                gridOptions.ColumnWidth={'fit','fit'};
                gridOptions.BackgroundColor='w';

                grid=codertarget.peripherals.UIComponentFactory.createGridLayout(accordianPanel,gridOptions);
                group=accordian;
            end
        end

    end

end