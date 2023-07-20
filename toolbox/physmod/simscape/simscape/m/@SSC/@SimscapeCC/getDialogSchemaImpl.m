function dlg=getDialogSchemaImpl(this,type)







    ccInfo=this.getSubComponentList;

    properties=SSC.DialogPropertyList(this.getClientProperties(true));
    groups=properties.createPropertyGroups(this);

    items=l_organizeLocalItems(this,groups,type);
    section(1).TabName=ccInfo(1).TabName;
    section(1).TreeName=ccInfo(1).TreeName;
    section(1).Items=items.Items{1};
    section(1).Source=this;
    section(1).Children={};









    if this.ComponentsAttached&&~isempty(this.Components)



        for i=2:length(ccInfo)

            try
                subCC=this.Components(i-1);
                subCCSchema=subCC.getDialogSchema(type);
                section(end+1)=subCCSchema;
            catch
                configData=SimscapeCC_config;
                pm_warning(configData.internal.getDialogSchemaError);
            end
        end

    end



    if~strcmp(type,'stack')


        dlg=l_createTabbedDialog(this,section);

    else


        dlg=l_createStack(this,section);

    end;

    function stack=l_createStack(this,sections)

        stack.List={};
        stack.Ids={};
        stack.Name={};
        stack.Items={};

        idCount=0;
        for idx=1:length(sections)

            stack.List=[stack.List,{sections(idx).TreeName}];
            stack.Ids=[stack.Ids,{idCount}];
            idCount=idCount+1;
            stack.Items=[stack.Items,{sections(idx).Items}];

            childList={};
            childIds={};
            for idxA=1:length(sections(idx).Children)
                child=sections(idx).Children{idxA};
                childList=[childList,{child.TreeName}];
                childIds=[childIds,{idCount}];
                idCount=idCount+1;
                stack.Items=[stack.Items,child.Items];
            end
            if~isempty(childList)
                childList={childList};
                childIds={childIds};
            end
            stack.List=[stack.List,childList];
            stack.Ids=[stack.Ids,childIds];
        end
        stack.Name={[l_getProductName,' stack']};


        function dlg=l_createTabbedDialog(this,sections)
            tabs.Name=[l_getProductName,' tabs'];
            tabs.Type='tab';
            tabs.Tabs={};
            tabs.TabChangedCallback=[class(this),'.tabChangeCallback'];
            tabs.ActiveTab=this.getActiveTab;

            for i=1:length(sections)
                aSection=sections(i);
                contents=l_make_panel(this,aSection.Items);
                aTab.Name=aSection.TabName;
                aTab.Source=aSection.Source;
                aTab.Items={contents.Items};
                aTab.LayoutGrid=contents.LayoutGrid;
                aTab.RowStretch=contents.RowStretch;

                tabs.Tabs={tabs.Tabs{:},aTab};

            end

            panel.Name='Top-level panel';
            panel.Type='panel';
            panel.Items={tabs};

            dlg.DialogTitle=this.getComponentName;

            dlg.Items={panel};
            dlg.LayoutGrid=[2,1];
            dlg.RowStretch=[0,1];





            dlg.HelpMethod='slprivate';
            dlg.HelpArgs={'configHelp','%dialog',this,'',l_getProductName};


            function dlg=l_organizeLocalItems(this,groups,type)





                items={};

                for i=1:length(groups)

                    if(~isempty(groups(i).Description))





                        text.Name=groups(i).Description;
                        text.Type='text';
                        text.ColSpan=[1,1];
                        text.RowSpan=[1,1];
                        text.WordWrap=true;

                        textpanel.Name='';
                        textpanel.Type='panel';
                        textpanel.Items={text};
                        textpanel.LayoutGrid=[2,1];
                        textpanel.RowStretch=[0,1];
                        textpanel.ColSpan=[1,1];
                        textpanel.RowSpan=[1,1];

                        parampanel.Name='';
                        parampanel.Type='panel';
                        parampanel.Items=groups(i).Items;
                        parampanel.LayoutGrid=[length(groups(i).Items)+1,3];
                        parampanel.RowStretch=[zeros(1,length(groups(i).Items)),1];
                        parampanel.RowSpan=[2,2];
                        parampanel.ColSpan=[1,1];

                        group.Name=groups(i).Name;
                        group.Tag=groups(i).Name;
                        group.Type='group';
                        group.Items={textpanel,parampanel};
                        group.LayoutGrid=[3,1];
                        group.RowSpan=[i,i];
                        group.ColSpan=[1,1];
                        group.RowStretch=[0,0,1];
                    else




                        parampanel.Name='';
                        parampanel.Type='panel';
                        parampanel.Items=groups(i).Items;
                        parampanel.LayoutGrid=[length(groups(i).Items)+1,3];
                        parampanel.RowStretch=[zeros(1,length(groups(i).Items)),1];
                        parampanel.RowSpan=[1,1];
                        parampanel.ColSpan=[1,1];

                        group.Name=groups(i).Name;
                        group.Tag=groups(i).Name;
                        group.Type='group';
                        group.Items={parampanel};
                        group.LayoutGrid=[2,1];
                        group.RowSpan=[i,i];
                        group.ColSpan=[1,1];
                        group.RowStretch=[0,1];
                    end

                    items{end+1}=group;
                end

                if isempty(type)
                    dlg=l_make_default(this,items);
                else
                    dlg=l_make_stack(this,items);
                end





                function dlg=l_make_default(this,items)


                    dlg=struct('DialogTitle',{l_getProductName},...
                    'DialogTag',{['Tag_ConfigSet_',l_getProductName,'_Panel']},...
                    'Items',{{l_make_panel(this,items)}},...
                    'LayoutGrid',{[2,1]},...
                    'RowStretch',{[0,1]},...
                    'HelpMethod','slprivate',...
                    'HelpArgs',{{'configHelp','%dialog',this,'',l_getProductName}});


                    function stack=l_make_stack(this,items)


                        stack=struct('Name','PhysicalModeling',...
                        'List',{{l_getProductName}},...
                        'Items',{{l_make_panel(this,items)}},...
                        'Ids',{{0,{1}}});


                        function panel=l_make_panel(this,items)


                            panel=struct('Name',{''},...
                            'Type',{'panel'},...
                            'Tag',{['Tag_ConfigSet_',l_getProductName,'_Panel']},...
                            'Items',{items},...
                            'Source',{this},...
                            'LayoutGrid',{[length(items)+1,2]},...
                            'RowStretch',{[zeros(1,length(items)),1]},...
                            'ColStretch',{[0,1]});

                            function productName=l_getProductName
                                persistent fProductName

                                if isempty(fProductName)
                                    hProductName=ssc_private('ssc_productname');
                                    fProductName=hProductName();
                                end

                                productName=fProductName;










