function delete(blockHandle,itemType,varargin)
    blockHandle=Simulink.SFunctionBuilder.internal.verifyBlockHandle(blockHandle);
    sfbController=sfunctionbuilder.internal.sfunctionbuilderController.getInstance;
    p=inputParser;
    switch(itemType)
    case{'Input','Output','Parameter'}
        p.addParameter('Name','');
        p.parse(varargin{:});
        if~isempty(p.Results.Name)
            sfbController.delItemFromPortTable(blockHandle,{p.Results.Name},{lower(char(itemType))});
        else
            error(DAStudio.message('Simulink:SFunctionBuilder:InvalidArgumentName'));
        end
    case 'LibraryItem'
        p.addParameter('Index',-1);
        p.parse(varargin{:});
        if(isstring(p.Results.Index)||ischar(p.Results.Index))
            indexValue=str2double(p.Results.Index);
        else
            indexValue=p.Results.Index;
        end
        if(rem(indexValue,1)==0&&indexValue>0)
            range.start=indexValue;
            range.end=indexValue;
            range.count=1;
            sfbController.delItemFromLibTable(blockHandle,'',range);
        else
            error(DAStudio.message('Simulink:SFunctionBuilder:InvalidArgumentIndex'));
        end
    case{'DiscreteState','ContinuousState'}
        p.addParameter('Index',-1);
        p.parse(varargin{:});
        if(isstring(p.Results.Index)||ischar(p.Results.Index))
            indexValue=str2double(p.Results.Index);
        else
            indexValue=p.Results.Index;
        end
        if(rem(indexValue,1)==0&&indexValue>0)


            AppData=Simulink.SFunctionBuilder.internal.getApplicationData(blockHandle);
            if strcmp(itemType,'DiscreteState')
                currentNum=AppData.SfunWizardData.NumberOfDiscreteStates;
                currentIC=str2num(AppData.SfunWizardData.DiscreteStatesIC);
                currentIC(indexValue)=[];
                settingNum.name='NumberDiscreteStates';
                settingNum.value=num2str(str2double(currentNum)-1);
                settingIC.name='DiscreteStatesIC';
                if str2num(currentNum)==1
                    settingIC.value='0';
                else
                    settingIC.value=['[',strjoin(arrayfun(@(x)num2str(x),currentIC,'UniformOutput',false),','),']'];
                end
            elseif strcmp(itemType,'ContinuousState')
                currentNum=AppData.SfunWizardData.NumberOfContinuousStates;
                currentIC=str2num(AppData.SfunWizardData.ContinuousStatesIC);
                currentIC(indexValue)=[];
                settingNum.name='NumberContinuousStates';
                settingNum.value=num2str(str2double(currentNum)-1);
                settingIC.name='ContinuousStatesIC';
                if str2num(currentNum)==1
                    settingIC.value='0';
                else
                    settingIC.value=['[',strjoin(arrayfun(@(x)num2str(x),currentIC,'UniformOutput',false),','),']'];
                end
            end

            try
                sfbController.updateSFunctionSetting(blockHandle,settingNum);
                sfbController.updateSFunctionSetting(blockHandle,settingIC);
            catch ME
                error(ME.message);
            end
        else
            error(DAStudio.message('Simulink:SFunctionBuilder:InvalidArgumentIndex'));
        end
    otherwise
        errorStruct.message=DAStudio.message('Simulink:SFunctionBuilder:InvalidField',itemType);
        errorStruct.identifier='Simulink:SFunctionBuilder:InvalidField';
        error(errorStruct);
    end
end

