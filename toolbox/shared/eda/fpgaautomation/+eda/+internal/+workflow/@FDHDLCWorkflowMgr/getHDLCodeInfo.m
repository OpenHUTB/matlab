function getHDLCodeInfo(h)




    hcData=h.mWorkflowInfo.hdlcData;


    hcData.hdlPropSet=PersistentHDLPropSet;


    hcData.modelName='';


    hcData.dutName=hdlentitytop;
    hcData.hdlFiles=hdlentityfilenames;


    clk=hdlgetcurrentclock;
    hcData.dut.clock.Name=hdlsignalname(clk);

    ce=hdlgetcurrentclockenable;
    hcData.dut.clkenable.Name=hdlsignalname(ce);

    rst=hdlgetcurrentreset;
    hcData.dut.reset.Name=hdlsignalname(rst);


    iports=hdlinportsignals;
    iports=iports(iports~=clk);
    iports=iports(iports~=ce);
    iports=iports(iports~=rst);

    name=hdlsignalname(iports);
    sltype=hdlsignalsltype(iports);
    hcData.dut.inputs=struct('Name',name,'Sltype',sltype);


    oports=hdloutportsignals;
    name=hdlsignalname(oports);
    sltype=hdlsignalsltype(oports);
    hcData.dut.outputs=struct('Name',name,'Sltype',sltype);

    h.mWorkflowInfo.hdlcData=hcData;

