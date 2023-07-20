classdef ParameterSelectionDialog<systemcomposer.internal.mixin.ModelClose&...
    systemcomposer.internal.mixin.CenterDialog&...
    systemcomposer.internal.mixin.BlockDelete



    properties(Access=private)
SourceComponent
SourceComponentWrapper
SelectionMode
        SelectedParameters={};
        DisplayedParamNames={};
    end


    methods
        function this=ParameterSelectionDialog(comp,selectionMode)
            this.SourceComponent=comp;
            this.SourceComponentWrapper=systemcomposer.internal.getWrapperForImpl(comp);
            this.SelectionMode=selectionMode;
        end

        function schema=getDialogSchema(this)


            paramNames=this.SourceComponent.getParameterNames;

            if strcmpi(this.SelectionMode,'single')
                if~isempty(paramNames)
                    type='radiobutton';
                    radio.Type=type;
                    radio.Name='';
                    radio.Tag='paramSelection_single_radio';
                    radio.Entries=paramNames;
                    radio.RowSpan=[1,1];
                    radio.ColSpan=[1,1];
                    this.DisplayedParamNames=radio.Entries;
                else
                    errorItem.Type='text';
                    errorItem.Tag='param_default_noparam_error';
                    errorItem.Name=DAStudio.message('SystemArchitecture:PropertyInspector:NoParametersDefined');
                    errorItem.RowSpan=[1,1];
                    errorItem.ColSpan=[1,1];
                end

                dummy.Type='text';
                dummy.Name='';
                dummy.RowSpan=[2,2];
                dummy.ColSpan=[1,1];

                group.Type='group';
                group.Name=DAStudio.message('SystemArchitecture:PropertyInspector:ViewSourceOfParameterTitle');
                if~isempty(paramNames)
                    group.Items={radio,dummy};
                else
                    group.Items={errorItem,dummy};
                end
                group.LayoutGrid=[2,1];
                group.RowStretch=[0,1];
            else
                item={};
                cnt=1;
                row=1;
                for i=1:numel(paramNames)
                    isDefault=this.SourceComponent.isParamValDefault(paramNames{i});
                    if~isDefault
                        item{cnt}.Type='checkbox';
                        item{cnt}.Tag=['paramSelection_',paramNames{i}];
                        item{cnt}.Name=paramNames{i};
                        item{cnt}.RowSpan=[row,row];
                        item{cnt}.ColSpan=[1,1];
                        item{cnt}.Source=this;
                        item{cnt}.ObjectMethod='handleParameterSelection';
                        item{cnt}.MethodArgs={'%dialog','%value','%tag'};
                        item{cnt}.ArgDataTypes={'handle','mxArray','string'};

                        this.DisplayedParamNames{end+1}=item{cnt}.Name;
                        cnt=cnt+1;
                        row=row+1;
                    end
                end

                errorStr='';
                if isempty(item)
                    if isempty(paramNames)
                        errorStr=DAStudio.message('SystemArchitecture:PropertyInspector:NoParametersDefined');
                    else
                        errorStr=DAStudio.message('SystemArchitecture:PropertyInspector:AllDefaultValuesNoReset');
                    end
                end

                errorItem.Type='text';
                errorItem.Tag='param_default_noparam_error';
                errorItem.Name=errorStr;
                errorItem.RowSpan=[row,row];
                errorItem.ColSpan=[1,1];

                group.Type='group';
                group.Name=DAStudio.message('SystemArchitecture:PropertyInspector:ResetParamsTitle');
                group.Items=[item,{errorItem}];
                group.LayoutGrid=[row,1];
                group.RowStretch=[zeros(1,row-1),1];
            end

            schema.DialogTitle='Parameter Selection';
            schema.DialogTag='param_selection_dialog';
            schema.Source=this;
            schema.Items={group};
            schema.CloseMethod='applySelection';
            schema.CloseMethodArgs={'%dialog','%closeaction'};
            schema.CloseMethodArgsDT={'handle','char'};
            schema.StandaloneButtonSet={'Ok'};
        end

        function handleParameterSelection(this,~,val,tag)
            if val
                paramName=strrep(tag,'paramSelection_','');
                this.SelectedParameters{end+1}=paramName;
            end
        end
        function applySelection(this,dlg,varargin)
            if strcmpi(this.SelectionMode,'single')
                if~isempty(this.DisplayedParamNames)

                    selection=dlg.getWidgetValue('paramSelection_single_radio');
                    paramName=this.DisplayedParamNames{selection+1};
                    srcArch=this.SourceComponent;
                    if isa(this.SourceComponent,'systemcomposer.architecture.model.design.BaseComponent')
                        srcArch=this.SourceComponent.getArchitecture;
                    end
                    promotedComp=srcArch.getComponentPromotedFrom(paramName);
                    if~isempty(promotedComp)
                        hilite_system(promotedComp.getQualifiedName);
                    else
                        hilite_system(srcArch.getQualifiedName);
                    end
                end
            else

                for i=1:numel(this.SelectedParameters)
                    this.SourceComponentWrapper.resetParameterToDefault(this.SelectedParameters{i});
                end
            end
        end
    end
end
