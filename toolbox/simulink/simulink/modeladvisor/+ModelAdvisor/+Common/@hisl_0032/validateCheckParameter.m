






function[subStatus,subResult]=validateCheckParameter(this)

    subStatus=true;
    subResult=ModelAdvisor.FormatTemplate('TableTemplate');
    subResult.setSubBar(false);

    if isempty(this.system)
        subStatus=false;
        subResult=[];
        return;
    end

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(this.system);
    allParameters=mdladvObj.getInputParameters();

    parBlockNamesConvention=allParameters{1};
    parBlockNamesRegexp=allParameters{2};
    parSignalNamesConvention=allParameters{3};
    parSignalNamesRegexp=allParameters{4};
    parParameterNamesConvention=allParameters{5};
    parParameterNamesRegexp=allParameters{6};
    parBusNamesConvention=allParameters{7};
    parBusNamesRegexp=allParameters{8};
    parStateflowNamesConvention=allParameters{9};
    parStateflowNamesRegexp=allParameters{10};

    this.conventionBlockNames=parBlockNamesConvention.Value;
    this.conventionSignalNames=parSignalNamesConvention.Value;
    this.conventionParameterNames=parParameterNamesConvention.Value;
    this.conventionBusNames=parBusNamesConvention.Value;
    this.conventionStateflowNames=parStateflowNamesConvention.Value;

    switch this.conventionBlockNames
    case 'MAAB'
        this.regexpBlockNames=Advisor.Utils.Naming.getRegExp('MAAB');
    case 'Custom'
        this.regexpBlockNames=parBlockNamesRegexp.Value;
    case 'None'
        this.regexpBlockNames='';
    end

    switch this.conventionSignalNames
    case 'MAAB'
        this.regexpSignalNames=Advisor.Utils.Naming.getRegExp('MAAB');
    case 'Custom'
        this.regexpSignalNames=parSignalNamesRegexp.Value;
    case 'None'
        this.regexpSignalNames='';
    end

    switch this.conventionParameterNames
    case 'MAAB'
        this.regexpParameterNames=Advisor.Utils.Naming.getRegExp('MAAB');
    case 'Custom'
        this.regexpParameterNames=parParameterNamesRegexp.Value;
    case 'None'
        this.regexpParameterNames='';
    end

    switch this.conventionBusNames
    case 'MAAB'
        this.regexpBusNames=Advisor.Utils.Naming.getRegExp('MAAB');
    case 'Custom'
        this.regexpBusNames=parBusNamesRegexp.Value;
    case 'None'
        this.regexpBusNames='';
    end

    switch this.conventionStateflowNames
    case 'MAAB'
        this.regexpStateflowNames=Advisor.Utils.Naming.getRegExp('MAAB');
    case 'Custom'
        this.regexpStateflowNames=parStateflowNamesRegexp.Value;
    case 'None'
        this.regexpStateflowNames='';
    end

end

