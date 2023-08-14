function out=spice_npn(in)










    out=in;


    C_param=in.getValue('C_param');
    if~isempty(C_param)
        if C_param~='1'
            C_param='2';
        end
        out=out.setValue('C_param',C_param);
    end

end