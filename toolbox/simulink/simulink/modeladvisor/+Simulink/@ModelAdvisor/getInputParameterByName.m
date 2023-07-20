function InputParameter=getInputParameterByName(this,paramName)




    InputParameter={};
    if~isempty(this.ActiveCheck)
        InputParameters=this.ActiveCheck.getInputParameters;
        for i=1:length(InputParameters)
            if strcmp(InputParameters{i}.Name,paramName)
                InputParameter=InputParameters{i};
                return
            end
        end
    end
