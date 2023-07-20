classdef CheckSpecifiedInGroup<SimulinkFixedPoint.WarningConditions.AbstractCondition







    methods

        function this=CheckSpecifiedInGroup()
            this.messageID={'FixedPointTool:fixedPointTool:alertPropDTDiffSpecDT'};
        end

        function flag=check(this,result,group)
            flag=false;
            if isequal(result.getProposedDT,'n/a')||result.isLocked
                if~isempty(group.finalProposedDataType)&&...
                    group.finalProposedDataType.containerType==SimulinkFixedPoint.AutoscalerDataTypes.FixedPoint
                    propDT={group.finalProposedDataType.evaluatedNumericType};
                else
                    propDT={};
                end


                if~isempty(propDT)
                    dtContainerInfo=result.getSpecifiedDTContainerInfo;
                    nt=dtContainerInfo.evaluatedNumericType;
                    if~isempty(nt)



                        [isClientOfNamedDt,~,~]=dtContainerInfo.traceVar();
                        isNTPartOfSharedDTs=this.checkIfPartOfSharedDTs(nt,propDT);

                        flag=~isNTPartOfSharedDTs&&~isClientOfNamedDt;

                    end
                end
            end

        end
    end

    methods(Access=public,Hidden)
        function isNumericTypeMember=checkIfPartOfSharedDTs(~,nt,arrayNumericTypes)



            isNumericTypeMember=false(length(arrayNumericTypes),1);
            for ntIndex=1:length(arrayNumericTypes)
                isNumericTypeMember(ntIndex)=...
                SimulinkFixedPoint.DataType.areEquivalent(nt,arrayNumericTypes{ntIndex});
            end

        end
    end

end


