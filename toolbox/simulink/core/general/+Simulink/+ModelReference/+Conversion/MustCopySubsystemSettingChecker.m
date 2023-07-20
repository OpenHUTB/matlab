classdef MustCopySubsystemSettingChecker<handle




    properties
ConversionData
ConversionParameters
currentSubsystem
    end
    methods(Access=public)
        function this=MustCopySubsystemSettingChecker(ConversionData,currentSubsystem)
            this.ConversionData=ConversionData;
            this.ConversionParameters=ConversionData.ConversionParameters;
            this.currentSubsystem=currentSubsystem;
        end

        function check(this)
            blockName=get_param(this.currentSubsystem,'Name');
            atomicSubsystem='off';
            inlineSubsystem=false;
            [~,inlineSubsystem,~]=this.checkForSubsystemSettings(atomicSubsystem,inlineSubsystem,blockName);
            if~inlineSubsystem
                this.ConversionData.MustCopySubsystem=true;
            end
        end
    end
    methods(Access=private)
        function[atomicSubsystem,inlineSubsystem,blockName]=checkForSubsystemSettings(this,atomicSubsystem,inlineSubsystem,blockName)
            if(strcmp(get_param(this.currentSubsystem,'IsSubsystemVirtual'),'off'))
                atomicSubsystem='on';
                rtwSystemCode=get_param(this.currentSubsystem,'RTWSystemCode');
                if(strcmp(rtwSystemCode,'Inline')||strcmp(rtwSystemCode,'Auto'))
                    inlineSubsystem=isequal(get_param(this.currentSubsystem,'Variant'),'off');
                elseif strcmp(rtwSystemCode,'Nonreusable function')
                    rtwFcnNameOpts=get_param(this.currentSubsystem,'RTWFcnNameOpts');
                    if strcmp(rtwFcnNameOpts,'Auto')||strcmp(rtwFcnNameOpts,'Use subsystem name')||...
                        this.ConversionParameters.SS2mdlForSLDV||this.ConversionParameters.SS2mdlForPLC
                        functionName=blockName;
                    else
                        functionName=get_param(this.currentSubsystem,'RTWFcnName');
                    end
                    rtwFileNameOpts=get_param(this.currentSubsystem,'RTWFileNameOpts');
                    if strcmp(rtwFileNameOpts,'Use subsystem name')||this.ConversionParameters.SS2mdlForSLDV||...
                        this.ConversionParameters.SS2mdlForPLC
                        fileName=blockName;
                    elseif strcmp(rtwFileNameOpts,'Auto')||strcmp(rtwFileNameOpts,'Use function name')
                        fileName=functionName;
                    else
                        fileName=get_param(this.currentSubsystem,'RTWFileName');
                    end

                    if~isempty(functionName)&&~all(isspace(functionName))&&...
                        strcmp(functionName,fileName)
                        blockName=functionName;
                        inlineSubsystem=isequal(get_param(this.currentSubsystem,'Variant'),'off');
                    end
                end
            end
        end
    end
end


