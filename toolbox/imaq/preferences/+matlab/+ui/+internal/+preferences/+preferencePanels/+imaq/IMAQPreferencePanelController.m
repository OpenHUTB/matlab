classdef IMAQPreferencePanelController<handle





    properties
View
Model
    end

    properties(Access=private)
ViewEventListenerHandles
    end

    properties(Access=private,Constant)
        MacvideoDiscoveryTimeoutMin=matlab.ui.internal.preferences.preferencePanels.imaq.Constants.MacvideoDiscoveryTimeoutMin
        MacvideoDiscoveryTimeoutMax=matlab.ui.internal.preferences.preferencePanels.imaq.Constants.MacvideoDiscoveryTimeoutMax
        MacvideoDiscoveryTimeoutStep=matlab.ui.internal.preferences.preferencePanels.imaq.Constants.MacvideoDiscoveryTimeoutStep

        GigePacketAckTimeoutMin=matlab.ui.internal.preferences.preferencePanels.imaq.Constants.GigePacketAckTimeoutMin
        GigePacketAckTimeoutMax=matlab.ui.internal.preferences.preferencePanels.imaq.Constants.GigePacketAckTimeoutMax
        GigePacketAckTimeoutStep=matlab.ui.internal.preferences.preferencePanels.imaq.Constants.GigePacketAckTimeoutStep

        GigeHeartbeatTimeoutMin=matlab.ui.internal.preferences.preferencePanels.imaq.Constants.GigeHeartbeatTimeoutMin
        GigeHeartbeatTimeoutMax=matlab.ui.internal.preferences.preferencePanels.imaq.Constants.GigeHeartbeatTimeoutMax
        GigeHeartbeatTimeoutStep=matlab.ui.internal.preferences.preferencePanels.imaq.Constants.GigeHeartbeatTimeoutStep

        GigeCommandRetriesMin=matlab.ui.internal.preferences.preferencePanels.imaq.Constants.GigeCommandRetriesMin
        GigeCommandRetriesMax=matlab.ui.internal.preferences.preferencePanels.imaq.Constants.GigeCommandRetriesMax
        GigeCommandRetriesStep=matlab.ui.internal.preferences.preferencePanels.imaq.Constants.GigeCommandRetriesStep
    end

    methods
        function obj=IMAQPreferencePanelController(view,model)
            obj.View=view;
            obj.Model=model;

            obj.setInitialPreferenceValuesOnView();

            obj.setupViewEventListeners();
        end

        function delete(obj)
            delete(obj.View);
            delete(obj.Model);
            delete(obj.ViewEventListenerHandles);
        end

        function result=commit(obj)

            if ismac()
                result=obj.Model.commitPreferences(...
                "MacvideoDiscoveryTimeout",obj.View.getMacvideoDiscoveryTimeout(),...
                "GigeCommandRetries",obj.View.getGigeCommandRetries(),...
                "GigeHeartbeatTimeout",obj.View.getGigeHeartbeatTimeout(),...
                "GigePacketAckTimeout",obj.View.getGigePacketAckTimeout(),...
                "GigeDisableForceIP",obj.View.getGigeDisableForceIP()...
                );
            else
                result=obj.Model.commitPreferences(...
                "GigeCommandRetries",obj.View.getGigeCommandRetries(),...
                "GigeHeartbeatTimeout",obj.View.getGigeHeartbeatTimeout(),...
                "GigePacketAckTimeout",obj.View.getGigePacketAckTimeout(),...
                "GigeDisableForceIP",obj.View.getGigeDisableForceIP()...
                );
            end

        end
    end

    methods(Access='private')

        function setInitialPreferenceValuesOnView(obj)

            preferenceStruct=obj.Model.getPreferenceValues();


            if ismac()
                obj.View.setMacvideoDiscoveryTimeout(preferenceStruct.MacvideoDiscoveryTimeout);
            end
            obj.View.setGigePacketAckTimeout(preferenceStruct.GigePacketAckTimeout);
            obj.View.setGigeHeartbeatTimeout(preferenceStruct.GigeHeartbeatTimeout);
            obj.View.setGigeCommandRetries(preferenceStruct.GigeCommandRetries);
            obj.View.setGigeDisableForceIP(preferenceStruct.GigeDisableForceIP);
        end

        function setupViewEventListeners(obj)

            obj.ViewEventListenerHandles=[...
            listener(obj.View,"MacvideoDiscoveryTimeoutChanged","PostSet",...
            @(src,event)obj.handleMacvideoDiscoveryTimeoutChanged(event.AffectedObject.MacvideoDiscoveryTimeoutChanged)),...
            listener(obj.View,"GigePacketAckTimeoutChanged","PostSet",...
            @(src,event)obj.handleGigePacketAckTimeoutChanged(event.AffectedObject.GigePacketAckTimeoutChanged)),...
            listener(obj.View,"GigeHeartbeatTimeoutChanged","PostSet",...
            @(src,event)obj.handleGigeHeartbeatTimeoutChanged(event.AffectedObject.GigeHeartbeatTimeoutChanged)),...
            listener(obj.View,"GigeCommandRetriesChanged","PostSet",...
            @(src,event)obj.handleGigeCommandRetriesChanged(event.AffectedObject.GigeCommandRetriesChanged)),...
            listener(obj.View,"GigeDisableForceIPEnabled","PostSet",...
            @(src,event)obj.handleGigeDisableForceIPEnabled(event.AffectedObject.GigeDisableForceIPEnabled)),...
            ];
        end

        function roundedValue=roundUp(~,value,step)

            roundedValue=step*ceil(value/step);
        end

    end

    methods(Access={?matlab.ui.internal.preferences.preferencePanels.imaq.ITestable})


        function handleMacvideoDiscoveryTimeoutChanged(obj,userDiscoveryTimeout)

            roundedTimeout=obj.roundUp(userDiscoveryTimeout,obj.MacvideoDiscoveryTimeoutStep);


            if roundedTimeout>obj.MacvideoDiscoveryTimeoutMax
                roundedTimeout=obj.MacvideoDiscoveryTimeoutMax;
            elseif roundedTimeout<obj.MacvideoDiscoveryTimeoutMin
                roundedTimeout=obj.MacvideoDiscoveryTimeoutMin;
            end

            obj.View.setMacvideoDiscoveryTimeout(roundedTimeout);
        end

        function handleGigePacketAckTimeoutChanged(obj,userAckTimeout)

            roundedTimeout=obj.roundUp(userAckTimeout,obj.GigePacketAckTimeoutStep);


            if roundedTimeout>obj.GigePacketAckTimeoutMax
                roundedTimeout=obj.GigePacketAckTimeoutMax;
            elseif roundedTimeout<obj.GigePacketAckTimeoutMin
                roundedTimeout=obj.GigePacketAckTimeoutMin;
            end

            obj.View.setGigePacketAckTimeout(roundedTimeout);
        end

        function handleGigeHeartbeatTimeoutChanged(obj,userHeartbeatTimeout)

            roundedTimeout=obj.roundUp(userHeartbeatTimeout,obj.GigeHeartbeatTimeoutStep);


            if roundedTimeout>obj.GigeHeartbeatTimeoutMax
                roundedTimeout=obj.GigeHeartbeatTimeoutMax;
            elseif roundedTimeout<obj.GigeHeartbeatTimeoutMin
                roundedTimeout=obj.GigeHeartbeatTimeoutMin;
            end

            obj.View.setGigeHeartbeatTimeout(roundedTimeout);
        end

        function handleGigeCommandRetriesChanged(obj,userRetries)

            roundedRetries=obj.roundUp(userRetries,obj.GigeCommandRetriesStep);


            if roundedRetries>obj.GigeCommandRetriesMax
                roundedRetries=obj.GigeCommandRetriesMax;
            elseif roundedRetries<obj.GigeCommandRetriesMin
                roundedRetries=obj.GigeCommandRetriesMin;
            end

            obj.View.setGigeCommandRetries(roundedRetries);
        end

        function handleGigeDisableForceIPEnabled(obj,userDisableForceIP)


            obj.View.setGigeDisableForceIP(userDisableForceIP);
        end
    end
end

