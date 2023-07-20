classdef RTEBuilder<m3i.Visitor









    properties(Access='private')
        IsBuilderInitialized;
    end

    properties(GetAccess='protected',SetAccess='private')
        M3iModel;
        M3iASWC;
    end

    properties(GetAccess='public',SetAccess='private')
        ASWCName;
        RTEGenerator;
        IsMultiInstantiable;
    end

    properties(GetAccess='public',SetAccess='protected')
        RTEData;
    end

    methods(Access='public')
        function this=RTEBuilder(rteGenerator,m3iComponent)


            autosar.mm.util.validateM3iArg(m3iComponent,...
            'Simulink.metamodel.arplatform.component.Component');
            autosar.mm.util.validateArg(rteGenerator,...
            'autosar.mm.mm2rte.RTEGenerator');

            this.M3iModel=m3iComponent.rootModel;
            this.RTEGenerator=rteGenerator;
            this.IsBuilderInitialized=false;
            this.RTEData=autosar.mm.mm2rte.RTEData;
            this.M3iASWC=m3iComponent;
            this.ASWCName=this.M3iASWC.Name;
            this.IsMultiInstantiable=this.M3iASWC.Behavior.isMultiInstantiable;


            this.registerVisitor('mmVisit','mmVisit');
        end

        function hasData=hasRTEData(this)
            assert(this.IsBuilderInitialized,...
            'Builder data cannot be accessed until builder is initialized!')
            hasData=~isempty(this.RTEData.DataItems);
        end

        function postBuild(this)
            this.IsBuilderInitialized=true;
        end
    end

    methods(Abstract)



        build(this);
    end
end


