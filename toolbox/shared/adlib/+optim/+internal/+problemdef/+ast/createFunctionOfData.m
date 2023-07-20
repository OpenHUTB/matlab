function outExprList=createFunctionOfData(func,nOutputs,inputs,evalVisitor)


















    outExprList=cell(1,nOutputs);


    evalOut=cell(1,nOutputs);
    try


        evalInputs=cellfun(@(input)generateInputPoint(input,evalVisitor),inputs,'UniformOutput',false);
        [evalOut{:}]=func(evalInputs{:});
    catch userFcn_ME

        optim_ME=MException(message('shared_adlib:fcn2optimexpr:FcnError'));
        userFcn_ME=addCause(userFcn_ME,optim_ME);
        rethrow(userFcn_ME);
    end

    OutputSize=cellfun(@checkOutputSize,evalOut,'UniformOutput',false);


    ReuseEvaluation=false;
    [optimFunc,vars,depth]=optim.internal.problemdef.FunctionWrapper.createFunctionWrapper(...
    func,inputs,nOutputs,ReuseEvaluation);


    type=optim.internal.problemdef.ImplType.Numeric;






    for i=1:nOutputs
        outputi=optim.problemdef.OptimizationExpression();

        outputi=createFunction(outputi,optimFunc,vars,depth,OutputSize{i},type,i);
        outExprList{i}=outputi;
    end

end



function evalArg=generateInputPoint(input,evalVisitor)
    if~isa(input,'optim.problemdef.OptimizationExpression')

        evalArg=input;
    elseif isNumeric(input)




        inputImpl=getExprImpl(input);
        acceptVisitor(inputImpl,evalVisitor);
        evalArg=getValue(evalVisitor);
    else


        error('shared_adlib:ast:NonNumericBlackBoxInput',...
        'All inputs must be numeric to wrap them as a black-box for static');
    end

end



function outSize=checkOutputSize(output)
    if isa(output,'optim.problemdef.OptimizationExpression')||...
        isa(output,'optim.problemdef.OptimizationConstraint')||...
        isa(output,'optim.internal.problemdef.ProblemImpl')


        error('shared_adlib:ast:NonNumericBlackBoxOutput',...
        'All outputs must be numeric to wrap them as a black-box for static');
    end
    outSize=size(output);
end
