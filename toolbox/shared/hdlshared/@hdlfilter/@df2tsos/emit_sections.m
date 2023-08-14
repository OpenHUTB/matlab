function[sections_arch,section_result]=emit_sections(this,current_input)







    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    if emitMode
        numChannels=0;
    else
        numChannels=current_input.input.Type.getDimensions;
    end

    coeffs=this.Coefficients;
    filterorders=this.SectionOrder;
    numsections=this.NumSections;

    sections_arch.typedefs='';
    sections_arch.constants='';
    sections_arch.body_blocks='';
    sections_arch.signals='';

    section_result=struct('input',0,...
    'wrenb',0,...
    'coeffs',0,...
    'wraddr',0,...
    'wrdone',0);
    section_result=current_input;

    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];


    hdlsetparameter('filter_target_language',hdlgetparameter('target_language'));


    rmode=this.Roundmode;
    [outputrounding,outregrounding,...
    productrounding,sumrounding,...
    numstoragerounding,denstoragerounding,...
    multiplicandrounding]=deal(rmode);

    omode=this.Overflowmode;
    [outputsaturation,outregsaturation,...
    productsaturation,sumsaturation,...
    numstoragesaturation,denstoragesaturation,...
    multiplicandsaturation]=deal(omode);

    numprodall=hdlgetallfromsltype(this.numprodSLtype);
    numproductvtype=numprodall.vtype;
    numproductsltype=numprodall.sltype;

    denprodall=hdlgetallfromsltype(this.denprodSLtype);
    denproductvtype=denprodall.vtype;
    denproductsltype=denprodall.sltype;


    numaccumall=hdlgetallfromsltype(this.numaccumSLtype);
    sumsize=numaccumall.size;
    sumsigned=numaccumall.signed;
    numsumvtype=numaccumall.vtype;
    numsumsltype=numaccumall.sltype;

    densumall=hdlgetallfromsltype(this.denAccumSLtype);
    densumbp=densumall.bp;
    densumvtype=densumall.vtype;
    densumsltype=densumall.sltype;


    storageall=hdlgetallfromsltype(this.StateSLtype);
    storagevtype=storageall.vtype;
    storagesltype=storageall.sltype;

    scaleresultall=hdlgetallfromsltype(this.SectionInputSLtype);

    scaleresultvtype=scaleresultall.vtype;
    scaleresultsltype=scaleresultall.sltype;

    inputtcvtype=scaleresultvtype;
    inputtcsltype=scaleresultsltype;
    sectionoutputall=hdlgetallfromsltype(this.sectionoutputSLtype);

    outputtcvtype=sectionoutputall.vtype;
    outputtcsltype=sectionoutputall.sltype;

    force_extra_quantization=0;

    bit_true=0;
    lastmultvtype=numproductvtype;
    lastmultsltype=numproductsltype;
    lastmultsaturation=productsaturation;
    lastmultrounding=productrounding;


    coeffs_internal=strcmpi(hdlgetparameter('filter_coefficient_source'),'internal');

    if~coeffs_internal



        scales=0.9585*ones(1,(this.NumSections+1));
        coeffs=0.9585*ones(size(this.coefficients));

        coeffs(:,3)=0.9585*(this.SectionOrder-1);
        coeffs(:,6)=coeffs(:,3);
    end








    scaled_input=current_input;

    coeffs_port=hdlgetparameter('filter_generate_coeff_port');
    for section=1:numsections

        if~coeffs_internal
            [sections_arch,num_list,den_list,scaled_input.input]=emit_procint(this,sections_arch,current_input,section,scaleresultall);
        elseif coeffs_port
            [sections_arch,num_list,den_list,scaled_input.input]=emit_scaleinput_port(this,sections_arch,current_input,section);
        else
            [sections_arch,num_list,den_list,scaled_input.input]=emit_coefficients(this,sections_arch,current_input.input,section,scaleresultall);
        end
        [num,den]=getcoeffs(coeffs,section);


        cplxty_sectioninput=hdlsignaliscomplex(scaled_input.input);
        if den(3)==0
            cplxty_ab3sum=cplxty_sectioninput||any(imag(num(3)));
            cplxty_b2sum=cplxty_sectioninput||any(imag(num(2:3)));
        else
            cplxty_ab3sum=cplxty_sectioninput||any(imag([num,den]));
            cplxty_b2sum=cplxty_sectioninput||any(imag([num,den]));
        end
        if den(2)==0;
            cplxty_ab2sum=cplxty_b2sum;
        else
            cplxty_ab2sum=cplxty_sectioninput||any(imag([num,den]));
        end
        cplxty_ab1sum=cplxty_sectioninput||any(imag([num,den]));




        if filterorders(section)==1
            disp(sprintf([hdlcodegenmsgs(5),', # ','%d'],section));

            sections_arch.body_blocks=[sections_arch.body_blocks,...
            indentedcomment,...
            '------------------ Section ',num2str(section),' (First Order) ------------------\n\n'];
            sections_arch.signals=[sections_arch.signals,indentedcomment,...
            'Section ',num2str(section),' Signals \n'];



            if~((num(1)==0)||(~bit_true&&(num(2)==0&&den(2)==0)))
                [tempname,ab1sum]=hdlnewsignal(['ab1sum',num2str(section)],'filter',-1,cplxty_ab1sum,numChannels,...
                numsumvtype,numsumsltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(ab1sum)];
            end

            if~(num(2)==0&&den(2)==0)
                [tempname,ab2sum]=hdlnewsignal(['ab2sum',num2str(section)],'filter',-1,cplxty_ab2sum,numChannels,...
                densumvtype,densumsltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(ab2sum)];
            end




            if~(num(2)==0&&den(2)==0)
                [tempname,delay]=hdlnewsignal(['delay_section',num2str(section)],'filter',-1,cplxty_ab2sum,numChannels,...
                storagevtype,storagesltype);
                if emitMode
                    hdlregsignal(delay);
                    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(delay)];
                end
            end



            [tempname,inputconv]=hdlnewsignal(['inputconv',num2str(section)],'filter',-1,hdlsignaliscomplex(scaled_input.input),numChannels,...
            inputtcvtype,inputtcsltype);

            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(inputconv)];

            [tempname,feedback]=hdlnewsignal(['feedback',num2str(section)],'filter',-1,cplxty_ab1sum,numChannels,...
            outputtcvtype,outputtcsltype);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(feedback)];




            tempbody=hdldatatypeassignment(scaled_input.input,inputconv,...
            multiplicandrounding,multiplicandsaturation);
            sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];



            [a2mul,a2blocks,a2signals,a2tempsignals]=hdlcoeffmultiply(feedback,den(2),den_list(2),...
            ['a2mul',num2str(section)],...
            denproductvtype,denproductsltype,...
            productrounding,productsaturation,this.DenAccumSLtype);

            [b1mul,b1blocks,b1signals,b1tempsignals]=hdlcoeffmultiply(inputconv,num(1),num_list(1),...
            ['b1mul',num2str(section)],...
            numproductvtype,numproductsltype,...
            productrounding,productsaturation,this.NumAccumSLtype);
            [b2mul,b2blocks,b2signals,b2tempsignals]=hdlcoeffmultiply(inputconv,num(2),num_list(2),...
            ['b2mul',num2str(section)],...
            numproductvtype,numproductsltype,...
            productrounding,productsaturation,this.NumAccumSLtype);
            sections_arch.signals=[sections_arch.signals,a2signals,b1signals,b2signals,...
            a2tempsignals,b1tempsignals,b2tempsignals];
            sections_arch.body_blocks=[sections_arch.body_blocks,a2blocks,b1blocks,b2blocks];


            if num(2)==0&&den(2)==0


            elseif den(2)==0
                tempbody=hdldatatypeassignment(b2mul,ab2sum,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
            elseif num(2)==0
                [tempbody,tempsignals]=hdlfilterunaryminus(a2mul,ab2sum,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                sections_arch.signals=[sections_arch.signals,tempsignals];
            end
            if num(2)~=0
                if den(2)~=0
                    cplxty_b2mulconv=cplxty_sectioninput||any(imag(num(2)));
                    [tempname,b2mulconv]=hdlnewsignal(['b2mulconv',num2str(section)],'filter',-1,cplxty_b2mulconv,numChannels,...
                    numsumvtype,numsumsltype);
                    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(b2mulconv)];
                    tempbody=hdldatatypeassignment(b2mul,b2mulconv,sumrounding,sumsaturation);
                    sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                    if hdlgetparameter('bit_true_to_filter')&&~strcmpi(numsumsltype,densumsltype)
                        [tempname,b2sumtc]=hdlnewsignal(['b2sumtypeconvert',num2str(section)],'filter',-1,cplxty_b2mulconv,numChannels,...
                        densumvtype,densumsltype);
                        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(b2sumtc)];
                        tempbody=hdldatatypeassignment(b2mulconv,b2sumtc,sumrounding,sumsaturation);
                        sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                    else
                        b2sumtc=b2mulconv;
                    end
                    [tempbody,tempsignals]=hdlfiltersub(b2sumtc,a2mul,ab2sum,sumrounding,sumsaturation);
                    sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                    sections_arch.signals=[sections_arch.signals,tempsignals];
                end

            end
            if num(2)==0&&den(2)==0
                if bit_true
                    sections_arch.body_blocks=[sections_arch.body_blocks,...
                    hdldatatypeassignment(b1mul,ab1sum,sumrounding,sumsaturation)];
                else
                    ab1sum=b1mul;
                end
            elseif num(1)==0
                ab1sum=delay;
            else
                [tempbody,tempsignals]=hdlfilteradd(delay,b1mul,ab1sum,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                sections_arch.signals=[sections_arch.signals,tempsignals];
            end




            if~(num(2)==0&&den(2)==0)
                if~strcmpi(densumsltype,storagesltype)
                    [tempname,storagecast]=hdlnewsignal(['delay_typeconvert',num2str(section)],...
                    'filter',-1,hdlsignaliscomplex(ab2sum),numChannels,...
                    storagevtype,storagesltype);
                    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(storagecast)];
                    tempbody=hdldatatypeassignment(ab2sum,storagecast,sumrounding,sumsaturation);
                    sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                else
                    storagecast=ab2sum;
                end
                [tempbody,tempsignals]=hdlunitdelay(storagecast,delay,...
                ['delay',hdlgetparameter('clock_process_label'),'_section',num2str(section)],0);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                sections_arch.signals=[sections_arch.signals,tempsignals];
            end




            tempbody=hdldatatypeassignment(ab1sum,feedback,...
            multiplicandrounding,multiplicandsaturation);
            sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];

            section_result.input=feedback;


        elseif filterorders(section)==2


            disp(sprintf([hdlcodegenmsgs(6),', # ','%d'],section));

            sections_arch.body_blocks=[sections_arch.body_blocks,...
            indentedcomment,...
            '------------------ Section ',num2str(section),' ------------------\n\n'];
            sections_arch.signals=[sections_arch.signals,indentedcomment,...
            'Section ',num2str(section),' Signals \n'];


            if num(3)==0&&num(2)==0&&bit_true
                b1vtype=lastmultvtype;
                b1sltype=lastmultsltype;
                b1saturation=lastmultsaturation;
                b1rounding=lastmultrounding;
            else
                b1vtype=numproductvtype;
                b1sltype=numproductsltype;
                b1saturation=productsaturation;
                b1rounding=productrounding;
            end

            if num(3)==0&&bit_true
                b2vtype=lastmultvtype;
                b2sltype=lastmultsltype;
                b2saturation=lastmultsaturation;
                b2rounding=lastmultrounding;
            else
                b2vtype=numproductvtype;
                b2sltype=numproductsltype;
                b2saturation=productsaturation;
                b2rounding=productrounding;
            end



            [tempname,ab1sum]=hdlnewsignal(['ab1sum',num2str(section)],'filter',-1,cplxty_ab1sum,numChannels,...
            numsumvtype,numsumsltype);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(ab1sum)];

            [tempname,ab2sum]=hdlnewsignal(['ab2sum',num2str(section)],'filter',-1,cplxty_ab2sum,numChannels,...
            densumvtype,densumsltype);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(ab2sum)];

            [tempname,ab3sum]=hdlnewsignal(['ab3sum',num2str(section)],'filter',-1,cplxty_ab3sum,numChannels,...
            numsumvtype,numsumsltype);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(ab3sum)];

            [tempname,b2sum]=hdlnewsignal(['b2sum',num2str(section)],'filter',-1,cplxty_b2sum,numChannels,...
            numsumvtype,numsumsltype);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(b2sum)];


            if hdlgetparameter('bit_true_to_filter')&&~strcmpi(numsumsltype,densumsltype)
                [tempname,b2sumtc]=hdlnewsignal(['b2sum_typeconvert',num2str(section)],'filter',-1,hdlsignaliscomplex(b2sum),numChannels,...
                densumvtype,densumsltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(b2sumtc)];
            end



            [tempname,delay1]=hdlnewsignal(['delay1_section',num2str(section)],'filter',-1,cplxty_ab2sum,numChannels,...
            storagevtype,storagesltype);
            if emitMode
                hdlregsignal(delay1);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(delay1)];
            end

            [tempname,delay2]=hdlnewsignal(['delay2_section',num2str(section)],'filter',-1,cplxty_ab3sum,numChannels,...
            storagevtype,storagesltype);
            if emitMode
                hdlregsignal(delay2);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(delay2)];
            end

            delaylist=[delay1,delay2];



            [tempname,inputconv]=hdlnewsignal(['inputconv',num2str(section)],'filter',-1,hdlsignaliscomplex(scaled_input.input),numChannels,...
            inputtcvtype,inputtcsltype);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(inputconv)];

            [tempname,feedback]=hdlnewsignal(['feedback',num2str(section)],'filter',-1,cplxty_ab1sum,numChannels,...
            outputtcvtype,outputtcsltype);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(feedback)];





            tempbody=hdldatatypeassignment(scaled_input.input,inputconv,...
            multiplicandrounding,multiplicandsaturation);
            sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];



            [a2mul,a2blocks,a2signals,a2tempsignals]=hdlcoeffmultiply(feedback,den(2),den_list(2),...
            ['a2mul',num2str(section)],...
            denproductvtype,denproductsltype,...
            productrounding,productsaturation,this.DenAccumslType);
            [a3mul,a3blocks,a3signals,a3tempsignals]=hdlcoeffmultiply(feedback,den(3),den_list(3),...
            ['a3mul',num2str(section)],...
            denproductvtype,denproductsltype,...
            productrounding,productsaturation,this.DenAccumslType);
            [b1mul,b1blocks,b1signals,b1tempsignals]=hdlcoeffmultiply(inputconv,num(1),num_list(1),...
            ['b1mul',num2str(section)],...
            b1vtype,b1sltype,...
            b1rounding,b1saturation,this.NumAccumslType);
            [b2mul,b2blocks,b2signals,b2tempsignals]=hdlcoeffmultiply(inputconv,num(2),num_list(2),...
            ['b2mul',num2str(section)],...
            b2vtype,b2sltype,...
            b2rounding,b2saturation,this.NumAccumslType);
            [b3mul,b3blocks,b3signals,b3tempsignals]=hdlcoeffmultiply(inputconv,num(3),num_list(3),...
            ['b3mul',num2str(section)],...
            lastmultvtype,lastmultsltype,...
            lastmultrounding,lastmultsaturation,this.NumAccumslType);

            sections_arch.signals=[sections_arch.signals,a2signals,a3signals,b1signals,b2signals,b3signals,...
            a2tempsignals,a3tempsignals,b1tempsignals,b2tempsignals,b3tempsignals];
            sections_arch.body_blocks=[sections_arch.body_blocks,a2blocks,a3blocks,b1blocks,b2blocks,b3blocks];




            if den(3)==0&&num(3)==0



                [cname,ab3sum]=hdlnewsignal(['zero_section',num2str(section)],'filter',-1,cplxty_ab3sum,numChannels,...
                storagevtype,storagesltype);
                sections_arch.constants=[sections_arch.constants,...
                makehdlconstantdecl(ab3sum,hdlconstantvalue(0,sumsize,densumbp,sumsigned))];
            elseif den(3)==0

                sections_arch.body_blocks=[sections_arch.body_blocks,...
                hdldatatypeassignment(b3mul,ab3sum,sumrounding,sumsaturation)];
            elseif num(3)==0
                [tempbody,tempsignals]=hdlfilterunaryminus(a3mul,ab3sum,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                sections_arch.signals=[sections_arch.signals,tempsignals];
            elseif force_extra_quantization
                [tempname,b3mulconv]=hdlnewsignal(['b3mul',num2str(section),'_quant'],'filter',-1,hdlsignaliscomplex(b3mul),numChannels,...
                numsumvtype,numsumsltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(b3mulconv)];
                tempbody=hdldatatypeassignment(b3mul,b3mulconv,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                [tempbody,tempsignals]=hdlfiltersub(b3mulconv,a3mul,ab3sum,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                sections_arch.signals=[sections_arch.signals,tempsignals];
            else
                [tempbody,tempsignals]=hdlfiltersub(b3mul,a3mul,ab3sum,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                sections_arch.signals=[sections_arch.signals,tempsignals];
            end

            if num(2)==0
                tempbody=hdldatatypeassignment(delaylist(2),b2sum,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];

            else
                [tempbody,tempsignals]=hdlfilteradd(b2mul,delaylist(2),b2sum,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                sections_arch.signals=[sections_arch.signals,tempsignals];
            end

            if hdlgetparameter('bit_true_to_filter')&&~strcmpi(numsumsltype,densumsltype)
                tempbody=hdldatatypeassignment(b2sum,b2sumtc,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                b2sum=b2sumtc;
            end

            if den(2)==0
                tempbody=hdldatatypeassignment(b2sum,ab2sum,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
            else
                [tempbody,tempsignals]=hdlfiltersub(b2sum,a2mul,ab2sum,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                sections_arch.signals=[sections_arch.signals,tempsignals];
            end

            if num(1)==0
                tempbody=hdldatatypeassignment(delaylist(1),ab1sum,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
            else
                [tempbody,tempsignals]=hdlfilteradd(delaylist(1),b1mul,ab1sum,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                sections_arch.signals=[sections_arch.signals,tempsignals];
            end





            if~strcmpi(densumsltype,storagesltype)
                [tempname,storagecast1]=hdlnewsignal(['delay1_typeconvert',num2str(section)],...
                'filter',-1,hdlsignaliscomplex(ab2sum),numChannels,...
                storagevtype,storagesltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(storagecast1)];
                tempbody=hdldatatypeassignment(ab2sum,storagecast1,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                [tempname,storagecast2]=hdlnewsignal(['delay2_typeconvert',num2str(section)],...
                'filter',-1,hdlsignaliscomplex(ab3sum),numChannels,...
                storagevtype,storagesltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(storagecast2)];
                tempbody=hdldatatypeassignment(ab3sum,storagecast2,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
            else
                storagecast1=ab2sum;
                storagecast2=ab3sum;
            end

            [tempbody,tempsignals]=hdlunitdelay([storagecast1,storagecast2],[delay1,delay2],...
            ['delay',hdlgetparameter('clock_process_label'),'_section',num2str(section)],...
            [0,0]);
            sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
            sections_arch.signals=[sections_arch.signals,tempsignals];



            tempbody=hdldatatypeassignment(ab1sum,feedback,...
            multiplicandrounding,multiplicandsaturation);
            sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];

            section_result.input=feedback;

        end

        current_input.input=section_result.input;

        if hdlgetparameter('filter_pipelined')&&section~=numsections
            hdlsetparameter('filter_excess_latency',hdlgetparameter('filter_excess_latency')+1);

            outsigvtype=hdlsignalvtype(current_input.input);
            outsigsltype=hdlsignalsltype(current_input.input);

            if emitMode
                [sections_arch,pipeout]=emit_delayprocess(this,sections_arch,...
                'sos_pipeline',current_input.input,outsigvtype,outsigsltype,section);
                current_input.input=pipeout;
            else
                [~,pipesignal]=hdlnewsignal('section_pipe',0,-1,hdlsignaliscomplex(current_input.input),numChannels,outsigvtype,outsigsltype);
                hWireComp=pirelab.getWireComp(hN,current_input.input,pipesignal);
                hWireComp.setOutputPipeline(1);
                current_input.input=pipesignal;
            end

        end

    end

    function[num,den]=getcoeffs(coeffs,section)
        num=coeffs(section,1:3);
        den=coeffs(section,4:6);



