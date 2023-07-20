function out=transmission_line_3ph(in)










    out=in;


    if~isempty(in.getValue('Cg'))
        Cg=in.getValue('Cg');


        if Cg=='0'
            out=out.setValue('Cg','0.1');
        end
    end
end