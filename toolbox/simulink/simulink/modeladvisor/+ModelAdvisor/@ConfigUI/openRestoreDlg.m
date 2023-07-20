function openRestoreDlg(varargin)




    caller='';
    if nargin>0
        caller=varargin{1};
    end

    if strcmp(caller,'MACEWeb')
        loc_handleMACECase();
    else

        MAObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;

        if isa(MAObj,'Simulink.ModelAdvisor')


            if~isa(MAObj.ConfigUIWindow,'DAStudio.Explorer')
                warnmsg=DAStudio.message('Simulink:tools:MAWarnResetDefaultConfig');
                response=questdlg(warnmsg,DAStudio.message('Simulink:tools:MAWarning'),...
                DAStudio.message('Simulink:tools:MAContinue'),...
                DAStudio.message('Simulink:tools:MACancel'),...
                DAStudio.message('Simulink:tools:MACancel'));
                if~strcmp(response,DAStudio.message('Simulink:tools:MAContinue'))
                    return;
                end
                ModelAdvisor.setDefaultConfiguration('');



                modelName=bdroot(MAObj.SystemName);
                cs=getActiveConfigSet(modelName);
                if cs.isValidParam('ModelAdvisorConfigurationFile')&&~isempty(get_param(bdroot,'ModelAdvisorConfigurationFile'))
                    set_param(modelName,'ModelAdvisorConfigurationFile','');
                end

                MAObj.activateConfiguration('');
            else
                warndlgHandle=loc_handleMACECase();
                MAObj.DialogCellArray{end+1}=warndlgHandle;
            end
        end
    end

    function warndlgHandle=loc_handleMACECase()
        ModelAdvisor.setDefaultConfiguration('');

        warnDlgHandle=findall(0,'type','figure','Tag','MAResetDefaultConfig');
        if isempty(warnDlgHandle)
            warndlgHandle=warndlg(DAStudio.message('Simulink:tools:MAResetDefaultConfig'));
            set(warndlgHandle,'Tag','MAResetDefaultConfig');
        end













