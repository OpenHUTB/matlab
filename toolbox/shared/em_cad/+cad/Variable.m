classdef Variable < cad.DependentObject



    properties
        Name( 1, : )char
        Value
        VariableMap( :, 1 )
    end

    methods

        function updateVariableNameInHandle( self, property, prevname, presentname )
            propfcnhandle = self.Value;
            newhandle = replaceVarInfcnHandle( self, propfcnhandle, prevname, presentname );
            self.Value = newhandle;
        end

        function self = Variable( Name, Value )

            arguments
                Name
                Value
            end

            self.Name = Name;
            self.Value = Value;
            self.ObjectType = 'Variable';
        end

        function set.Name( self, Name )

            em.internal.validateMLname( Name );

            self.Name = Name;
        end
        function set.Value( self, Value )
            arguments
                self
                Value{ mustBeNonempty }
            end


            self.Value = Value;
        end

        function updateValue( self, value )



            arguments
                self( 1, 1 )cad.Variable
                value{ mustBeNonempty }
            end








            if isnumeric( value )
                cad.DependentObject.AdditionalValidation( value );
            end



            self.verifyValue( value );


            self.Value = value;


            self.updateVarMaps(  );
        end

        function verifyValue( self, value )




            arguments
                self( 1, 1 )cad.Variable
                value{ mustBeNonempty }
            end





            for i = 1:numel( self.VariableMap )
                self.VariableMap( i ).verifyValidation( value );
            end
        end

        function updateVarMaps( self )



            arguments
                self( 1, 1 )cad.Variable
            end



            for i = 1:numel( self.VariableMap )
                self.VariableMap( i ).valueUpdated(  );
            end
        end



        function validationHandle = getValidation( self, propName, varname )

            arguments
                self( 1, 1 )cad.Variable
                propName( 1, : )char %#ok<INUSA> % property name must be a string
                varname( 1, : )char
            end
            if ~isempty( self.DependentMap )











                if isa( self.Value, 'function_handle' )

                    argsArray = self.generateArgsArray(  );

                    mapVariableNames = arrayfun( @( x )x.getVarName(  ),  ...
                        self.DependentMap, 'UniformOutput', false );

                    idx = strcmpi( varname, mapVariableNames );
                    if any( idx )




                        indexnum = find( idx );
                        nummaps = numel( self.DependentMap );
                        if indexnum == 1
                            validationHandle = @( x )self.Value( x, argsArray{ ~idx } );
                        elseif indexnum == nummaps
                            validationHandle = @( x )self.Value( argsArray{ ~idx }, x );
                        else
                            validationHandle = @( x )self.Value( argsArray{ 1:indexnum - 1 }, x, argsArray{ indexnum + 1:end  } );
                        end
                    else





                        validationHandle = self.NoValidationHandle;
                    end
                else


                    validationHandle = self.NoValidationHandle;
                end
            else


                validationHandle = self.NoValidationHandle;
            end
        end

        function scriptval = getScript( self )
            fact = 1;
            if isa( self.Value, 'function_handle' )
                rhsvalue = getExpressionWithoutInputs( self, self.Value );
            elseif isnumeric( self.Value )
                if numel( self.Value ) == 1
                    rhsvalue = num2str( self.Value .* fact );
                else
                    rhsvalue = mat2str( self.Value .* fact );
                end
            else
                rhsvalue = self.Value;
            end
            scriptval = [ self.Name, ' = ', rhsvalue, ';' ];
        end

        function value = getValue( self )



            arguments
                self( 1, 1 )cad.Variable
            end


            if ~isempty( self.DependentMap )


                argsArray = self.generateArgsArray(  );




                value = self.Value( argsArray{ : } );







            else

                value = self.Value;
            end
        end

        function addMapObjectToStack( self, varmap )


            arguments
                self( 1, 1 )cad.Variable
                varmap( 1, 1 )cad.VariableMap
            end


            idx = self.VariableMap == varmap;
            if any( idx )

                return ;
            end

            self.VariableMap = [ self.VariableMap;varmap ];
        end

        function removeMapObjectFromStack( self, varmap )


            arguments
                self( 1, 1 )cad.Variable
                varmap( 1, 1 )cad.VariableMap
            end


            idx = self.VariableMap == varmap;
            if any( idx )



                self.VariableMap( idx ) = [  ];
            end

        end

        function varmap = addVariableMap( self, object, property )





            arguments
                self( 1, 1 )cad.Variable
                object( 1, 1 )cad.DependentObject
                property
            end


            em.internal.validateMLname( property, 'property' );













            if self == object
                return ;
            end



            varmap = cad.VariableMap( self, object, property );


            self.addMapObjectToStack( varmap );


            object.addDependentMapToStack( varmap );

        end
        function additionalValidation( self, validationhandle, value )





            if isa( self.Value, 'function_handle' )
                actualvalue = validationhandle( value );
                self.verifyValue( actualvalue );
            else
                actualvalue = value;
                self.verifyValue( actualvalue );
            end

            additionalValidation@cad.DependentObject( self, validationhandle, actualvalue );
        end

        function assignValueToProperty( self, PropertyName, Value, varname )


            arguments
                self( 1, 1 )cad.Variable
                PropertyName( 1, : )char
                Value( 1, : )
                varname
            end



            if ~isa( self.Value, 'function_handle' )

                self.updateValue( Value )
            else
                self.updateVarMaps(  );
            end

        end

        function delete( self )




            self.deleteVariableMaps(  );


            self.deleteDependentVariableMaps(  );
        end

        function deleteVariableMaps( self )


            mapStack = self.VariableMap;
            for i = 1:numel( mapStack )


                if ~isvalid( mapStack( i ) )
                    continue ;
                end
                mapStack( i ).delete;
            end
        end

        function argsArray = generateArgsArray( self )

            argsArray = cell( numel( self.DependentMap ), 1 );
            for i = 1:numel( self.DependentMap )


                argsArray{ i } = self.DependentMap( i ).getValue(  );
            end
        end

    end

end
