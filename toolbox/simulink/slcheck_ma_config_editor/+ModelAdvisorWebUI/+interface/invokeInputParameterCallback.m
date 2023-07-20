function resultJSON=invokeInputParameterCallback(allInputParameters,originalNodeID,ip_index,newValue)

    try
        tempCopy=ModelAdvisorWebUI.interface.createConfigUIObj(allInputParameters,originalNodeID);

        tag=['InputParameters_',num2str(ip_index)];
        tempCopy.InputParameters{ip_index}.Value=newValue;
        if~isempty(tempCopy.InputParametersCallback)
            if(nargin(tempCopy.InputParametersCallback)==3)
                tempCopy.InputParametersCallback(tempCopy,tag,[]);
            else
                tempCopy.InputParametersCallback(tempCopy);
            end
        end

        value=Advisor.Utils.exportJSON(tempCopy,'MACE');
        title='';
        success=true;
        msg='';
    catch E
        value='';
        title='Error';
        success=false;
        msg=E.message;
    end

    result=struct('success',success,'message',jsonencode(struct('title',title,'content',msg)),'warning',false,'filepath','','value',value);
    resultJSON=jsonencode(result);

end

