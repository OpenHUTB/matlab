classdef CodeCoverageTools<handle




    properties(Constant=true,Access=private)

        Instance=Simulink.CodeCoverageTools;
        FactoryDisplayNames={'None','BullseyeCoverage'};
        FactoryClassNames={'','coder.coverage.Bullseye'};
        FactoryCompanies={'','Bullseye Testing Technology'};
    end

    properties(Access=private)
DisplayNames
ClassNames
Companies
    end

    methods(Access=public)

        function this=CodeCoverageTools


mlock
            clear(this);
        end

        function[lDisplayNames,lClassNames,lCompanies]=get(this)
            lDisplayNames=this.DisplayNames;
            lClassNames=this.ClassNames;
            lCompanies=this.Companies;
        end

        function add(this,lDisplayNames,lClassNames,lCompanies)
            this.DisplayNames{end+1}=lDisplayNames;
            this.ClassNames{end+1}=lClassNames;
            this.Companies{end+1}=lCompanies;
        end

        function clear(this)
            this.DisplayNames=Simulink.CodeCoverageTools.FactoryDisplayNames;
            this.ClassNames=Simulink.CodeCoverageTools.FactoryClassNames;
            this.Companies=Simulink.CodeCoverageTools.FactoryCompanies;
        end

    end

end
