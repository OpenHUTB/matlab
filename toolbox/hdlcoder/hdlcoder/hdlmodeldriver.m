function hc=hdlmodeldriver(modelname)





    try
        hcc=gethdlcc(modelname);
        if isempty(hcc)
            hcc=attachhdlcconfig(modelname);
        end
        hc=hcc.getHDLCoder;
    catch me %#ok<NASGU>
        hc=[];
    end
