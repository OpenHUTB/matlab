



function diagnosticViolations=getDiagnosticViolations(model,blkhandle)
    diagnosticViolations=[];
    editEngine=edittimecheck.EditTimeEngine.getInstance();
    if strcmp(get_param(blkhandle,'type'),'line')
        dst=get_param(blkhandle,'Dstporthandle');
        for i=1:length(dst)
            diagnosticViolations=[diagnosticViolations,editEngine.getDiagnosticViolationsForBlock(model,dst(i))];%#ok<*AGROW> 
        end
        src=get_param(blkhandle,'Srcporthandle');
        for i=1:length(src)
            diagnosticViolations=[diagnosticViolations,editEngine.getDiagnosticViolationsForBlock(model,src(i))];
        end
    end
    diagnosticViolations=[diagnosticViolations,editEngine.getDiagnosticViolationsForBlock(model,blkhandle)];
end
