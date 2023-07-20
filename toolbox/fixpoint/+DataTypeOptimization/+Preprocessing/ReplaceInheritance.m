classdef ReplaceInheritance<DataTypeOptimization.Preprocessing.BlockActions








    properties
        propertiesToCheck={...
        'OutDataTypeStr',...
        'ParamDataTypeStr',...
        'AccumDataTypeStr'}

        typesToReplace={...
        SimulinkFixedPoint.AutoscalerInheritanceTypes.SAMEASINPUT,...
        SimulinkFixedPoint.AutoscalerInheritanceTypes.SAMEASFIRSTINPUT,...
        SimulinkFixedPoint.AutoscalerInheritanceTypes.SAMEASACCUMULATOR};
        replacedBlocks={}
    end

    methods
        function this=ReplaceInheritance()
            this.ActionDescription=message('SimulinkFixedPoint:dataTypeOptimization:replaceInheritanceAction').getString();
        end
        function performAction(this,environmentContext)

            allBlocks=this.getAllBlocks(environmentContext);
            this.replacedBlocks={};
            for pIndex=1:numel(this.propertiesToCheck)

                hasProperty=false(numel(allBlocks),1);
                for bIndex=1:numel(allBlocks)
                    hasProperty(bIndex)=isprop(allBlocks(bIndex),this.propertiesToCheck{pIndex});
                end
                blocksWithProperty=allBlocks(hasProperty);



                for tIndex=1:numel(this.typesToReplace)


                    hasType=false(numel(blocksWithProperty),1);
                    for bIndex=1:numel(blocksWithProperty)
                        hasType(bIndex)=SimulinkFixedPoint.AutoscalerInheritanceTypes.encoder(blocksWithProperty(bIndex).(this.propertiesToCheck{pIndex}))==...
                        this.typesToReplace{tIndex};
                    end
                    blocksWithSameAs=blocksWithProperty(hasType);



                    for bIndex=1:numel(blocksWithSameAs)
                        this.replacedBlocks{end+1,1}={blocksWithSameAs(bIndex),this.propertiesToCheck{pIndex},get(blocksWithSameAs(bIndex),this.propertiesToCheck{pIndex})};
                        set(blocksWithSameAs(bIndex),this.propertiesToCheck{pIndex},'double');
                    end
                end
            end

        end

        function revertAction(this)


            for rIndex=1:numel(this.replacedBlocks)
                set(this.replacedBlocks{rIndex}{1},this.replacedBlocks{rIndex}{2},this.replacedBlocks{rIndex}{3});
            end

        end
    end
end