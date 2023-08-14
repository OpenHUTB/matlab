classdef CfgBuilder<autosar.mm.mm2rte.RTEBuilder




    properties(Access='private')
        M3iSystemConstSeq;
    end

    methods(Access='public')
        function this=CfgBuilder(rteGenerator,m3iComponent,modelName)
            this=this@autosar.mm.mm2rte.RTEBuilder(rteGenerator,m3iComponent);
            this.registerBinds();
            this.modelName=modelName;
        end

        function build(this)
            this.M3iSystemConstSeq=M3I.SequenceOfClassObject.makeUnique(this.M3iModel);
            this.apply('mmVisit',this.M3iASWC.Behavior);
        end
    end

    methods(Access='private')
        function registerBinds(this)
            this.bind('Simulink.metamodel.arplatform.behavior.ApplicationComponentBehavior',@mmWalkApplicationComponentBehavior,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.variant.SystemConst',@mmwalkSystemConst,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.variant.VariationPointProxy',@mmWalkVariationPointProxy,'mmVisit');
        end

        function ret=mmWalkApplicationComponentBehavior(this,m3iApplicationComponentBehavior)
            ret=[];
            this.applySeq('mmVisit',m3iApplicationComponentBehavior.variationPointProxy);
            this.applySeq('mmVisit',this.M3iSystemConstSeq);
        end

        function ret=mmWalkVariationPointProxy(this,m3iVpp)
            ret=[];


            m3iConditionAccess=m3iVpp.ConditionAccess;


            if m3iConditionAccess.isvalid()&&...
                strcmp(m3iConditionAccess.BindingTime.toString,'PreCompileTime')
                accessType='VariationPointConditionAccess';
                condExpr=...
                autosar.mm.util.extractCondExpressionFromM3iCondAccess(m3iConditionAccess);
                accessInfo.CondExpr=condExpr;
                dataItem=autosar.mm.mm2rte.RTEDataItemVariationPoint(...
                m3iVpp.Name,accessType,accessInfo);
                this.RTEData.insertItem(dataItem);

                m3iSysConsts=m3iConditionAccess.SysConst;
                this.M3iSystemConstSeq.addAll(m3iSysConsts);
            end

            m3iValueAccess=m3iVpp.ValueAccess;
            if m3iValueAccess.isvalid()&&...
                strcmp(m3iValueAccess.BindingTime.toString,'PreCompileTime')

                m3iSysConsts=m3iValueAccess.SysConst;
                this.M3iSystemConstSeq.addAll(m3iSysConsts);
            end
        end

        function ret=mmwalkSystemConst(this,m3iSysConst)
            ret=[];
            accessType='VariationPointValueAccess';
            accessInfo.SysConstName=m3iSysConst.Name;
            accessInfo.SysConstValue=autosar.mm.util.ExternalToolInfoAdapter.get(m3iSysConst,'RteSysConstNumericValue');
            dataItem=autosar.mm.mm2rte.RTEDataItemVariationPoint(...
            '',accessType,accessInfo);
            this.RTEData.insertItem(dataItem);
        end
    end

    properties(Access='private')
modelName
    end
end


