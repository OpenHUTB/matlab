



function advisorViolations=getAdvisorViolations(model,blkhandle)
    advisorViolations=[];
    editEngine=edittimecheck.EditTimeEngine.getInstance();
    if strcmp(get_param(blkhandle,'type'),'line')
        dst=get_param(blkhandle,'Dstporthandle');
        for i=1:length(dst)
            advisorViolations=[advisorViolations,editEngine.getAdvisorViolationsForBlock(model,dst(i))];%#ok<*AGROW>
        end
        src=get_param(blkhandle,'Srcporthandle');
        for i=1:length(src)
            advisorViolations=[advisorViolations,editEngine.getAdvisorViolationsForBlock(model,src(i))];
        end
    end
    advisorViolations=[advisorViolations,editEngine.getAdvisorViolationsForBlock(model,blkhandle)];
end