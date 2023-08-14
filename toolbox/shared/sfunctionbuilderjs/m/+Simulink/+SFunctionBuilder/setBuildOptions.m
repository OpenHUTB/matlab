function setBuildOptions(blockHandle,varargin)




    blockHandle=Simulink.SFunctionBuilder.internal.verifyBlockHandle(blockHandle);
    sfcnmodel=sfunctionbuilder.internal.sfunctionbuilderModel.getInstance();

    cliView=struct('publishChannel','cli');
    sfcnmodel.registerView(blockHandle,cliView);
    controller=sfunctionbuilder.internal.sfunctionbuilderController.getInstance;
    for i=1:2:numel(varargin)
        name=varargin{i};
        value=varargin{i+1};
        switch name
        case{'ShowCompileSteps','CreateDebuggableMEX','GenerateWrapperTLC','EnableSupportForCoverage','EnableSupportForDesignVerifier'}
            if~islogical(value)&&~strcmp(num2str(value),'0')&&~strcmp(num2str(value),'1')
                error('Simulink:SFunctionBuilder:MustBeLogicalValue',DAStudio.message('Simulink:SFunctionBuilder:MustBeLogicalValue'));
            end
            option.optionName=name;
            option.optionSelected=value;
        otherwise

        end
        controller.updateSFunctionBuildOption(blockHandle,option);
    end


    sfcnmodel.unregisterView(blockHandle,cliView);
end
