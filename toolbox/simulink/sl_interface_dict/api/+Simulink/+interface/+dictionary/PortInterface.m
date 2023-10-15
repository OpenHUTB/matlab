classdef ( Abstract, Hidden )PortInterface < Simulink.interface.dictionary.NamedElement &  ...
        matlab.mixin.CustomDisplay




    properties ( Dependent = true )
        Description{ mustBeTextScalar }
    end

    properties ( Dependent = true, SetAccess = private )
        Elements( 0, : )Simulink.interface.dictionary.BaseElement
    end

    properties ( Abstract, Access = protected )
        ElementQualifiedClassName;
    end

    methods ( Hidden, Access = protected )
        function propgrp = getPropertyGroups( ~ )

            proplist = { 'Name', 'Description', 'Elements', 'Owner' };
            propgrp = matlab.mixin.util.PropertyGroup( proplist );
        end
    end

    methods ( Hidden )
        function tf = getIsStereotypableElement( this )%#ok<MANU>
            tf = true;
        end
    end

    methods
        function this = PortInterface( zcImpl, dictImpl )
            arguments
                zcImpl{ mustBeA( zcImpl, [ "systemcomposer.architecture.model.interface.CompositeDataInterface",  ...
                    "systemcomposer.architecture.model.interface.CompositePhysicalInterface",  ...
                    "systemcomposer.architecture.model.swarch.ServiceInterface" ] ) }
                dictImpl sl.interface.dict.InterfaceDictionary
            end
            this@Simulink.interface.dictionary.NamedElement( zcImpl, dictImpl );
        end

        function value = get.Description( this )

            value = this.getDDEntryPropValue( 'Description' );
        end

        function set.Description( this, newDesc )

            this.setDDEntryPropValue( 'Description', newDesc );
        end

        function elements = get.Elements( this )
            zcInterfaceElms = this.getZCWrapper(  ).Elements;
            elements = eval( [ this.ElementQualifiedClassName, '.empty(numel(zcInterfaceElms),0);' ] );
            for i = 1:numel( zcInterfaceElms )
                elements( i ) = this.createElement( zcInterfaceElms( i ).getImpl(  ) );
            end
        end

        function element = addElement( this, elementName, varargin )




            zcElm = this.getZCWrapper(  ).addElement( elementName, varargin{ : } );
            element = this.createElement( zcElm.getImpl(  ) );
        end

        function removeElement( this, elementName )




            this.getZCWrapper(  ).removeElement( elementName );
        end

        function element = getElement( this, elementName )




            zcElm = this.getZCWrapper(  ).getElement( elementName );
            assert( ~isempty( zcElm ), 'Element %s does not exist.', elementName );
            element = this.createElement( zcElm.getImpl(  ) );
        end

        function destroy( this )
            this.getDictionary(  ).removeInterface( this.Name );
            delete( this );
        end
    end

    methods ( Access = private )
        function element = createElement( this, elemImpl )%#ok<INUSD>
            dictImpl = this.getDictImpl(  );%#ok<NASGU>
            element = eval( [ this.ElementQualifiedClassName, '(elemImpl, dictImpl, this);' ] );
        end
    end
end


