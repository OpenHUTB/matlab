function testBenchComponents(this,hF)





    component.SLBlockName='';
    component.loggingPortName='';
    component.SLPortHandle=-1;
    component.SLSampleTime={};
    component.HDLSampleTime={};
    component.timeseries={};
    component.data={};
    component.HDLPortName={};
    component.PortVType={};
    component.PortSLType={};
    component.datalength={};
    component.dataIsConstant=0;
    component.HDLNewType={};
    component.VectorPortSize={};
    component.procedureName={};
    component.procedureInput={};
    component.procedureOutput={};
    component.ClockName='';
    component.ClockEnable='';
    component.ClockEnableSigIdx='';
    component.ResetName='';
    component.dataRdEnb='';

    this.OutportSnk=[];
    snkComponent=component;


    if this.isOutputPortComplex
        HDLPortName={[hdlgetparameter('filter_output_name'),...
        hdlgetparameter('complex_real_postfix')],...
        [hdlgetparameter('filter_output_name'),...
        hdlgetparameter('complex_imag_postfix')]};
    else
        HDLPortName=hdlgetparameter('filter_output_name');
    end

    snkComponent.HDLPortName{end+1}=HDLPortName;
    if iscell(HDLPortName)
        snkComponent.loggingPortName=hdlgetparameter('filter_output_name');
        snkComponent.dataIsComplex=1;
    else
        snkComponent.loggingPortName=HDLPortName;
        snkComponent.dataIsComplex=0;
    end
    this.OutportSnk=[this.OutportSnk,snkComponent];

    this.InportSrc=[];
    srcComponent=component;

    InputsrcNames={hdlgetparameter('filter_input_name')};
    if~strcmpi(hdlgetparameter('filter_coefficient_source'),'internal')
        InputsrcNames={InputsrcNames{:},'write_enable','write_done',...
        'write_address','coeffs_in'};
    end
    if isa(hF,'hdlfilter.farrowfd')||isa(hF,'hdlfilter.farrowlinearfd')
        InputsrcNames={InputsrcNames{:},hdlgetparameter('filter_fracdelay_name')};
    end
    if hdlgetparameter('RateChangePort')
        InputsrcNames=[InputsrcNames,...
        {'load_rate','rate'}];
    end
    for n=1:length(InputsrcNames)

        if n==1
            if this.isInputPortComplex
                HDLPortName={[InputsrcNames{n},hdlgetparameter('complex_real_postfix')],...
                [InputsrcNames{n},hdlgetparameter('complex_imag_postfix')]};
                srcName=[InputsrcNames{n},'_data'];
                isInputComplex=1;
            else
                HDLPortName=InputsrcNames{n};
                srcName=[HDLPortName,'_data'];
                isInputComplex=0;
            end
        else
            HDLPortName=InputsrcNames{n};
            srcName=[HDLPortName,'_data'];
            isInputComplex=0;
        end

        LogName=[srcName,'_log'];
        srcComponent.SLBlockName=srcName;
        srcComponent.loggingPortName=hdllegalnamersvd(LogName);

        srcComponent.HDLPortName={HDLPortName};
        srcComponent.dataRdEnb=this.ClockEnableName;
        srcComponent.dataIsComplex=isInputComplex;

        this.InportSrc=[this.InportSrc,srcComponent];
    end

    if(isempty(this.InportSrc)&&isempty(this.OutportSnk))
        error(message('hdlfilter:filterhdlcoder:HDLTestbench:testBenchComponents:notbinputsoroutputs'));
    end
end


