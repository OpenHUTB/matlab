function[success,message]=verifyCheckResultStatus(this,successArray,checkArray)




    checkStatusArray=this.getCheckResultStatus(checkArray);

    if length(checkStatusArray)~=length(successArray)
        success=false;
        message=DAStudio.message('ModelAdvisor:engine:CheckLengthMismatchResultLength');
        return
    end

    for i=1:length(checkStatusArray)
        if successArray{i}~=checkStatusArray{i}
            success=false;
            message=DAStudio.message('ModelAdvisor:engine:CheckResultStatusMismatch',checkArray{i});
            return
        end
    end

    success=true;
    message='';
