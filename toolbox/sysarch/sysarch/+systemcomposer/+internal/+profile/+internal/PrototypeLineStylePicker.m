classdef PrototypeLineStylePicker<handle

    properties(Transient)
        Owner;
        OwnerDlg;
    end

    properties(Access=private,Constant)
        InternalGenericLineStyleName={'SolidLine'};
        InternalLineStyleNames={...
        'DotLine',...
        'DashLine',...
        'DashDotLine',...
'DashDotDotLine'
        };

        FileNames={...
        'LineStyleSolid.svg',...
        'LineStyleDot.svg',...
        'LineStyleDash.svg',...
        'LineStyleDashDot.svg',...
'LineStyleDashDotDot.svg'
        };

        IconNames={...
        'LineStyleSolid_16.png',...
        'LineStyleDot_16.png',...
        'LineStyleDash_16.png',...
        'LineStyleDashDot_16.png',...
'LineStyleDashDotDot_16.png'
        };

        InternalStyleNames=horzcat(systemcomposer.internal.profile.internal.PrototypeLineStylePicker.InternalGenericLineStyleName,...
        systemcomposer.internal.profile.internal.PrototypeLineStylePicker.InternalLineStyleNames);

        GenericLineStyleValue=systemcomposer.internal.profile.ConnectorStyle.GENERIC;
        LineStyleValues=[...
        systemcomposer.internal.profile.ConnectorStyle.DOT,...
        systemcomposer.internal.profile.ConnectorStyle.DASH,...
        systemcomposer.internal.profile.ConnectorStyle.DASH_DOT,...
        systemcomposer.internal.profile.ConnectorStyle.DASH_DOT_DOT
        ];

        StyleValues=horzcat(systemcomposer.internal.profile.internal.PrototypeLineStylePicker.GenericLineStyleValue,...
        systemcomposer.internal.profile.internal.PrototypeLineStylePicker.LineStyleValues);
    end

    methods(Static)
        function name=lineStyleEnum2InternalName(enumVal)
            idx=(systemcomposer.internal.profile.internal.PrototypeLineStylePicker.StyleValues==enumVal);
            if~any(idx)
                name=systemcomposer.internal.profile.internal.PrototypeLineStylePicker.InternalStyleNames{1};
            else
                name=systemcomposer.internal.profile.internal.PrototypeLineStylePicker.InternalStyleNames{idx};
            end
        end

        function enumVal=internalName2LineStyleEnum(name)
            idx=strcmpi(systemcomposer.internal.profile.internal.PrototypeLineStylePicker.InternalStyleNames,name);
            if~any(idx)
                enumVal=systemcomposer.internal.profile.ConnectorStyle.SOLID;
            else
                enumVal=systemcomposer.internal.profile.internal.PrototypeLineStylePicker.StyleValues(idx);
            end
        end

        function filePath=lineStyleEnum2FilePath(enumVal)
            idx=(systemcomposer.internal.profile.internal.PrototypeLineStylePicker.StyleValues==enumVal);
            if~any(idx)
                iconName=systemcomposer.internal.profile.internal.PrototypeLineStylePicker.IconNames{1};
            else
                iconName=systemcomposer.internal.profile.internal.PrototypeLineStylePicker.IconNames{idx};
            end
            filePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','ARCHITECTURE',iconName);
        end
    end

    methods
        function obj=PrototypeLineStylePicker(profileEditor,dlg)
            obj.Owner=profileEditor;
            obj.OwnerDlg=dlg;
        end

        function schema=getDialogSchema(this)
            numButtons=length(this.StyleValues);
            numRows=numButtons+1;r=1;
            numCols=1;c=1;
            assert((numRows-1)*numCols>=numButtons);

            label.Type='text';
            label.Name=DAStudio.message('SystemArchitecture:ProfileDesigner:PickALineStyle');
            label.RowSpan=[r,r];
            label.ColSpan=[1,numCols];
            r=r+1;

            items=cell(1,numButtons+1);
            items{1}=label;

            for idx=1:numButtons
                lineStyleName=this.InternalStyleNames{idx};

                lineStyleChoice.Type='pushbutton';
                lineStyleChoice.Tag=['lineStyleButton_',lineStyleName];
                lineStyleChoice.Name='';
                lineStyleChoice.Source=this;
                lineStyleChoice.ObjectMethod='handleSelectLineStyle';
                lineStyleChoice.MethodArgs={'%dialog',lineStyleName};
                lineStyleChoice.ArgDataTypes={'handle','char'};
                lineStyleChoice.DialogRefresh=true;
                lineStyleChoice.RowSpan=[r,r];
                lineStyleChoice.ColSpan=[c,c];
                lineStyleChoice.Enabled=true;
                lineStyleChoice.ToolTip='';
                lineStyleChoice.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio',...
                'resources','ARCHITECTURE',this.FileNames{idx});

                items{idx+1}=lineStyleChoice;
                r=r+1;
            end

            group.Type='group';
            group.Items=items;
            group.LayoutGrid=[numRows,numCols];

            schema.DialogTitle=DAStudio.message('SystemArchitecture:ProfileDesigner:PickALineStyle');
            schema.Items={group};
            schema.DialogTag='system_composer_prototype_linestylepicker';
            schema.Source=this;
            schema.SmartApply=true;
            schema.Transient=true;
            schema.DialogStyle='frameless';
            schema.ExplicitShow=true;
            schema.StandaloneButtonSet={''};
        end

        function handleSelectLineStyle(this,dlg,value)
            lineStyleEnum=systemcomposer.internal.profile.internal.PrototypeLineStylePicker.internalName2LineStyleEnum(value);
            this.Owner.handlePrototypeLineStyleSelected(this.OwnerDlg,lineStyleEnum);
            delete(dlg);
        end
    end
end