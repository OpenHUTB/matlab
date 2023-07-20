function checkOperatingPoint(slHandle)























    try


        op=simscape.compiler.sli.internal.resolveOperatingPoint(slHandle);



        lCheckTopLevelBlocks(slHandle,op);
        lCheckModelName(slHandle,op);
    catch

    end

end

function lCheckTopLevelBlocks(slObj,op)


    foundMatch=false;
    for idx=1:numel(op.ChildIds)
        result=find_system(slObj,'SearchDepth',...
        1,'Name',op.ChildIds{idx});
        if~isempty(result)
            foundMatch=true;
            break
        end
    end

    if~foundMatch
        warning(message('physmod:simscape:compiler:sli:op:NoMatchingBlocks'));
    end

end

function lCheckModelName(slObj,op)


    mdlName=getfullname(slObj);
    foundInOp=ismember(mdlName,op.ChildIds);

    if foundInOp
        foundChild=find_system(slObj,'SearchDepth',1,'Name',mdlName,'Parent',mdlName);
        if isempty(foundChild)
            warning(message('physmod:simscape:compiler:sli:op:ModelNameInOpPath',...
            mdlName,mdlName));
        end
    end
end
