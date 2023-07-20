function hdlbody=hdlbitop(ins,out,op)







    outname=hdlsignalname(out);
    outvec=hdlsignalvector(out);
    outsltype=hdlsignalsltype(out);
    [outsize,outbp,outsigned]=hdlwordsize(outsltype);

    numInputs=length(ins);
    for k=1:numInputs
        name{k}=hdlsignalname(ins(k));
        vec{k}=hdlsignalvector(ins(k));
        vtype{k}=hdlsignalvtype(ins(k));
        sltype{k}=hdlsignalsltype(ins(k));
        isinport{k}=hdlisinportsignal(ins(k));
    end


    gConnOld=hdlconnectivity.genConnectivity(0);
    if gConnOld,
        hConnDir=hdlconnectivity.getConnectivityDirector;


        minlen=max(hdlsignalvector(out));
        for jj=1:numInputs,
            minlen=min(minlen,max(vec{jj}));
        end
        if(minlen==0)
            minlen=1;
        end

        outv=hdlexpandvectorsignal(out);
        for jj=1:numInputs,
            inv=hdlexpandvectorsignal(ins(jj));
            for kk=1:minlen,
                hConnDir.addDriverReceiverPair(inv(kk),outv(kk),'realonly',true);
            end
        end
    end




    if all(outvec==0)

        for k=1:length(name)
            [insize,bp,signed]=hdlwordsize(sltype{k});
            [inname{k},insize]=hdlsignaltypeconvert(name{k},insize,signed,vtype{k},outsigned);
        end
        hdlbody=[scalarbody(inname,out,op),'\n'];
    elseif~hdlgetparameter('loop_unrolling')


        [name,vecsize]=scalarexpand(name,vec,'k');
        for k=1:length(name)
            [insize,bp,signed]=hdlwordsize(sltype{k});
            [inname{k},insize]=hdlsignaltypeconvert(name{k},insize,signed,vtype{k},outsigned);
        end

        genname=[outname,hdlgetparameter('block_generate_label')];
        hdlbody=[blanks(2),genname,' : ','FOR k IN 0 TO ',num2str(vecsize-1),' GENERATE\n'];
        hdlbody=[hdlbody,blanks(2),scalarbody(inname,out,op,'k')];
        hdlbody=[hdlbody,blanks(2),'END GENERATE;\n\n'];
    else
        hdlbody='';
        vecsize=max(outvec);

        for k=1:numInputs
            if all(vec{k}==0)
                tmp=[];
                for ii=1:vecsize
                    vectorsignals(k,ii)=ins(k);
                end

            else
                tmp=hdlexpandvectorsignal(ins(k));
                for ii=1:length(tmp)
                    vectorsignals(k,ii)=tmp(ii);
                end
            end
        end
        outvector=hdlexpandvectorsignal(out);

        for v=1:size(vectorsignals,2)
            inname={};
            for k=1:size(vectorsignals,1)
                sig=vectorsignals(k,v);
                [insize,bp,signed]=hdlwordsize(hdlsignalsltype(sig));
                [inname{k},insize]=hdlsignaltypeconvert(hdlsignalname(sig),...
                insize,signed,...
                hdlsignalvtype(sig),...
                outsigned);
            end
            hdlbody=[hdlbody,scalarbody(inname,outvector(v),op)];
        end
    end


    hdlconnectivity.genConnectivity(gConnOld);



    function[name,vecsize]=scalarexpand(name,vec,idx)

        array_deref=hdlgetparameter('array_deref');
        numInputPorts=length(name);
        vecsize=1;
        for k=1:numInputPorts

            if(isscalar(vec{k})&&(vec{k}>1))||~isscalar(vec{k}),
                name{k}=[name{k},array_deref(1),idx,array_deref(2)];
                vecsize=max(vecsize,max(vec{k}));
            end
        end


        function hdlbody=scalarbody(name,out,op,outidx)

            outname=hdlsignalname(out);

            if nargin==3
                outidx='';
            else
                array_deref=hdlgetparameter('array_deref');
                outname=[outname,array_deref(1),outidx,array_deref(2)];
            end

            [assign_prefix,assign_op]=hdlassignforoutput(out);

            hdlbody=[blanks(2),assign_prefix,outname,' ',assign_op,' '];

            if hdlgetparameter('isverilog')
                hdlneg='~';
                switch lower(op)
                case 'not'
                    hdlop='~';
                case 'and'
                    hdlop='&';
                case 'or'
                    hdlop='|';
                case 'nand'
                    hdlop='&';
                case 'nor'
                    hdlop='|';
                case 'xor'
                    hdlop='^';
                end
            else
                if strcmpi(op,'NAND')
                    hdlop='AND';
                elseif strcmpi(op,'NOR')
                    hdlop='OR';
                else
                    hdlop=op;
                end
                hdlneg='NOT';
            end


            if strcmp(op,'NOT')
                hdlbody=[hdlbody,' ',hdlneg,'(',name{1},');\n'];
            elseif strcmp(op,'AND')||strcmp(op,'OR')||strcmp(op,'XOR')
                numInputs=length(name);
                for k=1:numInputs-1
                    hdlbody=[hdlbody,blanks(1),name{k},blanks(1),hdlop];
                end
                hdlbody=[hdlbody,blanks(1),name{numInputs},';\n'];
            else
                if strcmp(op,'NAND'),op='AND';
                elseif strcmp(op,'NOR'),op='OR';
                else error(message('HDLShared:directemit:logicopnotsupported',op));
                end
                hdlbody=[hdlbody,' ',hdlneg,'('];
                numInputs=length(name);
                for k=1:numInputs-1
                    hdlbody=[hdlbody,blanks(1),name{k},blanks(1),hdlop];
                end
                hdlbody=[hdlbody,blanks(1),name{numInputs},' );\n'];
            end
