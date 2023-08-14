function state=initMakehdl(this,mdlName)





    this.logInfo={};
    this.cgInfo={};


    this.WebBrowserHandles=WebBrowserHandleCollector;

    this.NeedToGenerateHTMLReport=true;
    this.createConfigManager(mdlName);
    this.getCPObj;

    [oldDriver,oldMode,oldAutosaveState]=this.inithdlmake(mdlName);
    state.oldDriver=oldDriver;
    state.oldMode=oldMode;
    state.oldAutosaveState=oldAutosaveState;

    state.current_system=get_param(0,'CurrentSystem');


    this.updateLintParams(mdlName);
    updateCodingStdCustomizations(this);
end


function updateCodingStdCustomizations(this)
    codingStdOptions=this.getParameter('HDLCodingStandardCustomizations');


    if isempty(codingStdOptions)||~isa(codingStdOptions,'hdlcodingstd.BaseCustomizations')
        if this.isIndustryStandardMode()
            coding_std_mode='Industry';
        else
            coding_std_mode='None';
        end
        codingStdOptions=hdlcoder.CodingStandard(coding_std_mode);
        this.setParameter('HDLCodingStandardCustomizations',codingStdOptions);
    end
end
