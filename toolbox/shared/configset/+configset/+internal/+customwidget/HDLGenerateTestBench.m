function updateDeps=HDLGenerateTestBench(cs,msg)


    dlg=msg.dialog;

    updateDeps=false;
    cs=cs.getConfigSet;
    hdlcc=cs.getComponent('HDL Coder');
    hdltb=hdlcc.getsubcomponent('hdlcoderui.hdltb');

    hdltb.testbenchCallback(dlg,'ConfigSet_HDLCoder_TestBenchPanel_Generate','',hdlcc);


