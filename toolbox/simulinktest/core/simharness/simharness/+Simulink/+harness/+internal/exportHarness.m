function exportHarness(mdlname,varargin)




    mdlname=get_param(mdlname,'Name');

    prompt=false;
    if nargin>1
        prompt=varargin{1};
    end

    if prompt&&~Simulink.harness.internal.showExportToIndependentModalAlert(mdlname)
        return;
    end

    [filename,~]=Simulink.SaveDialog(mdlname,false);
    if~isempty(filename)
        try
            assert(Simulink.harness.isHarnessBD(mdlname),...
            'Simulink.harness.internal.ExportHarness should only be called for harness model');
            harnessOwnerBD=Simulink.harness.internal.getHarnessOwnerBD(mdlname);




            harnessExportStage=Simulink.output.Stage(...
            DAStudio.message('Simulink:Harness:ExportHarnessStage'),...
            'ModelName',harnessOwnerBD,...
            'UIMode',true);%#ok

            activeHarness=Simulink.harness.internal.getHarnessList(harnessOwnerBD,'active');
            assert(length(activeHarness)==1,...
            'Simulink.harness.internal.ExportHarness should only be called for active harness');
            assert(strcmp(activeHarness(1).name,mdlname),...
            'Harness name should be the same as model name');
            Simulink.harness.export(activeHarness(1).ownerHandle,activeHarness(1).name,'Name',filename);
        catch E

            if~strcmp(E.identifier,'Simulink:editor:DialogCancel')
                Simulink.harness.internal.error(E,true);
            end
        end
    end

end
