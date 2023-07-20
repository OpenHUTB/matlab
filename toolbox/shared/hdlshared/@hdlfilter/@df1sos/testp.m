function[sections_arch]=testp(Hd)




    sections_arch.typedefs='';
    sections_arch.constants='';
    sections_arch.body_blocks='';
    sections_arch.signals='';


    scaleall=hdlgetallfromsltype(Hd.scaleSLtype);
    scalevtype=scaleall.vtype;
    scalesltype=scaleall.sltype;
    [uname,scaleconstant]=hdlnewsignal(['scaleconst',num2str(1)],'filter',-1,1,0,...
    scalevtype,scalesltype);
    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(scaleconstant)];

    sections_arch.body_blocks=[sections_arch.body_blocks,scaleconstant];
end

