function out=transformR2021aILMechOrientationTranslational(in)





    out=in;

    mech_orientation=getValue(out,'mech_orientation');
    if startsWith(mech_orientation,'foundation.enum.mech_orientation')
        mech_orientation=replace(mech_orientation,...
        'foundation.enum.mech_orientation',...
        'foundation.enum.MechOrientationTranslational');
        mech_orientation=replace(mech_orientation,'.positive','.Positive');
        mech_orientation=replace(mech_orientation,'.negative','.Negative');
        out=setValue(out,'mech_orientation',mech_orientation);
    end

end