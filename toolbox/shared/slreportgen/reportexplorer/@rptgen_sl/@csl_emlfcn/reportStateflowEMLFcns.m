function reportStateflowEMLFcns(this,d,context,out)





    switch class(context)
    case 'Stateflow.EMFunction'
        this.reportChartFcns(d,context,out);
    case 'Stateflow.Chart'
        this.reportFcnsInChart(d,context,out);
    case 'Stateflow.Machine'
        this.reportFcnsInMachine(d,context,out)
    end







