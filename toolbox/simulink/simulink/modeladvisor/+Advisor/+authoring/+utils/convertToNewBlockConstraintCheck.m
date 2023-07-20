function newCheckObj=convertToNewBlockConstraintCheck(checkObj)




    newCheckObj=checkObj;

    if~isa(newCheckObj,'ModelAdvisor.BlockConstraintCheck')
        DAStudio.error('edittimecheck:engine:NotBlockConstraintObject');
    end

    if newCheckObj.isNewStyle
        return;
    end

    if isempty(newCheckObj.InputParameters)
        DAStudio.error('Advisor:engine:ConstraintsNoInformation')
    end

    for count=1:numel(newCheckObj.InputParameters)

        inputParamValue=newCheckObj.InputParameters{count};

        if~strcmp(inputParamValue.Name,'Data File')
            continue
        end
        inputParamValue.Visible=false;
        xmlFileName=inputParamValue.Value;
        newCheckObj.setConstraints(xmlFileName);
        newCheckObj.CallbackHandle=@(system,chkObj)newCheckObj.checkCallBack(system,chkObj);
        newCheckObj.CallbackStyle='DetailStyle';

        break;

    end

end
