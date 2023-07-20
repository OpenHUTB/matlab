function add(blockHandle,itemType,varargin)





    blockHandle=Simulink.SFunctionBuilder.internal.verifyBlockHandle(blockHandle);
    sfcnmodel=sfunctionbuilder.internal.sfunctionbuilderModel.getInstance();

    cliView=struct('publishChannel','cli');
    sfcnmodel.registerView(blockHandle,cliView);
    sfbController=sfunctionbuilder.internal.sfunctionbuilderController.getInstance;
    p=inputParser;
    switch(itemType)

    case{'Input','Output'}
        p.addParameter('Name','');
        p.addParameter('DataType','double');
        p.addParameter('Complexity','real');
        p.addParameter('Dimensions','1');
        p.parse(varargin{:});



        try
            portToBeAdded={char(p.Results.Name),lower(char(itemType)),'double'};
            port=sfbController.addItemToPortTable(blockHandle,portToBeAdded);
        catch ME
            error(ME.identifier,ME.message);
        end

        portName=port.Name;
        try
            Simulink.SFunctionBuilder.update(blockHandle,itemType,'Name',portName,'FieldToUpdate','DataType','NewValue',char(p.Results.DataType));
            Simulink.SFunctionBuilder.update(blockHandle,itemType,'Name',portName,'FieldToUpdate','Dimensions','NewValue',p.Results.Dimensions);
            Simulink.SFunctionBuilder.update(blockHandle,itemType,'Name',portName,'FieldToUpdate','Complexity','NewValue',char(p.Results.Complexity));
        catch ME
            sfbController.delItemFromPortTable(blockHandle,{portName},{lower(char(itemType))});
            error(ME.identifier,ME.message);
        end
    case 'Parameter'
        p.addParameter('Name','');
        p.addParameter('DataType','double');
        p.addParameter('Complexity','real');
        p.addParameter('Value','1');
        p.parse(varargin{:});



        try
            paramterToBeAdded={char(p.Results.Name),lower(char(itemType)),'double'};
            parameter=sfbController.addItemToPortTable(blockHandle,paramterToBeAdded);
        catch ME
            error(ME.identifier,ME.message);
        end

        parameterName=parameter.Name;
        try
            Simulink.SFunctionBuilder.update(blockHandle,itemType,'Name',parameterName,'FieldToUpdate','DataType','NewValue',char(p.Results.DataType));
            Simulink.SFunctionBuilder.update(blockHandle,itemType,'Name',parameterName,'FieldToUpdate','Complexity','NewValue',char(p.Results.Complexity));
            Simulink.SFunctionBuilder.update(blockHandle,itemType,'Name',parameterName,'FieldToUpdate','Value','NewValue',p.Results.Value);
        catch ME
            sfbController.delItemFromPortTable(blockHandle,{parameterName},{lower(char(itemType))});
            error(ME.identifier,ME.message);
        end
    case 'LibraryItem'
        p.addParameter('LibraryItemTag','SRC_PATH');
        p.addParameter('LibraryItemValue','');
        p.parse(varargin{:});
        try
            newLibItem.type=char(p.Results.LibraryItemTag);
            newLibItem.value=char(p.Results.LibraryItemValue);
            sfbController.addItemToLibTable(blockHandle,newLibItem);
        catch ME
            error(ME.identifier,ME.message);
        end
    case{'DiscreteState','ContinuousState'}
        p.addParameter('InitialCondition','0');
        p.parse(varargin{:});
        IC=p.Results.InitialCondition;
        if(~isstring(IC)&&~ischar(IC))||strlength(IC)==0
            error(DAStudio.message('Simulink:SFunctionBuilder:InvalidArgumentIC'));
        end


        AppData=Simulink.SFunctionBuilder.internal.getApplicationData(blockHandle);
        if strcmp(itemType,'DiscreteState')
            currentNum=AppData.SfunWizardData.NumberOfDiscreteStates;
            currentIC=str2num(AppData.SfunWizardData.DiscreteStatesIC);
            settingNum.name='NumberDiscreteStates';
            settingNum.value=num2str(str2num(currentNum)+1);
            settingIC.name='DiscreteStatesIC';
            if str2num(currentNum)==0
                settingIC.value=char(p.Results.InitialCondition);
            else
                settingIC.value=['[',strjoin(arrayfun(@(x)num2str(x),currentIC,'UniformOutput',false),','),',',char(IC),']'];
            end
        elseif strcmp(itemType,'ContinuousState')
            currentNum=AppData.SfunWizardData.NumberOfContinuousStates;
            currentIC=str2num(AppData.SfunWizardData.ContinuousStatesIC);
            settingNum.name='NumberContinuousStates';
            settingNum.value=num2str(str2num(currentNum)+1);
            settingIC.name='ContinuousStatesIC';
            if str2num(currentNum)==0
                settingIC.value=char(p.Results.InitialCondition);
            else
                settingIC.value=['[',strjoin(arrayfun(@(x)num2str(x),currentIC,'UniformOutput',false),','),',',char(IC),']'];
            end
        end

        try
            sfbController.updateSFunctionSetting(blockHandle,settingNum);
            sfbController.updateSFunctionSetting(blockHandle,settingIC);
        catch ME
            error(ME.identifier,ME.message);
        end
    otherwise
        errorStruct.message=DAStudio.message('Simulink:SFunctionBuilder:InvalidField',itemType);
        errorStruct.identifier='Simulink:SFunctionBuilder:InvalidField';
        error(errorStruct);
    end


    sfcnmodel.unregisterView(blockHandle,cliView);

end

