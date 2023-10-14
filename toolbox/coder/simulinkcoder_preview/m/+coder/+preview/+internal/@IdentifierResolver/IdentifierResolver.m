classdef IdentifierResolver < handle

    properties
        dN = ''
        dR = ''
        dC = ''
        dG = ''
        dU = ''
        dX = ''
        maxIdLen = 124;
    end

    properties ( Access = private )
        mf0
        Tokens = 'NRCGUX'
    end

    methods
        function obj = IdentifierResolver( options )

            arguments
                options.Placeholder( 1, 1 )matlab.lang.OnOffSwitchState = "off"
                options.N
                options.R
                options.C
                options.G
                options.U
                options.X
            end

            obj.mf0 = mf.zero.Model;

            if options.Placeholder == "on"
                obj.dN = 'ELEM';
                obj.dR = 'MODELNAME';
                obj.dC = 'CHECKSUM';
                obj.dG = 'SERVICE';
                obj.dU = 'USER';
                obj.dX = 'MODELNAME_FUNCTIONNAME';
            end

            for t = obj.Tokens
                if isfield( options, t )
                    obj.( [ 'd', t ] ) = options.( t );
                end
            end
        end

        out = getIdentifier( obj, rule )
    end

    methods ( Access = private )
        out = constructConfig( obj )
        out = replaceNonAscii( obj, text )
    end
end



