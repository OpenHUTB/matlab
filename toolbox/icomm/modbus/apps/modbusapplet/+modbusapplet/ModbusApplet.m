classdef ModbusApplet<matlab.hwmgr.internal.AppletBase








    properties(Access=public)
AppletSpaceManager
ModbusManager
Mediator
DialogDisplayManager
ToolstripTabManager
MatFileManager
GenerateScriptManager



MasterGrid

        ConnectionFailed(1,1)logical
    end

    properties(Access=private)

WarningListener
ErrorListener
OptionListener
    end

    properties(Constant)
        DisplayName=message('modbusapplet:modbusapplet:appDisplayName').getString
        IconLocation=fullfile(matlabroot,...
        'toolbox','icomm','modbus','apps','modbusapplet','icons','modbusExplorer_24.png')
    end

    methods(Access=private)
        function createDialogListeners(obj)


            obj.ErrorListener=listener(obj.DialogDisplayManager,'ErrorInfo',...
            'PostSet',@(src,event)obj.requestErrorDialog(event.AffectedObject.ErrorInfo));

            obj.WarningListener=listener(obj.DialogDisplayManager,'WarningInfo',...
            'PostSet',@(src,event)obj.requestWarningDialog(event.AffectedObject.WarningInfo));

            obj.OptionListener=listener(obj.DialogDisplayManager,"OptionInfo",...
            "PostSet",@(src,event)obj.requestOptionDialog(event.AffectedObject.OptionInfo));
        end

        function clearDialogListeners(obj)

            delete(obj.ErrorListener);
            delete(obj.WarningListener);
            delete(obj.OptionListener);
        end
    end

    methods
        function obj=ModbusApplet()
            try

                matlab.internal.licensing.checkoutProductLicense("OT");
            catch ex
                error(message('icommprovider:devicedescriptor:NotLicensed'));
            end
        end
    end

    methods
        function init(obj,hwmgrHandles)



            init@matlab.hwmgr.internal.AppletBase(obj,hwmgrHandles)

            obj.ConnectionFailed=false;



            obj.Mediator=matlabshared.mediator.internal.Mediator;



            obj.DialogDisplayManager=modbusapplet.modules.DialogDisplayManager(obj.Mediator,obj.RootWindow,...
            obj.DisplayName);
            obj.createDialogListeners();



            obj.ToolstripTabManager=modbusapplet.modules.ToolstripTabManager(...
            obj.Mediator,obj.ToolstripTabHandle);





            obj.AppletSpaceManager=modbusapplet.modules.AppletSpaceManager(obj.Mediator,obj.RootWindow,...
            obj.DeviceInfo.CustomData);





            obj.ModbusManager=modbusapplet.modules.ModbusManager(obj.Mediator,obj.DeviceInfo.CustomData);




            obj.MatFileManager=modbusapplet.modules.MatFileManager(obj.Mediator,...
            obj.DeviceInfo.CustomData.ServerId);




            obj.GenerateScriptManager=modbusapplet.modules.GenerateScriptManager...
            (obj.Mediator,obj.DeviceInfo.CustomData);
        end

        function construct(obj)


            obj.ToolstripTabHandle.Title=...
            message('modbusapplet:modbusapplet:tabTitleName').getString;


            obj.Mediator.connect();

            try




                obj.ModbusManager.connect();
            catch



                obj.ConnectionFailed=true;
            end


            if~obj.ConnectionFailed


                obj.ModbusManager.initializeTimer();



                obj.AppletSpaceManager.connect();
            end
        end

        function run(obj)


            if obj.ConnectionFailed
                closeReason=matlab.hwmgr.internal.AppletClosingReason.AppError;
                obj.closeApplet(closeReason);
            end
        end

        function destroy(obj)


            if~obj.ConnectionFailed

                obj.AppletSpaceManager.clearRegisterTable();


                obj.ModbusManager.disconnect();
            end

            obj.Mediator.disconnect();


            obj.clearDialogListeners();


            delete(obj.DialogDisplayManager);
            delete(obj.AppletSpaceManager);
            delete(obj.ToolstripTabManager);
            delete(obj.MatFileManager);
            delete(obj.GenerateScriptManager);
            delete(obj.ModbusManager);
            delete(obj.Mediator);
        end

        function requestErrorDialog(obj,errorInfo)
            obj.showError(errorInfo.Title,errorInfo.Message);
        end

        function requestWarningDialog(obj,warningInfo)
            obj.showWarning(warningInfo.Title,warningInfo.Message);
        end

        function requestOptionDialog(obj,optionInfo)
            val=obj.showConfirm(optionInfo.Title,optionInfo.Message,...
            optionInfo.Options,optionInfo.DefaultOption);
            obj.DialogDisplayManager.setOptionDialogResponse(optionInfo.Action,val);
        end

        function icon=getIcon(obj)
            icon=matlab.ui.internal.toolstrip.Icon(obj.IconLocation);
        end

        function okayToClose=canClose(obj,closeReason)




            if obj.ConnectionFailed
                okayToClose=true;

            else




                obj.AppletSpaceManager.disconnect();

                switch closeReason
                case 'DeviceChange'
                    warningStr=getString(message('modbusapplet:modbusapplet:connectionStop','Changing devices'));
                case{'AppClosing','CloseRunningApplet'}
                    warningStr=getString(message('modbusapplet:modbusapplet:connectionStop','Closing Modbus Explorer'));
                case 'RefreshHardware'
                    warningStr=getString(message('modbusapplet:modbusapplet:connectionStop','Refreshing the device list'));
                case 'DeviceRemove'
                    warningStr=getString(message('modbusapplet:modbusapplet:connectionStop','Removing the device'));
                otherwise
                    assert(false,'Unknown app closing reason!');
                end
                yesOptionText=string(getString(message('modbusapplet:modbusapplet:yesText')));
                noOptionText=string(getString(message('modbusapplet:modbusapplet:noText')));

                result=matlab.hwmgr.internal.DialogFactory.constructConfirmationDialog(...
                matlab.hwmgr.internal.util.getGlobalDialogParent,...
                warningStr,obj.DisplayName,...
                'Options',[string(yesOptionText),string(noOptionText)],...
                'DefaultOption',2);
                result=strcmp(result,string(yesOptionText));


                okayToClose=(result==1);

                if~okayToClose


                    obj.AppletSpaceManager.reconnect();
                end
            end
        end
    end
end