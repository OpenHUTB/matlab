classdef HardwareSettingsHelper





    methods(Static)




        function setHardwareDevice(hardwareConfig,platform,deviceName)
            import configset.internal.util.HardwareSettingsHelper

            if~isa(hardwareConfig,'Simulink.HardwareCC')
                return;
            end

            hwDevice=HardwareSettingsHelper.getUniqueHardwareDevice(deviceName);
            if isempty(hwDevice)


                return;
            end


            paramName=[platform,'HWDeviceType'];
            oldDevice=hardwareConfig.(paramName);
            convertFromUnknown=strcmp(hardwareConfig.TargetUnknown,'on');

            hardwareConfig.(paramName)=deviceName;

            hwParams=RTW.HWProp.getHardwareParams();
            HardwareSettingsHelper.doUpdateProperties(hardwareConfig,platform,hwParams,hwDevice);

            if strcmp(platform,'Prod')&&isa(hwDevice,'target.internal.FPGA')
                HardwareSettingsHelper.overrideParameter(hardwareConfig,'ProdEqTarget','off');

                HardwareSettingsHelper.overrideParameter(hardwareConfig,...
                'TargetHWDeviceType','Custom Processor->MATLAB Host Computer')
            elseif strcmp(platform,'Target')
                HardwareSettingsHelper.overrideParameter(hardwareConfig,'TargetUnknown','off');
                HardwareSettingsHelper.overrideParameter(hardwareConfig,'ProdEqTarget','off');
            end






            cs=hardwareConfig.getConfigSet();
            if~strcmp(oldDevice,deviceName)&&~convertFromUnknown&&~isempty(cs)
                configset.internal.util.resetInstructionSetExtensionsIfNecessary(cs,paramName);
            end

        end





        function updateHardwareProperties(hardwareConfig,paramsToUpdate)
            import configset.internal.util.HardwareSettingsHelper

            if~isa(hardwareConfig,'Simulink.HardwareCC')
                return;
            end

            HardwareSettingsHelper.updatePropertiesFor(hardwareConfig,'Prod',paramsToUpdate);


            updateTarget=strcmp(get_param(hardwareConfig,'ProdEqTarget'),'off');
            if updateTarget
                HardwareSettingsHelper.updatePropertiesFor(hardwareConfig,'Target',paramsToUpdate);
            end
        end

        function incorrectHardwareUpdate(hardwareConfig,incorrectHardware,varargin)
            import configset.internal.util.HardwareSettingsHelper

            if~isa(hardwareConfig,'Simulink.HardwareCC')
                return;
            end

            HardwareSettingsHelper.incorrectHardwareUpdateFor(hardwareConfig,'Prod',incorrectHardware,varargin);


            updateTarget=strcmp(get_param(hardwareConfig,'ProdEqTarget'),'off');
            if updateTarget
                HardwareSettingsHelper.incorrectHardwareUpdateFor(hardwareConfig,'Target',incorrectHardware,varargin);
            end
        end
    end

    methods(Static,Access=private)
        function incorrectHardwareUpdateFor(hardwareConfig,platform,incorrectHardware,incorrectParameters)
            import configset.internal.util.HardwareSettingsHelper

            deviceParam=[platform,'HWDeviceType'];
            deviceName=get_param(hardwareConfig,deviceParam);
            hwDevice=HardwareSettingsHelper.getUniqueHardwareDevice(deviceName);
            if(~isempty(hwDevice)&&strcmp(hwDevice.getQualifiedParameterString(),incorrectHardware))
                diffStrings=HardwareSettingsHelper.doUpdateProperties(hardwareConfig,platform,incorrectParameters,hwDevice);

                if~isempty(diffStrings)
                    MSLDiagnostic('Simulink:ConfigSet:Hardware_UpdatedBadValue',deviceParam,deviceName,strjoin(diffStrings,'\n')).reportAsWarning;
                end
            end
        end

        function updatePropertiesFor(hardwareConfig,platform,paramsToUpdate)
            import configset.internal.util.HardwareSettingsHelper

            deviceName=get_param(hardwareConfig,[platform,'HWDeviceType']);

            hwDevice=HardwareSettingsHelper.getUniqueHardwareDevice(deviceName);
            if isempty(hwDevice)


                return;
            end


            HardwareSettingsHelper.doUpdateProperties(hardwareConfig,platform,paramsToUpdate,hwDevice);
        end

        function diffStrings=doUpdateProperties(hardwareConfig,platform,props,hwDevice)
            import configset.internal.util.HardwareSettingsHelper

            if(hwDevice.Platform==target.internal.compatibility.HardwareImplementationPlatform.Target&&isequal(platform,'Prod'))
                DAStudio.error('Simulink:dialog:DeviceNotSuitable');
            elseif(hwDevice.Platform==target.internal.compatibility.HardwareImplementationPlatform.Production&&isequal(platform,'Target'))
                DAStudio.error('Simulink:dialog:DeviceNotSuitableEmulation');
            end

            hwSettings=RTW.getParameterMapForTargetRepositoryObject(hwDevice);

            if nargout==0
                cellfun(@(p)HardwareSettingsHelper.setDeviceValue(...
                hardwareConfig,hwSettings,platform,p),...
                props,'UniformOutput',false);
            else
                diffStrings=cellfun(@(p)HardwareSettingsHelper.setDeviceValue(...
                hardwareConfig,hwSettings,platform,p),...
                props,'UniformOutput',false);


                diffStrings(strcmp('',diffStrings))=[];
            end
        end

        function hwDevice=getUniqueHardwareDevice(deviceName)





            persistent queryString
            persistent result

            if isempty(queryString)||~strcmp(queryString,deviceName)||(~isempty(result)&&~isvalid(result))
                hh=targetrepository.getHardwareImplementationHelper();
                device=hh.getDevice(deviceName);

                if isempty(device)||length(device)>1
                    result=[];
                else
                    result=device;
                end

                queryString=deviceName;
            end

            hwDevice=result;
        end

        function diffString=setDeviceValue(hardwareConfig,hwSettings,prefix,prop)


            newValue=hwSettings.(prop);

            param=[prefix,prop];

            if(isequal(get_param(hardwareConfig,[prefix,'HWDeviceType']),'Unspecified'))
                currentValue='N/A';
            else
                currentValue=get_param(hardwareConfig,param);
            end


            if nargout~=0
                if isequal(currentValue,newValue)
                    diffString='';
                else
                    diffString=sprintf('''%s'': %s -> %s',param,num2str(currentValue),num2str(newValue));
                end
            end

            configset.internal.util.HardwareSettingsHelper.overrideParameter(hardwareConfig,param,newValue);
        end

        function overrideParameter(hardwareConfig,param,val)
            oldEnable=getPropEnabled(hardwareConfig,param);
            setPropEnabled(hardwareConfig,param,true);
            hardwareConfig.(param)=val;
            setPropEnabled(hardwareConfig,param,oldEnable);
        end
    end
end

