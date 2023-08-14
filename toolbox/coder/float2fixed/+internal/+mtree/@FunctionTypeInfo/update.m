
function update(this,otherFcnTypeInfo,typeProposalSettings)




    checkHasSameProperties(this,otherFcnTypeInfo);


    otherFcnTypeInfoVars=otherFcnTypeInfo.getAllVarNames;

    cellfun(@(var)this.addVarInfo(var...
    ,getMergedVarTypeInfo(this.getVarInfo(var)...
    ,otherFcnTypeInfo.getVarInfo(var)...
    ,typeProposalSettings))...
    ,otherFcnTypeInfoVars);




    this.callSites=[this.callSites,otherFcnTypeInfo.callSites];

    function newVarInfo=getMergedVarTypeInfo(varInfo,otherVarInfo,typeProposalSettings)
        if isempty(varInfo)

            newVarInfo=otherVarInfo.copy;
        elseif isempty(otherVarInfo)

            newVarInfo=varInfo;
        else
            varInfo.update(otherVarInfo,typeProposalSettings);
            newVarInfo=varInfo;
        end
    end

    function checkHasSameProperties(that,otherFcnTypeInfo)
        assert(strcmp(that.functionName,otherFcnTypeInfo.functionName)&&...
        strcmp(that.specializationName,otherFcnTypeInfo.specializationName)&&...
        strcmp(that.uniqueId,otherFcnTypeInfo.uniqueId)&&...
        strcmp(that.scriptPath,otherFcnTypeInfo.scriptPath)&&...
        all(strcmp(sort(that.inputVarNames)...
        ,sort(otherFcnTypeInfo.inputVarNames)))&&...
        all(strcmp(sort(that.outputVarNames)...
        ,sort(otherFcnTypeInfo.outputVarNames)))...
        ,'Internal Error: Function Infos do not match');

    end
end
