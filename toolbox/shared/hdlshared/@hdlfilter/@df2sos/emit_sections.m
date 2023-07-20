function[sections_arch,section_result]=emit_sections(this,current_input)









    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    if emitMode
        numChannels=0;
    else
        numChannels=current_input.input.Type.getDimensions;
    end

    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];

    coeffs=this.Coefficients;
    filterorders=this.SectionOrder;
    numsections=this.NumSections;
    scales=this.ScaleValues;

    sections_arch.signals='';
    sections_arch.body_blocks='';
    sections_arch.typedefs='';
    sections_arch.constants='';






    section_result=current_input;





    rmode=this.Roundmode;

    [outputrounding,outregrounding,...
    productrounding,sumrounding,...
    storagerounding,storagerounding,...
    multiplicandrounding]=deal(rmode);%#ok<ASGLU>



    omode=this.Overflowmode;
    [outputsaturation,outregsaturation,...
    productsaturation,sumsaturation,...
    storagesaturation,storagesaturation,...
    multiplicandsaturation]=deal(omode);%#ok<ASGLU>


    numprodall=hdlgetallfromsltype(this.numprodSLtype);
    numproductvtype=numprodall.vtype;
    numproductsltype=numprodall.sltype;

    denprodall=hdlgetallfromsltype(this.denprodSLtype);
    denproductvtype=denprodall.vtype;
    denproductsltype=denprodall.sltype;


    numaccumall=hdlgetallfromsltype(this.numaccumSLtype);
    sumsize=numaccumall.size;
    numsumbp=numaccumall.bp;
    sumsigned=numaccumall.signed;
    numsumvtype=numaccumall.vtype;
    numsumsltype=numaccumall.sltype;

    densumall=hdlgetallfromsltype(this.denAccumSLtype);
    densumbp=densumall.bp;
    densumvtype=densumall.vtype;
    densumsltype=densumall.sltype;



    storageall=hdlgetallfromsltype(this.StateSLtype);
    storagesize=storageall.size;
    storagebp=storageall.bp;
    storagesigned=storageall.signed;
    storagevtype=storageall.vtype;
    storagesltype=storageall.sltype;

    scaleresultall=hdlgetallfromsltype(this.SectionInputSLtype);

...
...
...
...
...
...
...
...
...








    forceaccumdtc=false;
    if any(~isreal(coeffs))&&~this.CastBeforeSum

        forceaccumdtc=true;
    end
    sectionoutputall=hdlgetallfromsltype(this.sectionoutputSLtype);
    stageoutsize=sectionoutputall.size;
    stageoutbp=sectionoutputall.bp;
    stageoutsigned=sectionoutputall.signed;
    outputtcvtype=sectionoutputall.vtype;
    outputtcsltype=sectionoutputall.sltype;


    bit_true=0;
    lastmultvtype=numproductvtype;
    lastmultsltype=numproductsltype;
    lastmultsaturation=productsaturation;
    lastmultrounding=productrounding;




    if hdlgetparameter('isvhdl')
        sections_arch.typedefs=[sections_arch.typedefs,...
        '  TYPE delay_pipeline_type IS ARRAY (NATURAL range <>) OF ',...
        storagevtype,'; -- ',storagesltype,'\n'];
        delay_vector_vtype='delay_pipeline_type(0 TO 1)';
    else
        delay_vector_vtype=storagevtype;
    end


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
        else
            if coeffs_port
                [sections_arch,num_list,den_list,scaled_input.input]=emit_scaleinput_port(this,sections_arch,current_input,section);
            else
                [sections_arch,num_list,den_list,scaled_input.input]=emit_coefficients(this,sections_arch,current_input.input,section,scaleresultall);
            end
            if~(isempty(scales)||section>length(scales)||scales(section)==1)




                cplxty_scaletc=hdlsignaliscomplex(scaled_input.input);
                [~,castscalesig]=hdlnewsignal(['scaletypeconvert',num2str(section)],...
                'filter',-1,cplxty_scaletc,numChannels,...
                scaleresultall.vtype,scaleresultall.sltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(castscalesig)];
                sections_arch.body_blocks=[sections_arch.body_blocks,...
                hdldatatypeassignment(scaled_input.input,castscalesig,...
                productrounding,productsaturation)];
                scaled_input.input=castscalesig;
            end
        end


        [num,den]=getcoeffs(coeffs,section);

        cplxty_densection=hdlsignaliscomplex(scaled_input.input)||...
        any(imag(den));
        cplxty_numsection=cplxty_densection||any(imag(num));


        if filterorders(section)==1
            fprintf([hdlcodegenmsgs(5),', # ','%d\n'],section);

            sections_arch.body_blocks=[sections_arch.body_blocks,...
            indentedcomment,...
            '  ------------------ Section ',num2str(section),' (First Order) ------------------\n\n'];
            sections_arch.signals=[sections_arch.signals,indentedcomment,'  -- Section ',num2str(section),' Signals \n'];



            [~,a1sum]=hdlnewsignal(['a1sum',num2str(section)],'filter',-1,cplxty_densection,numChannels,densumvtype,densumsltype);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(a1sum)];

            if bit_true||(num(1)~=0&&num(2)~=0)
                [~,b1sum]=hdlnewsignal(['b1sum',num2str(section)],'filter',-1,cplxty_numsection,numChannels,numsumvtype,numsumsltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(b1sum)];
            end


            if~strcmpi(storagevtype,densumvtype)||...
                ~strcmp(storagesltype,densumsltype)||...
                any([storagesize,storagebp,storagesigned]~=[sumsize,densumbp,sumsigned])||...
                ~strcmpi(storagerounding,sumrounding)||...
                storagesaturation~=sumsaturation

                [~,cast_result]=hdlnewsignal(['a1sumtypeconvert',num2str(section)],'filter',-1,hdlsignaliscomplex(a1sum),numChannels,...
                storagevtype,storagesltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(cast_result)];

                sections_arch.body_blocks=[sections_arch.body_blocks,hdldatatypeassignment(a1sum,cast_result,...
                storagerounding,storagesaturation)];

            else
                cast_result=a1sum;
            end



            if~(den(2)==0&&num(2)==0)

                [sections_arch,delay]=emit_delayprocess(this,sections_arch,...
                'delay_section',cast_result,storagevtype,storagesltype,section);
            else
                delay=0;
            end



            [~,inputconv]=hdlnewsignal(['inputconv',num2str(section)],'filter',-1,hdlsignaliscomplex(scaled_input.input),numChannels,...
            densumvtype,densumsltype);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(inputconv)];



            tempbody=hdldatatypeassignment(scaled_input.input,inputconv,...
            sumrounding,sumsaturation);
            sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];



            [a2mul,a2blocks,a2signals,a2tempsignals]=hdlcoeffmultiply(delay,den(2),den_list(2),...
            ['a2mul',num2str(section)],...
            denproductvtype,denproductsltype,...
            productrounding,productsaturation,this.DenAccumsltype,forceaccumdtc);

            [b1mul,b1blocks,b1signals,b1tempsignals]=hdlcoeffmultiply(cast_result,num(1),num_list(1),...
            ['b1mul',num2str(section)],...
            numproductvtype,numproductsltype,...
            productrounding,productsaturation,this.NumAccumsltype);
            [b2mul,b2blocks,b2signals,b2tempsignals]=hdlcoeffmultiply(delay,num(2),num_list(2),...
            ['b2mul',num2str(section)],...
            numproductvtype,numproductsltype,...
            productrounding,productsaturation,this.NumAccumsltype,forceaccumdtc);

            sections_arch.signals=[sections_arch.signals,a2signals,b1signals,b2signals,...
            a2tempsignals,b1tempsignals,b2tempsignals];
            sections_arch.body_blocks=[sections_arch.body_blocks,a2blocks,b1blocks,b2blocks];




            if den(2)==0

                sections_arch.body_blocks=[sections_arch.body_blocks,...
                hdldatatypeassignment(inputconv,a1sum,sumrounding,sumsaturation)];



            else
                [tempbody,tempsignals]=hdlfiltersub(inputconv,a2mul,a1sum,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                sections_arch.signals=[sections_arch.signals,tempsignals];
            end

            if num(1)~=0&&~strcmpi(numproductsltype,numsumsltype)
                cplxty_b1multc=hdlsignaliscomplex(b1mul);
                [~,b1multc]=hdlnewsignal(['b1multypeconvert',num2str(section)],...
                'filter',-1,cplxty_b1multc,numChannels,numsumvtype,numsumsltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(b1multc)];
                tempbody=hdldatatypeassignment(b1mul,b1multc,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                b1mul=b1multc;
            end

            if num(1)==0
                if bit_true
                    sections_arch.body_blocks=[sections_arch.body_blocks,...
                    hdldatatypeassignment(b2mul,b1sum,sumrounding,sumsaturation)];
                else
                    b1sum=b2mul;
                end
            elseif num(2)==0
                if bit_true
                    sections_arch.body_blocks=[sections_arch.body_blocks,...
                    hdldatatypeassignment(b1mul,b1sum,sumrounding,sumsaturation)];
                else
                    b1sum=b1mul;
                end
            else
                if bit_true
                    cplxty_b2multc=hdlsignaliscomplex(b2mul);
                    [tempname,temp]=hdlnewsignal(['b2sum',num2str(section)],...
                    'filter',-1,cplxty_b2multc,numChannels,numsumvtype,numsumsltype);
                    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(temp)];
                    sections_arch.body_blocks=[sections_arch.body_blocks,...
                    hdldatatypeassignment(b2mul,temp,sumrounding,sumsaturation)];
                else
                    temp=b2mul;
                end
                [tempbody,tempsignals]=hdlfilteradd(b1mul,temp,b1sum,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                sections_arch.signals=[sections_arch.signals,tempsignals];
            end



            if(~strcmpi(numsumvtype,outputtcvtype)||...
                ~strcmp(numsumsltype,outputtcsltype)||...
                any([sumsize,numsumbp,sumsigned]~=[stageoutsize,stageoutbp,stageoutsigned]))...
                &&length(scales)>=section+1&&scales(section+1)~=1
                [~,section_result.input]=hdlnewsignal(['section_result',num2str(section)],...
                'filter',-1,hdlsignaliscomplex(b1sum),numChannels,...
                outputtcvtype,outputtcsltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(section_result.input)];
                sections_arch.body_blocks=[sections_arch.body_blocks,hdldatatypeassignment(b1sum,section_result.input,...
                outputrounding,outputsaturation)];




            elseif length(scales)>section+1&&(~strcmpi(numsumvtype,densumvtype)||...
                ~strcmp(numsumsltype,densumsltype)||...
                numsumbp~=numsumbp)
                [~,section_result.input]=hdlnewsignal(['section_result',num2str(section)],...
                'filter',-1,hdlsignaliscomplex(b1sum),numChannels,...
                densumvtype,densumsltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(section_result.input)];
                sections_arch.body_blocks=[sections_arch.body_blocks,hdldatatypeassignment(b1sum,section_result.input,...
                sumrounding,sumsaturation)];
            else
                section_result.input=b1sum;
            end

        elseif filterorders(section)==2



            fprintf([hdlcodegenmsgs(6),', # ','%d\n'],section);

            sections_arch.body_blocks=[sections_arch.body_blocks,...
            indentedcomment,...
            '  ------------------ Section ',num2str(section),' ------------------\n\n'];
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


            [~,a1sum]=hdlnewsignal(['a1sum',num2str(section)],'filter',-1,cplxty_densection,numChannels,densumvtype,densumsltype);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(a1sum)];

            if den(2)~=0
                [~,a2sum]=hdlnewsignal(['a2sum',num2str(section)],'filter',-1,cplxty_densection,numChannels,densumvtype,densumsltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(a2sum)];
            end

            if num(3)~=0
                [~,b1sum]=hdlnewsignal(['b1sum',num2str(section)],'filter',-1,cplxty_numsection,numChannels,numsumvtype,numsumsltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(b1sum)];
            end

            if num(2)~=0
                [~,b2sum]=hdlnewsignal(['b2sum',num2str(section)],'filter',-1,cplxty_numsection,numChannels,numsumvtype,numsumsltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(b2sum)];
            end


            if~strcmpi(storagevtype,densumvtype)||...
                ~strcmp(storagesltype,densumsltype)||...
                any([storagesize,storagebp,storagesigned]~=[sumsize,densumbp,sumsigned])||...
                ~strcmpi(storagerounding,sumrounding)||...
                storagesaturation~=sumsaturation

                [~,cast_result]=hdlnewsignal(['typeconvert',num2str(section)],'filter',-1,cplxty_densection,numChannels,...
                storagevtype,storagesltype);







                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(cast_result)];
                sections_arch.body_blocks=[sections_arch.body_blocks,hdldatatypeassignment(a1sum,cast_result,...
                sumrounding,sumsaturation)];
            else
                cast_result=a1sum;
            end




            [~,delay]=hdlnewsignal(['delay_section',num2str(section)],'filter',-1,cplxty_densection,[2,0],...
            delay_vector_vtype,storagesltype);

            if emitMode
                hdlregsignal(delay);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(delay)];
                tdobj=hdl.tapdelay('clock',hdlgetcurrentclock,...
                'clockenable',hdlgetcurrentclockenable,...
                'reset',hdlgetcurrentreset,...
                'inputs',cast_result,...
                'outputs',delay,...
                'processName',['delay',hdlgetparameter('clock_process_label'),'_section',num2str(section)],...
                'resetvalues',0,...
                'nDelays',2,...
                'delayOrder','Newest');
                hdlc=tdobj.emit;
                sections_arch.body_blocks=[sections_arch.body_blocks,hdlc.arch_body_blocks];
                delaylist=hdlexpandvectorsignal(delay);
            else
                [~,tapsignals]=hdltapdelay(cast_result,delay,...
                ['delay',hdlgetparameter('clock_process_label'),'_section',num2str(section)],2,'Newest',0);

                if numChannels>1
                    delaylist=tapsignals;
                else
                    delaylist=hdlexpandvectorsignal(delay);
                end
            end


...
...
...
...
...



            [~,inputconv]=hdlnewsignal(['inputconv',num2str(section)],'filter',-1,hdlsignaliscomplex(scaled_input.input),numChannels,...
            densumvtype,densumsltype);



            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(inputconv)];






            tempbody=hdldatatypeassignment(scaled_input.input,inputconv,...
            multiplicandrounding,multiplicandsaturation);
            sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
...
...
...
...
...
...
...



            [a2mul,a2blocks,a2signals,a2tempsignals]=hdlcoeffmultiply(delaylist(1),den(2),den_list(2),...
            ['a2mul',num2str(section)],...
            denproductvtype,denproductsltype,...
            productrounding,productsaturation,this.DenAccumsltype,forceaccumdtc);
            [a3mul,a3blocks,a3signals,a3tempsignals]=hdlcoeffmultiply(delaylist(2),den(3),den_list(3),...
            ['a3mul',num2str(section)],...
            denproductvtype,denproductsltype,...
            productrounding,productsaturation,this.DenAccumsltype,forceaccumdtc);


            [b1mul,b1blocks,b1signals,b1tempsignals]=hdlcoeffmultiply(cast_result,num(1),num_list(1),...
            ['b1mul',num2str(section)],...
            b1vtype,b1sltype,...
            b1rounding,b1saturation,this.NumAccumsltype);
            [b2mul,b2blocks,b2signals,b2tempsignals]=hdlcoeffmultiply(delaylist(1),num(2),num_list(2),...
            ['b2mul',num2str(section)],...
            b2vtype,b2sltype,...
            b2rounding,b2saturation,this.NumAccumsltype,forceaccumdtc);
            [b3mul,b3blocks,b3signals,b3tempsignals]=hdlcoeffmultiply(delaylist(2),num(3),num_list(3),...
            ['b3mul',num2str(section)],...
            lastmultvtype,lastmultsltype,...
            lastmultrounding,lastmultsaturation,this.NumAccumsltype,forceaccumdtc);

            sections_arch.signals=[sections_arch.signals,a2signals,a3signals,b1signals,b2signals,b3signals,...
            a2tempsignals,a3tempsignals,b1tempsignals,b2tempsignals,b3tempsignals];
            sections_arch.body_blocks=[sections_arch.body_blocks,a2blocks,a3blocks,b1blocks,b2blocks,b3blocks];



            if den(2)==0
                a2sum=inputconv;
            else
                [tempbody,tempsignals]=hdlfiltersub(inputconv,a2mul,a2sum,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                sections_arch.signals=[sections_arch.signals,tempsignals];
            end

            if den(3)==0
                sections_arch.body_blocks=[sections_arch.body_blocks,...
                hdldatatypeassignment(a2sum,a1sum,sumrounding,sumsaturation)];

            else
                [tempbody,tempsignals]=hdlfiltersub(a2sum,a3mul,a1sum,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                sections_arch.signals=[sections_arch.signals,tempsignals];
            end

            if num(1)~=0
                if~strcmpi(numproductsltype,numsumsltype)
                    [~,b1multc]=hdlnewsignal(['b1multypeconvert',num2str(section)],...
                    'filter',-1,hdlsignaliscomplex(b1mul),numChannels,numsumvtype,numsumsltype);
                    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(b1multc)];
                    tempbody=hdldatatypeassignment(b1mul,b1multc,sumrounding,sumsaturation);
                    sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                else
                    b1multc=b1mul;
                end

                if num(2)~=0
                    [tempbody,tempsignals]=hdlfilteradd(b1multc,b2mul,b2sum,sumrounding,sumsaturation);
                    sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                    sections_arch.signals=[sections_arch.signals,tempsignals];
                else
                    if bit_true
                        sections_arch.body_blocks=[sections_arch.body_blocks,...
                        hdldatatypeassignment(b1multc,b2sum,sumrounding,sumsaturation)];
                    else
                        b2sum=b1multc;
                    end
                end
            else
                if bit_true
                    sections_arch.body_blocks=[sections_arch.body_blocks,...
                    hdldatatypeassignment(b2mul,b2sum,sumrounding,sumsaturation)];
                else
                    b2sum=b2mul;
                end
            end

            if num(3)~=0
                if num(1)==0&&num(2)==0
                    if bit_true
                        sections_arch.body_blocks=[sections_arch.body_blocks,...
                        hdldatatypeassignment(b3mul,b1sum,sumrounding,sumsaturation)];
                    else
                        b1sum=b3mul;
                    end
                else
                    [tempbody,tempsignals]=hdlfilteradd(b2sum,b3mul,b1sum,sumrounding,sumsaturation);
                    sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                    sections_arch.signals=[sections_arch.signals,tempsignals];
                end
            else
                b1sum=b2sum;
            end




            if(~strcmpi(numsumvtype,outputtcvtype)||...
                ~strcmp(numsumsltype,outputtcsltype)||...
                any([sumsize,numsumbp,sumsigned]~=[stageoutsize,stageoutbp,stageoutsigned]))...
                &&length(scales)>=section+1&&scales(section+1)~=1

                [~,section_result.input]=hdlnewsignal(['section_result',num2str(section)],...
                'filter',-1,hdlsignaliscomplex(b1sum),numChannels,...
                outputtcvtype,outputtcsltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(section_result.input)];
                sections_arch.body_blocks=[sections_arch.body_blocks,hdldatatypeassignment(b1sum,section_result.input,...
                outputrounding,outputsaturation)];



            elseif length(scales)>section+1&&(~strcmpi(numsumvtype,densumvtype)||...
                ~strcmp(numsumsltype,densumsltype)||...
                numsumbp~=numsumbp)
                [~,section_result.input]=hdlnewsignal(['section_result',num2str(section)],...
                'filter',-1,hdlsignaliscomplex(b1sum),numChannels,...
                densumvtype,densumsltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(section_result.input)];
                sections_arch.body_blocks=[sections_arch.body_blocks,hdldatatypeassignment(b1sum,section_result.input,...
                sumrounding,sumsaturation)];
            else
                section_result.input=b1sum;
            end

        end

        current_input.input=section_result.input;


        if hdlgetparameter('filter_pipelined')&&section~=numsections
            hdlsetparameter('filter_excess_latency',hdlgetparameter('filter_excess_latency')+1);

            outsigvtype=hdlsignalvtype(current_input.input);
            outsigsltype=hdlsignalsltype(current_input.input);

            if emitMode
                [sections_arch,pipeout]=emit_delayprocess(this,sections_arch,...
                'sos_pipeline',current_input.input,outsigvtype,outsigsltype,...
                section);
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


