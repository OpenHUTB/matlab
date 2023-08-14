function violations=getViolations(system,blkHandle,varargin)

    optargs={0,edittime.ViolationType.Error};
    numvarargs=length(varargin);



    optargs(1:numvarargs)=varargin;

    violationNum=optargs{1};
    startWithViolationType=optargs{2};
    EditTimeEngine=edittimecheck.EditTimeEngine.getInstance();
    strArray={EditTimeEngine.getViolations(system,blkHandle)};
    v={};
    for i=1:3:length(strArray)

        reasonID=strArray{i}.CheckAlgoID;
        checkID=strArray{i}.CheckID;
        type=strArray{i}.ViolationType;
        v{end+1}=getViolation(system,checkID,reasonID,blkHandle);%#ok<AGROW>
        if(type==ModelAdvisor.CheckStatus.Warning)
            v{end}.setType(ModelAdvisor.CheckStatus.Warning);
        else
            v{end}.setType(ModelAdvisor.CheckStatus.Failed);
        end


    end
    index=[];
    if(slfeature('ShowMissingVarsAtEditTime')>=3)

        violationVector=strcmp(cellfun(@(interest)interest.reasonID,v,'uni',false),{'BlockEditTimeMissingParams'});
        index=find(violationVector==1);

    end
    for i=1:length(v)
        if(slfeature('ShowMissingVarsAtEditTime')>=3&&find(index==i))
            continue;
        end
        if((v{i}.type==startWithViolationType)...
            ||((v{i}.type==ModelAdvisor.CheckStatus.Warning)&&(startWithViolationType==ModelAdvisor.CheckStatus.Warning))...
            ||((v{i}.type==ModelAdvisor.CheckStatus.Failed)&&(startWithViolationType==ModelAdvisor.CheckStatus.Failed)))
            index=[index,i];%#ok<AGROW>
        end
    end
    violations=v(index);
    violations=[violations,v(setdiff(1:length(v),index))];
    if(violationNum~=0)
        assert(violationNum<length(violations)+1&&violationNum>0,'index of violation should be > 0 and less than number of violations');
        violations=violations(violationNum);
    end
end

function violation=getViolation(system,checkID,reasonID,blkHandle)
    try
        if contains(reasonID,"BlockConstraintViolation")
            try
                checkId=strrep(checkID,'.','_');
                violation=feval(['edittime.violations.BlockConstraintViolation.',checkId],system,blkHandle,checkID);
            catch
                violation=feval(['edittime.violations.BlockConstraintViolation.','customCheck'],system,blkHandle,checkID);
            end
        else
            violation=feval(['edittime.violations.',reasonID],system,blkHandle,checkID);
        end
    catch
        DAStudio.error('sledittimecheck:edittimecheck:UnknownViolationType',reasonID)
    end
end
