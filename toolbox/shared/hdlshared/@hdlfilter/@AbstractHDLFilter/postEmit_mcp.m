function context=postEmit_mcp(this,context)














    if hdlconnectivity.genConnectivity,
        hCD=hdlconnectivity.getConnectivityDirector;



        compConn=struct();
        compConn.path=hCD.getCurrentHDLPath;
        inputs=hdlsignalname(hdlinportsignals);
        outputs=hdlsignalname(hdloutportsignals);

        if~iscell(inputs),
            inputs={inputs};
        end

        if~iscell(outputs),
            outputs={outputs};
        end
        compConn.inputs=inputs;
        compConn.outputs=outputs;
        this.componentConnectivity(end+1)=compConn;


        ltc=this.LocalTimingControllerInfo;
        filtpath=compConn.path;
        for ii=1:numel(filtpath),
            fp=filtpath{ii};
            for jj=1:numel(ltc),
                hCD.addRelativeClockEnable(ltc(jj).enbsOut,ltc(jj).enbsIn,ltc(jj).phases,ltc(jj).maxCount,...
                'newEnbPath',fp,'relEnbPath',fp);
            end
        end



        hCD.setCurrentHDLPath(context('currentHDLPath'));
    end


    hdlsetparameter('multiplier_input_pipeline',context('multiplier_input_pipeline'));
    hdlsetparameter('multiplier_output_pipeline',context('multiplier_output_pipeline'));
