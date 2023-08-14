classdef hdlvAppContext<dig.CustomContext













    properties(SetAccess=protected)
origTypeChain
modelH
studio
app
workflowContext
workflowDlgObj
    end

    properties(SetObservable=true)
systemTLCFileListener
selectedWorkflowContextListener
    end

    methods

        function obj=hdlvAppContext(app,cbinfo,workflowDlgObj)
            obj@dig.CustomContext(app);
            obj.modelH=cbinfo.model.Handle;
            obj.studio=cbinfo.studio;
            obj.app=app;
            obj.origTypeChain=obj.TypeChain;
            obj.workflowDlgObj=workflowDlgObj;
            obj.workflowContext=workflowDlgObj.selectedWorkflowContext;
            obj.updateTypeChain();
        end

        function updateTypeChain(obj)
            obj.TypeChain=[{obj.workflowContext},obj.origTypeChain];
        end

        function setupListeners(obj)

            obj.systemTLCFileListener=configset.ParamListener(obj.modelH,'SystemTargetFile',@obj.systemTLCFileChangeCB);

            obj.selectedWorkflowContextListener=addlistener(obj.workflowDlgObj,'selectedWorkflowContext','PostSet',@obj.selectedWorkflowContextChangeCB);
        end

        function selectedWorkflowContextChangeCB(obj,metaProp,eventData)

            obj.workflowContext=eventData.AffectedObject.selectedWorkflowContext;






            isSafeToLaunchApp=obj.setSystemTLCFileUponLaunch();
            if~isSafeToLaunchApp




                return;
            end
            obj.updateTypeChain();
        end


        function systemTLCFileChangeCB(obj,modelHandle,modelParam,newTLC)




            supportedTLCs_DPIC={'systemverilog_dpi_grt.tlc','systemverilog_dpi_ert.tlc'};
            supportedTLCs_UVM={'systemverilog_dpi_grt.tlc','systemverilog_dpi_ert.tlc'};
            supportedTLCs_TLM={'tlmgenerator_grt.tlc','tlmgenerator_ert.tlc'};

            switch obj.workflowContext
            case{'hdlvDPIContext'}

                if isempty(intersect(newTLC,supportedTLCs_DPIC))
                    obj.throwNotificationBanner('EDALink:SLToolstrip:DPIC:dpiCloseAppDueToTLCChange',newTLC);
                    obj.forceCloseApp();
                end
            case{'hdlvUVMContext'}

                if isempty(intersect(newTLC,supportedTLCs_UVM))
                    obj.throwNotificationBanner('EDALink:SLToolstrip:UVM:uvmCloseAppDueToTLCChange',newTLC);
                    obj.forceCloseApp();
                end
            case{'hdlvTLMGContext'}

                if isempty(intersect(newTLC,supportedTLCs_TLM))
                    obj.throwNotificationBanner('EDALink:SLToolstrip:TLM:tlmCloseAppDueToTLCChange',newTLC);
                    obj.forceCloseApp();
                end
            otherwise





















            end
        end

        function throwNotificationBanner(obj,msgID,newValue)

            msg=message(msgID,newValue).getString;
            editor=obj.studio.App.getActiveEditor;
            editor.deliverInfoNotification('hdlvCloseAppDueToPropertyChange',msg);
        end

        function forceCloseApp(obj)

            ts=obj.studio.getToolStrip;
            as=ts.getActionService;
            as.executeActionSync(obj.app.appActionName,false);
        end

        function isSafeToLaunchApp=setSystemTLCFileUponLaunch(obj)

            isSafeToLaunchApp=true;
            switch obj.workflowContext
            case{'hdlvDPIContext'}

                if dig.isProductInstalled('Embedded Coder')
                    set_param(obj.modelH,'SystemTargetFile','systemverilog_dpi_ert.tlc');
                elseif dig.isProductInstalled('Simulink Coder')
                    set_param(obj.modelH,'SystemTargetFile','systemverilog_dpi_grt.tlc');
                else


                    isSafeToLaunchApp=false;
                    obj.throwNotificationBanner('EDALink:SLToolstrip:DPIC:dpiCloseAppDueToNoTLC','');
                end
            otherwise

            end

        end

    end
end
