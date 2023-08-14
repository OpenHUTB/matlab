classdef VariableGroupNamesSSRow<handle




    properties
        GroupName;

        IsSelected(1,1)logical=true;

        VariableGroupNamesSrc slvariants.internal.manager.ui.vargrps.VariableGroupNamesSSSource;

        VariableGroupsSrc slvariants.internal.manager.ui.vargrps.VarGroupControlVariableSSSource;

        Next slvariants.internal.manager.ui.vargrps.VariableGroupNamesSSRow;

        Prev slvariants.internal.manager.ui.vargrps.VariableGroupNamesSSRow;
    end

    methods(Hidden)
        function obj=VariableGroupNamesSSRow(name,varGroupNamesSrc)
            if nargin==0
                return;
            end
            obj.GroupName=name;
            obj.VariableGroupNamesSrc=varGroupNamesSrc;
            obj.VariableGroupsSrc=slvariants.internal.manager.ui.vargrps.VarGroupControlVariableSSSource(obj);
        end

        function val=getPropValue(obj,propName)
            val='';
            if isempty(obj.GroupName)
                return;
            end
            switch propName
            case slvariants.internal.manager.ui.config.VMgrConstants.VariableGroupTitle
                val=obj.GroupName;
            case slvariants.internal.manager.ui.config.VMgrConstants.SelectCol
                val=num2str(obj.IsSelected);
            end
        end

        function propType=getPropDataType(~,propName)
            propType='string';
            if~strcmp(propName,slvariants.internal.manager.ui.config.VMgrConstants.SelectCol)
                return;
            end
            propType='bool';
        end

        function iconFile=getDisplayIcon(obj)
            iconFile='';
            if~isempty(obj.GroupName)
                return;
            end
            iconFile=slvariants.internal.manager.ui.config.VMgrConstants.AddRowIcon;
        end

        function getPropertyStyle(obj,propName,propStyle)
            if isempty(obj.GroupName)
                return;
            end
            switch propName
            case 'X'

                propStyle.BackgroundColor=[0.95,0.95,0.95];
                propStyle.Icon=slvariants.internal.manager.ui.config.VMgrConstants.DeleteRowIcon;
                propStyle.IconAlignment='left';
            case 'C'

                propStyle.Icon=slvariants.internal.manager.ui.config.VMgrConstants.CopyRowIcon;
                propStyle.IconAlignment='left';
            end
        end

        function setPropValue(obj,propName,val)
            switch propName
            case slvariants.internal.manager.ui.config.VMgrConstants.VariableGroupTitle


                isExistingGrpName=any(ismember({obj.VariableGroupNamesSrc.Children.GroupName},val));
                if~isvarname(val)||isExistingGrpName

                    slvariants.internal.manager.ui.util.createErrorDialog(...
                    val,'Simulink:VariantManagerUI:VariantReducerInvalidGroupName');
                    return;
                end

                obj.GroupName=val;



                dlg=slvariants.internal.manager.ui.vargrps.getVariableGroupDialog(obj.VariableGroupNamesSrc.ModelName);
                slvariants.internal.manager.ui.vargrps.VariableGroupsDialogSchema.modifyGroupNameText(obj,dlg);
            case slvariants.internal.manager.ui.config.VMgrConstants.SelectCol
                obj.IsSelected=str2double(val);

                slvariants.internal.manager.ui.callRefresherForReduceAnalyseBtn(obj.VariableGroupNamesSrc.ModelName);
            end

        end

        function flag=isEditableProperty(obj,~)
            flag=~isempty(obj.GroupName);
        end

        function flag=isValidProperty(~,propName)
            flag=ismember(propName,{slvariants.internal.manager.ui.config.VMgrConstants.VariableGroupTitle...
            ,slvariants.internal.manager.ui.config.VMgrConstants.SelectCol});
        end

        function flag=isReadonlyProperty(obj,~)
            flag=isempty(obj.GroupName);
        end

        function insertAfter(obj,rowBefore,dlg)
            if isempty(rowBefore)


                obj.VariableGroupNamesSrc.RootRow=obj;

                dlg.setVisible('varGrpSS',true);
                dlg.setVisible('grpNameLabelTag',true);
                return;
            end
            next=rowBefore.Next;
            rowBefore.Next=obj;
            obj.Prev=rowBefore;
            if isempty(next)
                obj.Next=slvariants.internal.manager.ui.vargrps.VariableGroupNamesSSRow.empty;
                return;
            end
            obj.Next=next;
            next.Prev=obj;
        end

        function removeRow(obj,dlg)

            import slvariants.internal.manager.ui.vargrps.VariableGroupNamesSSRow;

            if isempty(obj)
                return;
            end

            prevRow=obj.Prev;
            nextRow=obj.Next;

            if~isempty(prevRow)
                prevRow.Next=nextRow;
            end

            if~isempty(nextRow)
                nextRow.Prev=prevRow;
            end

            if~isempty(nextRow)&&isempty(prevRow)
                nextRow.VariableGroupNamesSrc.RootRow=nextRow;
            end

            if isempty(nextRow)&&isempty(prevRow)
                obj.VariableGroupNamesSrc.RootRow=VariableGroupNamesSSRow.empty;


                dlg.setVisible('varGrpSS',false);
                dlg.setVisible('grpNameLabelTag',false);
            end

            obj.Next=VariableGroupNamesSSRow.empty;
            obj.Prev=VariableGroupNamesSSRow.empty;
        end

        function newObj=deepCopy(obj,newGrpName)
            newObj=slvariants.internal.manager.ui.vargrps.VariableGroupNamesSSRow;

            newObj.GroupName=newGrpName;
            newObj.IsSelected=obj.IsSelected;
            newObj.VariableGroupNamesSrc=obj.VariableGroupNamesSrc;
            newObj.VariableGroupsSrc=obj.VariableGroupsSrc.deepCopy(newObj);
        end

        function mdlName=getModelName(obj)
            mdlName=obj.VariableGroupNamesSrc.ModelName;
        end
    end

    methods(Static,Hidden)

        function variableGroupNameClicked(~,item,~,dlg)
            currNameRow=item{1};
            slvariants.internal.manager.ui.vargrps.VariableGroupsDialogSchema.modifyGroupNameText(currNameRow,dlg);
            currNameRow.switchVarGroupControlVariableSSSource(currNameRow,dlg);
        end

        function deleteVarGrpCB(dlg)
            varGrpNamesSS=dlg.getWidgetInterface('varGrpNamesSS');
            selectedRows=varGrpNamesSS.getSelection();
            if isempty(selectedRows)
                return;
            end
            currNameRow=selectedRows{1};

            nextRow=currNameRow.Next;
            if isempty(currNameRow.Prev)&&isempty(nextRow)
                slvariants.internal.manager.ui.callRefresherForReduceAnalyseBtn(currNameRow.VariableGroupNamesSrc.ModelName);
            end

            currNameRow.removeRow(dlg);

            if~isempty(nextRow)
                varGrpDlgSchema=dlg.getSource();
                varGrpDlgSchema.modifyGroupNameText(nextRow,dlg);
                varGrpNamesSS.select(nextRow);
                nextRow.switchVarGroupControlVariableSSSource(nextRow,dlg);
            end
            varGrpNamesSS.update(true);
        end

        function copyVarGrpCB(dlg)
            varGrpNamesSS=dlg.getWidgetInterface('varGrpNamesSS');
            selectedRows=varGrpNamesSS.getSelection();
            if isempty(selectedRows)
                return;
            end
            currNameRow=selectedRows{1};

            varGrpDlgSchema=dlg.getSource();
            allNameRows=varGrpDlgSchema.VarGrpNamesSSSrc.getChildren([]);
            varGrpNames={allNameRows.GroupName};
            newGrpName=matlab.lang.makeUniqueStrings(currNameRow.GroupName,varGrpNames);
            newNameRow=currNameRow.deepCopy(newGrpName);
            newNameRow.insertAfter(currNameRow,dlg);
            varGrpDlgSchema.modifyGroupNameText(newNameRow,dlg);
            varGrpNamesSS.select(newNameRow);
            newNameRow.switchVarGroupControlVariableSSSource(newNameRow,dlg);
            varGrpNamesSS.update(true);
        end

        function addVarGrpCB(dlg)
            import slvariants.internal.manager.ui.config.VMgrConstants;
            import slvariants.internal.manager.ui.vargrps.VariableGroupNamesSSRow;

            varGrpDlgSchema=dlg.getSource();
            allNameRows=varGrpDlgSchema.VarGrpNamesSSSrc.getChildren([]);
            newGrpName=matlab.lang.makeUniqueStrings(...
            VMgrConstants.DefaultGroupName,{allNameRows.GroupName});

            newNameRow=VariableGroupNamesSSRow(newGrpName,varGrpDlgSchema.VarGrpNamesSSSrc);

            lastRow=slvariants.internal.manager.ui.vargrps.VariableGroupNamesSSRow.empty;
            if~isempty(varGrpDlgSchema.VarGrpNamesSSSrc.Children)
                lastRow=varGrpDlgSchema.VarGrpNamesSSSrc.Children(end);
            end
            newNameRow.insertAfter(lastRow,dlg);
            varGrpDlgSchema.modifyGroupNameText(newNameRow,dlg);
            varGrpNamesSS=dlg.getWidgetInterface('varGrpNamesSS');
            varGrpNamesSS.select(newNameRow);
            newNameRow.switchVarGroupControlVariableSSSource(newNameRow,dlg);
            varGrpNamesSS.update(true);


            slvariants.internal.manager.ui.callRefresherForReduceAnalyseBtn(varGrpDlgSchema.VarGrpNamesSSSrc.ModelName);
        end

        function switchVarGroupControlVariableSSSource(currNameRow,dlg)
            varGrpSS=dlg.getWidgetInterface('varGrpSS');
            varGrpSS.setSource(currNameRow.VariableGroupsSrc);
            varGrpSS.update(true);
        end

        function dummyOut=varGrpSelectionChanged(~,sels,dlg,~)

            dummyOut=true;
            if numel(sels)==1
                dlg.setEnabled('deleteVarGrpButtonTag',true);
                dlg.setEnabled('copyVarGrpButtonTag',true);
            else

                dlg.setEnabled('deleteVarGrpButtonTag',false);
                dlg.setEnabled('copyVarGrpButtonTag',false);
            end
        end
    end
end


