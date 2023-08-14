function OutputEventParens(obj)


    if isR2012aOrEarlier(obj.ver)

        machine=getStateflowMachine(obj);
        if isempty(machine)
            return;
        end

        allChartIds=sf('get',machine.Id,'machine.charts');
        for i=1:length(allChartIds)
            sfBlkH=sfprivate('chart2block',allChartIds(i));
            op_port=Stateflow.SLUtils.findSystem(sfBlkH,'BlockType','Outport');
            for j=1:length(op_port)
                oldname=get_param(op_port(j),'Name');
                if length(oldname)>2&&strcmp(oldname(end-1:end),'()')
                    newname=oldname(1:end-2);
                    set(op_port(j),'Name',newname);
                end
            end
        end
    end
