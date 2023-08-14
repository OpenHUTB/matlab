function openHDLCodeMappingSS(modelHandle,minimize)




    if~(slfeature('HDLTargetModelMapping')>0)
        return;
    end
    src=simulinkcoder.internal.util.getSource(modelHandle);
    st=src.studio;
    bd=get_param(modelHandle,'object');
    modelName=get_param(modelHandle,'Name');
    hm=hdlcoder.mapping.internal.ModelUtils.createOrActivateMapping(modelName);
    hm.sync();

    ss=st.getComponent('GLUE2:SpreadSheet','HDLCodeProperties');
    title=DAStudio.message('codemapping_hdl:mapping:CodeMappingsHDL','');
    if isempty(ss)
        ss=GLUE2.SpreadSheetComponent(st,'HDLCodeProperties');
        ss.DestroyOnHide=false;
        obj=DataView(bd,ss);
        st.registerComponent(ss);

        ss.ShowMinimized=minimize;
        st.moveComponentToDock(ss,title,'Bottom','Tabbed');
        ss.ShowMinimized=false;
        ss.setTitleView(obj);
        ss.setCurrentTab(0);
    elseif~ss.isVisible
        ss.ShowMinimized=minimize;
        ss.setMinimizeTabTitle(title);
        ss.setTitle(title);
        st.showComponent(ss);
        titleView=ss.getTitleView();
        if isa(titleView,'DAStudio.Dialog')
            dataViewObj=titleView.getDialogSource;


            dataViewObj.DataView_initListeners(bd,ss);
            if(ss.getTabCount==0)

                dataViewObj.DataView_initProperties(bd,ss);
            end
        end
    end



