function out=transformR2016aTLRotationalMechanicalConverter(in)





    out=in;



    if~isempty(getValue(in,'or'))&&isempty(getValue(in,'mech_orientation'))

        orient=getValue(in,'or');



        if str2double(orient)==1
            out=setValue(out,'mech_orientation','1');
        else
            out=setValue(out,'mech_orientation','-1');

            theta0=getValue(in,'theta0');
            if contains(theta0,'%')
                theta0=strip(extractBefore(theta0,'%'));
            end


            out=setValue(out,'theta0',['-(',theta0,')']);
        end
    end

end