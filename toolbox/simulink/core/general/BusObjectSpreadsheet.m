


classdef BusObjectSpreadsheet<handle

    properties
        m_SelectedBusElement;
        m_BusObject;
        m_Data;
        m_cachedDataSource;
        m_BusObjectName;
m_isSlidStructureType
    end

    methods

        function obj=BusObjectSpreadsheet(dialogSource,cachedDataSource,busObjectName,isSlidStructureType)

            obj.m_BusObject=dialogSource;

            obj.m_SelectedBusElement=1;
            obj.m_Data=[];
            obj.m_cachedDataSource=cachedDataSource;

            obj.m_BusObjectName=busObjectName;
            obj.m_isSlidStructureType=isSlidStructureType;

        end



        function children=getChildren(obj)
            children=BusObjectSpreadsheetrow.empty;
            dlgs=DAStudio.ToolRoot.getOpenDialogs.find('dialogTag','BusObjectDialog');
            dlg={};


            for i=numel(dlgs):-1:1
                if isequal(obj,dlgs(i).getWidgetSource('BusObjectSpreadsheet'))
                    dlg=dlgs(i);
                    break;
                end
            end
            if~isempty(dlg)
                if dlg.getUserData('BusObjectSpreadsheet')


                    DialogState=dlg.getUserData('MoveElementUpBtn');
                    tempBusObject=DialogState.tempBusObject;


                    dlg.setUserData('BusObjectSpreadsheet',false);
                else
                    tempBusObject=obj.m_BusObject;
                end
            else


                tempBusObject=obj.m_BusObject;
            end
            count=numel(tempBusObject.Elements);

            for i=1:count


                children(i)=BusObjectSpreadsheetrow(obj,tempBusObject,i,obj.m_SelectedBusElement,...
                obj.m_cachedDataSource,obj.m_BusObjectName,obj.m_isSlidStructureType);
            end

            obj.m_Data=children;
            children=obj.m_Data;



            if~isempty(dlg)


                selectionData=dlg.getUserData('MoveElementDownBtn');

                if isempty(selectionData)
                    return;
                end

                selRows=selectionData.selectedRows;






                if(any(selRows>numel(children)))
                    if isempty(children)
                        selRows=[];
                    else
                        selRows=numel(children);
                    end
                end

                arrayOfSelectedChildren=children(selRows);
                selectionData.selData=num2cell(arrayOfSelectedChildren);



                dlg.setUserData('MoveElementDownBtn',selectionData);
            end
        end
    end
end