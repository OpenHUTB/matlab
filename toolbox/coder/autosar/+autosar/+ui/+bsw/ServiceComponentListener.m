classdef ServiceComponentListener




    methods(Static)
        function updateDiagnosticServiceComponentUI()



            import autosar.ui.bsw.ServiceComponentListener

            dlgs=ServiceComponentListener.getOpenDlgsDuringDiagUpdate('Dem');
            for ii=1:numel(dlgs)
                dlg=dlgs(ii);
                if ServiceComponentListener.areClientPortsAssigned(dlg)
                    ServiceComponentListener.reloadServiceComponentSS(dlg);
                    ServiceComponentListener.reloadFimSS(dlg);
                    if slfeature('FaultAnalyzerBsw')
                        ServiceComponentListener.reloadFaultSS(dlg);
                    end
                    dlg.refresh();
                end
            end
        end

        function updateNVRAMServiceComponentUI()



            import autosar.ui.bsw.ServiceComponentListener

            dlgs=ServiceComponentListener.getOpenDlgsDuringDiagUpdate('NvM');
            for ii=1:numel(dlgs)
                dlg=dlgs(ii);
                if ServiceComponentListener.areClientPortsAssigned(dlg)
                    ServiceComponentListener.reloadServiceComponentSS(dlg);
                    if slfeature('NVRAMInitialValue')
                        ServiceComponentListener.reloadNvInitValSS(dlg);
                    end
                    dlg.refresh();
                end
            end
        end
    end

    methods(Static,Access=private)
        function reloadServiceComponentSS(dlg)
            servCompSpreadsheet=dlg.getWidgetSource('tag_MappingSpreadsheet');
            servCompSpreadsheet.loadChildren();
        end

        function reloadFimSS(dlg)
            fimSpreadsheet=dlg.getWidgetSource('fimTagmatrixSpreadsheet');
            fimSpreadsheet.loadChildren();
        end

        function reloadFaultSS(dlg)
            faultSpreadsheet=dlg.getWidgetSource('faultTagfaultSpreadsheet');
            faultSpreadsheet.loadChildren();
        end

        function reloadNvInitValSS(dlg)
            nvmInitSpreadsheet=dlg.getWidgetSource('nvmInitValTagmatrixSpreadsheet');
            nvmInitSpreadsheet.loadChildren();
        end

        function dlgs=getOpenDlgsDuringDiagUpdate(serviceCompType)



            dlgs=findDDGByTag('tag_DiagnosticServiceComponent');
            if isempty(dlgs)
                return;
            end

            idx=1;
            while idx<=numel(dlgs)
                source=dlgs(idx).getSource();
                if~strcmp(autosar.bsw.ServiceComponent.getBswCompType(source.getBlock.Handle),serviceCompType)
                    dlgs(idx)=[];
                    continue;
                end



                isDuringPreApply=isfield(source.UserData,'duringPreApply')&&source.UserData.duringPreApply;
                if isDuringPreApply
                    dlgs(idx)=[];
                    continue;
                end
                idx=idx+1;
            end
        end

        function assigned=areClientPortsAssigned(dlg)



            assigned=true;

            blkH=dlg.getDialogSource.getBlock().Handle;
            clientPortNames=eval(get_param(blkH,'ClientPortNames'));
            portDefinedArgs=eval(get_param(blkH,'ClientPortPortDefinedArguments'));

            try
                idTypes=eval(get_param(blkH,'IdTypes'));
            catch E
                E.rethrow();
            end

            if numel(clientPortNames)~=numel(portDefinedArgs)...
                ||numel(clientPortNames)~=numel(idTypes)


                assigned=false;
                return;
            end
        end
    end
end


