function vtype=pirgetvtype(hS)





    hT=hS.Type;

    if strcmpi(hT.ClassName,'tp_record')||strcmpi(hT.ClassName,'tp_enum')||hT.isArrayOfEnums||hT.isArrayOfRecords
        vtype='';
    else
        tpinfo=pirgetdatatypeinfo(hT);
        hD=hdlcurrentdriver;
        isVhdl=hD.getParameter('isvhdl');
        if isVhdl
            vtype=vhdlblockdatatype(tpinfo.sltype);
        else
            vtype=verilogblockdatatype(tpinfo.sltype);
        end
        numdims=tpinfo.numdims;

        if numdims==1
            parsedindims=[numdims;tpinfo.dims;0];
        else
            parsedindims=[numdims;tpinfo.dims(:)];
        end

        if hdlisvectorport(parsedindims,1)
            isvector=[parsedindims(2),parsedindims(3)];
            if isVhdl
                vtype=vhdlvectorblockdatatype(tpinfo.iscomplex,isvector,vtype,tpinfo.sltype);
            else
                vtype=verilogvectorblockdatatype(tpinfo.iscomplex,isvector,vtype,tpinfo.sltype);
            end
        end
    end


