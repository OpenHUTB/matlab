function dialogCallback(this,action)






    selectedComponent=this.coreObj;
    advisorObj=selectedComponent.HierAnalyzer;

    isvalid=advisorObj.validateAdvisor();

    if~isvalid
        return;
    end

    switch action

    case 'run_tg'
        this.coreObj.startTG;
    case 'load_tg_results'
        this.coreObj.loadCurrentResults;
    otherwise

    end
end

