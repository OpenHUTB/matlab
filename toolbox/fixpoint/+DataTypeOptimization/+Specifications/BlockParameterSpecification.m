classdef BlockParameterSpecification<DataTypeOptimization.Specifications.OptimizationSpecification



    methods

        function str=toString(this)
            str=sprintf("[%s::%s]",this.Element.BlockPath,this.Element.Name);
        end

        function dataTypeStr=getDataTypeStr(this)
            dataTypeStr=this.Element.Value;
        end

        function setUniqueID(this,varargin)
            eai=SimulinkFixedPoint.EntityAutoscalersInterface.getInterface();

            blkObj=get_param(this.Element.BlockPath,'Object');
            ea=eai.getAutoscaler(blkObj);


            pathItems=ea.getPathItems(blkObj);
            settingStrategyIndx=false(1,numel(pathItems));
            for pIndex=1:numel(pathItems)
                settingStrategy=ea.getSettingStrategies(blkObj,pathItems{pIndex});
                if isequal(settingStrategy{1}{1},'FullDataTypeStrategy')&&isequal(settingStrategy{1}{3},this.Element.Name)
                    settingStrategyIndx(pIndex)=true;
                    break;
                end
            end



            if~any(settingStrategyIndx)
                DAStudio.error('SimulinkFixedPoint:dataTypeOptimization:specificationsUnmappedBlockParameter');
            end


            dh=fxptds.SimulinkDataArrayHandler();
            this.UniqueID=dh.getUniqueIdentifier(struct('Object',blkObj,'ElementName',pathItems{settingStrategyIndx}));

        end
    end
end

