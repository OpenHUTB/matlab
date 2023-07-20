



classdef CppClassSettingUI<handle
    properties
URL
ID
        SubScriptions={};
Dlg
        debug=0
ClassSettingListenerMap
        DlgPosition=[100,100,465,230]
modelH
    end

    methods
        function this=CppClassSettingUI(modelH,debug)
            this.modelH=modelH;
            connector.ensureServiceOn;
            connector.newNonce;
            this.debug=debug;
            this.ID=sprintf('/SoftwareDeploymentType/%f',modelH);
            if this.debug==0
                this.URL=connector.applyNonce(connector.getBaseUrl(['toolbox/coder/simulinkcoder_app/dplDlg/index.html?',this.ID]));
            else
                this.URL=connector.applyNonce(connector.getBaseUrl(['toolbox/coder/simulinkcoder_app/dplDlg/index-debug.html?',this.ID]));
            end
            this.ClassSettingListenerMap=containers.Map;
        end

        function receive(this,msg)
            if strcmp(msg.Type,'command')
                switch(msg.Value)
                case 'ready'
                    this.populateFields();
                case 'validateIdentifier'
                    this.isValidIdentifier(msg);
                case 'setValues'
                    this.setValues(msg);

                case 'applyButton'
                    this.setValues(msg);
                case 'okButton'
                    this.setValues(msg);
                    simulinkcoder.internal.dplDlg.CppClassSettingUI.closeCallBack(this);
                case 'cancelButton'
                    simulinkcoder.internal.dplDlg.CppClassSettingUI.closeCallBack(this);
                case 'helpButton'
                    helpview(fullfile(docroot,'ecoder','helptargets.map'),'cpp_config_class_name_ns');
                end
            end
        end

        function populateFields(this)
            msg='';
            mapping=Simulink.CodeMapping.getCurrentMapping(this.modelH);
            cppClassReference=mapping.CppClassReference;
            this.ClassSettingListenerMap('ClassSettingChanged')=event.listener(cppClassReference,'CppClassReferenceUpdated',@this.refreshUI);
            msg.Type='setFields';
            msg.description=message('coderdictionary:mapping:DplTypeDlgDescription').getString;
            msg.className=mapping.CppClassReference.ClassName;
            msg.computedDefaultClassName=get_param(this.modelH,'Name');
            msg.classNamespace=mapping.CppClassReference.ClassNamespace;
            msg.currentdeploymentType=mapping.DeploymentType;
            message.publish(this.ID,msg);
        end

        function refreshUI(this,cppClassReference,~)
            msg.Type='RefreshUI';
            msg.className=cppClassReference.ClassName;
            msg.classNamespace=cppClassReference.ClassNamespace;
            message.publish(this.ID,msg);
        end

        function flag=isValidIdentifier(this,msg)
            identifier=msg.Identifier;
            identifierType=msg.IdentifierType;
            if(size(identifier)==0)
                msg.Type='Validation';
                msg.isValid='true';
                message.publish(this.ID,msg);
                return;
            end

            if strcmp(identifierType,'classNamespace')&&(slfeature('CppNestedNamespaces')>0)
                namespaces=split(string(identifier),'::');
                flag=isempty(identifier)||...
                (~strcmp(namespaces(1),'std')&&...
                all(arrayfun(@(argValue)RTW.CPPFcnArgSpec('','Inport','Pointer',argValue,0,'None',0,0).isValidCPPIdentifier,namespaces)));
            else
                flag=RTW.CPPFcnArgSpec('','Inport','Pointer',identifier,0,'None',0,0).isValidCPPIdentifier;
            end

            msg='';
            msg.Type='Validation';
            if(flag)
                msg.isValid='true';
            else
                msg.isValid='false';
            end
            msg.IdentifierType=identifierType;
            message.publish(this.ID,msg);
        end

        function setValues(this,msg)
            mappings=Simulink.CodeMapping.getCurrentMapping(this.modelH);
            mappings.CppClassReference.ClassName=msg.ClassName;
            mappings.CppClassReference.ClassNamespace=msg.ClassNamespace;
        end

        function show(this)
            if isempty(this.SubScriptions)
                this.SubScriptions{end+1}=message.subscribe(this.ID,@this.receive);
            end

            if this.debug
                disp(strrep(this.URL,'index.html','index-debug.html'));
                return;
            end
            if~isa(this.Dlg,'DAStudio.Dialog')
                this.Dlg=DAStudio.Dialog(this);
                this.Dlg.Position=this.DlgPosition;
            end

            this.Dlg.showNormal;
            this.Dlg.show;
        end

        function dlgstruct=getDialogSchema(this,~)
            dlgstruct.DialogTitle=message('coderdictionary:mapping:DplTypeDlgTitle',getfullname(this.modelH)).getString;
            dlgstruct.CloseCallback='simulinkcoder.internal.dplDlg.CppClassSettingUI.closeCallBack';
            dlgstruct.CloseArgs={this};


            item.Url=this.URL;
            item.DisableContextMenu=true;
            item.EnableInspectorOnLoad=false;
            item.Type='webbrowser';
            item.WebKit=true;
            item.Tag='Tag_SoftwareDeploymentType_Browser';
            item.MinimumSize=[450,0];

            dlgstruct.Items={item};
            dlgstruct.HelpMethod='helpview';
            dlgstruct.HelpArgs='';
            dlgstruct.MinMaxButtons=true;
            buttonSet={''};
            dlgstruct.StandaloneButtonSet=buttonSet;
            dlgstruct.ExplicitShow=true;

        end
    end

    methods(Static=true,Hidden=true)
        function closeCallBack(this)
            for i=1:length(this.SubScriptions)
                message.unsubscribe(this.SubScriptions{i});
            end
            simulinkcoder.internal.dplDlg.CppClassSettingUI.removeDialogRecord(this.modelH);
            delete(this.Dlg);
            this.Dlg=[];
        end
        function out=getData()
            mlock;
            persistent uiRegistry;
            if isempty(uiRegistry)
                uiRegistry=containers.Map('KeyType','char','ValueType','any');
            end
            out=uiRegistry;
        end
        function openDialog(modelH,debug)
            uiRegistry=simulinkcoder.internal.dplDlg.CppClassSettingUI.getData;
            modelName=get_param(modelH,'Name');
            if uiRegistry.isKey(modelName)
                ui=uiRegistry(modelName);
                if debug~=ui.debug
                    delete(ui);
                    ui=simulinkcoder.internal.dplDlg.CppClassSettingUI(modelH,debug);
                    uiRegistry(modelName)=ui;%#ok<NASGU>
                end
            else
                ui=simulinkcoder.internal.dplDlg.CppClassSettingUI(modelH,debug);
                uiRegistry(modelName)=ui;%#ok<NASGU>
            end
            modelObject=get_param(modelH,'object');
            if~modelObject.hasCallback('PreClose','SimulinkCppClassSetting_PreClose')
                Simulink.addBlockDiagramCallback(modelH,'PreClose','SimulinkCppClassSetting_PreClose',...
                @()simulinkcoder.internal.dplDlg.CppClassSettingUI.closeDialogOnModelClose(modelH));
            end
            ui.show;
        end
        function closeDialogOnModelClose(modelH)
            uiRegistry=simulinkcoder.internal.dplDlg.CppClassSettingUI.getData;
            modelName=get_param(modelH,'Name');
            if uiRegistry.isKey(modelName)
                ui=uiRegistry(modelName);
                delete(ui);
            end
            Simulink.removeBlockDiagramCallback(modelH,'PreClose','SimulinkCppClassSetting_PreClose');
        end
        function removeDialogRecord(modelH)
            modelName=get_param(modelH,'Name');
            uiRegistry=simulinkcoder.internal.dplDlg.CppClassSettingUI.getData;
            if uiRegistry.isKey(modelName)
                uiRegistry.remove(modelName);
            end
        end

    end
end


