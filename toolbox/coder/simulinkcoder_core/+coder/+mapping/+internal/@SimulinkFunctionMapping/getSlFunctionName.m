function fcnName=getSlFunctionName(blk)




    [~,~,fcnName]=coder.mapping.internal.SimulinkFunctionMapping.getSLFcnInOutArgs(blk);
end
