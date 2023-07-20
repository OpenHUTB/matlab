




function adderComp=getAddTreeComp(hN,inSigs,hOutSignals,...
    rndMode,satMode,compName,accumType,inputSigns,desc,slbh,nfpOptions)

    if nargin<11
        nfpOptions.Latency=int8(0);
        nfpOptions.MantMul=int8(0);
        nfpOptions.Denormals=int8(0);
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
        accumType=[];
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


    isArray=false;
    hasCplx=false;
    if pirelab.hasComplexType(hOutSignals.Type)
        hasCplx=true;
    end
    if hOutSignals.Type.isArrayType
        isArray=true;
    end


    if isArray
        if hasCplx
            basetype=pirelab.getComplexType(hOutSignals.Type);
        else
            basetype=hOutSignals.Type.getLeafType;
        end

        tOutType=hN.getType('Array','BaseType',basetype,...
        'Dimensions',hOutSignals.Type.getDimensions,'VectorOrientation',getSignalOrientation(hOutSignals.Type));

        if isempty(accumType)
            accumType=tOutType;
        end
    elseif isempty(accumType)
        if hasCplx
            accumType=hOutSignals.Type.getLeafType();
        else
            accumType=hOutSignals.Type;
        end
    end

    prev_stage_sig=inSigs(1);
    itr=2;
    nfpMode=targetcodegen.targetCodeGenerationUtils.isNFPMode;
    while length(inputSigns)>=2
        final_stage=(length(inputSigns)<=2);
        stageInputSignals=[prev_stage_sig,inSigs(itr)];
        if~final_stage
            if~nfpMode



                tInputType=stageInputSignals(1).Type;
                if stageInputSignals(2).Type.isArrayType
                    tInputType=stageInputSignals(2).Type;
                end
                tOutType=hdlarch.tree.getStageOutputType(tInputType,'sum',[stageInputSignals(1).Type,stageInputSignals(2).Type],...
                hOutSignals.Type,inputSigns);
            elseif~hOutSignals.Type.isArrayType

                if hasCplx
                    tOutType=pir_complex_t(accumType);
                else
                    tOutType=accumType;
                end
            end
            op_stage_sig=hN.addSignal(tOutType,[compName,'_op_stage',int2str(itr-1)]);
            op_stage_sig.SimulinkRate=hOutSignals.SimulinkRate;
        else
            op_stage_sig=hOutSignals;
        end
        if targetmapping.mode(hOutSignals)
            adderComp=targetmapping.getTwoInputAddComp(hN,[prev_stage_sig,inSigs(itr)],...
            op_stage_sig,rndMode,satMode,[compName,'_stage',int2str(itr)],accumType,...
            inputSigns(1:2),desc,slbh,nfpOptions);
        else
            adderComp=pircore.getAddComp(hN,[prev_stage_sig,inSigs(itr)],op_stage_sig,...
            rndMode,satMode,[compName,'_stage',int2str(itr)],accumType,inputSigns(1:2),...
            desc,slbh,nfpOptions);
        end



        if hasCplx&&~pirelab.hasComplexType(prev_stage_sig.Type)&&...
            ~pirelab.hasComplexType(inSigs(itr).Type)
            adderP=adderComp.findOutputPort('index',0);
            op_stage_sig.disconnectDriver(adderP);
            realType=op_stage_sig.Type.getLeafType;
            if tOutType.isArrayType
                realType=getpirarraytype(realType,hOutSignals.Type.getDimensions);
            end
            hSreal=hN.addSignal(realType,op_stage_sig.Name);
            hSreal.SimulinkRate=op_stage_sig.SimulinkRate;
            hSreal.addDriver(adderP);
            pirelab.getRealImag2Complex(hN,hSreal,op_stage_sig,'real');
        end
        inputSigns(2)='+';
        inputSigns(1)=[];
        prev_stage_sig=op_stage_sig;
        itr=itr+1;
    end
end


function pirType=getpirarraytype(basetp,portDims)
    arrtypef=pir_arr_factory_tc;

    vecLen=portDims(1);
    arrtypef.addDimension(vecLen);

    arrtypef.addBaseType(basetp);
    pirType=pir_array_t(arrtypef);
end

function orientation=getSignalOrientation(type)





    if(type.isRowVector)
        orientation=1;
    elseif(type.isColumnVector)
        orientation=2;
    else
        orientation=0;
    end
end
