function setInputParametersLayoutGrid(this,layoutGrid)




    if isnumeric(layoutGrid)&&length(layoutGrid)==2&&layoutGrid(1)>0&&layoutGrid(2)>0
        this.InputParametersLayoutGrid=layoutGrid;
    elseif isempty(layoutGrid)
        this.InputParametersLayoutGrid=[length(this.InputParameters),1];
    else
        DAStudio.error('Simulink:tools:MAInvalidParam','integer');
    end
