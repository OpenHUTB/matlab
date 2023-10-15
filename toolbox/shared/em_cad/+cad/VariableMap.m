classdef VariableMap < handle

    properties
        Variable
        DependentObject
        PropertyName( 1, : )char
    end

    properties ( Dependent = true, AbortSet )
        ValidationHandle
    end

    methods
        function self = VariableMap( VariableObj, DependentObj, PropertyName )




            arguments
                VariableObj cad.Variable = cad.Variable.empty(  )
                DependentObj cad.DependentObject = cad.DependentObject.empty(  )
                PropertyName = ''

            end


            self.Variable = VariableObj;
            self.DependentObject = DependentObj;
            self.PropertyName = PropertyName;

            if ~isempty( DependentObj )





                self.verifyValidation( getValue( self ) );


                self.valueUpdated(  );
            end

        end

        function varname = getVarName( self )
            varname = self.Variable.Name;
        end

        function fcnhandle = get.ValidationHandle( self )

            fcnhandle = self.DependentObject.getValidation( self.PropertyName, self.Variable.Name );
        end

        function set.PropertyName( self, Name )

            if ~isempty( Name )
                em.internal.validateMLname( Name );
            end

            self.PropertyName = Name;
        end

        function verifyValidation( self, value )




            arguments
                self( 1, 1 )cad.VariableMap
                value{ mustBeNonempty }
            end


            self.ValidationHandle( value );
            self.DependentObject.additionalValidation( self.ValidationHandle, value )
        end

        function value = getValue( self )




            value = getValue( self.Variable );
        end

        function valueUpdated( self )



            arguments
                self( 1, 1 )cad.VariableMap
            end



            assignValueToProperty( self.DependentObject, self.PropertyName, getValue( self ), self.Variable.Name );
        end

        function delete( self )



            if ~isempty( self.Variable )
                self.Variable.removeMapObjectFromStack( self );
            end

            if ~isempty( self.DependentObject )

                self.DependentObject.removeDependentMapFromStack( self );
            end
        end

        function variableNameUpdated( self, prevname, presentname )
            self.DependentObject.updateVariableNameInHandle( self.PropertyName, prevname, presentname );
        end
    end
end
