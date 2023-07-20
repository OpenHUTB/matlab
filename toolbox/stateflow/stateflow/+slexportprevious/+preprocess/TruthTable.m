function TruthTable(obj)

    if sf('feature','UseWebBasedTruthTable')&&isR2017bOrEarlier(obj.ver)
        machine=getStateflowMachine(obj);
        if isempty(machine)
            return;
        end














        obj.appendRule('<Object<ViewObjType|TruthTableChart><LoadSaveID:repval "1">>');
        obj.appendRule('<Object<ViewObjType|TruthTableChart:repval "SimulinkTopLevel">>');
    end

end