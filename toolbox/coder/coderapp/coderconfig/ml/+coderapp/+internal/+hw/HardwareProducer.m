classdef ( Sealed )HardwareProducer < coderapp.internal.config.AbstractProducer

    methods
        function produce( this )
            hardwareName = this.value( 'hardwareName' );
            if coderapp.internal.hw.HardwareConfigController.isHardwareName( hardwareName )
                this.Production = this.applyHardwareData( emlcprivate( 'projectCoderHardware', hardwareName ) );
            else
                this.Production = [  ];
                this.ScriptModel = '';
            end
        end

        function update( this, triggerKeys )
            if any( strcmp( 'hardwareName', triggerKeys ) )
                this.produce(  );
            elseif ~isempty( this.Production )
                this.Production = this.applyHardwareData(  );
            end
        end

        function imported = import( this, hw )
            if ~isempty( hw ) && isa( hw, 'coder.HardwareBase' )
                current = this.Production;
                if isempty( current ) || ~strcmp( current.Name, hw.Name )


                    imported.hardwareName = hw.Name;
                end
                imported.hardwareData = struct(  );
                try
                    default = emlcprivate( 'projectCoderHardware', hw.Name );
                catch
                    return
                end

                if ~isa( hw, 'coder.Hardware' )
                    return
                end
                props = properties( hw );
                for i = 1:numel( props )
                    if ~isequal( default.( props{ i } ), hw.( props{ i } ) )




                        imported.hardwareData.( props{ i } ) = hw.( props{ i } );
                    end
                end
            else
                imported = [  ];
            end
        end
    end

    methods ( Access = private )
        function hw = applyHardwareData( this, hw )
            arguments
                this
                hw = this.Production
            end

            hwData = this.value( 'hardwareData' );
            if isempty( hw ) || isempty( hwData )
                this.ScriptModel = '[]';
                return
            end

            construction = coderapp.internal.script.ScriptBuilder(  ).appendf(  ...
                '`%s`.Hardware = coder.hardware("%s");\n', this.Key, hw.Name ) ...
                .annotate( 'param', 'hardwareName' );
            script = coderapp.internal.script.ScriptBuilder( construction );
            fields = setdiff( fieldnames( hwData ), { 'Name' } );

            for i = 1:numel( fields )
                if isprop( hw, fields{ i } )
                    value = resolveValueTypes( hwData.( fields{ i } ), hw.( fields{ i } ) );
                    if isequal( value, hw.( fields{ i } ) )
                        continue
                    end
                    try
                        hw.( fields{ i } ) = value;
                    catch me %#ok<NASGU>

                        continue
                    end
                    scriptValue = coderapp.internal.value.valueToExpression( value, Inf, false, false );
                    if ~isempty( scriptValue )
                        script = script.appendf( '`%s`.Hardware.%s = %s;\n',  ...
                            this.Key, fields{ i }, scriptValue );
                    end
                end
            end
            this.ScriptModel = script.input( this.Key, 'hardware' );
        end
    end
end


function value = resolveValueTypes( value, example )
if ( ischar( value ) || isstring( value ) ) && isnumeric( example )
    value = str2double( value );
end
if isnumeric( value ) || islogical( value )
    value = cast( value, 'like', example );
end
end


