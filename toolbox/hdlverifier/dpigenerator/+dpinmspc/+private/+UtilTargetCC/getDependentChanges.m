function chg=getDependentChanges(hObj,propName,propVal)



    cbName=str2func(['l_',propName,'_cb']);


    chg=cbName(hObj,propVal);

end

function chg=l_DPICustomizeSystemVerilogCode_cb(~,propVal)%#ok<DEFNU>

    switch(propVal)
    case 'off'
        chg.en.DPIGenerateTestBench=true;
        chg.en.DPISystemVerilogTemplate=false;
    case 'on'
        chg.en.DPIGenerateTestBench=false;
        chg.val.DPIGenerateTestBench='off';
        chg.en.DPISystemVerilogTemplate=true;
    end
end
































