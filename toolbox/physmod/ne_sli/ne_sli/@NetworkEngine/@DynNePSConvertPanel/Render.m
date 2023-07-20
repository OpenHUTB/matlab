function[retVal,schema]=Render(hThis,schema)












    [retVal,schema]=hThis.renderChildren();
    schema=schema{1};

    if strcmp(get(hThis.BlockHandle,'SubClassName'),'ps_input')
        schema.Items{1}.Tabs{2}.LayoutGrid=[4,1];
        schema.Items{1}.Tabs{2}.RowStretch=[0,0,0,1];
        [derivSourceSchema,derivSourcePath]=pmsl_extractdialogschema(schema.Items{1}.Tabs{2},'Type','combobox',...
        'Name',pm_message('physmod:ne_sli:nesl_utility:sl2ps:FilteringAndDerivativesPrompt'));
        [userProvidedDerivsSchema,userProvidedDerivsPath]=pmsl_extractdialogschema(schema.Items{1}.Tabs{2},'Type','combobox',...
        'Name',pm_message('physmod:ne_sli:nesl_utility:sl2ps:ProvidedSignalsPrompt'));
        [simscapeFilterOrderSchema,simscapeFilterOrderPath]=pmsl_extractdialogschema(schema.Items{1}.Tabs{2},'Type','combobox',...
        'Name',pm_message('physmod:ne_sli:nesl_utility:sl2ps:SimscapeFilterOrder'));
        [filterTimeConstantSchema,filterTimeConstantPath]=pmsl_extractdialogschema(schema.Items{1}.Tabs{2},'Type','edit',...
        'Name',pm_message('physmod:ne_sli:nesl_utility:sl2ps:FilterTimeConstantPrompt'));
        derivSourceSchema.Source.Listeners{end+1}=@lChange;
        sta=l_get_visible_status(find(strcmp(derivSourceSchema.Value,derivSourceSchema.Entries))-1);

        j=1;

        j=j+1;
        userProvidedDerivsSchema.Visible=sta.upd;
        schema.Items{1}.Tabs{2}.Items{j}.Items{1}.Visible=sta.upd;

        j=j+1;
        simscapeFilterOrderSchema.Visible=sta.sfo;
        schema.Items{1}.Tabs{2}.Items{j}.Items{1}.Visible=sta.sfo;

        j=j+1;
        filterTimeConstantSchema.Visible=sta.ftc;
        schema.Items{1}.Tabs{2}.Items{j}.Items{1}.Visible=sta.ftc;

        schema.Items{1}.Tabs{2}=pmsl_updatedialogschema(schema.Items{1}.Tabs{2},derivSourceSchema,derivSourcePath);
        schema.Items{1}.Tabs{2}=pmsl_updatedialogschema(schema.Items{1}.Tabs{2},userProvidedDerivsSchema,userProvidedDerivsPath);
        schema.Items{1}.Tabs{2}=pmsl_updatedialogschema(schema.Items{1}.Tabs{2},simscapeFilterOrderSchema,simscapeFilterOrderPath);
        schema.Items{1}.Tabs{2}=pmsl_updatedialogschema(schema.Items{1}.Tabs{2},filterTimeConstantSchema,filterTimeConstantPath);
    end

    function sta=l_get_visible_status(widgetVal)
        switch widgetVal
        case 0
            sta.upd=true;
            sta.sfo=false;
        case 1
            sta.upd=false;
            sta.sfo=true;
        case 2
            sta.upd=false;
            sta.sfo=false;
        end
        sta.ftc=sta.sfo;
    end



    function lChange(hThis,hDlg,widgetVal,tagVal)
        sta=l_get_visible_status(widgetVal);

        hDlg.setVisible(userProvidedDerivsSchema.Tag,sta.upd);
        hDlg.setVisible(schema.Items{1}.Tabs{2}.Items{2}.Items{1}.Tag,sta.upd);

        hDlg.setVisible(simscapeFilterOrderSchema.Tag,sta.sfo);
        hDlg.setVisible(schema.Items{1}.Tabs{2}.Items{3}.Items{1}.Tag,sta.sfo);

        hDlg.setVisible(filterTimeConstantSchema.Tag,sta.ftc);
        hDlg.setVisible(schema.Items{1}.Tabs{2}.Items{4}.Items{1}.Tag,sta.ftc);

        hDlg.resetSize(false);
    end
end

