function[status,dscr]=HDL_testbenchEnabled(cs,name)





    dscr='';
    hdl=cs.getComponent('HDL Coder');
    cli=hdl.getCLI;


    if isempty(strfind(cli.HDLSubsystem,'/'))||...
        strcmpi(cli.GenerateModel,'off')||...
        isempty(hdl.getModel)||...
        hdl.getSourceObject.isObjectLocked
        status=configset.internal.data.ParamStatus.ReadOnly;
        return;
    end


    if ismember(name,{'GenerateHDLTestBench','GenerateCoSimModel','GenerateSVDPITestBench'})
        status=configset.internal.data.ParamStatus.Normal;
        return;
    end

    tbenabled=strcmp(cli.GenerateHDLTestBench,'on');



    cosim=strcmp(configset.internal.customwidget.HDL_SimToolValues(cs,'GenerateCoSimModel',0,{}),'on');
    svdpi=strcmp(configset.internal.customwidget.HDL_SimToolValues(cs,'GenerateSVDPITestbench',0,{}),'on');

    if tbenabled||cosim||svdpi
        status=configset.internal.data.ParamStatus.Normal;
    else
        status=configset.internal.data.ParamStatus.ReadOnly;
    end
