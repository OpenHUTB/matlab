classdef(Abstract,Hidden,AllowedSubclasses={?simscape.battery.internal.sscinterface.Assertion,...
    ?simscape.battery.internal.sscinterface.Branch,?simscape.battery.internal.sscinterface.Comment,?simscape.battery.internal.sscinterface.Component,?simscape.battery.internal.sscinterface.CompositeComponent,...
    ?simscape.battery.internal.sscinterface.ConditionalBlock,?simscape.battery.internal.sscinterface.Connection,?simscape.battery.internal.sscinterface.Equation,?simscape.battery.internal.sscinterface.ExternalAccess,...
    ?simscape.battery.internal.sscinterface.Icon,?simscape.battery.internal.sscinterface.ForLoop,?simscape.battery.internal.sscinterface.IfStatement,?simscape.battery.internal.sscinterface.EqualityStatement,...
    ?simscape.battery.internal.sscinterface.Section,?simscape.battery.internal.sscinterface.UiGroup,?simscape.battery.internal.sscinterface.UiLayout,?simscape.battery.internal.sscinterface.PortLocation})...
    StringItem<matlab.mixin.Heterogeneous




    properties(Abstract,Constant)
        Type string{mustBeTextScalar,mustBeNonzeroLengthText};
    end

    properties(Access=protected)
        IdealCharsPerLine=70;
    end

    methods(Abstract,Access=protected)
        children=getChildren(obj);

        opener=getOpenerString(obj);

        terminal=getTerminalString(obj);
    end

    methods
        function str=getString(obj)



            str=obj.getOpenerString();


            children=obj.getChildren();
            for ii=1:length(children)
                childString=children(ii).getString();
                str=str.append(childString);
            end


            terminal=obj.getTerminalString();
            str=str.append(terminal);
        end
    end
end


