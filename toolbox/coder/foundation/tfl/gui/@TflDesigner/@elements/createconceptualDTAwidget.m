function typeWidget=createconceptualDTAwidget(h,tag)







    if~isempty(h.object.ConceptualArgs)

        value=h.object.ConceptualArgs(h.activeconceptarg).toString(true);

        if~isempty(find(value=='[',1))
            value=value(1:find((value=='['),1)-1);
        end

        if strcmp(value(end),'*')
            value=value(1:end-1);
        end

        value=strrep(value,'const ','');
        value=strrep(value,'volatile ','');

        if strcmp(value(1),'c')&&~strcmp(value(2),'h')
            dtVal=value(2:end);
        else
            dtVal=value;
        end

        if h.isDataTypeStruct(value)
            dtVal='struct';
        end

    else
        dtVal='double';
    end

    daDataType=DAStudio.message('RTW:tfldesigner:DataTypeText');
    dtPrompt=daDataType;
    dtTag=tag;

    entries=h.getentries('Tfldesigner_ConceptualDatatype');




    dlghandle=TflDesigner.getdialoghandle;
    if~isempty(dlghandle)&&dlghandle.hasUnappliedChanges
        h.cargdtypeunapplied=dlghandle.getWidgetValue('Tfldesigner_DataType');
    else
        h.cargdtypeunapplied=dtVal;
    end

    typeWidget=TflDesigner.widgetnode;
    typeWidget.Name=dtPrompt;
    typeWidget.Type='combobox';
    typeWidget.Tag=dtTag;
    typeWidget.Entries=entries;
    typeWidget.Source=h;
    typeWidget.Editable=true;
    typeWidget.Value=dtVal;
    typeWidget.ToolTip=DAStudio.message('RTW:tfldesigner:DatatypeTooltip');
    typeWidget.ObjectMethod='setproperties';
    typeWidget.MethodArgs={'%dialog',{typeWidget.Tag}};
    typeWidget.ArgDataTypes={'handle','mxArray'};
    typeWidget.DialogRefresh=true;





