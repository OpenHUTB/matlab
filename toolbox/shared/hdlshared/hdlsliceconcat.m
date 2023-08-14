function hdlbody=hdlsliceconcat(ins,slices,out)












    if(length(ins)~=length(slices))
        error(message('HDLShared:directemit:badsizes',length(ins),length(slices)));
    end


    gConnOld=hdlconnectivity.genConnectivity(0);
    if gConnOld,
        hCD=hdlconnectivity.getConnectivityDirector;
        for ii=1:numel(ins),
            inscalar=max(hdlsignalvector(ins(ii)));
            if(inscalar==1)||(inscalar==0),
                hCD.addDriverReceiverPair(ins(ii),out,'realonly',true,'unroll',false);
            else
                hCD.addDriverReceiverPair(ins(ii),out,'realonly',true,'unroll',false,'driverIndices',slices{ii});
            end
        end
    end


    [assign_prefix,assign_op]=hdlassignforoutput(out);
    arrderef=hdlgetparameter('array_deref');
    if hdlgetparameter('isvhdl')
        startconcat='';
        concatop=' & ';
        endconcat='';
    else
        startconcat='{';
        concatop=', ';
        endconcat='}';
    end


    hdlbody=['  ',assign_prefix,hdlsignalname(out),' ',assign_op,' '];
    hdlbody=[hdlbody,startconcat];
    for ii=1:length(ins)
        name=hdlsignalname(ins(ii));
        tmpslices=slices{ii};
        if isempty(tmpslices)
            hdlbody=[hdlbody,name,concatop];
        else
            for jj=1:length(tmpslices)
                hdlbody=[hdlbody,name,arrderef(1),num2str(tmpslices(jj)),arrderef(2),concatop];
            end
        end
    end
    hdlbody=hdlbody(1:end-length(concatop));
    hdlbody=[hdlbody,endconcat,';\n\n'];



    hdlconnectivity.genConnectivity(gConnOld);


