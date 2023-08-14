function v=validateBlock(~,hC)



    bfp=hC.SimulinkHandle;
    blkName=get_param(bfp,'Name');
    blkName=regexprep(blkName,'\n',' ');


    isNFPMode=targetcodegen.targetCodeGenerationUtils.isNFPMode;
    if isNFPMode
        v=hdlvalidatestruct;
        if strcmpi(get_param(bfp,'ApproximationMethod'),'CORDIC')
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:Pol2CartCORDICNFP',blkName));
        end
    else


        v=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:MA2Cplx'));
        return;

        v=hdlvalidatestruct(3,message('hdlcoder:validate:NumericsMismatch',blkName));%#ok<UNRCH>
        if~strcmpi(get_param(bfp,'ApproximationMethod'),'CORDIC')
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:InvalidApproxMethod',blkName));
        end
    end
    if~strcmpi(get_param(bfp,'Input'),'Magnitude and angle')
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:Pol2CartMagAngle'));
    end
    if~strcmpi(get_param(bfp,'ScaleReciprocalGainFactor'),'on')
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:Pol2CartScaleFactor'));
    end
end


