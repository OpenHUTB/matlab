function checkForJacobianMultiplyFcn(probStruct,solver,helpAnchor,problemClass)

    opts=probStruct.options;


    optionsClass="optim.options."+upper(solver(1))+solver(2:end);
    hasJacobianMultiplyFcn=(isstruct(opts)&&isfield(opts,'JacobMult'))||isa(opts,optionsClass);
    linkToDoc=addLink('this example','optim',helpAnchor,false);
    if hasJacobianMultiplyFcn&&~isempty(opts.JacobMult)
        errId="optim_problemdef:"+problemClass+":solve:NoJacobianMultiplyFcn";
        msgId='optim_problemdef:OptimizationProblem:solve:NoJacobianMultiplyFcn';
        error(errId,getString(message(msgId,linkToDoc,solver)));
    end

end