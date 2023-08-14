function out=transformR2015bTLConstantVolumeChamber(in)





    out=in;



    if~isempty(getValue(in,'length'))&&isempty(getValue(in,'area'))

        V=getValue(in,'volume');
        V_unit=getValue(in,'volume_unit');
        L=getValue(in,'length');
        L_unit=getValue(in,'length_unit');

        if contains(V,'%')
            V=strip(extractBefore(V,'%'));
        end
        if contains(L,'%')
            L=strip(extractBefore(L,'%'));
        end



        out=setValue(out,'area',['(',V,')/(',L,')']);
        out=setValue(out,'area_unit',['(',V_unit,')/(',L_unit,')']);
    end

end