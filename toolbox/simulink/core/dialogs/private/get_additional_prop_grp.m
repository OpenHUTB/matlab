function[grpAdditional,tab]=get_additional_prop_grp(h,simulink_class_name,tab_tag)



















    grpAdditional.Name=DAStudio.message('Simulink:dialog:DataAdditionalPropsPrompt');
    grpAdditional.Type='panel';
    grpAdditional.RowSpan=[1,1];
    grpAdditional.ColSpan=[1,1];
    grpAdditional.Tag=strcat('sfCoderoptsdlg_',grpAdditional.Name);
    grpAdditional.Items={};
    grpAdditional.Tag='GrpAdditional';


    props=find_reduced_set_of_properties(h,simulink_class_name);
    numItems=1;



    immediateMode=true;

    for i=1:length(props)
        if(~ddg_is_property_visible(h,props(i)))
            continue;
        end
        type2=get_widget_type_from_property(h,props(i));

        if(strcmp(type2,'unknown')==1)
            continue;
        end

        wid=populate_widget_from_object_property(h,props(i),h,immediateMode);
        wid.RowSpan=[numItems,numItems];
        wid.ColSpan=[1,2];
        grpAdditional.Items{numItems}=wid;
        numItems=numItems+1;
    end
    grpAdditional.LayoutGrid=[numItems,2];
    grpAdditional.Items=align_names(grpAdditional.Items);

    spacer.Type='panel';
    spacer.RowSpan=[2,2];
    spacer.ColSpan=[1,1];
    spacer.Tag='Spacer';

    tab.Name=DAStudio.message('Simulink:dialog:DataTab2Prompt');
    tab.Items={grpAdditional,spacer};
    tab.LayoutGrid=[2,1];
    tab.RowStretch=[0,1];
    tab.Tag=tab_tag;

end


