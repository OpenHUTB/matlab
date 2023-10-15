classdef InterfaceFunctionGetter








    properties ( Hidden, Constant )





        InstrumentInterfaces( 1, : )string =  ...
            [ "udpport", "visadev", "tcpserver" ]

        DefaultFcn = @(  )[  ]
        InstrumentLicenseFcn = @instrument.internal.InstrumentBaseClass.attemptLicenseCheckout
    end

    methods ( Hidden, Static )
        function fcn = getLicenseFcn( interfaceName )

            arguments
                interfaceName string
            end

            if isempty( interfaceName ) ||  ...
                    ~ismember( interfaceName, instrument.internal.InterfaceFunctionGetter.InstrumentInterfaces )
                fcn = instrument.internal.InterfaceFunctionGetter.DefaultFcn;
            else
                fcn = instrument.internal.InterfaceFunctionGetter.InstrumentLicenseFcn;
            end
        end
    end
end

