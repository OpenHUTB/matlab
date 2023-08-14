function v=checkFullPrecision(this,hF)%#ok<INUSL>




    v=hdlvalidatestruct;

    mults=hF.getHDLParameter('filter_nummultipliers');
    uff=hF.getHDLParameter('userspecified_foldingfactor');

    if(mults==-1)
        [mults,~]=hF.getSerialPartForFoldingFactor('foldingfactor',uff);
    end

    if~strcmpi(hF.InputSLType,'double')&&hF.needModifyforFullPrecision
        fpvalues=hF.getFullPrecisionSettings;
        err=3;
        if(mults==1)
            messageid='hdlcoder:filters:biquad:validate:biquaddiffsumtype';
        else
            messageid='hdlcoder:filters:biquad:validate:biquadsumnotfullprecision';
        end
        v=hdlvalidatestruct(err,...
        message(messageid,...
        fpvalues.accumulator(1),fpvalues.accumulator(2),...
        fpvalues.accumulator(1),fpvalues.accumulator(2)));
    end
