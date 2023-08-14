classdef DDSLibraryRow<handle




    properties(Access=private)
        mListController;
        mDDSMdl;
        mDDSMdlTree;
        mDDSMdlNode;
        mData;
        mColumnNames;
        mColumnProperties;
        mDataClass;
        mMdl;
        mRefreshChildren;
    end


    methods(Static,Access=public)
    end


    methods(Access=public)
        function this=DDSLibraryRow(listController,ddsMdl,ddsMdlTree,ddsNode,columnNames)
            this.mData=containers.Map;
            this.mRefreshChildren=true;
            this.mListController=listController;
            this.mDDSMdl=ddsMdl;
            this.mDDSMdlTree=ddsMdlTree;
            this.mDDSMdlNode=ddsNode;
            this.mColumnNames=columnNames;
            this.mColumnProperties=columnNames;
            if~isempty(ddsNode)
                this.mColumnProperties=ddsNode.ColumnValues.toArray;
                if isempty(this.mColumnProperties)

                    this.mColumnProperties={'Name'};
                end
                dataClass=['dds.internal.simulink.ui.internal.',class(this.mDDSMdlNode.Element)];
                this.mDataClass=feval(dataClass,this.mDDSMdl,this.mDDSMdlTree,this.mDDSMdlNode.Element);
            end

        end

        function uuid=getUUID(thisObj)
            uuid=thisObj.mDDSMdlNode.UUID;
        end

        function handled=refresh(thisObj,changeReport)
            handled=false;
            if~isempty(changeReport.Created)||~isempty(changeReport.Destroyed)
                thisObj.refreshChildren();
            end
            for modIdx=1:numel(changeReport.Modified)
                if thisObj.processRefresh(changeReport.Modified(modIdx))
                    handled=true;
                end
            end
        end

        function handled=processRefresh(thisObj,modifiedItem)
            handled=false;
            fwdObj=thisObj.getForwardedObject();
            if isequal(fwdObj.getElement(),modifiedItem.Element)
                thisObj.refreshRow();
                handled=true;
            else

                children=thisObj.mData.values;
                for i=1:numel(children)
                    row=children{i};
                    if row.processRefresh(modifiedItem)
                        handled=true;
                        break;
                    end
                end
            end
        end

        function refreshChildren(thisObj)
            thisObj.mRefreshChildren=true;
            children=thisObj.mData.values;
            for i=1:numel(children)
                row=children{i};
                row.refreshChildren();
            end
        end

        function refreshRow(thisObj)
            thisObj.mListController.updateRow(thisObj);
            if thisObj.mRefreshChildren
                thisObj.mDDSMdlNode.parseNode(thisObj.mDDSMdlNode.Element);
            end
        end

        function dlgStruct=getDialogSchema(thisObj,arg1)
            dlgStruct=thisObj.mDataClass.getDialogSchema(arg1);
        end

        function src=getForwardedObject(thisObj)
            src=thisObj.mDataClass;
        end

        function children=getHierarchicalChildren(thisObj)
            children=[];
            if isempty(thisObj.mData)||thisObj.mRefreshChildren
                if isempty(thisObj.mData)

                    thisObj.mDDSMdlNode.parseNode(thisObj.mDDSMdlNode.Element);
                end
                thisObj.mRefreshChildren=false;
                thisObj.mData=thisObj.buildChildrenRows();
            end
            values=thisObj.mData.values;
            if~isempty(values)
                children=values{1};
                for i=2:numel(values)
                    children(i)=values{i};
                end
            end
        end

        function isHier=isHierarchical(thisObj)
            isHier=true;
        end

        function children=getChildren(thisObj)
            if isempty(thisObj.mData)||thisObj.mRefreshChildren
                thisObj.mRefreshChildren=false;
                thisObj.mData=thisObj.buildChildrenRows();
            end
            values=thisObj.mData.values;
            children=values{1};
            for i=2:numel(values)
                children(i)=values{i};
            end
        end

        function name=getDisplayLabel(thisObj)
            name=thisObj.mDataClass.getDisplayLabel();
        end

        function icon=getDisplayIcon(thisObj)
            icon=thisObj.mDataClass.getDisplayIcon();
        end

        function isValid=isValidProperty(thisObj,columnName)
            propName=thisObj.getPropertyName(columnName);
            if isempty(propName)
                isValid=false;
                return;
            end
            isValid=thisObj.mDataClass.isValidProperty(propName);
        end

        function isReadonly=isReadonlyProperty(thisObj,columnName)
            propName=thisObj.getPropertyName(columnName);
            if isempty(propName)
                isReadonly=true;
                return;
            end
            isReadonly=thisObj.mDataClass.isReadonlyProperty(propName);
        end

        function dataType=getPropDataType(thisObj,columnName)
            propName=thisObj.getPropertyName(columnName);
            dataType=thisObj.mDataClass.getPropDataType(propName);
        end

        function values=getPropAllowedValues(thisObj,columnName)
            propName=thisObj.getPropertyName(columnName);
            values=thisObj.mDataClass.getPropAllowedValues(propName);
        end

        function propVal=getPropValue(thisObj,columnName)
            propName=thisObj.getPropertyName(columnName);
            propVal=thisObj.mDataClass.getPropDisplayValue(propName);
        end

        function setPropValue(thisObj,columnName,propVal)
            propName=thisObj.getPropertyName(columnName);
            thisObj.mDataClass.setPropValue(propName,propVal);
        end

        function addSection(thisObj)
            src=thisObj.getForwardedObject();
            if ismethod(src,'addSection')
                src.addSection();
            end
        end

        function addObject(thisObj,type)
            src=thisObj.getForwardedObject();
            if ismethod(src,'addObject')
                src.addObject(type);
            end
        end

        function duplicate(thisObj)
            src=thisObj.getForwardedObject();
            src.duplicate();
        end

        function typeChain=getTypeChain(thisObj)
            typeChain=thisObj.mDataClass.getTypeChain();
        end
    end


    methods(Access=private)

        function children=buildChildrenRows(thisObj)
            children=containers.Map;

            if isempty(thisObj.mDDSMdlNode)
                return;
            end
            numChildren=thisObj.mDDSMdlNode.Children.Size();
            if numChildren<1
                return;
            end
            for idx=1:numChildren
                if thisObj.mData.isKey(thisObj.mDDSMdlNode.Children(idx).UUID)
                    children(thisObj.mDDSMdlNode.Children(idx).UUID)=thisObj.mData(thisObj.mDDSMdlNode.Children(idx).UUID);
                else
                    try
                        child=dds.internal.simulink.ui.internal.DDSLibraryRow(thisObj.mListController,...
                        thisObj.mDDSMdl,...
                        thisObj.mDDSMdlTree,...
                        thisObj.mDDSMdlNode.Children(idx),...
                        thisObj.mColumnNames);
                    catch E
                        child='';
                        if slfeature('DDSUI')>3
                            disp(E.message);
                        end
                    end
                    if~isempty(child)
                        children(thisObj.mDDSMdlNode.Children(idx).UUID)=child;
                    end
                end
            end
        end

        function propName=getPropertyName(thisObj,columnName)
            propName='';
            colIdx=find(ismember(thisObj.mColumnNames(1,:),columnName));
            if colIdx>0&&(numel(thisObj.mColumnProperties)>=colIdx)
                propName=thisObj.mColumnProperties{colIdx};
            end
        end

    end
end
