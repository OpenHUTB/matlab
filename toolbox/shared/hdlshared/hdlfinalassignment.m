function[hdlbody,hdlsignals]=hdlfinalassignment(in,out,inidx,outidx,vectsize)









    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    hdlbody='';
    hdlsignals='';

    if emitMode

        if nargin==2
            inidx=[];
            outidx=[];
            vectsize=1;
        elseif nargin==3
            outidx=[];
            vectsize=1;
        elseif nargin==4
            vectsize=1;
        end

        array_deref=hdlgetparameter('array_deref');

        inname=hdlsignalname(in);
        incomplex=hdlsignalcomplex(in);
        invtype=hdlsignalvtype(in);



        gConnOld=hdlconnectivity.genConnectivity(0);
        if gConnOld,
            hCD=hdlconnectivity.getConnectivityDirector;
            if isempty(inidx)&&isempty(outidx),
                hCD.addDriverReceiverPair(in,out,'realonly',~incomplex,'unroll',false);
            elseif isempty(inidx)&&~isempty(outidx),
                hCD.addDriverReceiverPair(in,out,'realonly',~incomplex,'unroll',false,'receiverIndices',str2num(outidx));
            elseif~isempty(inidx)&&isempty(outidx),
                hCD.addDriverReceiverPair(in,out,'realonly',~incomplex,'unroll',false,'driverIndices',str2num(inidx));
            else
                hCD.addDriverReceiverPair(in,out,'realonly',~incomplex,'unroll',false,...
                'receiverIndices',str2num(outidx),'driverIndices',str2num(inidx));
            end
        end


        if~isempty(inidx)
            inname=[inname,array_deref(1),inidx,array_deref(2)];
        end

        outname=hdlsignalname(out);

        if~isempty(outidx)
            outname=[outname,array_deref(1),outidx,array_deref(2)];
        end

        hdlbody=localassignment(inname,invtype,out,outname);
        if any(incomplex~=0)
            inname=hdlsignalname(hdlsignalimag(in));
            if~isempty(inidx)
                inname=[inname,array_deref(1),inidx,array_deref(2)];
            end
            outname=hdlsignalname(hdlsignalimag(out,vectsize));
            if~isempty(outidx)
                outname=[outname,array_deref(1),outidx,array_deref(2)];
            end

            hdlbody=[hdlbody,localassignment(inname,invtype,out,outname)];
        end


        hdlconnectivity.genConnectivity(gConnOld);
    else
        pirelab.getWireComp(hN,in,out);
    end




    function hdlbody=localassignment(inname,invtype,out,outname)
        [assign_prefix,assign_op]=hdlassignforoutput(out);
        outvtype=hdlsignalvtype(out);
        outsltype=hdlsignalsltype(out);
        [outsize,outbp,outsigned]=hdlwordsize(outsltype);


        if hdlgetparameter('isvhdl')&&vhdlisstdlogicvector(out)
            hdlbody=['  ',assign_prefix,outname,' ',assign_op,...
            ' std_logic_vector(',inname,');\n'];
        elseif outsize==0&&...
            hdlgetparameter('isverilog')
            assign_prefix='assign ';
            assign_op='=';
            if length(invtype)>3&&strcmpi(invtype(1:4),'real')
                hdlbody=['  ',assign_prefix,outname,' ',assign_op,...
                ' $realtobits(',inname,');\n'];
            else
                hdlbody=['  ',assign_prefix,outname,' ',assign_op,...
                ' ',inname,';\n'];
            end
        else
            hdlbody=['  ',assign_prefix,outname,' ',assign_op,...
            ' ',inname,';\n'];
        end



