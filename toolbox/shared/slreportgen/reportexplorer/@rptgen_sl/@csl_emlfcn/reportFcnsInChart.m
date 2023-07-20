function reportFcnsInChart(this,d,chart,out)





    emlFcns=chart.find('-isa','Stateflow.EMFunction');
    if~isempty(emlFcns)
        this.reportChartFcns(d,emlFcns,out);

        if this.includeSupportingFunctions||this.includeSupportingFunctionsCode
            fcnData=getSupportingFcnByEMLNameResolution(this,chart);
        end

        if this.includeSupportingFunctions
            this.makeSupportingFunctionsTable(d,out,chart,fcnData);
        end

        if this.includeSupportingFunctionsCode
            this.makeSupportingFunctionsCodeElems(d,out,fcnData);
        end
    end


