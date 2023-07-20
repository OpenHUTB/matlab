function VariantTransitions(obj)






    if isR2019bOrEarlier(obj.ver)


        machineH=getStateflowMachine(obj);
        if isempty(machineH)
            return;
        end
        charts=machineH.find('-isa','Stateflow.Chart');
        for i=1:length(charts)
            ch=charts(i);
            vts=ch.find('-isa','Stateflow.Transition','isVariant',1);
            if~isempty(vts)
                obj.reportWarning('Stateflow:misc:VariantTransitionsInPrevVersion',ch.path);
                break;
            end
        end
    end
end
