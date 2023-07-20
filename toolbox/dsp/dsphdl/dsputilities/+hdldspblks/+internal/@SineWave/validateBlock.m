function v=validateBlock(~,hC)


    bfp=hC.SimulinkHandle;

    v=hdlvalidatestruct;


    outport=hC.SLOutputPorts;
    outsig=outport.Signal;
    outsig_size=hdlsignalsizes(outsig);
    if(outsig_size(3)&&outsig_size(1)==0&&outsig_size(2)==0),
        v(end+1)=hdlvalidatestruct(1,...
        message('dsp:hdl:SineWave:validateBlock:outputdatatype'));
    end


    mwsvar=get_param(bfp,'MaskWSVariables');
    names={mwsvar.Name};

...
...
...
...

    SampleMode_wsvaridx=strcmp('SampleMode',names);
    CompMethod_wsvaridx=strcmp('CompMethod',names);



    if(mwsvar(SampleMode_wsvaridx).Value~=1),
        v(end+1)=hdlvalidatestruct(1,...
        message('dsp:hdl:SineWave:validateBlock:samplemode'));

    else


        if(mwsvar(CompMethod_wsvaridx).Value~=2),
            v(end+1)=hdlvalidatestruct(1,...
            message('dsp:hdl:SineWave:validateBlock:computationmethod'));
        end
    end


