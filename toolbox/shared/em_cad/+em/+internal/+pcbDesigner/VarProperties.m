classdef VarProperties < cad.DependentObject
    properties
        Model
        Properties
        PropertyValues
    end

    methods
        function self = VarProperties( opts )
            arguments
                opts.Model( 1, 1 )cad.CADModel = [  ]
                opts.Properties cell = [  ]
            end


            if ~isempty( opts.Model )
                self.Model = opts.Model;
            end
            if ~isempty( opts.Properties )
                self.Properties = opts.Properties;
            end
        end

        function info = getInfo( self )
            info.CategoryType = 'PCBAntenna';
        end


        function set.Properties( self, val )
            self.Properties = val;

            self.deleteDependentVariableMaps(  );

            setPropMap( self, val );
        end

        function setPropMap( self, val )

            self.PropertyValueMap = [  ];
            self.PropertyValues = [  ];



            for i = 1:numel( val )
                self.PropertyValueMap.( val{ i } ) = [  ];
                self.PropertyValues.( val{ i } ) = [  ];
            end
        end





        function validationHandleOut = getDefaultValidation( self, propName )


            switch propName
                otherwise
                    validationHandleOut = @( x )validateattributes( x, { 'double' }, { 'nonempty', 'nonnan', 'finite', 'real', 'scalar', 'nonzero', 'positive' } );
            end
        end


        function assignValueToProperty( self, propname, value, varname )
            opVal = self.getValueOfProperty( propname, value, varname );
            if ~isa( opVal, 'MException' )
                self.PropertyValues.( propname ) = opVal;
                if ~isempty( self.Model )
                    self.Model.( propname ) = opVal;
                end
            end

        end

    end
end
