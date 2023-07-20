classdef SimulinkStatesExtractor<handle







    methods(Access={?FunctionApproximation.internal.AbstractUtils})
        function this=SimulinkStatesExtractor()
        end
    end

    methods
        function states=extract(~,blockPath)
            sid=Simulink.ID.getSID(blockPath);
            modelName=Simulink.ID.getModel(sid);


            originalSaveFormat=get_param(modelName,'SaveFormat');
            dirtyFlag=get_param(modelName,'Dirty');


            set_param(modelName,'SaveFormat','DataSet');


            dataSet=Simulink.BlockDiagram.getInitialState(modelName);


            set_param(modelName,'SaveFormat',originalSaveFormat);
            set_param(modelName,'Dirty',dirtyFlag);




            nElements=~strcmp(modelName,blockPath)*dataSet.numElements;

            for ii=nElements:-1:1
                deleteElement=true;
                if isa(dataSet{ii},'Simulink.SimulationData.State')
                    blockName=getBlock(dataSet{ii}.BlockPath,1);
                    if contains(blockName,blockPath)
                        deleteElement=false;
                    end
                end

                if deleteElement
                    dataSet=dataSet.removeElement(ii);
                end
            end

            states=arrayfun(@(x)dataSet{x},1:dataSet.numElements);
        end
    end
end
