function mappingExist=openCodeMappingSS(st,modelHandle,minimize)





    if nargin<3
        minimize=false;
    end

    modelName=get_param(modelHandle,'Name');

    cp=simulinkcoder.internal.CodePerspective.getInstance;
    [app,~,lang]=cp.getInfo(modelHandle);
    isEmbeddedCoderC=strcmp(app,'EmbeddedCoder')&&~strcmp(lang,'cpp');
    if isEmbeddedCoderC
        sharedDDName=coderdictionary.data.SlCoderDataClient.getSharedCoderDictionarySource(modelHandle);
        isSharedDictSpecified=~isempty(sharedDDName);


        hideSSforDataInterface=coder.internal.toolstrip.util.getPlatformType(modelHandle)==0...
        &&isSharedDictSpecified&&~exist(sharedDDName,'file');

        hideSSforServiceInterface=coder.internal.toolstrip.util.getPlatformType(modelHandle)==1...
        &&(~exist(sharedDDName,'file')||...
        ~coder.dictionary.exist(sharedDDName));
        if(hideSSforServiceInterface||hideSSforDataInterface)
            notifyKey='SharedDictionaryIsInaccessible';
            msg=message('SimulinkCoderApp:codeperspective:SharedDictionaryInaccessible',...
            modelName,sharedDDName).getString;
            editor=st.App.getActiveEditor;
            editor.deliverInfoNotification(notifyKey,msg);
            return;
        else
            cmi=Simulink.CodeMapping.getCurrentMapping(bdroot);
            if~isempty(cmi)&&(cmi.isFunctionPlatform~=coder.internal.toolstrip.util.getPlatformType(modelHandle))
                serviceInterfaceLabel=message('SimulinkCoderApp:sdp:ServiceInterfaceLabel').getString;
                dataInterfaceLabel=message('SimulinkCoderApp:sdp:DataInterfaceLabel').getString;
                if(cmi.isFunctionPlatform)
                    dictionaryCodeInterface=dataInterfaceLabel;
                    mappingCodeInterface=serviceInterfaceLabel;
                else
                    dictionaryCodeInterface=serviceInterfaceLabel;
                    mappingCodeInterface=dataInterfaceLabel;
                end
                notifyKey='SharedDictionaryIsInaccessible';
                msg=message('coderdictionary:mapping:SharedDictionaryIncompatibleWithCodeMappings',...
                sharedDDName,dictionaryCodeInterface,modelName,mappingCodeInterface).getString;
                editor=st.App.getActiveEditor;
                editor.deliverInfoNotification(notifyKey,msg);
            end
        end
    end

    mappingExist=simulinkcoder.internal.util.createMappingAndInitDictIfNecessary(modelName,false);
    modelRefDepTypeChanged=false;
    if mappingExist&&isEmbeddedCoderC&&strcmp(coder.dictionary.internal.getPlatformType(modelName),"FunctionPlatform")
        editor=st.App.getActiveEditor;
        cgrModelH=coder.internal.toolstrip.util.getCodeGenRoot(editor);
        if cgrModelH~=modelHandle
            [modelMapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(modelName);
            assert(strcmp(mappingType,'CoderDictionary'));
            modelMapping.DeploymentType='Subcomponent';

            refresher=coder.internal.toolstrip.util.Refresher(st,true);
            modelRefDepTypeChanged=true;
        end
    end
    if mappingExist
        ss=st.getComponent('GLUE2:SpreadSheet','CodeProperties');
        title=Simulink.CodeMapping.getTitle(modelHandle);
        bd=get_param(modelHandle,'object');
        if isempty(ss)
            ss=GLUE2.SpreadSheetComponent(st,'CodeProperties');
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



                if modelRefDepTypeChanged
                    DataView.handleCanvasChanged(ss,dataViewObj.m_Source,dataViewObj);
                end
            end
        end
    end


