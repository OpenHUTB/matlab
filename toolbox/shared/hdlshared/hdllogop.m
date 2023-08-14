function hdlbody=hdllogop(inarray,out,op)






    array_deref=hdlgetparameter('array_deref');

    numInputs=length(inarray);

    for k=1:numInputs
        name{k}=hdlsignalname(inarray(k));
        vec{k}=hdlsignalvector(inarray(k));

        sltype{k}=hdlsignalsltype(inarray(k));
    end

    outname=hdlsignalname(out);
    outvec=hdlsignalvector(out);



    gConnOld=hdlconnectivity.genConnectivity(0);
    if gConnOld
        hCD=hdlconnectivity.getConnectivityDirector;
    end

    if(length(outvec)==1&&outvec(1)<=1)

        hdlbody=[scalarbody(name,sltype,outname,out,op),'\n'];

        if gConnOld
            for i=1:numInputs
                hCD.addDriverReceiverPair(inarray(i),out,'realonly',true);
            end
        end

    else


        [name,vecsize]=scalarexpand(name,vec);
        genname=[outname(1:strfind(outname,'_out')-1),hdlgetparameter('block_generate_label')];

        hdlbody=[blanks(2),genname,' : ','FOR k IN 0 TO ',num2str(vecsize-1),' GENERATE\n'];
        hdlbody=[hdlbody,blanks(2),scalarbody(name,sltype,...
        [outname,array_deref(1),'k',array_deref(2)],out,op)];
        hdlbody=[hdlbody,blanks(2),'END GENERATE;\n\n'];

        if gConnOld
            outv=hdlexpandvectorsignal(out);
            for i=1:numInputs
                inv=hdlexpandvectorsignal(inarray(i));
                for j=1:vecsize
                    hCD.addDriverReceiverPair(inv(j),outv(j),'realonly',true);
                end
            end
        end

    end


    hdlconnectivity.genConnectivity(gConnOld);



    function[name,vecsize]=scalarexpand(name,vec)

        numInputPorts=length(name);
        vecsize=1;
        array_deref=hdlgetparameter('array_deref');
        for k=1:numInputPorts
            if~(length(vec{k})==1&&vec{k}(1)<=1)
                name{k}=[name{k},array_deref(1),'k',array_deref(2)];
                vecsize=max(vecsize,max(vec{k}));
            end
        end


        function hdlbody=scalarbody(name,sltype,outname,out,op)



            numInputPorts=length(name);
            boolflag=1;
            for k=1:numInputPorts
                if~(strcmp(sltype{k},'boolean')||strcmp(sltype{k},'ufix1'))
                    boolflag=0;
                end
            end
            if boolflag
                hdlbody=booleanlogic(name,outname,out,op);
            else

                for k=1:numInputPorts
                    if strcmp(sltype{k},'boolean')||strcmp(sltype{k},'ufix1')
                        if hdlgetparameter('isvhdl')
                            name{k}=['(',name{k},' = ''1'')'];
                        elseif(hdlgetparameter('isverilog')||hdlgetparameter('issystemverilog'))
                            name{k}=['(',name{k},' == 1''b1)'];
                        end
                    elseif strcmp(sltype{k},'double')||strcmp(sltype{k},'single')
                        if hdlgetparameter('isvhdl')
                            name{k}=['(',name{k},' /= 0.0)'];
                        elseif(hdlgetparameter('isverilog')||hdlgetparameter('issystemverilog'))
                            name{k}=['(',name{k},' != 0.0)'];
                        end
                    else
                        if hdlgetparameter('isvhdl')
                            savedsafe=hdlgetparameter('safe_zero_concat');
                            name{k}=['(',name{k},' /= ',...
                            vhdlnzeros(hdlgetsizesfromtype(sltype{k})),...
                            ')'];
                            hdlsetparameter('safe_zero_concat',savedsafe);
                        elseif(hdlgetparameter('isverilog')||hdlgetparameter('issystemverilog'))
                            name{k}=['(',name{k},' != 0)'];
                        end
                    end
                end
                hdlbody=mixlogic(name,outname,out,op);
            end


            function hdlbody=booleanlogic(name,outname,out,op)

                [assign_prefix,assign_op]=hdlassignforoutput(out);

                hdlbody=[blanks(2),assign_prefix,outname,' ',assign_op,' '];
                if strcmp(op,'NOT')
                    if hdlgetparameter('isvhdl')
                        hdlbody=[hdlbody,'NOT(',name{1},');\n'];
                    elseif(hdlgetparameter('isverilog')||hdlgetparameter('issystemverilog'))
                        hdlbody=[hdlbody,'!',name{1},';\n'];
                    end

                elseif strcmp(op,'AND')||strcmp(op,'OR')||strcmp(op,'XOR')
                    if(hdlgetparameter('isverilog')||hdlgetparameter('issystemverilog'))
                        switch op
                        case 'AND'
                            op='&';
                        case 'OR'
                            op='|';
                        case 'XOR'
                            op='^';
                        end
                    end

                    numInputs=length(name);
                    for k=1:numInputs-1
                        hdlbody=[hdlbody,blanks(1),name{k},blanks(1),op];%#ok<*AGROW> 
                    end
                    hdlbody=[hdlbody,blanks(1),name{numInputs},';\n'];
                else
                    if strcmp(op,'NAND'),op='AND';
                    elseif strcmp(op,'NOR'),op='OR';
                    else,error(message('HDLShared:directemit:operatornotsupported'));
                    end
                    if hdlgetparameter('isvhdl')
                        invertop='NOT(';
                    elseif(hdlgetparameter('isverilog')||hdlgetparameter('issystemverilog'))
                        invertop='!(';
                        switch op
                        case 'AND'
                            op='&';
                        case 'OR'
                            op='|';
                        case 'XOR'
                            op='^';
                        end
                    end

                    hdlbody=[hdlbody,invertop];
                    numInputs=length(name);
                    for k=1:numInputs-1
                        hdlbody=[hdlbody,blanks(1),name{k},blanks(1),op];
                    end
                    hdlbody=[hdlbody,blanks(1),name{numInputs},' );\n'];
                end


                function hdlbody=mixlogic(name,outname,out,op)

                    [assign_prefix,assign_op]=hdlassignforoutput(out);

                    if hdlgetparameter('isvhdl')
                        hdlbody=[blanks(2),assign_prefix,outname,...
                        ' ',assign_op,' ''1'' WHEN'];
                    elseif(hdlgetparameter('isverilog')||hdlgetparameter('issystemverilog'))
                        hdlbody=[blanks(2),assign_prefix,outname,...
                        ' ',assign_op,' (',];
                    end

                    if strcmp(op,'NOT')
                        if hdlgetparameter('isvhdl')
                            hdlbody=[hdlbody,' NOT',name{1},' ELSE ''0'';\n'];
                        elseif(hdlgetparameter('isverilog')||hdlgetparameter('issystemverilog'))
                            hdlbody=[hdlbody,'!',name{1},') ? 1''b1 : 1''b0;\n'];
                        end

                    elseif strcmp(op,'AND')||strcmp(op,'OR')||strcmp(op,'XOR')
                        if(hdlgetparameter('isverilog')||hdlgetparameter('issystemverilog'))
                            switch op
                            case 'AND'
                                op='&';
                            case 'OR'
                                op='|';
                            case 'XOR'
                                op='^';
                            end
                        end
                        numInputs=length(name);
                        for k=1:numInputs-1
                            hdlbody=[hdlbody,blanks(1),name{k},blanks(1),op];
                        end
                        if hdlgetparameter('isvhdl')
                            hdlbody=[hdlbody,blanks(1),name{numInputs},' ELSE ''0'';\n'];
                        else
                            hdlbody=[hdlbody,blanks(1),name{numInputs},') ? 1''b1 : 1''b0;\n'];
                        end

                    else
                        if strcmp(op,'NAND'),op='AND';
                        elseif strcmp(op,'NOR'),op='OR';
                        else,error(message('HDLShared:directemit:operatornotsupported'));
                        end
                        if hdlgetparameter('isvhdl')
                            invertop=' NOT(';
                        elseif(hdlgetparameter('isverilog')||hdlgetparameter('issystemverilog'))
                            invertop='!(';
                            switch op
                            case 'AND'
                                op='&';
                            case 'OR'
                                op='|';
                            case 'XOR'
                                op='^';
                            end
                        end

                        hdlbody=[hdlbody,invertop];
                        numInputs=length(name);
                        for k=1:numInputs-1
                            hdlbody=[hdlbody,blanks(1),name{k},blanks(1),op];
                        end
                        if hdlgetparameter('isvhdl')
                            hdlbody=[hdlbody,blanks(1),name{numInputs},' ) ELSE ''0'';\n'];
                        elseif(hdlgetparameter('isverilog')||hdlgetparameter('issystemverilog'))
                            hdlbody=[hdlbody,blanks(1),name{numInputs},' ) ) ? 1''b1 : 1''b0;\n'];
                        end
                    end



