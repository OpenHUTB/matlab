classdef ComponentChoice<handle



    properties
        Enabled=true;
    end

    properties(SetAccess=private)
        Description=''
        ShortDescription=''
        SourceFile=''
    end

    properties(Access=private)
Source
    end

    methods

        function obj=ComponentChoice(src)
            obj.Source=src;
            obj.SourceFile=get_param(obj.Source,'SourceFile');
            obj.updateDescription();
        end

        function set.ShortDescription(obj,val)
            obj.ShortDescription=pm.sli.internal.cleanGroupLabel(val);
        end

        function s=getDialogSchema(hThis,varargin)
            s=l_buildComponentDescriptionBox(hThis);
            s=l_wrapWithStretchPanel(s);
        end

        function viewSource(obj)
            [sourceFile,isEditable]=...
            simscape.compiler.mli.internal.sourcefilefromcomponentpath(obj.SourceFile);
            if isEditable
                edit(sourceFile);
            end
        end

        function refreshSource(obj,dlg)
            ch=dlg.getWidgetValue('ComponentChoice');
            obj.applyChoice(dlg,ch);
        end

        function applyChoice(obj,hDialog,choice)

            res=obj.setComp(choice);


            hDialog.setWidgetValue('ComponentChoice',choice);
            hDialog.setWidgetValue('ComponentDescription',...
            obj.Description);


            [~,isEditable]=...
            simscape.compiler.mli.internal.sourcefilefromcomponentpath(choice);
            hDialog.setVisible('ViewSource',isEditable);


            if res
                hDialog.clearWidgetDirtyFlag('ComponentChoice');
                hDialog.clearWidgetWithError('ComponentChoice')
            else
                hDialog.setWidgetWithError('ComponentChoice',...
                DAStudio.UI.Util.Error('ComponentChoice','Error',obj.Description))
            end

        end

        function browseSource(obj,dlg)

            dlgEntry=dlg.getWidgetValue('ComponentChoice');


            cmp=simscape.internal.dialog.selectSourceFile(dlgEntry);


            if~ismissing(cmp)
                obj.applyChoice(dlg,cmp);
            end
        end

        function updateDescription(obj)

            if isempty(obj.SourceFile)

                obj.Description=getString(message(...
                'physmod:ne_sli:dialog:EmptyComponentSpecification'));
                obj.ShortDescription=getString(message(...
                'physmod:ne_sli:dialog:SimscapeComponentUnspecifiedTitle'));
            else

                [obj.ShortDescription,obj.Description]=...
                simscape.internal.dialog.getBasicComponentInfo(...
                obj.SourceFile);
            end
        end

        function res=setComp(obj,sourceFile)
            res=false;
            obj.SourceFile=sourceFile;
            lClearSource(which(obj.SourceFile));
            if isempty(obj.SourceFile)||simscape.internal.dialog.isValidSimscapeComponent(obj.SourceFile)
                try
                    set_param(obj.Source,'SourceFile',obj.SourceFile);
                    obj.updateDescription();
                    res=true;
                catch ME


                    obj.Description=ME.getReport();
                    obj.ShortDescription='Error';
                end
            else
                obj.updateDescription();
            end
        end
    end
end

function lClearSource(src)
    clear(which(src));
end

function groupBox=l_buildComponentDescriptionBox(obj)

    src=struct(...
    'Type',{'edit'},...
    'Name',{''},...
    'ObjectProperty',{'SourceFile'},...
    'ObjectMethod',{'applyChoice'},...
    'MethodArgs',{{'%dialog','%value'}},...
    'ArgDataTypes',{{'handle','mxarray'}},...
    'RowSpan',{[1,1]},...
    'NameLocation',{2},...
    'Source',{obj},...
    'Enabled',{obj.Enabled},...
    'DisableInPlaceEvaluation',true,...
    'Tag',{'ComponentChoice'}...
    );

    browse=lBrowseWidget(obj);
    browse.RowSpan=[1,1];

    refresh=lRefreshWidget(obj);
    refresh.RowSpan=[1,1];

    descTextStruct=l_generateDescriptionTextStruct(obj.Description);
    descTextStruct.RowSpan=[3,3];
    descTextStruct.ColSpan=[1,3];

    groupBox=l_generateGroupBox(obj.ShortDescription,{});
    groupBox.ColStretch=1;

    viewSource=l_generateHyperlink(obj);
    viewSource.RowSpan=[4,4];
    groupBox.Items={src,viewSource,browse,refresh,descTextStruct};
    groupBox.LayoutGrid=[4,1];
    groupBox.RowStretch=[0,0,0,1];
end

function widget=l_generateDescriptionTextStruct(text)
    widget=struct(...
    'Name',{text},...
    'Type',{'text'},...
    'WordWrap',{true},...
    'MinimumSize',{[240,1]},...
    'RowSpan',{[2,2]},...
    'ColSpan',{[1,2]},...
    'Graphical',{true},...
    'Tag',{'ComponentDescription'});
end

function widget=l_generateGroupBox(name,items)
    widget=struct(...
    'Type',{'group'},...
    'RowSpan',{[1,1]},...
    'ColSpan',{[1,1]},...
    'LayoutGrid',{[2,2]},...
    'ColStretch',{[0,1]},...
    'Items',{items},...
    'Tag',{'ComponentDescriptionGroup'});
end

function widget=lBrowseWidget(obj)

    widget.Type='pushbutton';
    widget.Tag='BrowseSource';
    widget.Graphical=true;
    widget.ObjectMethod='browseSource';
    widget.MethodArgs={'%dialog'};
    widget.ArgDataTypes={'handle'};
    widget.Source=obj;
    widget.ColSpan=[2,2];
    widget.RowSpan=[1,1];
    widget.ToolTip=getString(...
    message('physmod:ne_sli:dialog:BrowseSourceToolTip'));
    widget.FilePath=...
    fullfile(matlabroot,'toolbox','physmod','ne_sli','ne_sli','internal','resources','open.png');
    widget.Enabled=obj.Enabled;
end

function widget=lRefreshWidget(obj)

    widget.Type='pushbutton';
    widget.Tag='RefreshSource';
    widget.Graphical=true;
    widget.ObjectMethod='refreshSource';
    widget.MethodArgs={'%dialog'};
    widget.ArgDataTypes={'handle'};
    widget.Source=obj;
    widget.ColSpan=[3,3];
    widget.Enabled=obj.Enabled;
    widget.RowSpan=[1,1];
    widget.ToolTip=getString(...
    message('physmod:ne_sli:dialog:RefreshSourceToolTip'));
    widget.FilePath=...
    fullfile(matlabroot,'toolbox','physmod','ne_sli','ne_sli','internal','resources','refresh.png');
end

function widget=l_generateHyperlink(obj)
    name=getString(message('physmod:ne_sli:dialog:OpenSourceString'));
    [~,isEditable]=...
    simscape.compiler.mli.internal.sourcefilefromcomponentpath(obj.SourceFile);
    widget=struct(...
    'Name',{name},...
    'Type',{'hyperlink'},...
    'RowSpan',{[1,1]},...
    'ColSpan',{[1,1]},...
    'ObjectMethod',{'viewSource'},...
    'Source',{obj},...
    'Visible',{isEditable},...
    'Graphical',{true},...
    'Tag',{'ViewSource'});
end

function dlgStruct=l_wrapWithStretchPanel(innerWidget)

    dlgStruct=struct(...
    'DialogTitle',{''},...
    'Items',{{innerWidget}},...
    'CloseMethod',{'closeDialogCB'},...
    'CloseMethodArgs',{{'%dialog'}},...
    'CloseMethodArgsDT',{{'handle'}},...
    'EmbeddedButtonSet',{{''}},...
    'RowStretch',{[0,1]},...
    'LayoutGrid',{[2,1]},...
    'StandaloneButtonSet',{{''}});

end
