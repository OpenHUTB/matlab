function setSettings(blockHandle,varargin)

    blockHandle=Simulink.SFunctionBuilder.internal.verifyBlockHandle(blockHandle);
    sfcnmodel=sfunctionbuilder.internal.sfunctionbuilderModel.getInstance();

    cliView=struct('publishChannel','cli');
    sfcnmodel.registerView(blockHandle,cliView);
    controller=sfunctionbuilder.internal.sfunctionbuilderController.getInstance;

    for i=1:2:numel(varargin)
        name=varargin{i};
        value=varargin{i+1};
        switch name
        case 'ArrayLayout'
            setting.name='Majority';
            setting.value=value;
        case 'SampleMode'
            setting.name='SampleTime';
            setting.value=value;
        case 'SampleTime'
            setting.name='SampleTimeValue';
            setting.value=num2str(value);
        case 'NumberOfPWorks'
            setting.name='NumberPWorks';
            setting.value=num2str(value);
        case 'UseSimStruct'
            setting.name='UseSimStruct';
            if~islogical(value)&&~strcmp(num2str(value),'0')&&~strcmp(num2str(value),'1')
                error('Simulink:SFunctionBuilder:MustBeLogicalValue',DAStudio.message('Simulink:SFunctionBuilder:MustBeLogicalValue'));
            end
            setting.value=value;
        case 'DirectFeedthrough'
            setting.name='DirectFeedThrough';
            if~islogical(value)&&~strcmp(num2str(value),'0')&&~strcmp(num2str(value),'1')
                error('Simulink:SFunctionBuilder:MustBeLogicalValue',DAStudio.message('Simulink:SFunctionBuilder:MustBeLogicalValue'));
            end
            setting.value=value;
        case 'MultiInstanceSupport'
            setting.name='ForEach';
            if~islogical(value)&&~strcmp(num2str(value),'0')&&~strcmp(num2str(value),'1')
                error('Simulink:SFunctionBuilder:MustBeLogicalValue',DAStudio.message('Simulink:SFunctionBuilder:MustBeLogicalValue'));
            end
            setting.value=value;
        case 'MultiThreadSupport'
            setting.name='MultiThread';
            if~islogical(value)&&~strcmp(num2str(value),'0')&&~strcmp(num2str(value),'1')
                error('Simulink:SFunctionBuilder:MustBeLogicalValue',DAStudio.message('Simulink:SFunctionBuilder:MustBeLogicalValue'));
            end
            setting.value=value;
        case 'CodeReuseSupport'
            setting.name='CodeReuse';
            if~islogical(value)&&~strcmp(num2str(value),'0')&&~strcmp(num2str(value),'1')
                error('Simulink:SFunctionBuilder:MustBeLogicalValue',DAStudio.message('Simulink:SFunctionBuilder:MustBeLogicalValue'));
            end
            setting.value=value;
        otherwise

        end
        controller.updateSFunctionSetting(blockHandle,setting);
    end
    sfcnmodel.unregisterView(blockHandle,cliView);
end


