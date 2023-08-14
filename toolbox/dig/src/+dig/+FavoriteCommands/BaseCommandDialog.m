
classdef(Abstract=true,Hidden=true)BaseCommandDialog
    properties(Access=public,Hidden=true)
Manager
SelectedIcon
CustomIcon
    end

    methods(Hidden=true)
        function this=BaseCommandDialog(manager)
            this.Manager=manager;
        end

        function str=getString(~,key)
            str=DAStudio.message(['simulink_ui:studio:resources:',key]);
        end

        function label=getLabel(~,row,tag,text,tooltip)
            width=60;
            height=24;

            label.Tag=[tag,'Text'];
            label.Type='text';
            label.Name=text;
            label.ToolTip=tooltip;
            label.ColSpan=[1,1];
            label.RowSpan=[row,row];
            label.PreferredSize=[width,height];
            label.Alignment=2;
        end

        function input=getInput(~,row,tag,type,tooltip)
            width=420;
            height=24;

            input.Tag=tag;
            input.Type=type;
            input.RowSpan=[row,row];
            input.ColSpan=[2,2];
            input.PreferredSize=[width,height];
            input.ToolTip=tooltip;
        end

        function[label,input]=getInputAndLabel(this,row,type,tag,text,tooltip)
            input=this.getInput(row,tag,type,tooltip);
            label=this.getLabel(row,tag,text,tooltip);
        end

        function[label,input]=getEditWidget(this)
            text=this.getString('simulinkFavoriteCommandDialogEditName');
            tooltip=this.getString('simulinkFavoriteCommandDialogEditToolTip');

            [label,input]=this.getInputAndLabel(1,'edit','label',text,tooltip);

            input.PlaceholderText=this.getString('simulinkFavoriteCommandDialogEditPlaceholderText');
        end

        function[label,input]=getTypeWidget(this)
            text=this.getString('simulinkFavoriteCommandDialogTypeName');
            tooltip=this.getString('simulinkFavoriteCommandDialogTypeToolTip');

            [label,input]=this.getInputAndLabel(2,'combobox','type',text,tooltip);

            input.Entries=dig.FavoriteCommands.Manager.CommandTypes;
            input.MatlabMethod='dig.FavoriteCommands.BaseCommandDialog.onChangeType';
            input.MatlabArgs={'%dialog'};
        end

        function[label,input]=getCodeWidget(this)
            text=this.getString('simulinkFavoriteCommandDialogCodeName');
            tooltip=this.getString('simulinkFavoriteCommandDialogCodeToolTip');

            [label,input]=this.getInputAndLabel(3,'matlabeditor','code',text,tooltip);

            input.Value=this.getString('simulinkFavoriteCommandDialogCodeScriptValue');
        end

        function[label,input]=getCategoryWidget(this)
            text=this.getString('simulinkFavoriteCommandDialogCategoryName');
            tooltip=this.getString('simulinkFavoriteCommandDialogCategoryToolTip');

            [label,input]=this.getInputAndLabel(4,'combobox','category',text,tooltip);

            input.Entries=this.Manager.getElidedCategoryNames();
        end

        function[label,input]=getIconWidget(this)
            text=this.getString('simulinkFavoriteCommandDialogIconName');
            tooltip=this.getString('simulinkFavoriteCommandDialogIconToolTip');

            [label,input]=this.getInputAndLabel(5,'splitbutton','icon',text,tooltip);

            icons=this.Manager.getIcons();

            if(~isempty(this.CustomIcon))
                idx=length(icons)-1;
                icons=[icons(1:idx),{this.CustomIcon},icons(idx+1:end)];
            end

            this.SelectedIcon=icons{1}.getTag();

            input.ActionEntries=icons;
            input.DefaultAction=this.SelectedIcon;
            input.ActionCallback=@dig.FavoriteCommands.BaseCommandDialog.onIconChange;
        end

        function input=getQABAddWidget(this)
            row=6;
            column=2;

            input.Tag='qabAdd';
            input.Type='checkbox';
            input.Name=this.getString('simulinkFavoriteCommandDialogAddToQABName');
            input.ObjectMethod='onQABAddChanged';
            input.MethodArgs={'%dialog','%value'};
            input.ArgDataTypes={'handle','mxArray'};
            input.RowSpan=[row,row];
            input.ColSpan=[column,column];
        end

        function input=getQABShowLabelWidget(this)
            row=7;
            column=2;

            input.Tag='qabShowLabel';
            input.Type='checkbox';
            input.Name=this.getString('simulinkFavoriteCommandDialogShowTextInQABName');
            input.Enabled=false;
            input.RowSpan=[row,row];
            input.ColSpan=[column,column];
        end

        function panel=getPanelWidget(~,widgets)
            panel.Tag='Panel';
            panel.Type='panel';
            panel.Items=widgets;
            panel.LayoutGrid=[7,2];
            panel.Spacing=10;
            panel.ColStretch=[0,1];
        end

        function dlg=getDialogWidget(this)
            dlg.DialogTitle=this.getString('simulinkFavoriteCommandDialogTitle');
            dlg.StandaloneButtonSet={'Ok','Cancel','Help'};
            dlg.IsScrollable=false;
            dlg.Sticky=true;
            dlg.OpenCallback=@dig.FavoriteCommands.BaseCommandDialog.onOpen;
            dlg.HelpMethod='helpview';
            dlg.HelpArgs=this.Manager.CommandEditorHelpArgs;
        end

        function dlg=getDialogSchema(this,~)
            [editLabel,edit]=this.getEditWidget();
            [typeLabel,type]=this.getTypeWidget();
            [codeLabel,code]=this.getCodeWidget();
            [categoryLabel,category]=this.getCategoryWidget();
            [iconLabel,icon]=this.getIconWidget();
            qabAdd=this.getQABAddWidget();
            qabShowLabel=this.getQABShowLabelWidget();
            panel=this.getPanelWidget({editLabel,edit,typeLabel,type,codeLabel,code,categoryLabel,category,iconLabel,icon,qabAdd,qabShowLabel});

            dlg=this.getDialogWidget();
            dlg.Items={panel};
        end

        function onQABAddChanged(~,dlg,value)
            dlg.setEnabled('qabShowLabel',value);
        end
    end

    methods(Static,Hidden=true)
        function data=getValues(dlg)
            src=dlg.getDialogSource();
            data.label=dlg.getWidgetValue('label');
            data.code=dlg.getWidgetValue('code');
            data.category=dlg.getWidgetValue('category');
            data.addToQAB=dlg.getWidgetValue('qabAdd');
            data.showQABLabel=dlg.getWidgetValue('qabShowLabel');
            data.icon=src.SelectedIcon;
            data.type=dig.FavoriteCommands.BaseCommandDialog.getType(dlg);
        end

        function onOpen(dlg)
            dlg.setFocus('label');
        end

        function type=getType(dlg)
            value=dlg.getWidgetValue('type');
            type=dig.FavoriteCommands.Manager.getCommandTypeByIndex(value+1);
        end

        function onChangeType(dlg)
            type=dig.FavoriteCommands.BaseCommandDialog.getType(dlg);
            code=dlg.getWidgetValue('code');
            defaultCodeScript=DAStudio.message('simulink_ui:studio:resources:simulinkFavoriteCommandDialogCodeScriptValue');
            defaultCodeFunction=DAStudio.message('simulink_ui:studio:resources:simulinkFavoriteCommandDialogCodeFunctionValue');

            if(strcmp(type,'Script')==1)
                if(strcmp(code,defaultCodeFunction)==1)
                    dlg.setWidgetValue('code',defaultCodeScript);
                end
            else
                if(strcmp(code,defaultCodeScript)==1)
                    dlg.setWidgetValue('code',defaultCodeFunction);
                end
            end
        end

        function setCustomIcon(dlg,path,file)
            src=dlg.getDialogSource();
            src.SelectedIcon=[path,file];
            src.CustomIcon=SampleActionBuilder(file,src.SelectedIcon,src.SelectedIcon);

            dlg.refresh();
            dlg.setWidgetValue('icon',src.SelectedIcon);
        end

        function p=lastIconPath(inPath)
            persistent last;
            if isempty(last)
                last=pwd;
            end

            p=last;

            if nargin==1
                last=inPath;
            end
        end

        function onIconChange(dlg,tag,actionTag)
            src=dlg.getDialogSource();



            if(strcmp(actionTag,'custom'))
                [file,path]=uigetfile('.png',...
                DAStudio.message('simulink_ui:studio:resources:simulinkFavoriteCommandDialogSelectIconDialogTitle'),...
                dig.FavoriteCommands.BaseCommandDialog.lastIconPath());


                if(~isequal(path,0)&&~isequal(file,0))
                    dig.FavoriteCommands.BaseCommandDialog.setCustomIcon(dlg,path,file);
                    dig.FavoriteCommands.BaseCommandDialog.lastIconPath(path);
                end
            else
                dlg.setWidgetValue(tag,actionTag);

                src.SelectedIcon=actionTag;
            end
        end

        function onClose(dlg,closeAction,manager)
            if(strcmp(closeAction,'ok'))
                src=dlg.getDialogSource();

                if(~isempty(src.CustomIcon)&&strcmp(src.CustomIcon.DisplayIcon,src.SelectedIcon))
                    manager.addIcon(src.CustomIcon.DisplayLabel,src.SelectedIcon,src.SelectedIcon);
                end
            end
        end
    end
end