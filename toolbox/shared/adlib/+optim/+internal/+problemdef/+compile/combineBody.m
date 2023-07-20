function CombinedBlock=combineBody(FunctionBlock,GradientBlock,numFcnOutputs,...
    GradientBlockFirst,jointFunAndGrad)





























    if jointFunAndGrad


        FunctionBlock=addIndentation(FunctionBlock);
        FunctionBlock="if nargout < "+(numFcnOutputs+1)+newline+...
        FunctionBlock;
        GradientBlock=addIndentation(GradientBlock);
        GradientBlock="else"+newline+...
        GradientBlock+newline+"end"+newline;

        CombinedBlock=FunctionBlock+newline+GradientBlock;
    else

        GradientBlock=addIndentation(GradientBlock);
        GradientBlock="if nargout > "+numFcnOutputs+...
        newline+GradientBlock+"end"+newline;

        if GradientBlockFirst

            CombinedBlock=GradientBlock+newline+FunctionBlock;
        else

            CombinedBlock=FunctionBlock+newline+GradientBlock;
        end
    end

end

function block=addIndentation(block)
    block=splitlines(block);
    block(end)=[];
    block=strjoin("    "+block,'\n')+newline;
end
