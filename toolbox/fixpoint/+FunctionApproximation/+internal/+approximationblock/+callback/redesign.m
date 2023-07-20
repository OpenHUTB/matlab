function redesign(variantSystemTag)%#ok<INUSD>




    variantSystemHandle=gcbh;
    blockPath=Simulink.ID.getFullName(variantSystemHandle);
    problemDefinition=FunctionApproximation.Problem(blockPath);
    FunctionApproximation.internal.ui.Wizard.launch([],problemDefinition);
end