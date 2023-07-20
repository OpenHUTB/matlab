function component=getComponentStruct(~)




    component.SLBlockName='';
    component.loggingPortName='';
    component.SLPortHandle=-1;
    component.SLSampleTime={};
    component.HDLSampleTime={};
    component.timeseries={};
    component.data={};
    component.data_im={};
    component.HDLPortName={};
    component.PortVType={};
    component.PortSLType={};
    component.datalength={};
    component.dataIsConstant=0;
    component.dataIsComplex=0;
    component.dataIsBus=0;
    component.dataWidth=0;
    component.HDLNewType={};
    component.VectorPortSize={};
    component.procedureName={};
    component.ClockName='';
    component.ClockEnable='';
    component.ResetName='';
    component.dataRdEnb='';
    component.hasFeedBack=0;
    component.feedBackPort=0;
    component.isRecordPort=0;
