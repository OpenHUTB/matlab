classdef IMAQPreferencesModel < handle

    properties ( Access = { ?matlab.ui.internal.preferences.preferencePanels.imaq.ITestable } )
        PreferencePanelProperties


        ImaqmexFunction
    end

    methods
        function obj = IMAQPreferencesModel(  )
            obj.PreferencePanelProperties = PreferencePanelProperties.getOrResetInstance(  );
            obj.ImaqmexFunction = @imaqmex;
        end

        function result = commitPreferences( obj, preferenceArgs )
            arguments
                obj matlab.ui.internal.preferences.preferencePanels.imaq.IMAQPreferencesModel


                preferenceArgs.GigePacketAckTimeout{ mustBeInteger }
                preferenceArgs.GigeHeartbeatTimeout{ mustBeInteger }
                preferenceArgs.GigeCommandRetries{ mustBeInteger }
                preferenceArgs.GigeDisableForceIP logical



                preferenceArgs.MacvideoDiscoveryTimeout{ mustBeInteger } = [  ]
            end


            obj.commitPreferencesToIMAQEngine( preferenceArgs );
            obj.savePreferenceValues( preferenceArgs );

            result = true;
        end

        function preferenceStruct = getPreferenceValues( obj )
            preferenceStruct = struct(  ...
                "GigeCommandRetries", obj.PreferencePanelProperties.getGigeCommandPacketRetries(  ),  ...
                "GigePacketAckTimeout", obj.PreferencePanelProperties.getGigePacketAckTimeout(  ),  ...
                "GigeHeartbeatTimeout", obj.PreferencePanelProperties.getGigeHeartbeatTimeout(  ),  ...
                "GigeDisableForceIP", obj.PreferencePanelProperties.getGigeDisableForceIP(  ) ...
                );
            if ismac(  )
                preferenceStruct.MacvideoDiscoveryTimeout = obj.PreferencePanelProperties.getMacvideoDiscoveryTimeout(  );
            end
        end

    end

    methods ( Access = private )
        function commitPreferencesToIMAQEngine( obj, preferenceStruct )
            if ismac(  )
                obj.ImaqmexFunction( 'feature', '-macvideoframegrabduringdevicediscoverytimeout', preferenceStruct.MacvideoDiscoveryTimeout );
            end
            obj.ImaqmexFunction( 'feature', '-gigecommandpacketretries', preferenceStruct.GigeCommandRetries );
            obj.ImaqmexFunction( 'feature', '-gigeheartbeattimeout', preferenceStruct.GigeHeartbeatTimeout );
            obj.ImaqmexFunction( 'feature', '-gigepacketacktimeout', preferenceStruct.GigePacketAckTimeout );
            obj.ImaqmexFunction( 'feature', '-gigedisableforceip', preferenceStruct.GigeDisableForceIP );
        end

        function savePreferenceValues( obj, preferenceStruct )


            if ismac(  )
                obj.PreferencePanelProperties.setMacvideoDiscoveryTimeout( preferenceStruct.MacvideoDiscoveryTimeout );
            end
            obj.PreferencePanelProperties.setGigeCommandPacketRetries( preferenceStruct.GigeCommandRetries );
            obj.PreferencePanelProperties.setGigeHeartbeatTimeout( preferenceStruct.GigeHeartbeatTimeout );
            obj.PreferencePanelProperties.setGigePacketAckTimeout( preferenceStruct.GigePacketAckTimeout );
            obj.PreferencePanelProperties.setGigeDisableForceIP( preferenceStruct.GigeDisableForceIP );
        end
    end
end

