function[success,message]=verifyCheckResult(this,matfileName,checkArray)





    success=false;
    message='';

    encodedModelName=modeladvisorprivate('HTMLjsencode',getfullname(this.System),'encode');


    for i=1:length(checkArray)
        newID=ModelAdvisor.convertCheckID(checkArray{i});
        if~isempty(newID)
            checkArray{i}=newID;
        end
    end


    current_checkArray={};


    condensedCheck={};
    for i=1:length(this.CheckCellArray)
        if ismember(this.CheckCellArray{i}.ID,checkArray)

            condensedCheck=copy(this.CheckCellArray{i});
            condensedCheck.CallbackHandle=[];
            current_checkArray{end+1}=condensedCheck;%#ok<AGROW>
        end
    end

    if length(current_checkArray)~=length(checkArray)
        success=false;
        message=DAStudio.message('ModelAdvisor:engine:AllChecksNotFound');
        return
    end


    if this.BaselineMode
        save(matfileName,'current_checkArray');
        s=load(matfileName);
        if locCompareResult(current_checkArray,s.current_checkArray,encodedModelName)
            success=true;
            message='';
        else
            success=false;
            message=DAStudio.message('ModelAdvisor:engine:SaveMatFileFailed',matfileName);
        end
        return
    end





    try
        s=load(matfileName);
    catch
        message=DAStudio.message('ModelAdvisor:engine:LoadMatFileFailed');
        success=false;
        return
    end


    if locCompareResult(current_checkArray,s.current_checkArray,encodedModelName)
        success=true;
        message='';
    else
        success=false;
        message=DAStudio.message('ModelAdvisor:engine:SavedMatFileMismatch',matfileName);
    end
    return


    function result=locCompareResult(checkArray1,checkArray2,encodedModelName)
        result=false;

        matchCounter=0;
        for i=1:length(checkArray1)
            for j=1:length(checkArray2)

                if isa(checkArray1{i},'Simulink.MdlAdvisorCheck')
                    checkArray1{i}=ModelAdvisor.Check(checkArray1{i});
                end
                if isa(checkArray2{i},'Simulink.MdlAdvisorCheck')
                    checkArray2{i}=ModelAdvisor.Check(checkArray2{i});
                end
                if locCompareCheck(checkArray1{i},checkArray2{j},encodedModelName)
                    matchCounter=matchCounter+1;
                    break
                end
            end
        end
        if(matchCounter==length(checkArray1))&&...
            (length(checkArray1)==length(checkArray2))
            result=true;
        else
            result=false;
        end

        function result=locCompareCheck(check1,check2,~)
            result=false;%#ok<NASGU>

            if~strcmp(check1.ID,check2.ID)
                newID=ModelAdvisor.convertCheckID(check2.ID);
                if~strcmp(check1.ID,newID)
                    result=false;
                    return
                end
            end
            if~strcmp(check1.CallbackStyle,check2.CallbackStyle)
                result=false;
                return
            end


            shuffeledResultsCheck1=modeladvisorprivate('modeladvisorutil2','shuffleReport',check1.ResultInHTML);
            shuffeledResultsCheck2=modeladvisorprivate('modeladvisorutil2','shuffleReport',check2.ResultInHTML);


            shuffeledResultsCheck1=regexprep(shuffeledResultsCheck1,'\n','');
            shuffeledResultsCheck2=regexprep(shuffeledResultsCheck2,'\n','');

            result=strcmp(shuffeledResultsCheck1,shuffeledResultsCheck2);

