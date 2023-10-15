classdef ( Sealed, Hidden )IfStatement < simscape.battery.internal.sscinterface.StringItem

    properties ( Constant )
        Type = "IfStatement";
    end

    properties ( Access = private )
        IfBlock = simscape.battery.internal.sscinterface.IfBlock.empty;
        ElseIfBlock = simscape.battery.internal.sscinterface.ElseIfBlock.empty;
        ElseBlock = simscape.battery.internal.sscinterface.ElseBlock.empty;
    end

    methods
        function obj = IfStatement( ifBlock )


            arguments
                ifBlock{ mustBeA( ifBlock, "simscape.battery.internal.sscinterface.IfBlock" ) }
            end

            obj.IfBlock = ifBlock;
        end

        function obj = addElseIfBlock( obj, elseIfBlock )

            arguments
                obj
                elseIfBlock{ mustBeA( elseIfBlock, "simscape.battery.internal.sscinterface.ElseIfBlock" ) }
            end

            obj.ElseIfBlock( end  + 1 ) = elseIfBlock;
        end

        function obj = setElseBlock( obj, elseBlock )

            arguments
                obj
                elseBlock{ mustBeA( elseBlock, "simscape.battery.internal.sscinterface.ElseBlock" ) }
            end
            obj.ElseBlock = elseBlock;
        end
    end

    methods ( Access = protected )
        function children = getChildren( obj )

            children = [ obj.IfBlock, obj.ElseIfBlock, obj.ElseBlock ];
        end

        function str = getOpenerString( ~ )

            str = "";
        end

        function str = getTerminalString( ~ )

            str = "end" + newline;
        end
    end
end

