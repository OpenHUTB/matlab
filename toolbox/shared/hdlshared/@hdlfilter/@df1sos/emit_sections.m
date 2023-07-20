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

    rmode=this.Roundmode;
    [outputrounding,outregrounding,...
    productrounding,sumrounding,...
    numstoragerounding,denstoragerounding]=deal(rmode);

    omode=this.Overflowmode;
    [outputsaturation,outregsaturation,...
    productsaturation,sumsaturation,...
    numstoragesaturation,denstoragesaturation]=deal(omode);


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

    numstorageall=hdlgetallfromsltype(this.numstateSLtype);
    numstoragevtype=numstorageall.vtype;
    numstoragesltype=numstorageall.sltype;

    denstorageall=hdlgetallfromsltype(this.denstateSLtype);
    denstoragesize=denstorageall.size;
    denstoragebp=denstorageall.bp;
    denstoragesigned=denstorageall.signed;
    denstoragevtype=denstorageall.vtype;
    denstoragesltype=denstorageall.sltype;

    scaleresultall=numstorageall;

    bit_true=true;
    lastmultvtype=numproductvtype;
    lastmultsltype=numproductsltype;
    lastmultsaturation=productsaturation;
    lastmultrounding=productrounding;

    if hdlgetparameter('isvhdl')
        sections_arch.typedefs=[sections_arch.typedefs,...
        '  TYPE numdelay_pipeline_type IS ARRAY (NATURAL range <>) OF ',...
        numstoragevtype,'; -- ',numstoragesltype,'\n',...
        '  TYPE dendelay_pipeline_type IS ARRAY (NATURAL range <>) OF ',...
        denstoragevtype,'; -- ',denstoragesltype,'\n'];

        numdelay_vector_vtype=['numdelay_pipeline_type(0 TO 1)'];
        dendelay_vector_vtype=['dendelay_pipeline_type(0 TO 1)'];
    else
        numdelay_vector_vtype=numstoragevtype;
        dendelay_vector_vtype=denstoragevtype;
    end

    last_section_was_second_order=false;

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
        can_share_delays=false;
        if isempty(scales)||section>length(scales)||scales(section)==1
            scaled_input.input=current_input.input;
            if last_section_was_second_order&&...
                (strcmpi(denstoragesltype,numstoragesltype))&&...
                ~hdlgetparameter('filter_pipelined')
                can_share_delays=true;
            end
        end
        [num,den]=getcoeffs(coeffs,section);

        if filterorders(section)==1
            disp(sprintf([hdlcodegenmsgs(5),', # ','%d'],section));

            last_section_was_second_order=false;
            sections_arch.body_blocks=[sections_arch.body_blocks,...
            indentedcomment,...
            '------------------ Section ',num2str(section),' (First Order) ------------------\n\n'];
            sections_arch.signals=[sections_arch.signals,indentedcomment,...
            'Section ',num2str(section),' Signals \n'];














            cplxty_numcast=hdlsignaliscomplex(scaled_input.input);



            [castname,numcast_result]=hdlnewsignal(['numtypeconvert',num2str(section)],'filter',-1,cplxty_numcast,numChannels,...
            numstoragevtype,numstoragesltype);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(numcast_result)];
            sections_arch.body_blocks=[sections_arch.body_blocks,hdldatatypeassignment(scaled_input.input,numcast_result,...
            numstoragerounding,numstoragesaturation)];









            cplxty_densection=any(imag([num,den]))||cplxty_numcast;

            [tempname,a1sum]=hdlnewsignal(['a1sum',num2str(section)],'filter',-1,cplxty_densection,numChannels,...
            densumvtype,densumsltype);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(a1sum)];

            cplxty_numsum=cplxty_numcast||any(imag(num));

            if~((num(1)==0||num(2)==0)&&~bit_true)
                [tempname,b1sum]=hdlnewsignal(['b1sum',num2str(section)],'filter',-1,cplxty_numsum,numChannels,...
                numsumvtype,numsumsltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(b1sum)];
            end


            if~strcmpi(denstoragevtype,densumvtype)||...
                ~strcmp(denstoragesltype,densumsltype)||...
                any([denstoragesize,denstoragebp,denstoragesigned]~=[sumsize,numsumbp,sumsigned])||...
                ~strcmpi(denstoragerounding,sumrounding)||...
                denstoragesaturation~=sumsaturation

                cplxty_dencast=hdlsignaliscomplex(a1sum);


                [castname,dencast_result]=hdlnewsignal(['dentypeconvert',num2str(section)],'filter',-1,cplxty_dencast,numChannels,...
                denstoragevtype,denstoragesltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(dencast_result)];
                sections_arch.body_blocks=[sections_arch.body_blocks,hdldatatypeassignment(a1sum,dencast_result,...
                denstoragerounding,denstoragesaturation)];
            else
                dencast_result=a1sum;
            end


            if num(2)~=0
                [sections_arch,numdelay]=emit_delayprocess(this,sections_arch,'numdelay_section',numcast_result,numstoragevtype,numstoragesltype,section);
            else
                numdelay=numcast_result;
            end

            if den(2)~=0
                [sections_arch,dendelay]=emit_delayprocess(this,sections_arch,'dendelay_section',dencast_result,denstoragevtype,denstoragesltype,section);
            else
                dendelay=dencast_result;
            end



            [a2mul,a2blocks,a2signals,a2tempsignals]=hdlcoeffmultiply(dendelay,den(2),den_list(2),...
            ['a2mul',num2str(section)],...
            denproductvtype,denproductsltype,...
            productrounding,productsaturation,densumsltype);

            [b1mul,b1blocks,b1signals,b1tempsignals]=hdlcoeffmultiply(numcast_result,num(1),num_list(1),...
            ['b1mul',num2str(section)],...
            numproductvtype,numproductsltype,...
            productrounding,productsaturation,numsumsltype);

            [b2mul,b2blocks,b2signals,b2tempsignals]=hdlcoeffmultiply(numdelay,num(2),num_list(2),...
            ['b2mul',num2str(section)],...
            numproductvtype,numproductsltype,...
            productrounding,productsaturation,numsumsltype);

            sections_arch.signals=[sections_arch.signals,a2signals,b1signals,b2signals,...
            a2tempsignals,b1tempsignals,b2tempsignals];
            sections_arch.body_blocks=[sections_arch.body_blocks,a2blocks,b1blocks,b2blocks];




            if num(1)~=0&&~strcmpi(numproductsltype,numsumsltype)
                cplxty_b1multype=hdlsignaliscomplex(b1mul);
                [b1multcname,b1multc]=hdlnewsignal(['b1multypeconvert',num2str(section)],...
                'filter',-1,cplxty_b1multype,numChannels,numsumvtype,numsumsltype);
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
                temp=b2mul;
                [tempbody,tempsignals]=hdlfilteradd(b1mul,temp,b1sum,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                sections_arch.signals=[sections_arch.signals,tempsignals];
            end

            if den(2)==0
                if bit_true
                    sections_arch.body_blocks=[sections_arch.body_blocks,...
                    hdldatatypeassignment(b1sum,a1sum,sumrounding,sumsaturation)];
                else
                    a1sum=b1sum;
                end
            else
                if~strcmpi(densumvtype,numsumvtype)||~strcmpi(densumsltype,numsumsltype)
                    cplxty_midtc=hdlsignaliscomplex(b1sum);
                    [midtcname,midtc]=hdlnewsignal(['midtypeconvert',num2str(section)],...
                    'filter',-1,cplxty_midtc,numChannels,densumvtype,densumsltype);
                    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(midtc)];
                    tempbody=hdldatatypeassignment(b1sum,midtc,sumrounding,sumsaturation);
                    sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                else
                    midtc=b1sum;
                end
                [tempbody,tempsignals]=hdlfiltersub(midtc,a2mul,a1sum,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                sections_arch.signals=[sections_arch.signals,tempsignals];
            end

            section_result.input=dencast_result;



        elseif filterorders(section)==2


            disp(sprintf([hdlcodegenmsgs(6),', # ','%d'],section));

            last_section_was_second_order=true;

            sections_arch.body_blocks=[sections_arch.body_blocks,...
            indentedcomment,...
            '------------------ Section ',num2str(section),' ------------------\n\n'];
            sections_arch.signals=[sections_arch.signals,indentedcomment,...
            'Section ',num2str(section),' Signals \n'];

            b1vtype=numproductvtype;
            b1sltype=numproductsltype;
            b1saturation=productsaturation;
            b1rounding=productrounding;


            b2vtype=numproductvtype;
            b2sltype=numproductsltype;
            b2saturation=productsaturation;
            b2rounding=productrounding;














            cplxty_numcast=hdlsignaliscomplex(scaled_input.input);










            cplxty_densection=any(imag([num,den]))||cplxty_numcast;

            [castname,numcast_result]=hdlnewsignal(['numtypeconvert',num2str(section)],'filter',-1,cplxty_numcast,...
            numChannels,numstoragevtype,numstoragesltype);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(numcast_result)];
            sections_arch.body_blocks=[sections_arch.body_blocks,hdldatatypeassignment(scaled_input.input,numcast_result,...
            numstoragerounding,numstoragesaturation)];





            [tempname,a1sum]=hdlnewsignal(['a1sum',num2str(section)],'filter',-1,cplxty_densection,numChannels,densumvtype,densumsltype);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(a1sum)];


            if~strcmpi(denstoragevtype,densumvtype)||...
                ~strcmp(denstoragesltype,densumsltype)||...
                any([denstoragesize,denstoragebp,denstoragesigned]~=[sumsize,densumbp,sumsigned])||...
                ~strcmpi(denstoragerounding,sumrounding)||...
                denstoragesaturation~=sumsaturation

                [castname,dencast_result]=hdlnewsignal(['dentypeconvert',num2str(section)],'filter',-1,cplxty_densection,numChannels,...
                denstoragevtype,denstoragesltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(dencast_result)];
                sections_arch.body_blocks=[sections_arch.body_blocks,hdldatatypeassignment(a1sum,dencast_result,...
                denstoragerounding,denstoragesaturation)];
            else
                dencast_result=a1sum;
            end



            if can_share_delays
                numdelaylist=prevdendelaylist;
                sections_arch.body_blocks=[sections_arch.body_blocks,...
                indentedcomment,...
                'Reusing denominator delays from last section as this section''s numerator delays\n\n'];
            else



                [tempname,numdelay]=hdlnewsignal(['numdelay_section',num2str(section)],'filter',-1,cplxty_numcast,[2,0],...
                numdelay_vector_vtype,numstoragesltype);

                if emitMode
                    hdlregsignal(numdelay);
                    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(numdelay)];

                    tdobj=hdl.tapdelay('clock',hdlgetcurrentclock,...
                    'clockenable',hdlgetcurrentclockenable,...
                    'reset',hdlgetcurrentreset,...
                    'inputs',numcast_result,...
                    'outputs',numdelay,...
                    'processName',['numdelay',hdlgetparameter('clock_process_label'),'_section',num2str(section)],...
                    'resetvalues',0,...
                    'nDelays',2,...
                    'delayOrder','Newest');
                    hdlc=tdobj.emit;
                    sections_arch.body_blocks=[sections_arch.body_blocks,hdlc.arch_body_blocks];
                    numdelaylist=hdlexpandvectorsignal(numdelay);
                else
                    [~,tapsignals]=hdltapdelay(numcast_result,numdelay,...
                    ['numdelay',hdlgetparameter('clock_process_label'),'_section',num2str(section)],2,'Newest',0);

                    if numChannels>1
                        numdelaylist=tapsignals;
                    else
                        numdelaylist=hdlexpandvectorsignal(numdelay);
                    end
                end

            end

            [tempname,dendelay]=hdlnewsignal(['dendelay_section',num2str(section)],'filter',-1,cplxty_densection,[2,0],...
            dendelay_vector_vtype,denstoragesltype);

            if emitMode
                hdlregsignal(dendelay);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(dendelay)];
                tdobj=hdl.tapdelay('clock',hdlgetcurrentclock,...
                'clockenable',hdlgetcurrentclockenable,...
                'reset',hdlgetcurrentreset,...
                'inputs',dencast_result,...
                'outputs',dendelay,...
                'processName',['dendelay',hdlgetparameter('clock_process_label'),'_section',num2str(section)],...
                'resetvalues',0,...
                'nDelays',2,...
                'delayOrder','Newest');

                hdlc=tdobj.emit;
                sections_arch.body_blocks=[sections_arch.body_blocks,hdlc.arch_body_blocks];
                dendelaylist=hdlexpandvectorsignal(dendelay);
            else
                [~,tapsignals]=hdltapdelay(dencast_result,dendelay,...
                ['dendelay',hdlgetparameter('clock_process_label'),'_section',num2str(section)],2,'Newest',0);

                if numChannels>1
                    dendelaylist=tapsignals;
                else
                    dendelaylist=hdlexpandvectorsignal(dendelay);
                end
            end

            prevdendelaylist=dendelaylist;



            [a2mul,a2blocks,a2signals,a2tempsignals]=hdlcoeffmultiply(dendelaylist(1),den(2),den_list(2),...
            ['a2mul',num2str(section)],...
            denproductvtype,denproductsltype,...
            productrounding,productsaturation,densumsltype);
            [a3mul,a3blocks,a3signals,a3tempsignals]=hdlcoeffmultiply(dendelaylist(2),den(3),den_list(3),...
            ['a3mul',num2str(section)],...
            denproductvtype,denproductsltype,...
            productrounding,productsaturation,densumsltype);
            [b1mul,b1blocks,b1signals,b1tempsignals]=hdlcoeffmultiply(numcast_result,num(1),num_list(1),...
            ['b1mul',num2str(section)],...
            b1vtype,b1sltype,...
            b1rounding,b1saturation,numsumsltype);
            [b2mul,b2blocks,b2signals,b2tempsignals]=hdlcoeffmultiply(numdelaylist(1),num(2),num_list(2),...
            ['b2mul',num2str(section)],...
            b2vtype,b2sltype,...
            b2rounding,b2saturation,numsumsltype);
            [b3mul,b3blocks,b3signals,b3tempsignals]=hdlcoeffmultiply(numdelaylist(2),num(3),num_list(3),...
            ['b3mul',num2str(section)],...
            lastmultvtype,lastmultsltype,...
            lastmultrounding,lastmultsaturation,numsumsltype);

            sections_arch.signals=[sections_arch.signals,a2signals,a3signals,b1signals,b2signals,b3signals,...
            a2tempsignals,a3tempsignals,b1tempsignals,b2tempsignals,b3tempsignals];
            sections_arch.body_blocks=[sections_arch.body_blocks,a2blocks,a3blocks,b1blocks,b2blocks,b3blocks];







            cplxty_numsum=cplxty_numcast||any(imag(num));

            [tempname,b1sum]=hdlnewsignal(['b1sum',num2str(section)],'filter',-1,cplxty_numsum,numChannels,numsumvtype,numsumsltype);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(b1sum)];

            if num(3)~=0
                [tempname,b2sum]=hdlnewsignal(['b2sum',num2str(section)],'filter',-1,cplxty_numsum,numChannels,numsumvtype,numsumsltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(b2sum)];
            end


            if num(1)~=0
                cplxty_b1multc=hdlsignaliscomplex(b1mul);
                [b1multcname,b1multc]=hdlnewsignal(['b1multypeconvert',num2str(section)],...
                'filter',-1,cplxty_b1multc,numChannels,numsumvtype,numsumsltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(b1multc)];
                tempbody=hdldatatypeassignment(b1mul,b1multc,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];

                if num(2)~=0
                    [tempbody,tempsignals]=hdlfilteradd(b1multc,b2mul,b1sum,sumrounding,sumsaturation);
                    sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                    sections_arch.signals=[sections_arch.signals,tempsignals];
                else
                    tempbody=hdldatatypeassignment(b1multc,b1sum,sumrounding,sumsaturation);
                    sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                end
            else
                tempbody=hdldatatypeassignment(b2mul,b1sum,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
            end


            if num(3)~=0
                [tempbody,tempsignals]=hdlfilteradd(b1sum,b3mul,b2sum,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                sections_arch.signals=[sections_arch.signals,tempsignals];
            else
                b2sum=b1sum;
            end


            if~strcmpi(densumvtype,numsumvtype)||~strcmpi(densumsltype,numsumsltype)
                cplxty_midtc=hdlsignaliscomplex(b2sum);
                [midtcname,midtc]=hdlnewsignal(['midtypeconvert',num2str(section)],...
                'filter',-1,cplxty_midtc,numChannels,densumvtype,densumsltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(midtc)];
                tempbody=hdldatatypeassignment(b2sum,midtc,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
            else
                midtc=b2sum;
            end








            if(den(2)~=0)
                [tempname,a2sum]=hdlnewsignal(['a2sum',num2str(section)],'filter',-1,cplxty_densection,numChannels,densumvtype,densumsltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(a2sum)];

                [tempbody,tempsignals]=hdlfiltersub(midtc,a2mul,a2sum,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                sections_arch.signals=[sections_arch.signals,tempsignals];
            else
                a2sum=midtc;
            end

            if den(3)~=0
                [tempbody,tempsignals]=hdlfiltersub(a2sum,a3mul,a1sum,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                sections_arch.signals=[sections_arch.signals,tempsignals];
            else
                tempbody=hdldatatypeassignment(a2sum,a1sum,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
            end

            section_result.input=dencast_result;

        end

        current_input.input=section_result.input;

        if hdlgetparameter('filter_pipelined')&&section~=numsections
            hdlsetparameter('filter_excess_latency',hdlgetparameter('filter_excess_latency')+1);

            outsigvtype=hdlsignalvtype(current_input.input);
            outsigsltype=hdlsignalsltype(current_input.input);

            if emitMode
                [sections_arch,pipeout]=emit_delayprocess(this,sections_arch,'sos_pipeline',...
                current_input.input,outsigvtype,outsigsltype,section);
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


