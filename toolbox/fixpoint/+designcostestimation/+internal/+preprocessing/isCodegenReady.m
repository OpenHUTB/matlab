function isCodegenReady(Model)





    try
        evalc('feval(Model, [],[], [], ''compileForRTW'')');
        feval(Model,[],[],[],'term');
    catch ME
        DAStudio.error('SimulinkFixedPoint:designCostEstimation:notReadyForCodegen',...
        Model);
    end
end