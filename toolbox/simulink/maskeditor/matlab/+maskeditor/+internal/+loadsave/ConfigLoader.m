

classdef ConfigLoader<handle



    properties
        m_Context;
        m_SystemType;
        m_MF0Model;
        m_ConfigMF0Object;
        m_ConfigManager;
        m_DataNamespace;
        m_SystemTypeConfigFileMap;
    end

    properties(Constant)
        ConfigConstants=maskeditor.internal.loadsave.ConfigConstants();
    end

    methods
        function obj=ConfigLoader(mf0Model,systemOrBlockContext)
            obj.m_Context=systemOrBlockContext;
            obj.m_SystemType=systemOrBlockContext.systemType;
            obj.m_MF0Model=mf0Model;
            obj.m_ConfigMF0Object=[];
            obj.m_ConfigManager=[];

            obj.m_SystemTypeConfigFileMap=jsondecode(fileread([matlabroot,obj.ConfigConstants.CONFIG_DIRECTORY,obj.ConfigConstants.SYSTEM_TYPE_CONFIG_FILE]));
        end

        function[bSuccess,aConfigMF0Object]=loadConfigAndDataFiles(this)
            try
                this.m_ConfigMF0Object=simulink.maskeditor.Configurations(this.m_MF0Model);


                aConfiguration=this.loadConfigFile();
                this.m_ConfigManager=maskeditor.internal.loadsave.ConfigManager(aConfiguration);

                this.m_DataNamespace=aConfiguration.(this.ConfigConstants.DATA_NAMESPACE);


                this.loadJsonDataFiles();


                this.loadToolstripConfigFiles();

                aConfigMF0Object=this.m_ConfigMF0Object;
                bSuccess=true;
            catch exp
                msg=slprivate('getExceptionMsgReport',exp);
                errordlg(msg);

                aConfigMF0Object=[];
                bSuccess=false;
            end
        end

        function aConfiguration=loadConfigFile(this)
            aConfigFileName=this.m_SystemTypeConfigFileMap.(this.m_SystemType);
            aConfiguration=jsondecode(fileread([matlabroot,this.ConfigConstants.CONFIG_DIRECTORY,aConfigFileName]));
            this.m_ConfigMF0Object.config=jsonencode(aConfiguration);
        end

        function changeConfiguration(this,aFullKey,aNewValue)
            this.m_ConfigManager=this.m_ConfigManager.setConfig(aFullKey,aNewValue);
            aConfiguration=this.m_ConfigManager.getConfig([]);
            this.m_ConfigMF0Object.config=jsonencode(aConfiguration);
        end

        function loadJsonFile(this,aConfigFileKey,aConfigFileName)
            aConfigFile=jsondecode(fileread([matlabroot,'/',this.m_DataNamespace,'/',aConfigFileName]));

            if strcmp(aConfigFileKey,this.ConfigConstants.WIDGET_PROPERTIES)
                aConfigFile=maskeditor.internal.loadsave.widgetPropertiesCallbackResolver(aConfigFile,this.m_Context);
            end

            aDataFileMF0Object=simulink.maskeditor.DataFile(this.m_MF0Model,...
            struct('name',aConfigFileKey,'configData',jsonencode(aConfigFile)));

            this.m_ConfigMF0Object.dataFiles.add(aDataFileMF0Object);
        end

        function loadJsonDataFiles(this)
            if this.m_ConfigManager.isDocumentSupported(this.ConfigConstants.PARAMETERS_AND_DIALOG)

                aConfigFileKey=this.ConfigConstants.WIDGETS_LIBRARY;
                aConfigFileFullKey={this.ConfigConstants.PARAMETERS_AND_DIALOG,aConfigFileKey,this.ConfigConstants.CONFIG_FILE};
                this.loadJsonFile(aConfigFileKey,this.m_ConfigManager.getConfig(aConfigFileFullKey));


                aConfigFileKey=this.ConfigConstants.WIDGET_PROPERTIES;
                aConfigFileFullKey={this.ConfigConstants.PARAMETERS_AND_DIALOG,aConfigFileKey,this.ConfigConstants.CONFIG_FILE};
                this.loadJsonFile(aConfigFileKey,this.m_ConfigManager.getConfig(aConfigFileFullKey));
            end

            if this.m_ConfigManager.isDocumentSupported(this.ConfigConstants.ICON)
                aConfigFileKey=this.ConfigConstants.PORT_PROPERTIES;
                aConfigFileFullKey={this.ConfigConstants.ICON,aConfigFileKey,this.ConfigConstants.CONFIG_FILE};
                this.loadJsonFile(aConfigFileKey,this.m_ConfigManager.getConfig(aConfigFileFullKey));

                aConfigFileKey=this.ConfigConstants.MATLAB_DRAWING_COMMANDS;
                aConfigFileFullKey={this.ConfigConstants.ICON,this.ConfigConstants.ICON_AUTHORING,aConfigFileKey,this.ConfigConstants.CONFIG_FILE};
                this.loadJsonFile(aConfigFileKey,this.m_ConfigManager.getConfig(aConfigFileFullKey));
            end
        end

        function loadToolstripJsonFile(this,aConfigFileKey,aConfigFileName)
            aConfigFile=jsondecode(fileread([matlabroot,'/',this.m_DataNamespace,'/',aConfigFileName]));

            aDataFileMF0Object=simulink.maskeditor.ToolstripConfig(this.m_MF0Model,...
            struct('name',aConfigFileKey,'configData',jsonencode(aConfigFile)));

            this.m_ConfigMF0Object.toolstripConfigFiles.add(aDataFileMF0Object);
        end

        function loadToolstripConfigFiles(this)

            aConfigFileKey=this.ConfigConstants.HOME;
            aConfigFileFullKey={aConfigFileKey,this.ConfigConstants.TOOLSTRIP_CONFIG};
            this.loadToolstripJsonFile(aConfigFileKey,this.m_ConfigManager.getConfig(aConfigFileFullKey));

            aDocumentTabs={this.ConfigConstants.PARAMETERS_AND_DIALOG,this.ConfigConstants.CALLBACKS,...
            this.ConfigConstants.ICON,this.ConfigConstants.CONSTRAINT_MANAGER};

            for idx=1:length(aDocumentTabs)
                aConfigFileKey=aDocumentTabs{idx};
                if this.m_ConfigManager.isDocumentSupported(aConfigFileKey)
                    aConfigFileFullKey={aConfigFileKey,this.ConfigConstants.TOOLSTRIP_CONFIG};
                    this.loadToolstripJsonFile(aConfigFileKey,this.m_ConfigManager.getConfig(aConfigFileFullKey));
                end
            end


            aConfigFileKey=this.ConfigConstants.POPUPS;
            aConfigFileFullKey={aConfigFileKey};
            this.loadToolstripJsonFile(aConfigFileKey,this.m_ConfigManager.getConfig(aConfigFileFullKey));


            aConfigFileKey=this.ConfigConstants.QAB;
            aConfigFileFullKey={aConfigFileKey};
            this.loadToolstripJsonFile(aConfigFileKey,this.m_ConfigManager.getConfig(aConfigFileFullKey));
        end

        function bIsSupported=isDocumentSupported(this,aDocumentKey)
            bIsSupported=this.m_ConfigManager.isDocumentSupported(aDocumentKey);
        end
    end
end

