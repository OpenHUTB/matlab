function mappingExist=openDefaultsSS(st,modelHandle,minimize)





    if nargin<3
        minimize=false;
    end

    bd=get_param(modelHandle,'object');
    modelName=get_param(modelHandle,'Name');
    mappingExist=simulinkcoder.internal.util.createMappingAndInitDictIfNecessary(modelName,false);
    if mappingExist
        ss=st.getComponent('GLUE2:SpreadSheet','DefaultsProperties');
        readOnlyText='';
        if~Simulink.CodeMapping.enableCodeMappings(modelName)
            readOnlyText=DAStudio.message('coderdictionary:mapping:ReadOnly');
        end
        title=DAStudio.message('coderdictionary:mapping:CodeMappingsDefaults',readOnlyText);
        if isempty(ss)
            ss=GLUE2.SpreadSheetComponent(st,'DefaultsProperties');
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
                dataViewObj.m_Source=get_param(modelHandle,'Object');

                if(ss.getTabCount==0)
                    dataViewObj.DataView_initProperties(bd,ss);
                end


                dataViewObj.DataView_initListeners(bd,ss);
            end
        end
    end


