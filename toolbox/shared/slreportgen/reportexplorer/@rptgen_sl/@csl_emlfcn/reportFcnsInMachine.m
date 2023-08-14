function reportFcnsInMachine(this,d,machine,out)




    charts=machine.find('-isa','Stateflow.Chart');
    for iChart=1:length(charts)
        if~isempty(emlFcns)
            emlFcns=context.find('-isa','Stateflow.EMFunction');
            this.reportChartFcns(d,emlFcns,out);

            if this.includeSupportingFunctions||this.includeSupportingFunctionsCode
                fcnData=getSupportingFcnByEMLNameResolution(this,chart);
            end

            if this.includeSupportingFunctions
                this.makeSupportingFunctionsTable(d,out,context,fcnData);
            end

            if this.includeSupportingFunctionsCode
                this.makeSupportingFunctionsCodeElems(d,out,fcnData);
            end
        end
    end








