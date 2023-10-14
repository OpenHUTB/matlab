classdef ( Abstract )EnumOptionSource

    properties ( SetAccess = immutable )
        Option( 1, 1 )coderapp.internal.config.data.EnumOption = coderapp.internal.config.data.EnumOption(  )
    end

    properties ( Dependent, SetAccess = immutable )
        Value
    end

    methods
        function this = EnumOptionSource( value, displayKey )
            arguments
                value{ mustBeTextScalar( value ) }
                displayKey{ mustBeTextScalar( displayKey ) } = ''
            end
            assert( isenum( this ), 'EnumOptionMixin should only be used with enumerations' );
            this.Option.Value = value;
            if ~isempty( displayKey )
                this.Option.DisplayValue = message( displayKey ).getString(  );
            end
        end

        function value = get.Value( this )
            value = this.Option.Value;
        end
    end
end


