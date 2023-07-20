function VectorOutputs1D(obj)





    if isR2021aOrEarlier(obj.ver)

        machineH=getStateflowMachine(obj);
        if isempty(machineH)
            return;
        end

        emlBlocks=find(machineH,'-isa','Stateflow.EMChart');
        for i=1:numel(emlBlocks)
            if emlBlocks(i).VectorOutputs1D==false
                obj.reportWarning('Stateflow:misc:VectorOutputs1DInPrevVersion',emlBlocks(i).Path)
            end
        end

    end
