classdef PrototypeIconPicker<handle

    properties(Transient)
        Owner;
        OwnerDlg;
    end

    properties(Access=private,Constant)
        GenericIconName={'generic'};
        ComponentIconNames={...
        'application',...
        'channel',...
        'controller',...
        'database',...
        'devicedriver',...
        'memory',...
        'network',...
        'plant',...
        'sensor',...
        'subsystem',...
'transmitter'...
        };
        PortIconNames={...
        'angle',...
        'arrow',...
        'chevron',...
        'forward',...
        'trident',...
        };
        CustomIconName={'custom'};
        NoIconName={'NoIcon'};

        IconNames=horzcat(systemcomposer.internal.profile.internal.PrototypeIconPicker.GenericIconName,...
        systemcomposer.internal.profile.internal.PrototypeIconPicker.ComponentIconNames,...
        systemcomposer.internal.profile.internal.PrototypeIconPicker.PortIconNames,...
        systemcomposer.internal.profile.internal.PrototypeIconPicker.CustomIconName);

        GenericIconValue=systemcomposer.internal.profile.PrototypeIcon.GENERIC;
        ComponentIconValues=[...
        systemcomposer.internal.profile.PrototypeIcon.APPLICATION,...
        systemcomposer.internal.profile.PrototypeIcon.CHANNEL,...
        systemcomposer.internal.profile.PrototypeIcon.CONTROLLER,...
        systemcomposer.internal.profile.PrototypeIcon.DATABASE,...
        systemcomposer.internal.profile.PrototypeIcon.DEVICEDRIVER,...
        systemcomposer.internal.profile.PrototypeIcon.MEMORY,...
        systemcomposer.internal.profile.PrototypeIcon.NETWORK,...
        systemcomposer.internal.profile.PrototypeIcon.PLANT,...
        systemcomposer.internal.profile.PrototypeIcon.SENSOR,...
        systemcomposer.internal.profile.PrototypeIcon.SUBSYSTEM,...
        systemcomposer.internal.profile.PrototypeIcon.TRANSMITTER,...
        ];

        PortIconValues=[...
        systemcomposer.internal.profile.PrototypeIcon.ANGLE,...
        systemcomposer.internal.profile.PrototypeIcon.ARROW,...
        systemcomposer.internal.profile.PrototypeIcon.CHEVRON,...
        systemcomposer.internal.profile.PrototypeIcon.FORWARD,...
        systemcomposer.internal.profile.PrototypeIcon.TRIDENT,...
        ];

        CustomIconValue=systemcomposer.internal.profile.PrototypeIcon.CUSTOM;

        IconValues=horzcat(systemcomposer.internal.profile.internal.PrototypeIconPicker.GenericIconValue,...
        systemcomposer.internal.profile.internal.PrototypeIconPicker.ComponentIconValues,...
        systemcomposer.internal.profile.internal.PrototypeIconPicker.PortIconValues,...
        systemcomposer.internal.profile.internal.PrototypeIconPicker.CustomIconValue);
    end

    methods(Static)
        function name=iconEnum2Name(enumVal)

            idx=(systemcomposer.internal.profile.internal.PrototypeIconPicker.IconValues==enumVal);
            if~any(idx)
                name=systemcomposer.internal.profile.internal.PrototypeIconPicker.IconNames{1};
            else
                name=systemcomposer.internal.profile.internal.PrototypeIconPicker.IconNames{idx};
            end
        end

        function enumVal=iconName2Enum(name)

            idx=strcmpi(systemcomposer.internal.profile.internal.PrototypeIconPicker.IconNames,name);
            if~any(idx)
                enumVal=systemcomposer.internal.profile.PrototypeIcon.NONE;
            else
                enumVal=systemcomposer.internal.profile.internal.PrototypeIconPicker.IconValues(idx);
            end
        end

        function filepath=iconName2FilePath(name,type)
            switch type
            case 'Port'
                subfolder='port';
            case 'Component'
                subfolder='component';
            otherwise
                subfolder='';
            end
            filepath=fullfile(matlabroot,'toolbox','sysarch','sysarch',...
            '+systemcomposer','+internal','+profile','resources','prototypes',subfolder,[name,'.svg']);
        end

        function filepath=getInvalidIconPath(type)
            switch type
            case 'Port'
                subfolder='port';
            case 'Component'
                subfolder='component';
            otherwise
                subfolder='';
            end
            filepath=fullfile(matlabroot,'toolbox','sysarch','sysarch',...
            '+systemcomposer','+internal','+profile','resources','prototypes',subfolder,'error.svg');
        end
    end

    methods
        function obj=PrototypeIconPicker(profileEditor,dlg)
            obj.Owner=profileEditor;
            obj.OwnerDlg=dlg;
        end

        function schema=getDialogSchema(this)

            switch this.Owner.getCurrentPrototype.getExtendedElement
            case 'Port'
                numButtons=length(this.PortIconNames)+1;
                numRows=3;r=1;
                numCols=3;c=1;
            case 'Component'
                numButtons=length(this.ComponentIconNames)+1;
                numRows=5;r=1;
                numCols=3;c=1;
            end

            assert((numRows-1)*numCols>=numButtons);

            label.Type='text';
            label.Name=DAStudio.message('SystemArchitecture:ProfileDesigner:PickAnIcon');
            label.RowSpan=[r,r];
            label.ColSpan=[1,numCols];
            r=r+1;

            items=cell(1,numButtons+1);
            items{1}=label;


            genericIconName=char(this.GenericIconName);
            items{2}.Type='pushbutton';
            items{2}.Tag=['iconButton_',genericIconName];
            items{2}.Source=this;
            items{2}.ObjectMethod='handleSelectIcon';
            items{2}.MethodArgs={'%dialog',genericIconName};
            items{2}.ArgDataTypes={'handle','char'};
            items{2}.DialogRefresh=true;
            items{2}.RowSpan=[r,r];
            items{2}.ColSpan=[c,c];
            items{2}.Enabled=true;
            items{2}.ToolTip='';
            items{2}.FilePath=systemcomposer.internal.profile.internal.PrototypeIconPicker.iconName2FilePath(genericIconName,this.Owner.getCurrentPrototype.getExtendedElement);
            c=c+1;


            for idx=1:numButtons-1

                switch this.Owner.getCurrentPrototype.getExtendedElement
                case 'Port'
                    iconName=this.PortIconNames{idx};
                case 'Component'
                    iconName=this.ComponentIconNames{idx};
                end

                iconChoice.Type='pushbutton';
                iconChoice.Tag=['iconButton_',iconName];
                iconChoice.Source=this;
                iconChoice.ObjectMethod='handleSelectIcon';
                iconChoice.MethodArgs={'%dialog',iconName};
                iconChoice.ArgDataTypes={'handle','char'};
                iconChoice.DialogRefresh=true;
                iconChoice.RowSpan=[r,r];
                iconChoice.ColSpan=[c,c];
                iconChoice.Enabled=true;
                iconChoice.ToolTip='';
                iconChoice.FilePath=systemcomposer.internal.profile.internal.PrototypeIconPicker.iconName2FilePath(iconName,this.Owner.getCurrentPrototype.getExtendedElement);

                items{idx+2}=iconChoice;
                c=c+1;
                if c>numCols
                    c=1;
                    r=r+1;
                end
            end

            iconName=this.CustomIconName{1};
            customIconChoice.Type='pushbutton';
            customIconChoice.Tag=['iconButton_',iconName];
            customIconChoice.Name=DAStudio.message('SystemArchitecture:ProfileDesigner:Custom');
            customIconChoice.Source=this;
            customIconChoice.ObjectMethod='handleSelectCustomIcon';
            customIconChoice.MethodArgs={'%dialog',iconName};
            customIconChoice.ArgDataTypes={'handle','char'};
            customIconChoice.DialogRefresh=true;
            customIconChoice.RowSpan=[numRows+1,numRows+1];
            customIconChoice.ColSpan=[1,numCols];
            customIconChoice.Enabled=true;
            customIconChoice.ToolTip='';

            iconName=this.NoIconName{1};
            noIconIconChoice.Type='pushbutton';
            noIconIconChoice.Tag=['iconButton_',iconName];
            noIconIconChoice.Name=DAStudio.message('SystemArchitecture:ProfileDesigner:NoIcon');
            noIconIconChoice.Source=this;
            noIconIconChoice.ObjectMethod='handleSelectNoIcon';
            noIconIconChoice.MethodArgs={'%dialog'};
            noIconIconChoice.ArgDataTypes={'handle'};
            noIconIconChoice.DialogRefresh=true;
            noIconIconChoice.RowSpan=[numRows+2,numRows+2];
            noIconIconChoice.ColSpan=[1,numCols];
            noIconIconChoice.Enabled=true;
            noIconIconChoice.ToolTip='';

            sizeText.Type='text';
            sizeText.Name=DAStudio.message('SystemArchitecture:ProfileDesigner:CustomIconSize');
            sizeText.FontPointSize=8;
            sizeText.Bold=false;
            sizeText.RowSpan=[numRows+3,numRows+3];
            sizeText.ColSpan=[1,numCols];

            group.Type='group';
            group.Items=[items,{customIconChoice,noIconIconChoice,sizeText}];
            group.LayoutGrid=[numRows+3,numCols];

            schema.DialogTitle=DAStudio.message('SystemArchitecture:ProfileDesigner:PickAnIcon');
            schema.Items={group};
            schema.DialogTag='system_composer_prototype_iconpicker';
            schema.Source=this;
            schema.Transient=true;
            schema.DialogStyle='frameless';
            schema.ExplicitShow=true;
            schema.StandaloneButtonSet={''};
        end

        function handleSelectIcon(this,dlg,value)
            iconEnum=systemcomposer.internal.profile.internal.PrototypeIconPicker.iconName2Enum(value);
            this.Owner.handlePrototypeIconSelected(this.OwnerDlg,iconEnum);
            delete(dlg);
        end

        function handleSelectNoIcon(this,dlg)
            this.Owner.handleSelectNoIcon(this.OwnerDlg);
            delete(dlg);
        end

        function throwOversizedIconWarning(~)
            eDlg=errordlg(DAStudio.message('SystemArchitecture:ProfileDesigner:OversizedCustomIconWarnMsg'),...
            DAStudio.message('SystemArchitecture:ProfileDesigner:OversizedCustomIconWarnDlg'),...
            true);
            this.Owner.positionDialog(eDlg,dlg);
            waitfor(eDlg);
        end

        function success=handleIconFile(this,fileName,filePath)
            success=false;
            sourceIconPath=fullfile(filePath,fileName);
            [~,~,ext]=fileparts(fileName);
            if strcmpi(ext,'.png')||strcmpi(ext,'.jpg')
                input=imread(sourceIconPath);
                [width,height,~]=size(input);
                if width~=16||height~=16
                    this.throwOversizedIconWarning;
                    return;
                end
            else
                if this.Owner.getCurrentPrototype.isSVGIconOversized(sourceIconPath)
                    this.throwOversizedIconWarning;
                    return;
                end
            end
            this.Owner.handleCustomPrototypeIconSelected(this.OwnerDlg,fileName);
            success=true;
        end

        function handleSelectCustomIcon(this,dlg,~)
            filespec={'*.jpg;*.png;*.svg','All Image Files (*.jpg,*.png,*.svg)'};
            success=false;
            while~success
                [fileName,filePath,~]=uigetfile(filespec,...
                DAStudio.message('SystemArchitecture:ProfileDesigner:BrowseForIcon'),'');
                this.OwnerDlg.show;
                if fileName==0
                    break;
                end
                if isfile(which(fileName))
                    success=this.handleIconFile(fileName,filePath);
                else
                    eDlg=errordlg(DAStudio.message('SystemArchitecture:ProfileDesigner:IconFileNotOnMatlabPathWarnMsg'),...
                    DAStudio.message('SystemArchitecture:ProfileDesigner:IconFileNotOnMatlabPathWarnDlg'),...
                    'modal');
                    this.Owner.positionDialog(eDlg,dlg);
                    waitfor(eDlg);
                end
            end
            delete(dlg);
        end
    end

end
