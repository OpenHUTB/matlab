classdef ConfigManager
    properties
        m_Config;
    end

    properties(Constant)
        ConfigConstants=maskeditor.internal.loadsave.ConfigConstants();
    end

    methods
        function obj=ConfigManager(aConfig)
            obj.m_Config=aConfig;
        end

        function aConfig=getConfig(this,aConfigFileFullKey)
            if isempty(aConfigFileFullKey)
                aConfig=this.m_Config;
            else
                aConfig=getfield(this.m_Config,aConfigFileFullKey{:});
            end
        end

        function[this]=setConfig(this,aConfigFileFullKey,aNewValue)
            this.m_Config=setfield(this.m_Config,aConfigFileFullKey{:},aNewValue);
        end

        function aLoadSourceFile=getLoadSourceFile(this)
            aLoadSourceFile=this.m_Config.(this.ConfigConstants.LOAD_DATA).(this.ConfigConstants.LOAD_SRC_FILE);
        end

        function aPPLoadSourceFile=getPPLoadSourceFile(this)
            aPPLoadSourceFile=this.m_Config.(this.ConfigConstants.PARAMETERS_AND_DIALOG).(this.ConfigConstants.PARAMETER_PROMOTION).(this.ConfigConstants.LOAD_SRC_FILE);
        end

        function aSaveSourceFile=getSaveSourceFile(this)
            aSaveSourceFile=this.m_Config.(this.ConfigConstants.SAVE_DATA).(this.ConfigConstants.SAVE_SRC_FILE);
        end

        function bIsSupported=isDocumentSupported(this,aDocumentKey)
            bIsSupported=false;
            if isfield(this.m_Config,aDocumentKey)
                bIsSupported=true;
                if isfield(this.m_Config.(aDocumentKey),this.ConfigConstants.IS_DOCUMENT_SUPPORTED)
                    bIsSupported=eval(this.m_Config.(aDocumentKey).(this.ConfigConstants.IS_DOCUMENT_SUPPORTED));
                end
            end
        end

        function isSupported=isParameterPromotionSupported(this)
            isSupported=false;
            if~this.isDocumentSupported(this.ConfigConstants.PARAMETERS_AND_DIALOG)
                return;
            end

            if isfield(this.m_Config.(this.ConfigConstants.PARAMETERS_AND_DIALOG),(this.ConfigConstants.PARAMETER_PROMOTION))
                isSupported=true;
                if isfield(this.m_Config.(this.ConfigConstants.PARAMETERS_AND_DIALOG).(this.ConfigConstants.PARAMETER_PROMOTION),this.ConfigConstants.IS_DOCUMENT_SUPPORTED)
                    isSupported=eval(this.m_Config.(this.ConfigConstants.PARAMETERS_AND_DIALOG).(this.ConfigConstants.PARAMETER_PROMOTION).(this.ConfigConstants.IS_DOCUMENT_SUPPORTED));
                end
            end
        end

    end
end

