function addComp=getAddComp(hN,hInSignals,hOutSignals,...
    rndMode,satMode,compName,accType,inputSigns,desc,slbh,nfpOptions)


    if nargin<11
        nfpOptions.Latency=int8(0);
        nfpOptions.MantMul=int8(0);
        nfpOptions.Denormals=int8(0);
        nfpOptions.CustomLatency=int8(0);
    end

    if~isfield(nfpOptions,'CustomLatency')
        nfpOptions.CustomLatency=int8(0);
    end

    if nargin<10
        slbh=-1;
    end

    if nargin<9
        desc='';
    end

    if nargin<8
        inputSigns='++';
    end

    if(nargin<7)
        accType=[];
    end

    if(nargin<6)
        compName='adder';
    end

    if(nargin<5)
        satMode='Wrap';
    end

    if(nargin<4)
        rndMode='Floor';
    end

    if numel(hInSignals)==1&&(prod(hInSignals.Type.getDimensions)==1)

        if hInSignals.Type.isFloatType()&&hInSignals.Type.isEqual(accType)

            addComp=pirelab.getWireComp(hN,hInSignals,hOutSignals);
        else

            if~isempty(accType)
                if hInSignals.Type.isComplexType
                    dtcType=hdlcoder.tp_complex(accType);
                else
                    dtcType=accType;
                end
                accumDTCSig=pirelab.insertDTCCompOnInput(hN,hInSignals,...
                dtcType,rndMode,satMode);
            else
                accumDTCSig=hInSignals;
            end
            addComp=pirelab.getDTCComp(hN,accumDTCSig,hOutSignals,rndMode,satMode);
        end
    else

        addComp=hN.addComponent2(...
        'kind','add',...
        'SimulinkHandle',slbh,...
        'name',compName,...
        'InputSignals',hInSignals,...
        'OutputSignals',hOutSignals,...
        'RoundingMode',rndMode,...
        'OverflowMode',satMode,...
        'AccumulatorType',accType,...
        'BlockComment',desc,...
        'inputSigns',inputSigns,...
        'NFPLatency',nfpOptions.Latency,...
        'NFPCustomLatency',nfpOptions.CustomLatency);

        addComp.setSupportAlteraMegaFunctions(true);
        addComp.setSupportXilinxCoreGen(true);
    end
end
