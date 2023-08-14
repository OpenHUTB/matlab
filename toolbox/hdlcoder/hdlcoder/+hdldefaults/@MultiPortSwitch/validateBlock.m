function v=validateBlock(~,hC)


    v=hdlvalidatestruct;


    ninputs=hC.NumberOfSLInputPorts;

    out=hC.SLOutputPorts(1).Signal;
    out_iscmplx=hdlsignaliscomplex(out);


    ins=hdlhandles(1,ninputs-1);
    ins_iscmplx=zeros(ninputs-1,1);
    for n=2:ninputs
        ins(n-1)=hC.SLInputPorts(n).Signal;
        ins_iscmplx(n-1)=hdlsignaliscomplex(hC.SLInputPorts(n).Signal);
    end
    controlSignal=hC.SLInputPorts(1).Signal;
    if targetmapping.mode(controlSignal)
        if targetcodegen.targetCodeGenerationUtils.isNFPMode()
            v(end+1)=hdlvalidatestruct(2,message('hdlcommon:nativefloatingpoint:ControlPortIsFlPtType'));
        else
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:ControlPortIsFlPtType'));
        end
    end

    isdouble=hdlsignalisdouble([ins,out]);
    if any(isdouble==true)&&any(isdouble==false)
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:illegalconversionmultiportswitch'));
    end


    if~((all(ins_iscmplx)&&out_iscmplx)||...
        (~any(ins_iscmplx)&&~out_iscmplx))
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:mixedrealcomplexmultiportswitch'));
    end



    sv=hdlsignalvector(hC.SLInputPorts(2).Signal);
    if ninputs>2
        for ii=3:ninputs
            if~all(sv==hdlsignalvector(hC.SLInputPorts(ii).Signal))
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:mixeddimensioninput'));%#ok<AGROW>
            end
        end
    end

    block=get_param(hC.SimulinkHandle,'object');
    blockMode=block.dataPortOrder;
    possibleValues=block.getPropAllowedValues('dataPortOrder');
    if strcmp(blockMode,possibleValues{3})
        if~controlSignal.Type.isEnumType
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:unsupportedswitchspecifyindicesmode'));
        end
    end
end




