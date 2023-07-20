function MalCharts(obj)






    machine=getStateflowMachine(obj);
    if isempty(machine)
        return;
    end

    charts=sf('get',machine.Id,'.charts');

    if isR2011aOrEarlier(obj.ver)
        obj.appendRule('<state<eml<fimathString:remove>>>');
        obj.appendRule('<state<eml<treatAsFi:remove>>>');
        obj.appendRule('<state<eml<fimathForFiConstructors:remove>>>');
        obj.appendRule('<state<eml<emlDefaultFimath:remove>>>');
        obj.appendRule('<state<eml<constantFoldingTimOut:remove>>>');
    end

    if isR2011bOrEarlier(obj.ver)
        obj.appendRule('<transition<eml.cvMapInfo:remove>>');
    end

    if isR2012aOrEarlier(obj.ver)
        for i=1:length(charts)
            currChart=charts(i);

            if Stateflow.MALUtils.isMalChart(currChart)
                obj.reportWarning('Stateflow:misc:MalSaveInPrevVersion',sf('get',currChart,'.name'));


                sf('set',currChart,'.actionLanguage',0);
            end
        end

        obj.appendRule('<event<subchart.isMappedToSubchart:remove>>');
    end

    if isR2013bOrEarlier(obj.ver)

        TTs=machine.find('-isa','Stateflow.TruthTableChart');
        for i=1:length(TTs)
            currTT=TTs(i);



            sf('set',currTT.Id,'.actionLanguage',0);
        end

    end

end
