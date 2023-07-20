




function panel=generateDDGStructForProperties(obj,props,panelType,panelTag,...
    panelName,immediateMode,initialToggleState,propTagBase,highlightProperties)






    if~exist('propTagBase','var')
        propTagBase='';
    end

    if~exist('highlightProperties','var')
        highlightProperties={};
    end

    if~exist('immediateMode','var')||isempty(immediateMode)

        immediateMode=true(size(props));
    elseif isscalar(immediateMode)

        immediateMode=immediateMode.*true(size(props));
    end


    if~exist('initialToggleState','var')
        initialToggleState=true;
    end

    panel=struct('Type',panelType,'LayoutGrid',[1,3],'ColStretch',[0,0,1],'Name',panelName,'Tag',panelTag);
    if strcmp(panelType,'togglepanel')
        panel.Expand=slreq.gui.togglePanelHandler('get',panel.Tag,initialToggleState);
        panel.ExpandCallback=@slreq.gui.togglePanelHandler;
    end

    panel.Items={};


    if isempty(obj)
        return;
    end

    nRow=1;
    for n=1:length(props)
        propName=props{n};
        propValue=obj.(propName);


        if iscell(propValue)
            propValue=char(propValue);
        end

        if isempty(propValue)
            propValue='';
        end

        if isa(obj,'slreq.das.Requirement')
            displayFieldName=obj.getDisplayName(propName);
        elseif isa(obj,'slreq.das.Link')||isa(obj,'slreq.das.RequirementSet')||isa(obj,'slreq.das.LinkSet')
            displayFieldName=obj.getDisplayNameForBuiltin(propName);
        else
            displayFieldName=obj.getDisplayName(propName);
        end


        if isa(propValue,'datetime')
            propValue=slreq.utils.getDateStr(propValue);
        end

        if~strcmp(panelName,'preview')
            isEditable=obj.isEditablePropertyInInspector(propName);
        else

            isEditable=false;
        end


        nameWidget=struct('Type','text','Name',[displayFieldName,':'],...
        'RowSpan',[nRow,nRow],'ColSpan',[1,1]);


        if any(strcmp(highlightProperties,propName))
            nameWidget.Bold=true;
            nameWidget.ForegroundColor=slreq.gui.CustomAttributeItemPanel.HIGHLIGHT_COLOR;
        end



        valueWidget=struct('RowSpan',[nRow,nRow],'ColSpan',[2,3],...
        'Enabled',isEditable,'Tag',[propTagBase,propName],'WidgetId',[propName,'_widget']);

        if ischar(propValue)

            widgetType=obj.getPropertyWidgetType(propName);
            valueWidget.Type=widgetType;
            if strcmp(widgetType,'editarea')


                nameWidget.Alignment=2;
                valueWidget.PreferredSize=[-1,100];
                valueWidget.ColSpan=[2,3];
                if immediateMode(n)
                    valueWidget.Mode=true;
                    valueWidget.ObjectProperty=propName;
                    valueWidget.Graphical=true;
                else
                    valueWidget.Value=propValue;
                end
            elseif strcmp(widgetType,'textbrowser')

                valueWidget.Text=propValue;
                valueWidget.Enabled=true;
                valueWidget.ColSpan=[2,3];
                nameWidget.Alignment=2;
            elseif strcmp(widgetType,'webbrowser')

                valueWidget.HTML=propValue;
                valueWidget.WebKit=true;
                valueWidget.Enabled=true;
                valueWidget.PreferredSize=[30,70];
                valueWidget.ColSpan=[2,3];
                nameWidget.Alignment=2;
            elseif~isEditable


                valueWidget.Type='text';
                valueWidget.Name=propValue;
                valueWidget.Enabled=true;
                valueWidget.ColSpan=[2,3];
                valueWidget.Alignment=0;
                valueWidget.Elide=true;
                valueWidget.WordWrap=false;
                valueWidget.ToolTip=propValue;
            else

                if immediateMode(n)
                    valueWidget.Mode=true;
                    valueWidget.ObjectProperty=propName;
                    valueWidget.Graphical=true;
                else
                    valueWidget.Value=propValue;
                end
            end
        elseif islogical(propValue)

            valueWidget.Type='checkbox';
            if immediateMode(n)
                valueWidget.Mode=true;
                valueWidget.ObjectProperty=propName;
            else
                valueWidget.Value=propValue;
            end
        elseif isenum(propValue)

            enumList=enumeration(propValue);
            dispList=cell(1,length(enumList));
            selectedIdx=1;
            for m=1:length(enumList)
                if enumList(m)==propValue
                    selectedIdx=m;
                end
                dispList{m}=enumList(m).char;
            end
            valueWidget.Type='combobox';
            valueWidget.Value=selectedIdx-1;
            valueWidget.Entries=dispList;


        elseif isinteger(propValue)
            valueWidget.Type='text';
            valueWidget.Name=num2str(propValue);
            valueWidget.Enabled=true;
            valueWidget.ColSpan=[2,2];
            valueWidget.Alignment=1;
        else
            continue;
        end
        panel.Items{end+1}=nameWidget;
        panel.Items{end+1}=valueWidget;
        nRow=nRow+1;
    end
end
