classdef(Abstract,Hidden,AllowedSubclasses={?simscape.battery.internal.sscinterface.IfBlock,?simscape.battery.internal.sscinterface.ElseBlock,?simscape.battery.internal.sscinterface.ElseIfBlock})...
    ConditionalBlock<simscape.battery.internal.sscinterface.StringItem





    properties(Access=protected)
        SectionsContainer=simscape.battery.internal.sscinterface.SectionsContainer;
    end

    properties(Abstract,Access=protected)
        Condition;
    end

    properties(Abstract,Constant,Access=protected)
        Operator;
    end

    methods
        function obj=addSection(obj,section)

            obj.SectionsContainer=obj.SectionsContainer.addSection(section);
        end

        function obj=addIfStatement(obj,ifStatement)

            obj.SectionsContainer=obj.SectionsContainer.addIfStatement(ifStatement);
        end
    end

    methods(Access=protected)
        function children=getChildren(obj)

            children=obj.SectionsContainer.getContent;
        end

        function str=getOpenerString(obj)

            str=newline+obj.Operator+" "+obj.Condition+newline;
        end

        function str=getTerminalString(~)

            str="";
        end
    end
end

