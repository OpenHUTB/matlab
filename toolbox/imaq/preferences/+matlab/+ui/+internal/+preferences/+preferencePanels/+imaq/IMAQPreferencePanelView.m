classdef IMAQPreferencePanelView<matlab.mixin.SetGetExactNames







    properties(Access=private)

MasterGrid

GigePacketAckTimeoutField
GigeHeartbeatTimeoutField
GigeCommandRetriesField
GigeDisableForceIPField

MacvideoDiscoveryTimeoutField
    end

    properties(SetObservable)
GigePacketAckTimeoutChanged
GigeHeartbeatTimeoutChanged
GigeCommandRetriesChanged
GigeDisableForceIPEnabled

MacvideoDiscoveryTimeoutChanged
    end

    properties(Constant,Access=private)
        MacvideoRow=1
        GigeRow=2
        ImaqresetMessageRow=3


        GigePacketAckTimeoutStep=matlab.ui.internal.preferences.preferencePanels.imaq.Constants.GigePacketAckTimeoutStep
        GigeHeartbeatTimeoutStep=matlab.ui.internal.preferences.preferencePanels.imaq.Constants.GigeHeartbeatTimeoutStep
        GigeCommandRetriesStep=matlab.ui.internal.preferences.preferencePanels.imaq.Constants.GigeCommandRetriesStep
        MacvideoDiscoveryTimeoutStep=matlab.ui.internal.preferences.preferencePanels.imaq.Constants.MacvideoDiscoveryTimeoutStep
    end

    methods
        function obj=IMAQPreferencePanelView(figureHandle)
            obj.MasterGrid=uigridlayout(figureHandle,[3,1]);



            obj.MasterGrid.RowHeight={'fit','fit','fit'};
            obj.MasterGrid.ColumnWidth={'fit'};

            if ismac()

                obj.drawMacvideoSection();
            end

            obj.drawGigeSection();

            obj.drawImaqresetMessage();

            obj.addPreferenceEditListeners();
        end

        function delete(obj)
            delete(obj.MasterGrid);
        end

    end

    methods(Access=?matlab.ui.internal.preferences.preferencePanels.imaq.IMAQPreferencePanelController)


        function setGigePacketAckTimeout(obj,timeout)
            obj.GigePacketAckTimeoutField.Value=timeout;
        end

        function setGigeHeartbeatTimeout(obj,timeout)
            obj.GigeHeartbeatTimeoutField.Value=timeout;
        end

        function setGigeCommandRetries(obj,retries)
            obj.GigeCommandRetriesField.Value=retries;
        end

        function setGigeDisableForceIP(obj,disable)
            obj.GigeDisableForceIPField.Value=disable;
        end

        function setMacvideoDiscoveryTimeout(obj,timeout)
            obj.MacvideoDiscoveryTimeoutField.Value=timeout;
        end

        function timeout=getGigePacketAckTimeout(obj)
            timeout=obj.GigePacketAckTimeoutField.Value;
        end

        function timeout=getGigeHeartbeatTimeout(obj)
            timeout=obj.GigeHeartbeatTimeoutField.Value;
        end

        function retries=getGigeCommandRetries(obj)
            retries=obj.GigeCommandRetriesField.Value;
        end

        function disable=getGigeDisableForceIP(obj)
            disable=obj.GigeDisableForceIPField.Value;
        end

        function timeout=getMacvideoDiscoveryTimeout(obj)
            timeout=obj.MacvideoDiscoveryTimeoutField.Value;
        end
    end

    methods(Access=private)


        function drawMacvideoSection(obj)
            macvideoGrid=uigridlayout(obj.MasterGrid,[2,3]);
            macvideoGrid.Layout.Row=obj.MacvideoRow;
            macvideoGrid.RowHeight={'fit','fit'};
            macvideoGrid.ColumnWidth={'fit','fit','fit'};
            macvideoGrid.RowSpacing=4;

            macvideoSectionTitleText=getString(message("imaq:preferencepanel:macvideoSectionTitle"));
            label=obj.drawSectionLabel(macvideoGrid,macvideoSectionTitleText);
            label.Tag="MacvideoSectionLabel";

            discoveryTimeoutText=getString(message("imaq:preferencepanel:macvideoDiscoveryTimeout"));
            discoveryTimeoutUnits=getString(message("imaq:preferencepanel:millisecondsLabel"));
            discoveryTimeoutStep=obj.MacvideoDiscoveryTimeoutStep;
            [obj.MacvideoDiscoveryTimeoutField,label,unitLabel]=obj.drawIntegerPreferenceWithUnits(macvideoGrid,discoveryTimeoutText,discoveryTimeoutStep,discoveryTimeoutUnits,2);

            obj.MacvideoDiscoveryTimeoutField.Tag="MacvideoDiscoveryTimeout";
            label.Tag="MacvideoDiscoveryTimeoutLabel";
            unitLabel.Tag="MacvideoDiscoveryTimeoutUnits";
        end

        function drawGigeSection(obj)
            gigeGrid=uigridlayout(obj.MasterGrid,[5,3]);
            gigeGrid.Layout.Row=obj.GigeRow;
            gigeGrid.RowHeight=repmat({'fit'},1,5);
            gigeGrid.ColumnWidth={'fit','fit','fit'};
            gigeGrid.RowSpacing=4;

            gigeSectionTitleText=getString(message("imaq:preferencepanel:gigeSectionTitle"));
            label=obj.drawSectionLabel(gigeGrid,gigeSectionTitleText);
            label.Tag="GigeSectionLabel";

            packetAckTimeoutText=getString(message("imaq:preferencepanel:gigePacketAckTimeout"));
            packetAckUnitsText=getString(message("imaq:preferencepanel:millisecondsLabel"));
            packetAckStep=obj.GigePacketAckTimeoutStep;
            [obj.GigePacketAckTimeoutField,label,unitLabel]=obj.drawIntegerPreferenceWithUnits(gigeGrid,packetAckTimeoutText,packetAckStep,packetAckUnitsText,2);
            obj.GigePacketAckTimeoutField.Tag="GigeAckTimeout";
            label.Tag="GigeAckTimeoutLabel";
            unitLabel.Tag="GigeAckTimeoutUnits";

            heartbeatTimeoutText=getString(message("imaq:preferencepanel:gigeHeartbeatTimeout"));
            heartbeatTimeoutUnitsText=getString(message("imaq:preferencepanel:millisecondsLabel"));
            heartbeatTimeoutStep=obj.GigeHeartbeatTimeoutStep;
            [obj.GigeHeartbeatTimeoutField,label,unitLabel]=obj.drawIntegerPreferenceWithUnits(gigeGrid,heartbeatTimeoutText,heartbeatTimeoutStep,heartbeatTimeoutUnitsText,3);
            obj.GigeHeartbeatTimeoutField.Tag="GigeHeartbeatTimeout";
            label.Tag="GigeHeartbeatTimeoutLabel";
            unitLabel.Tag="GigeHeartbeatTimeoutUnits";


            packetRetriesText=getString(message("imaq:preferencepanel:gigeCommandRetries"));
            packetRetriesStep=obj.GigeCommandRetriesStep;
            [obj.GigeCommandRetriesField,label]=obj.drawIntegerPreference(gigeGrid,packetRetriesText,packetRetriesStep,4);
            obj.GigeCommandRetriesField.Tag="GigeCommandRetries";
            label.Tag="GigeCommandRetriesLabel";

            cameraIPCorrectionText=getString(message("imaq:preferencepanel:gigeDisableForceIP"));
            obj.GigeDisableForceIPField=obj.drawLogicalPreference(gigeGrid,cameraIPCorrectionText,5);
            obj.GigeDisableForceIPField.Tag="GigeDisableForceIP";
        end

        function drawImaqresetMessage(obj)


            messageGrid=uigridlayout(obj.MasterGrid,[1,1]);
            messageGrid.Layout.Row=obj.ImaqresetMessageRow;

            imaqresetMessageText=getString(message("imaq:preferencepanel:callimaqreset"));
            uilabel(messageGrid,"Text",imaqresetMessageText);
        end

        function addPreferenceEditListeners(obj)
            if ismac()
                obj.MacvideoDiscoveryTimeoutField.ValueChangedFcn=@(src,event)set(obj,"MacvideoDiscoveryTimeoutChanged",src.Value);
            end
            obj.GigePacketAckTimeoutField.ValueChangedFcn=@(src,event)set(obj,"GigePacketAckTimeoutChanged",src.Value);
            obj.GigeHeartbeatTimeoutField.ValueChangedFcn=@(src,event)set(obj,"GigeHeartbeatTimeoutChanged",src.Value);
            obj.GigeCommandRetriesField.ValueChangedFcn=@(src,event)set(obj,"GigeCommandRetriesChanged",src.Value);
            obj.GigeDisableForceIPField.ValueChangedFcn=@(src,event)set(obj,"GigeDisableForceIPEnabled",src.Value);
        end



        function label=drawSectionLabel(~,gridHandle,labelText)


            label=uilabel(gridHandle,"Text",labelText,"FontWeight","bold");
            label.Layout.Row=1;
            label.Layout.Column=[1,2];
        end

        function[field,label]=drawIntegerPreference(~,gridHandle,labelText,step,row)
            label=uilabel(gridHandle,"Text",labelText);
            label.Layout.Row=row;
            label.Layout.Column=1;

            field=uispinner(gridHandle,...
            "RoundFractionalValues","on","Step",step);
            field.Layout.Row=row;
            field.Layout.Column=2;
        end

        function[field,label,unitLabel]=drawIntegerPreferenceWithUnits(obj,gridHandle,labelText,step,unitText,row)
            [field,label]=obj.drawIntegerPreference(gridHandle,labelText,step,row);
            unitLabel=uilabel(gridHandle,"Text",unitText);
            unitLabel.Layout.Row=row;
            unitLabel.Layout.Column=3;
        end

        function field=drawLogicalPreference(~,gridHandle,labelText,row)
            field=uicheckbox(gridHandle,"Text",labelText);
            field.Layout.Row=row;
            field.Layout.Column=[1,2];
        end

    end
end

