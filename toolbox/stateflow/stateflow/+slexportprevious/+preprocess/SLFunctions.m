function SLFunctions(obj)






    machineH=getStateflowMachine(obj);
    if isempty(machineH)
        return;
    end

    if isR2008aOrEarlier(obj.ver)



        charts=machineH.find('-isa','Stateflow.Chart');
        for i=1:length(charts)
            ch=charts(i);
            simf=ch.find('-isa','Stateflow.SLFunction');
            if~isempty(simf)
                simf=simf(1);

                fcnRelPath=sf('FullName',simf.Id,simf.Chart.id,'.');
                chartRelPath=sf('FullName',simf.Chart.Id,simf.Machine.Id,'/');
                obj.reportWarning('Stateflow:slinsf:SaveInPrevVersion',fcnRelPath,chartRelPath);

                break;
            end
        end

    end




    if isR2007bOrEarlier(obj.ver)

        obj.appendRule('<state<simulink:remove>>');





        simFcns=machineH.find('-isa','Stateflow.SLFunction');
        for i=1:length(simFcns)
            delete(simFcns(i));
        end

        return;
    end

    if isR2008bOrEarlier(obj.ver)





        simFunctions=machineH.find('-isa','Stateflow.SLFunction');
        for i=1:length(simFunctions)
            simf=simFunctions(i);
            subsys=simf.getDialogProxy;

            subsys.UserData=simf.SSIdNumber;
            subsys.UserDataPersistent='on';
        end


        obj.appendRule('<state<simulink<blockName:remove>>>');
    end

end
