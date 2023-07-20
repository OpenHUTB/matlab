classdef(Sealed,Hidden)EquationsSection<simscape.battery.internal.sscinterface.Section




    properties(Constant)
        Type="EquationsSection";
    end

    properties(Constant,Access=protected)
        SectionIdentifier="equations"
    end

    methods
        function obj=EquationsSection()

        end

        function obj=addEquation(obj,name,value)



            obj.SectionContent(end+1)=simscape.battery.internal.sscinterface.Equation(name,value);
        end

        function obj=addAssertion(obj,condition,varargin)



            obj.SectionContent(end+1)=simscape.battery.internal.sscinterface.Assertion(condition,varargin{:});
        end
    end
end


