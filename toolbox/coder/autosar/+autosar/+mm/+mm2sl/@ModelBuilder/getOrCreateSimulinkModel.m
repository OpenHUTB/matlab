




function slModelName=getOrCreateSimulinkModel(m3iComponent,nameConflictAction,mdlFileName,template)

    function nCreateSimulinkModel(modelName,stfName,template)
        if isempty(template)
            new_system(modelName,'Model');
        else
            bdH=Simulink.createFromTemplate(template,'Name',modelName);


            handles=find_system(bdH,...
            'FindAll','on',...
            'SearchDepth',1,...
            'type','Block');
            arrayfun(@(block)delete_block(block),handles);
            handles=find_system(bdH,...
            'FindAll','on',...
            'SearchDepth',1,...
            'type','Line');
            delete(handles);
        end
        set_param(modelName,'SolverType','Fixed-step');
        set_param(modelName,'Solver','FixedStepDiscrete');
        set_param(modelName,'SignalResolutionControl','UseLocalSettings');
        set_param(modelName,'SampleTimeColors','on');

        cs=getActiveConfigSet(modelName);
        switchTarget(cs,stfName,[]);
        set_param(cs,'SaveFormat','StructureWithTime');


        set_param(cs,'StrictBusMsg','ErrorLevel1');
    end

    if nargin<4
        template=[];
    end


    if isempty(mdlFileName)
        mdlFileName=m3iComponent.Name;

        mdlFileName=genvarname(mdlFileName);
    end
    mdlFileName=autosar.mm.mm2sl.ModelBuilder.checkModelFileName(mdlFileName,nameConflictAction);

    if isa(m3iComponent,'Simulink.metamodel.arplatform.component.AdaptiveApplication')
        stfName='autosar_adaptive.tlc';
    else
        stfName='autosar.tlc';
    end


    slModelName=mdlFileName;
    nCreateSimulinkModel(slModelName,stfName,template);

end


