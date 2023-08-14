function[sections_arch,opconvert,phase_0]=emit_iirserial(this,current_input)







    uff=hdlgetparameter('userspecified_foldingfactor');
    mults=hdlgetparameter('filter_nummultipliers');
    if(mults==-1)
        [mults,ffactor]=this.getSerialPartForFoldingFactor('foldingfactor',uff);
    else
        [mults,ffactor]=this.getSerialPartForFoldingFactor('multipliers',mults);
    end

    if(mults==1)

        [sections_arch,opconvert,phase_0]=emitfullyserial(this,current_input);
    elseif(mults==2||mults==3)

        [sections_arch,opconvert,phase_0]=emitpartlyserial2mults(this,current_input);
    end
end


