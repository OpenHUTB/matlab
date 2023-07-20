function setInputParameters(this,inputParamArray)




    this.InputParameters={};

    for i=1:length(inputParamArray)
        if isa(inputParamArray{i},'ModelAdvisor.InputParameter')

            switch(inputParamArray{i}.Type)
            case{'Enum','ComboBox'}

                if~isempty(inputParamArray{i}.Entries)&&iscell(inputParamArray{i}.Entries)...
                    &&isempty(inputParamArray{i}.Entries(cellfun(@(x)~ischar(x),inputParamArray{i}.Entries)))

                    if isempty(inputParamArray{i}.Value)
                        inputParamArray{i}.Value=inputParamArray{i}.Entries{1};
                    end
                else
                    DAStudio.error('Simulink:tools:MAInvalidParam','cell array of string');
                end
            end

            if~isempty(this.InputParameters(cellfun(@(x)strcmp(x.Name,inputParamArray{i}.Name),this.InputParameters)))
                DAStudio.error('Simulink:tools:MADuplicatedArgName','InputParameters');
            end
            this.InputParameters{end+1}=inputParamArray{i};
        else
            DAStudio.error('Simulink:tools:MAInvalidParam','ModelAdvisor.InputParameter object');
        end
    end
