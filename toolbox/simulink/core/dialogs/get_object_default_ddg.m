function dlgstruct=get_object_default_ddg(dlgSource,objectName,objectValue)

















    grpProperties.Name=DAStudio.message('Simulink:dialog:DataAdditionalPropsPrompt');
    grpProperties.Type='panel';
    grpProperties.RowSpan=[1,1];
    grpProperties.ColSpan=[1,1];
    grpProperties.Tag='ObjectProperties';


    props=Simulink.data.getPropList(objectValue,'GetAccess','public');
    if~isempty(props)
        numItems=1;



        immediateMode=true;

        for i=1:length(props)
            if(~ddg_is_property_visible(objectValue,props(i)))
                continue;
            end
            try
                type2=get_widget_type_from_property(objectValue,props(i));
            catch
                type2='unknown';
            end

            if(strcmp(type2,'unknown')==1)
                continue;
            end;

            wid=populate_widget_from_object_property(objectValue,props(i),objectValue,immediateMode);
            wid.RowSpan=[numItems,numItems];
            wid.ColSpan=[1,2];
            grpProperties.Items{numItems}=wid;
            numItems=numItems+1;

        end
        if(numItems>1)
            grpProperties.LayoutGrid=[numItems,2];
            grpProperties.Items=align_names(grpProperties.Items);

            spacer.Type='panel';
            spacer.RowSpan=[2,2];
            spacer.ColSpan=[1,1];
            spacer.Tag='Spacer';

            dlgstruct.LayoutGrid=[3,2];
            dlgstruct.ColStretch=[0,1];
            dlgstruct.RowStretch=[0,0,1];
            dlgstruct.Items={grpProperties,spacer};
        else
            numItems=0;
        end
    else
        numItems=0;
    end

    if(numItems==0)

        messageText.Name=DAStudio.message('Simulink:dialog:ObjectHasNoPublicProperties');
        messageText.RowSpan=[1,1];
        messageText.ColSpan=[1,1];
        messageText.Alignment=6;
        messageText.Type='text';

        spacer.Type='panel';
        spacer.RowSpan=[2,2];
        spacer.ColSpan=[1,1];

        dlgstruct.LayoutGrid=[2,1];
        dlgstruct.ColStretch=1;
        dlgstruct.RowStretch=[0,1];
        dlgstruct.Items={messageText,spacer};
    end

    dlgstruct.SmartApply=0;
    dlgstruct.DialogTag='ObjectDDG';
    dlgstruct.DialogTitle=[class(objectValue),': ',objectName];
    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'matlab_variable'};

end




