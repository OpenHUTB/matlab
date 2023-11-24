classdef ( Abstract )BaseAnnotation < handle & matlab.mixin.Heterogeneous

    properties ( Hidden, SetAccess = immutable )
        UUID
    end

    properties ( SetObservable )

        ParentPanel( 1, 1 )string{ mustBeMember( ParentPanel, { 'body', 'header' } ) } = "body";
    end

    methods ( Hidden, Abstract )
        html = generateHTML(  )
    end

    methods
        function obj = BaseAnnotation( options )
            arguments


                options.UUID( 1, 1 )string{ mustBeNonempty } = matlab.lang.internal.uuid;
            end

            obj.UUID = options.UUID;
        end
    end

    methods ( Hidden )
        function observableProps = getAllSetObservableProperties( obj )
            mc = metaclass( obj );
            propertyList = mc.PropertyList;
            observableProps = propertyList( [ propertyList.SetObservable ] );
        end

        function id = getHtmlId( obj )

            id = "SequenceDiagramQuasiAnnotation_" + obj.UUID;
        end
    end

    methods ( Sealed )
        function varargout = eq( obj, varargin )
            [ varargout{ 1:nargout } ] = eq@handle( obj, varargin{ : } );
        end
    end

end



