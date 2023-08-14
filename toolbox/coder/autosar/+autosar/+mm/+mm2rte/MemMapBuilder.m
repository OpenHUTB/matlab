classdef MemMapBuilder<autosar.mm.mm2rte.RTEBuilder




    methods(Access='public')
        function this=MemMapBuilder(rteGenerator,m3iComponent)
            this=this@autosar.mm.mm2rte.RTEBuilder(rteGenerator,m3iComponent);
            this.registerBinds();
        end

        function build(this)



            m3iSwAddrMethods=autosar.mm.Model.findChildByTypeName(this.M3iModel,...
            'Simulink.metamodel.arplatform.common.SwAddrMethod');
            for inx=1:length(m3iSwAddrMethods)
                this.apply('mmVisit',m3iSwAddrMethods{inx});
            end
        end
    end

    methods(Access='private')
        function registerBinds(this)
            this.bind('Simulink.metamodel.arplatform.common.SwAddrMethod',@mmWalkSwAddrMethod,'mmVisit');
        end

        function ret=mmWalkSwAddrMethod(this,m3iSwAddrMethod)
            ret=[];
            if autosar.mm.mm2sl.utils.isCompatibleSwAddrMethod(m3iSwAddrMethod)
                dataItem=autosar.mm.mm2rte.RTEDataItemSwAddrMethod(...
                m3iSwAddrMethod.Name);
                this.RTEData.insertItem(dataItem);
            end
        end
    end
end


