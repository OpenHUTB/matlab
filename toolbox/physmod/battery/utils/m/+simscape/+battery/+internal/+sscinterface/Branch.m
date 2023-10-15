classdef ( Sealed, Hidden )Branch < simscape.battery.internal.sscinterface.StringItem

    properties ( Constant )
        Type = "Branch";
    end

    properties ( Access = private )
        ComponentVariable
        DomainVariable1
        DomainVariable2
    end

    methods
        function obj = Branch( componentVariable, domainVariable1, domainVariable2 )

            arguments
                componentVariable string{ mustBeTextScalar, mustBeNonzeroLengthText }
                domainVariable1 string{ mustBeTextScalar, mustBeNonzeroLengthText }
                domainVariable2 string{ mustBeTextScalar, mustBeNonzeroLengthText }
            end

            obj.ComponentVariable = componentVariable;
            obj.DomainVariable1 = domainVariable1;
            obj.DomainVariable2 = domainVariable2;
        end
    end

    methods ( Access = protected )

        function children = getChildren( ~ )

            children = [  ];
        end

        function str = getOpenerString( obj )

            str = obj.ComponentVariable.append( " : ", obj.DomainVariable1, " -> ", obj.DomainVariable2 );
        end

        function str = getTerminalString( ~ )

            str = ";" + newline;
        end
    end
end


