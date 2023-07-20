classdef PbCfgBuilder<autosar.mm.mm2rte.RTEBuilder




    methods(Access='public')
        function this=PbCfgBuilder(rteGenerator,m3iComponent,modelName)
            this=this@autosar.mm.mm2rte.RTEBuilder(rteGenerator,m3iComponent);
            this.registerBinds();
            this.modelName=modelName;
        end

        function build(this)
            this.apply('mmVisit',this.M3iASWC.Behavior);
        end
    end

    methods(Access='private')
        function registerBinds(this)
            this.bind('Simulink.metamodel.arplatform.behavior.ApplicationComponentBehavior',@mmWalkApplicationComponentBehavior,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.variant.VariationPointProxy',@mmWalkVariationPointProxy,'mmVisit');
        end

        function ret=mmWalkApplicationComponentBehavior(this,m3iApplicationComponentBehavior)
            ret=[];
            this.applySeq('mmVisit',m3iApplicationComponentBehavior.variationPointProxy);
        end

        function ret=mmWalkVariationPointProxy(this,m3iVpp)
            ret=[];


            pbAccessInfo.pbCondExpr="";
            m3iPostBuildVariantCondition=m3iVpp.PostBuildVariantCondition;
            needParen=size(m3iPostBuildVariantCondition)>1;
            for aIdx=1:size(m3iPostBuildVariantCondition)
                var=m3iPostBuildVariantCondition.at(aIdx).MatchingCriterion.Name;



                indexOfVar=matches(this.PostBuildVariables,var);
                if isempty(this.PostBuildVariables(indexOfVar))


                    this.PostBuildVariables(end+1)=string(var);


                    [exists,value,inModelWs]=autosar.utils.Workspace.objectExistsInModelScope(this.modelName,var);
                    validPB=~isobject(value)||isa(value,'Simulink.VariantControl');
                    assert(exists&&validPB&&~inModelWs,'Expected value to exist as a literal value or Simulink.VariantControl');

                    dAccessType='PostBuildDefinition';
                    daccessInfo.PbConstName=var;
                    if isa(value,'Simulink.VariantControl')
                        daccessInfo.PbConstValue=value.Value;
                    else
                        daccessInfo.PbConstValue=value;
                    end
                    dataItem=autosar.mm.mm2rte.RTEDataItemVariationPoint(...
                    '',dAccessType,daccessInfo);
                    this.RTEData.insertItem(dataItem);

                end

                value=m3iPostBuildVariantCondition.at(aIdx).Value;
                currentCond=strcat(var," == ",string(value));
                if needParen
                    currentCond=strcat("(",currentCond,")");
                end
                if pbAccessInfo.pbCondExpr==""
                    pbAccessInfo.pbCondExpr=currentCond;
                else
                    pbAccessInfo.pbCondExpr=strcat(pbAccessInfo.pbCondExpr," && ",currentCond);
                end
            end

            if pbAccessInfo.pbCondExpr~=""
                accessType='PostBuildVariationCondition';
                dataItem=autosar.mm.mm2rte.RTEDataItemVariationPoint(...
                m3iVpp.Name,accessType,pbAccessInfo);
                this.RTEData.insertItem(dataItem);
            end
        end
    end

    properties(Access='private')
        PostBuildVariables=strings
modelName
    end
end


