function out=transformR2016aTLTranslationalMechanicalConverter(in)





    out=in;



    if~isempty(getValue(in,'or'))&&isempty(getValue(in,'mech_orientation'))

        orient=getValue(in,'or');



        if str2double(orient)==1
            out=setValue(out,'mech_orientation','1');
        else
            out=setValue(out,'mech_orientation','-1');

            x0=getValue(in,'x0');
            if contains(x0,'%')
                x0=strip(extractBefore(x0,'%'));
            end


            out=setValue(out,'x0',['-(',x0,')']);
        end
    end

end