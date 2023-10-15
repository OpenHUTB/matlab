classdef PortSignalSource < slsim.SignalSource

    properties ( SetAccess = private, GetAccess = public )

        PortName

        Element

        Port{ slsim.PortSignalSource.validatePort } = ''
    end

    methods


        function obj = PortSignalSource( propArgs )
            arguments
                propArgs.BlockPath
                propArgs.UserData
                propArgs.BusElement
                propArgs.PortName
                propArgs.Element
                propArgs.Port
            end
            obj = obj@slsim.SignalSource( BlockPath = propArgs.BlockPath,  ...
                UserData = propArgs.UserData,  ...
                BusElement = propArgs.BusElement );
            obj.PortName = propArgs.PortName;
            obj.Element = propArgs.Element;
            obj.Port = propArgs.Port;
        end

    end

    methods ( Static, Hidden )

        function validatePortName( portName )
            mustBeTextScalar( portName );
        end

        function validateElement( element )
            mustBeTextScalar( element );
        end

        function validatePort( port )
            mustBeTextScalar( port );
        end

        function val = getDefaultStruct(  )
            val = struct( 'BlockPath', Simulink.SimulationData.BlockPath.empty(  ),  ...
                'UserData', [  ],  ...
                'BusElement', '',  ...
                'PortName', '',  ...
                'Element', '',  ...
                'Port', '' );
        end

    end

end

