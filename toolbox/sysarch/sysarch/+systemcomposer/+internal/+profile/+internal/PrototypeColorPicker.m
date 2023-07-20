classdef PrototypeColorPicker<handle

    properties(Transient)
        Owner;
        OwnerDlg;
    end

    properties(Access=private,Constant)
        ColorNames={
        'Default',...
        'Blue',...
        'Green',...
        'Red',...
        'Orange',...
        'Violet',...
        'Yellow',...
        'Pink',...
        'Purple',...
        };

        PaletteRGBValues=[
        210,210,210;...
        172,221,242;...
        180,215,144;...
        244,172,176;...
        248,165,133;...
        131,164,253;...
        251,214,132;...
        220,133,151;...
        198,147,201;...
        ];

        ColorRGBValues=[
        210,210,210;...
        206,232,246;...
        210,228,184;...
        242,203,205;...
        244,198,177;...
        177,196,252;...
        249,228,177;...
        225,178,187;...
        213,187,220;...
        ];
    end

    methods(Static)
        function RGBValue=colorName2RGBValue(name)
            idx=strcmpi(systemcomposer.internal.profile.internal.PrototypeColorPicker.ColorNames,name);
            if~any(idx)
                RGBValue=systemcomposer.internal.profile.internal.PrototypeColorPicker.ColorRGBValues(1,:);
            else
                RGBValue=systemcomposer.internal.profile.internal.PrototypeColorPicker.ColorRGBValues(idx,:);
            end
        end

        function RGBValue=getPaletteColor(rgbValue)
            idx=ismember(systemcomposer.internal.profile.internal.PrototypeColorPicker.ColorRGBValues,rgbValue,'rows');
            if~any(idx)


                RGBValue=rgbValue;
            else
                RGBValue=systemcomposer.internal.profile.internal.PrototypeColorPicker.PaletteRGBValues(idx,:);
            end
        end
    end

    methods
        function obj=PrototypeColorPicker(profileEditor,dlg)
            obj.Owner=profileEditor;
            obj.OwnerDlg=dlg;
        end

        function schema=getDialogSchema(this)
            numButtons=length(this.PaletteRGBValues);
            numRows=4;r=1;
            numCols=3;c=1;
            assert((numRows-1)*numCols>=numButtons);

            label.Type='text';
            label.Name=DAStudio.message('SystemArchitecture:ProfileDesigner:PickAColor');
            label.RowSpan=[r,r];
            label.ColSpan=[1,numCols];
            r=r+1;

            items=cell(1,numButtons);
            items{1}=label;

            for idx=1:numButtons
                colorName=this.ColorNames{idx};

                colorChoice.Type='pushbutton';
                colorChoice.Tag=['colorButton_',colorName];
                colorChoice.Name='';
                colorChoice.Source=this;
                colorChoice.ObjectMethod='handleSelectColor';
                colorChoice.MethodArgs={'%dialog',colorName};
                colorChoice.ArgDataTypes={'handle','char'};
                colorChoice.DialogRefresh=true;
                colorChoice.RowSpan=[r,r];
                colorChoice.ColSpan=[c,c];
                colorChoice.Enabled=true;
                colorChoice.ToolTip='';
                colorChoice.BackgroundColor=this.PaletteRGBValues(idx,:);

                items{idx+1}=colorChoice;
                c=c+1;
                if c>numCols
                    c=1;
                    r=r+1;
                end
            end

            customColorChoice.Type='pushbutton';
            customColorChoice.Tag='colorButton_Custom';
            customColorChoice.Name=DAStudio.message('SystemArchitecture:ProfileDesigner:Custom');
            customColorChoice.Source=this;
            customColorChoice.ObjectMethod='handleSelectCustomColor';
            customColorChoice.MethodArgs={'%dialog'};
            customColorChoice.ArgDataTypes={'handle'};
            customColorChoice.DialogRefresh=true;
            customColorChoice.RowSpan=[numRows+1,numRows+1];
            customColorChoice.ColSpan=[1,numCols];
            customColorChoice.Enabled=true;
            customColorChoice.ToolTip='';
            customColorChoice.BackgroundColor=[255,255,255];

            group.Type='group';
            group.Items=[items,{customColorChoice}];
            group.LayoutGrid=[numRows+1,numCols];

            schema.DialogTitle=DAStudio.message('SystemArchitecture:ProfileDesigner:PickAColor');
            schema.Items={group};
            schema.DialogTag='system_composer_prototype_colorpicker';
            schema.Source=this;
            schema.SmartApply=true;
            schema.Transient=true;
            schema.DialogStyle='frameless';
            schema.ExplicitShow=true;
            schema.StandaloneButtonSet={''};
        end

        function handleSelectColor(this,dlg,value)
            rgbValue=systemcomposer.internal.profile.internal.PrototypeColorPicker.colorName2RGBValue(value);
            rgbValue=uint32(rgbValue);
            this.Owner.handlePrototypeColorSelected(this.OwnerDlg,rgbValue);
            delete(dlg);
        end

        function handleSelectCustomColor(this,dlg)
            s=settings;
            if(~s.matlab.ui.dialog.uisetcolor.ControllerName.hasTemporaryValue)
                s.matlab.ui.dialog.uisetcolor.ControllerName.TemporaryValue='matlab.ui.internal.dialog.ColorChooser';
                c=onCleanup(@()s.matlab.ui.dialog.uisetcolor.ControllerName.clearTemporaryValue());
            end
            rgbValue=uisetcolor;
            this.OwnerDlg.show;
            if~isequal(rgbValue,0)
                rgbValue=uint32(rgbValue*255);
                this.Owner.handlePrototypeColorSelected(this.OwnerDlg,rgbValue);
            end
            delete(dlg);
        end
    end
end