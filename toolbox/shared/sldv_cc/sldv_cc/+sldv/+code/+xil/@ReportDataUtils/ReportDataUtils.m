




classdef ReportDataUtils
    properties(Constant)
        SHARED_UTILITY_LABEL='Shared Utilities'
    end

    methods(Static,Hidden=true)




        function objectiveDescr=makeRptCodeLink(objective,createLink)
            if nargin<2
                createLink=0;
            end
            objectiveDescr=sldv.code.internal.CodeInfoUtils.makeRptCodeLink(objective,createLink);
        end




        sldvData=addCodeMappingInfo(sldvData,allGoals)




        sldvData=applyCodeMappingInfo(sldvData)




        status=hiliteCode(actionOrSid,moduleName,fileId,line)

    end
end
