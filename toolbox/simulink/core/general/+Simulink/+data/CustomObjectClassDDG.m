classdef CustomObjectClassDDG<handle






    properties
        Parameter={};
        Signal={};
        LookupTable={};
        parentDlg=[];
        isParentPortOrBlock=0;
        parentObj=[];
    end

    methods
        function schema=getDialogSchema(obj)
            if isequal(1,slfeature('CustomizeClassLists'))
                hText.Name=DAStudio.message('Simulink:dialog:CommonCustomizeClassListsDialogPrompt');
            else
                hText.Name=DAStudio.message('Simulink:dialog:CustomizeClassListsDialogPrompt');
            end
            hText.Tag='headingText';
            hText.Type='text';
            hText.RowSpan=[1,1];
            if isequal(1,slfeature('CustomizeClassLists'))
                hText.ColSpan=[1,3];
            else
                hText.ColSpan=[1,2];
            end

            currParamList=Simulink.data.findValidClasses('Parameter');
            currSignalList=Simulink.data.findValidClasses('Signal');
            if isequal(1,slfeature('CustomizeClassLists'))
                currLookupTableList=Simulink.data.findValidClasses('LookupTable');
            end



            [allClasses,~]=Simulink.data.findValidClasses;
            newParamList=sort(allClasses.Parameter);
            newSignalList=sort(allClasses.Signal);
            newLookupTableList=sort(allClasses.LookupTable(:));

            paramPanel=generateClassSchema(obj,currParamList,newParamList,'Parameter');
            paramPanel.RowSpan=[2,3];
            paramPanel.ColSpan=[1,1];
            if isequal(1,slfeature('CustomizeClassLists'))
                lookupTablePanel=generateClassSchema(obj,currLookupTableList,newLookupTableList,'LookupTable');
                lookupTablePanel.RowSpan=[2,3];
                lookupTablePanel.ColSpan=[2,2];
            end
            signalPanel=generateClassSchema(obj,currSignalList,newSignalList,'Signal');
            signalPanel.RowSpan=[2,3];
            if isequal(1,slfeature('CustomizeClassLists'))
                signalPanel.ColSpan=[3,3];
            else
                signalPanel.ColSpan=[2,2];
            end






            schema.StandaloneButtonSet={'Cancel','Ok'};




            schema.DialogTag='CustomObjectClassDDG';
            schema.DialogTitle=DAStudio.message('Simulink:dialog:CustomizeClassListsDialogTitle');

            if isequal(1,slfeature('CustomizeClassLists'))
                schema.LayoutGrid=[3,3];
                schema.Geometry=[350,350,725,475];
                schema.Items={hText,paramPanel,lookupTablePanel,signalPanel};
            else
                schema.LayoutGrid=[3,2];
                schema.Geometry=[500,500,600,375];
                schema.Items={hText,paramPanel,signalPanel};
            end

            schema.RowStretch=[0,1,0];
            schema.CloseArgs={'%dialog','%closeaction'};
            schema.CloseCallback='Simulink.data.CustomObjectClassDDG.buttonCB';
        end

        function obj=CustomObjectClassDDG(varargin)
            if nargin==1
                srcObj=varargin{1};
                if isa(srcObj,'Simulink.Port')||isa(srcObj,'Simulink.Block')
                    obj.isParentPortOrBlock=1;
                    obj.parentObj=varargin{1};
                else

                    obj.parentDlg=varargin{1};
                end
            end
        end
    end

    methods(Access=private)
        function objectListPanel=generateClassSchema(obj,oldList,newList,classType)

            slectionStatus=ismember(newList,oldList);
            rowPosition=2;
            dataClsItemList={};

            for i=1:numel(newList)
                dataClsItem.Name=newList{i};
                dataClsItem.Tag=newList{i};
                dataClsItem.Type='checkbox';
                dataClsItem.Graphical=true;
                dataClsItem.Value=slectionStatus(i);
                dataClsItem.RowSpan=[rowPosition,rowPosition];
                rowPosition=rowPosition+1;
                dataClsItem.ColSpan=[1,2];
                dataClsItemList{1,end+1}=dataClsItem;%#ok
            end

            spacer.Type='panel';
            spacer.RowSpan=[1,1];

            obj.(classType)=newList;

            itemGroup.Type='panel';
            itemGroup.Items=dataClsItemList;
            itemGroup.RowSpan=[1,1];
            itemGroup.ColSpan=[1,1];

            objectListPanel.Type='group';
            objectListPanel.Name=[classType,' classes'];
            objectListPanel.LayoutGrid=[2,1];
            objectListPanel.RowStretch=[0,1];
            objectListPanel.Items={itemGroup,spacer};
        end
    end


    methods(Static)
        function buttonCB(dlg,closeaction)
            if strcmpi(closeaction,'ok')
                Simulink.data.CustomObjectClassDDG.saveSelectedList(dlg,'Parameter');
                Simulink.data.CustomObjectClassDDG.saveSelectedList(dlg,'Signal');
                if isequal(1,slfeature('CustomizeClassLists'))
                    Simulink.data.CustomObjectClassDDG.saveSelectedList(dlg,'LookupTable');
                end
            end

            obj=dlg.getDialogSource;
            if~isempty(obj.parentDlg)||obj.isParentPortOrBlock
                if obj.isParentPortOrBlock


                    dlgList=DAStudio.ToolRoot.getOpenDialogs;
                    for i=1:length(dlgList)
                        if isa(obj.parentObj,'Simulink.Port')
                            dlgSrc=dlgList(i).getDialogSource();
                            if isa(dlgSrc,'Simulink.Line')
                                dlgList(i).refresh;
                            elseif isa(dlgSrc,'Simulink.LinePropertiesDDGSource')


                                if(dlgSrc.source.getSourcePort==obj.parentObj)
                                    dlgList(i).refresh;
                                end
                            end
                        else
                            if isa(dlgList(i).getDialogSource(),'Simulink.DDGSource')
                                ddgSource=dlgList(i).getDialogSource();
                                if isfield(ddgSource.state,'StateSignalObjectClass')
                                    dlgList(i).refresh;
                                end
                            end
                        end
                    end
                else

                    Simulink.data.ChangeDefaultClassDDG.onCustomDialogClose(obj.parentDlg);
                end
            end
        end

        function saveSelectedList(dlg,class)
            obj=dlg.getDialogSource;
            selectedList={};
            for i=1:numel(obj.(class))
                tag=obj.(class){i};
                if dlg.getWidgetValue(tag)
                    selectedList{end+1}=tag;%#ok
                end
            end
            if(isempty(selectedList))
                selectedList{end+1}=['Simulink.',class];
            end
            Simulink.data.findValidClasses(class,selectedList);
        end
    end
end
