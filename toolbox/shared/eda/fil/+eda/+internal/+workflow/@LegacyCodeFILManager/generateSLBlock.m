function generateSLBlock(h)




    h.displayStatus('Generating FIL simulation block in a new model ...');

    switch(h.mBuildInfo.HDLSourceType)
    case 'LegacyCode'
        p=eda.internal.filhost.ParamsT(h.mBuildInfo);
        for m=1:numel(h.mBuildInfo.OutputDataTypes.Name)
            switch h.mBuildInfo.OutputDataTypes.DataType{m}
            case 'Inherit'
                TypeStr='Inherit: auto';
            case{'Logical','Boolean'}
                TypeStr='boolean';
            case{'Single','Double'}
                TypeStr=lower(h.mBuildInfo.OutputDataTypes.DataType{m});
            case 'Integer'
                if h.mBuildInfo.OutputDataTypes.Sign{m}
                    TypeStr=['int',num2str(h.mBuildInfo.OutputDataTypes.BitWidth{m})];
                else
                    TypeStr=['uint',num2str(h.mBuildInfo.OutputDataTypes.BitWidth{m})];
                end
            otherwise
                if h.mBuildInfo.OutputDataTypes.Sign{m}
                    TypeStr=['fixdt(1,',num2str(h.mBuildInfo.OutputDataTypes.BitWidth{m}),',',num2str(h.mBuildInfo.OutputDataTypes.FracLen{m}),')'];
                else
                    TypeStr=['fixdt(0,',num2str(h.mBuildInfo.OutputDataTypes.BitWidth{m}),',',num2str(h.mBuildInfo.OutputDataTypes.FracLen{m}),')'];
                end
            end
            currPort=p.outputPorts(m);
            currPort.dtypeSpec=eda.internal.filhost.DTypeSpecT(TypeStr);
            p.outputPorts(m)=currPort;
        end


        if(p.getNumInputPorts==0)
            p.outputFrameSize=1;
            p.overclocking=1;
            for idx=1:p.getNumOutputPorts
                p.outputPorts(idx).sampleTime=1;
            end
        end

    case 'SLHDLCoder'
        p1=eda.internal.filhost.ParamsT(h.mBuildInfo);
        p=h.mBuildInfo.ParamsTObj;
        p.commIPDevices=p1.commIPDevices;
        p.buildInfo=p1.buildInfo;


        switch(p.getNumInputPorts)
        case 0

            inBaseSampleTime=h.mBuildInfo.OrigDutBaseRate;
        case 1
            inBaseSampleTime=p.inputPorts(1).sampleTime.period;
        otherwise
            stimes=arrayfun(@(x)(x.sampleTime.period),p.inputPorts);
            inBaseSampleTime=computeBaseRate(stimes);
        end
        p.overclocking=...
        round(inBaseSampleTime*(h.mBuildInfo.DutBaseRateScalingFactor/h.mBuildInfo.OrigDutBaseRate));

    otherwise
        error(message('EDALink:FILWorkflow:UnknownHDLSourceType'));
    end

    p.connectionOptions=h.mBuildInfo.BoardObj.ConnectionOptions;
    p.programFPGAOptions=h.mBuildInfo.BoardObj.ProgramFPGAOptions;

    p.dialogState.bitstreamFile=h.BitFile.FullPath;
    eda.internal.filhost.SimulinkBlockParamManagerT.CreateUntitledMdl(p);