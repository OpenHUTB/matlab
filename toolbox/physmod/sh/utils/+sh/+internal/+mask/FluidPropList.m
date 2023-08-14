function FluidPropList(model)






    fluidBlock=get_param([model,'/Fluid properties'],'fluidPropList');


    objParam=get_param(model,'ModelWorkspace');


    fluidPropBlockList=objParam.getVariable('FluidPropBlockList');

    fluidPropBlockListPath=cellfun((@(s)s{1}),fluidPropBlockList,'UniformOutput',false);

    fluidPropBlockListName=cellfun((@(s)s{2}),fluidPropBlockList,'UniformOutput',false);


    activeFluidPropBlock=objParam.getVariable('ActiveFluidPropBlock');
    indexActiveBlock=strcmp(fluidPropBlockListName,activeFluidPropBlock);

    if strcmp(get_param(model,'SimulationStatus'),'stopped')


        if strcmp(fluidBlock,'Custom Hydraulic Fluid (Default settings)')
            newName=sprintf('Custom Hydraulic\nFluid (Default settings)');


            replace_block(model,'Name',activeFluidPropBlock,'fl_lib/Hydraulic/Hydraulic Utilities/Custom Hydraulic Fluid','noprompt');

            set_param(sprintf([model,'/',activeFluidPropBlock]),'Name',newName);

            pm.sli.highlightSystem(fluidPropBlockListPath{indexActiveBlock},'none');

        else

            index=strcmp(fluidPropBlockListPath,fluidBlock);

            newName=fluidPropBlockList{index}{2};

            replace_block(model,'Name',activeFluidPropBlock,fluidBlock,'noprompt');

            set_param(sprintf([model,'/',activeFluidPropBlock]),'Name',newName);

            pm.sli.highlightSystem(fluidBlock);

        end
        objParam.assignin('ActiveFluidPropBlock',newName)
    end
end
