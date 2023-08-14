classdef HasPropertySheets<matlabshared.application.HasPropertySheets
    properties(Access=protected)
        SheetHeightChangedListener;
        LabelWidth;
    end

    methods
        function update(this,spec)
            update@matlabshared.application.HasPropertySheets(this,spec);
            if isempty(spec)
                enab='off';
                string='';
            else
                enab=matlabshared.application.logicalToOnOff(this.Enabled);
                string=spec.Name;
            end

            set(this.hName,'Enable',enab,'String',string);
        end
    end

    methods(Access=protected)
        function onPropertySheetChanged(this,oldSheet)
            sheet=this.CurrentPropertySheet;
            if~isempty(sheet)&&~isequal(oldSheet,sheet)
                layout=this.Layout;




                row=getPropertySheetRow(this);
                if~isempty(oldSheet)&&contains(layout,oldSheet.Panel)
                    layout.remove(row,1);
                end
                this.SheetHeightChangedListener=event.listener(sheet,'HeightChanged',@this.onSheetHeightChanged);
                layout.add(sheet.Panel,row,[1,size(layout.Grid,2)],...
                'Fill','Both','MinimumHeight',getMinimumHeight(sheet),...
                'RightInset',getRightInset(sheet),...
                'LeftInset',getLeftInset(sheet),...
                'TopInset',getTopInset(sheet));
                labelRow=getFirstLabelRow(this);
                if~isempty(labelRow)
                    for row=labelRow:getLastLabelRow(this)
                        layout.setConstraints(row,1,'MinimumWidth',max(this.LabelWidth,getLabelMinimumWidth(sheet)-3));
                    end
                end


                if~useAppContainer(this.Application)
                    uistack(this.hDelete,'bottom');
                end
            end
        end
    end

    methods(Hidden)
        function onSheetHeightChanged(this,~,~)
            this.Layout.setConstraints(getPropertySheetRow(this),1,...
            'MinimumHeight',getMinimumHeight(this.CurrentPropertySheet));
        end

        function row=getFirstLabelRow(~)
            row=1;
        end

        function row=getLastLabelRow(this)
            row=getFirstLabelRow(this);
        end
    end
end


