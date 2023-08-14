function action_performed=ModelRefFixes(aMsgId,varargin)





    fix_function=['fix',aMsgId];
    action_performed=feval(fix_function,varargin);
end


function action_performed=fixprotectedModelUnsavedChanges(varargin)
    model=bdroot(varargin{1}{1});
    save_system(model);
    action_performed=message('Simulink:protectedModel:protectedModelUnsavedChangesFixed').getString();
end


function action_performed=fixMultiInstanceToFile(varargin)
    model=varargin{1}{1};

    set_param(model,'ModelReferenceNumInstancesAllowed','single');
    action_performed=message('Simulink:modelReference:MultiInstanceToFileFixed',model).getString();
end


function action_performed=fixMultipleRefToSingleInstMdl(varargin)
    model=varargin{1}{1};


    set_param(model,'ModelReferenceNumInstancesAllowed','Multi');
    action_performed=message('Simulink:modelReference:MultipleRefToSingleInstMdlFixed',model).getString();
end


function action_performed=fixModelBlockSimulationMode(varargin)
    modelBlock=varargin{1}{1};
    set_param(modelBlock,'SimulationMode','Normal');
    action_performed=message('Simulink:modelReference:ModelBlockSimulationModeFixed',modelBlock).getString();
end


function action_performed=fixNonvirtualOutportForExpFcn(varargin)
    block=varargin{1}{1};
    set_param(block,'BusOutputAsStruct','on');
    action_performed=MSLDiagnostic(message('Simulink:FcnCall:RootOutportCannotOutputVirtualBusForExportFcn_fix',...
    block)).message();
end


function action_performed=fixFixedStepMismatch(varargin)

    referencedModel=varargin{1}{1};
    stepSize=varargin{1}{2};
    set_param(referencedModel,'FixedStep',stepSize);

    action_performed=message('Simulink:modelReference:FixedStepMismatchFixed',...
    referencedModel,stepSize).getString();
end


function action_performed=fixSolverTypeChangeSubModel(varargin)

    parentModel=varargin{1}{1};
    referencedModel=varargin{1}{2};
    load_system(referencedModel);

    solverTypeParent=get_param(parentModel,'SolverType');
    set_param(referencedModel,'SolverType',solverTypeParent);

    action_performed=message('Simulink:modelReference:SolverTypeMismatchFixed',...
    referencedModel,solverTypeParent).getString();
end


function action_performed=fixSolverTypeChangeParentModel(varargin)

    parentModel=varargin{1}{1};
    referencedModel=varargin{1}{2};
    load_system(referencedModel);

    solverTypeSub=get_param(referencedModel,'SolverType');
    set_param(parentModel,'SolverType',solverTypeSub);

    action_performed=message('Simulink:modelReference:SolverTypeMismatchFixed',...
    parentModel,solverTypeSub).getString();
end


function action_performed=fixRefreshModelBlock(varargin)
    modelBlock=varargin{1}{1};
    Simulink.ModelReference.refresh(modelBlock);

    action_performed=message('Simulink:modelReference:ModelBlockRefreshFixedMsg',...
    modelBlock).getString();
end
