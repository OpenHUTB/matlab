function[sections_arch,section_result]=emit_sections(this,current_input)








    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    if emitMode
        numChannels=0;
    else
        numChannels=current_input.input.Type.getDimensions;
    end

    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];
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

    coeffs=this.Coefficients;
    filterorders=this.SectionOrder;
    numsections=this.NumSections;
    scales=this.ScaleValues;

    rmode=this.Roundmode;
    [outputrounding,outregrounding,...
    productrounding,sumrounding,...
    numstoragerounding]=deal(rmode);

    omode=this.Overflowmode;
    [outputsaturation,outregsaturation,...
    productsaturation,sumsaturation,...
    numstoragesaturation]=deal(omode);


    numprodall=hdlgetallfromsltype(this.numprodSLtype);
    productsize=numprodall.size;
    numproductbp=numprodall.bp;
    numproductvtype=numprodall.vtype;
    numproductsltype=numprodall.sltype;

    denprodall=hdlgetallfromsltype(this.denprodSLtype);
    denproductvtype=denprodall.vtype;
    denproductsltype=denprodall.sltype;


    numaccumall=hdlgetallfromsltype(this.numaccumSLtype);
    sumsize=numaccumall.size;
    numsumbp=numaccumall.bp;
    numsumvtype=numaccumall.vtype;
    numsumsltype=numaccumall.sltype;

    densumall=hdlgetallfromsltype(this.denAccumSLtype);
    densumvtype=densumall.vtype;
    densumsltype=densumall.sltype;


    numstorageall=hdlgetallfromsltype(this.numstateSLtype);
    numstoragevtype=numstorageall.vtype;
    numstoragesltype=numstorageall.sltype;

    denstorageall=hdlgetallfromsltype(this.denstateSLtype);
    denstoragevtype=denstorageall.vtype;
    denstoragesltype=denstorageall.sltype;

    scaleresultall=hdlgetallfromsltype(this.SectionInputSLtype);
    sectionoutputall=hdlgetallfromsltype(this.sectionoutputSLtype);
    outputtcvtype=sectionoutputall.vtype;
    outputtcsltype=sectionoutputall.sltype;

    multiplicandall=hdlgetallfromsltype(this.multiplicandSLtype);
    multiplicandvtype=multiplicandall.vtype;
    multiplicandsltype=multiplicandall.sltype;

    force_extra_quantization=false;
    if hdlgetparameter('bit_true_to_filter')&&...
        ((productsize>sumsize)||...
        (productsize==sumsize&&numproductbp>numsumbp))
        warning(message('HDLShared:hdlfilter:quantizedifferencedf1'));

        if~(strcmp(sumrounding,productrounding)&&sumsaturation==productsaturation)

            force_extra_quantization=true;
        end
    else

    end


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
                [uname,castscalesig]=hdlnewsignal(['scaletypeconvert',num2str(section)],...
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

        cplxty_densection=hdlsignaliscomplex(scaled_input.input)||any(imag(den));
        cplxty_numsection=cplxty_densection||any(imag(num));



        if isempty(scales)||section>length(scales)||(scales(section)==1&&this.OptimizeScaleValues)

            if strcmpi(numsumsltype,densumsltype)&&section~=1
                cplxty_scaletc=hdlsignaliscomplex(current_input.input);
                [uname,scaled_input.input]=hdlnewsignal(['scaletypeconvert',num2str(section)],...
                'filter',-1,cplxty_scaletc,numChannels,...
                densumvtype,densumsltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(scaled_input.input)];
                sections_arch.body_blocks=[sections_arch.body_blocks,...
                hdldatatypeassignment(current_input.input,scaled_input.input,...
                sumrounding,sumsaturation)];
            end

        end



        if filterorders(section)==0
            error(message('HDLShared:hdlfilter:zero_order'));
        elseif filterorders(section)==1
            disp(sprintf([hdlcodegenmsgs(5),', # ','%d'],section));

            sections_arch.body_blocks=[sections_arch.body_blocks,...
            indentedcomment,...
            '------------------ Section ',num2str(section),' (First Order) ------------------\n\n'];
            sections_arch.signals=[sections_arch.signals,indentedcomment,...
            'Section ',num2str(section),' Signals \n'];




            if den(2)==0
                if force_extra_quantization
                    [tempname,a1sum]=hdlnewsignal(['a1sum',num2str(section)],'filter',-1,cplxty_densection,numChannels,densumvtype,densumsltype);
                    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(a1sum)];

                    sections_arch.body_blocks=[sections_arch.body_blocks,...
                    hdldatatypeassignment(scaled_input.input,a1sum,...
                    sumrounding,sumsaturation)];

                else
                    a1sum=scaled_input.input;
                end
            else
                [tempname,a1sum]=hdlnewsignal(['a1sum',num2str(section)],'filter',-1,cplxty_densection,numChannels,...
                densumvtype,densumsltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(a1sum)];

                [tempname,a2sum]=hdlnewsignal(['a2sum',num2str(section)],'filter',-1,cplxty_densection,numChannels,...
                densumvtype,densumsltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(a2sum)];
            end

            [tempname,b1sum]=hdlnewsignal(['b1sum',num2str(section)],'filter',-1,cplxty_numsection,numChannels,...
            numsumvtype,numsumsltype);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(b1sum)];




            [castname,cast_result]=hdlnewsignal(['typeconvert',num2str(section)],'filter',-1,cplxty_densection,numChannels,...
            multiplicandvtype,multiplicandsltype);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(cast_result)];
            sections_arch.body_blocks=[sections_arch.body_blocks,hdldatatypeassignment(a1sum,cast_result,...
            numstoragerounding,numstoragesaturation)];


            [a2mul,a2blocks,a2signals,a2tempsignals]=hdlcoeffmultiply(cast_result,den(2),den_list(2),...
            ['a2mul',num2str(section)],...
            denproductvtype,denproductsltype,...
            productrounding,productsaturation,this.DenAccumSLtype);

            if den(2)~=0
                sections_arch.body_blocks=[sections_arch.body_blocks,...
                hdldatatypeassignment(a2mul,a2sum,sumrounding,sumsaturation)];
            end

            [b1mul,b1blocks,b1signals,b1tempsignals]=hdlcoeffmultiply(cast_result,num(1),num_list(1),...
            ['b1mul',num2str(section)],...
            numproductvtype,numproductsltype,...
            productrounding,productsaturation,this.NumAccumSLtype);

            b2mulvtype=numproductvtype;
            b2mulsltype=numproductsltype;
            b2mulrounding=productrounding;
            b2mulsaturation=productsaturation;


            [b2mul,b2blocks,b2signals,b2tempsignals]=hdlcoeffmultiply(cast_result,num(2),num_list(2),...
            ['b2mul',num2str(section)],...
            b2mulvtype,b2mulsltype,...
            b2mulrounding,b2mulsaturation,this.NumAccumSLtype);

            sections_arch.signals=[sections_arch.signals,a2signals,b1signals,b2signals,...
            a2tempsignals,b1tempsignals,b2tempsignals];
            sections_arch.body_blocks=[sections_arch.body_blocks,a2blocks,b1blocks,b2blocks];



            if num(2)~=0
                if~strcmpi(numproductsltype,numstoragesltype)
                    [tempname,storagecast]=hdlnewsignal(['numdelay_typeconvert',num2str(section)],...
                    'filter',-1,cplxty_numsection,numChannels,...
                    numstoragevtype,numstoragesltype);
                    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(storagecast)];
                    tempbody=hdldatatypeassignment(b2mul,storagecast,sumrounding,sumsaturation);
                    sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                else
                    storagecast=b2mul;
                end

                [sections_arch,numdelay]=emit_delayprocess(this,sections_arch,'numdelay_section',storagecast,numstoragevtype,numstoragesltype,section);
            end

            if den(2)~=0
                if~strcmpi(denproductsltype,denstoragesltype)
                    [tempname,storagecast]=hdlnewsignal(['dendelay_typeconvert',num2str(section)],...
                    'filter',-1,cplxty_densection,numChannels,...
                    denstoragevtype,denstoragesltype);
                    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(storagecast)];
                    tempbody=hdldatatypeassignment(a2sum,storagecast,sumrounding,sumsaturation);
                    sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                else
                    storagecast=a2sum;
                end

                [sections_arch,dendelay]=emit_delayprocess(this,sections_arch,'dendelay_section',storagecast,denstoragevtype,denstoragesltype,section);
            end



            if den(2)~=0

                [tempbody,tempsignals]=hdlfiltersub(scaled_input.input,dendelay,a1sum,...
                sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                sections_arch.signals=[sections_arch.signals,tempsignals];

            end

            if num(2)==0
                if force_extra_quantization
                    sections_arch.body_blocks=[sections_arch.body_blocks,...
                    hdldatatypeassignment(b1mul,b1sum,sumrounding,sumsaturation)];
                else
                    b1sum=b1mul;
                end

            elseif num(1)==0
                if force_extra_quantization
                    sections_arch.body_blocks=[sections_arch.body_blocks,...
                    hdldatatypeassignment(numdelay,b1sum,sumrounding,sumsaturation)];
                else
                    b1sum=numdelay;
                end
            else
                [tempbody,tempsignals]=hdlfilteradd(b1mul,numdelay,b1sum,sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                sections_arch.signals=[sections_arch.signals,tempsignals];
            end



            section_result.input=b1sum;

        elseif filterorders(section)==2




            disp(sprintf([hdlcodegenmsgs(6),', # ','%d'],section));

            sections_arch.body_blocks=[sections_arch.body_blocks,...
            indentedcomment,...
            '------------------ Section ',num2str(section),' ------------------\n\n'];
            sections_arch.signals=[sections_arch.signals,indentedcomment,...
            'Section ',num2str(section),' Signals \n'];




            [tempname,a1sum]=hdlnewsignal(['a1sum',num2str(section)],'filter',-1,cplxty_densection,numChannels,...
            densumvtype,densumsltype);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(a1sum)];

            if den(2)~=0
                [tempname,a2sum]=hdlnewsignal(['a2sum',num2str(section)],'filter',-1,cplxty_densection,numChannels,...
                densumvtype,densumsltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(a2sum)];
            end

            if~((num(1)==0&&num(2)==0)||...
                (num(1)==0&&num(3)==0)||...
                (num(2)==0&&num(3)==0&&force_extra_quantization==0))
                [tempname,b1sum]=hdlnewsignal(['b1sum',num2str(section)],'filter',-1,cplxty_numsection,numChannels,...
                numsumvtype,numsumsltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(b1sum)];
            end

            if num(2)~=0
                [tempname,b2sum]=hdlnewsignal(['b2sum',num2str(section)],'filter',-1,cplxty_numsection,numChannels,...
                numsumvtype,numsumsltype);
                sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(b2sum)];
            end





            [castname,cast_result]=hdlnewsignal(['typeconvert',num2str(section)],'filter',-1,cplxty_densection,numChannels,...
            multiplicandvtype,multiplicandsltype);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(cast_result)];
            sections_arch.body_blocks=[sections_arch.body_blocks,hdldatatypeassignment(a1sum,cast_result,...
            numstoragerounding,numstoragesaturation)];




            [a2mul,a2blocks,a2signals,a2tempsignals]=hdlcoeffmultiply(cast_result,den(2),den_list(2),...
            ['a2mul',num2str(section)],...
            denproductvtype,denproductsltype,...
            productrounding,productsaturation,this.DenAccumSLtype);
            [a3mul,a3blocks,a3signals,a3tempsignals]=hdlcoeffmultiply(cast_result,den(3),den_list(3),...
            ['a3mul',num2str(section)],...
            denproductvtype,denproductsltype,...
            productrounding,productsaturation,this.DenAccumSLtype);
            a3sum=a3mul;


            [b1mul,b1blocks,b1signals,b1tempsignals]=hdlcoeffmultiply(cast_result,num(1),num_list(1),...
            ['b1mul',num2str(section)],...
            numproductvtype,numproductsltype,...
            productrounding,productsaturation,this.NumAccumSLtype);

            [b2mul,b2blocks,b2signals,b2tempsignals]=hdlcoeffmultiply(cast_result,num(2),num_list(2),...
            ['b2mul',num2str(section)],...
            numproductvtype,numproductsltype,...
            productrounding,productsaturation,this.NumAccumSLtype);

            [b3mul,b3blocks,b3signals,b3tempsignals]=hdlcoeffmultiply(cast_result,num(3),num_list(3),...
            ['b3mul',num2str(section)],...
            numproductvtype,numproductsltype,...
            productrounding,productsaturation,this.NumAccumSLtype);

            sections_arch.signals=[sections_arch.signals,a2signals,a3signals,b1signals,b2signals,b3signals,...
            a2tempsignals,a3tempsignals,b1tempsignals,b2tempsignals,b3tempsignals];
            sections_arch.body_blocks=[sections_arch.body_blocks,a2blocks,a3blocks,b1blocks,b2blocks,b3blocks];




            if num(2)==0&&num(3)==0
                numdelaylist=[0,0];

            elseif num(3)==0
                [tempname,numdelay]=hdlnewsignal(['numdelay_section',num2str(section)],'filter',-1,cplxty_numsection,numChannels,...
                numstoragevtype,numstoragesltype);
                if emitMode
                    hdlregsignal(numdelay);
                    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(numdelay)];
                end

                if~strcmpi(numproductsltype,numstoragesltype)
                    [tempname,storagecast]=hdlnewsignal(['delay_typeconvert',num2str(section)],...
                    'filter',-1,cplxty_numsection,numChannels,...
                    numstoragevtype,numstoragesltype);
                    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(storagecast)];
                    tempbody=hdldatatypeassignment(b2mul,storagecast,sumrounding,sumsaturation);
                    sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                else
                    storagecast=b2mul;
                end

                [tempbody,tempsignals]=hdlunitdelay(storagecast,numdelay,...
                ['numdelay',hdlgetparameter('clock_process_label'),'_section',num2str(section)],...
                0);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                sections_arch.signals=[sections_arch.signals,tempsignals];

                numdelaylist=[numdelay,numdelay];
            else
                if emitMode
                    [~,numdelay]=hdlnewsignal(['numdelay_section',num2str(section)],'filter',-1,cplxty_numsection,[2,0],...
                    numdelay_vector_vtype,numstoragesltype);
                    hdlregsignal(numdelay);
                    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(numdelay)];
                    numdelaylist=hdlexpandvectorsignal(numdelay);
                else
                    [~,numdelay1]=hdlnewsignal(['numdelay_section',num2str(section),'_1'],'filter',-1,cplxty_numsection,numChannels,...
                    numdelay_vector_vtype,numstoragesltype);
                    [~,numdelay2]=hdlnewsignal(['numdelay_section',num2str(section),'_2'],'filter',-1,cplxty_numsection,numChannels,...
                    numdelay_vector_vtype,numstoragesltype);
                    numdelaylist=[numdelay1,numdelay2];
                end

                if num(2)==0
                    b2sum=numdelaylist(1);
                end

                if~strcmpi(hdlsignalsltype(b3mul),numstoragesltype)
                    [tempname,storagecast1]=hdlnewsignal(['numdelay1_typeconvert',num2str(section)],...
                    'filter',-1,cplxty_numsection,numChannels,...
                    numstoragevtype,numstoragesltype);
                    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(storagecast1)];
                    tempbody=hdldatatypeassignment(b3mul,storagecast1,sumrounding,sumsaturation);
                    sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                else
                    storagecast1=b3mul;
                end

                if~strcmpi(hdlsignalsltype(b2sum),numstoragesltype)
                    [tempname,storagecast2]=hdlnewsignal(['numdelay2_typeconvert',num2str(section)],...
                    'filter',-1,cplxty_numsection,numChannels,...
                    numstoragevtype,numstoragesltype);
                    sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(storagecast2)];
                    tempbody=hdldatatypeassignment(b2sum,storagecast2,sumrounding,sumsaturation);
                    sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                else
                    storagecast2=b2sum;
                end

                [tempbody,tempsignals]=hdlunitdelay([storagecast1,storagecast2],numdelaylist,...
                ['numdelay',hdlgetparameter('clock_process_label'),'_section',num2str(section)],...
                [0,0]);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                sections_arch.signals=[sections_arch.signals,tempsignals];
            end

            if den(3)~=0||den(2)~=0
                if den(3)==0
                    [tempname,dendelay]=hdlnewsignal(['dendelay_section',num2str(section)],'filter',-1,cplxty_densection,numChannels,...
                    denstoragevtype,denstoragesltype);
                    if emitMode
                        hdlregsignal(dendelay);
                        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(dendelay)];
                    end

                    if~strcmpi(hdlsignalsltype(a2sum),denstoragesltype)
                        [tempname,storagecast1]=hdlnewsignal(['dendelay1_typeconvert',num2str(section)],...
                        'filter',-1,cplxty_densection,numChannels,...
                        denstoragevtype,denstoragesltype);
                        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(storagecast1)];
                        tempbody=hdldatatypeassignment(a2sum,storagecast1,sumrounding,sumsaturation);
                        sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                    else
                        storagecast1=a2sum;
                    end

                    [tempbody,tempsignals]=hdlunitdelay(storagecast1,dendelay,...
                    ['dendelay',hdlgetparameter('clock_process_label'),'_section',num2str(section)],...
                    0);
                    sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                    sections_arch.signals=[sections_arch.signals,tempsignals];

                    dendelaylist=[dendelay,dendelay];
                else
                    if emitMode
                        [~,dendelay]=hdlnewsignal(['dendelay_section',num2str(section)],'filter',-1,cplxty_densection,[2,0],...
                        dendelay_vector_vtype,denstoragesltype);
                        hdlregsignal(dendelay);
                        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(dendelay)];
                        dendelaylist=hdlexpandvectorsignal(dendelay);
                    else
                        [~,dendelay1]=hdlnewsignal(['dendelay_section',num2str(section),'_1'],'filter',-1,cplxty_densection,numChannels,...
                        dendelay_vector_vtype,denstoragesltype);
                        [~,dendelay2]=hdlnewsignal(['dendelay_section',num2str(section),'_2'],'filter',-1,cplxty_densection,numChannels,...
                        dendelay_vector_vtype,denstoragesltype);
                        dendelaylist=[dendelay1,dendelay2];
                    end

                    if den(2)==0
                        a2sum=dendelaylist(1);
                    end

                    if~strcmpi(hdlsignalsltype(a3sum),denstoragesltype)
                        [tempname,storagecast1]=hdlnewsignal(['dendelay1_typeconvert',num2str(section)],...
                        'filter',-1,cplxty_densection,numChannels,...
                        denstoragevtype,denstoragesltype);
                        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(storagecast1)];
                        tempbody=hdldatatypeassignment(a3sum,storagecast1,sumrounding,sumsaturation);
                        sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                    else
                        storagecast1=a3sum;
                    end

                    if~strcmpi(hdlsignalsltype(a2sum),denstoragesltype)
                        [tempname,storagecast2]=hdlnewsignal(['dendelay2_typeconvert',num2str(section)],...
                        'filter',-1,cplxty_densection,numChannels,...
                        denstoragevtype,denstoragesltype);
                        sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(storagecast2)];
                        tempbody=hdldatatypeassignment(a2sum,storagecast2,sumrounding,sumsaturation);
                        sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                    else
                        storagecast2=a2sum;
                    end

                    [tempbody,tempsignals]=hdlunitdelay([storagecast1,storagecast2],dendelaylist,...
                    ['dendelay',hdlgetparameter('clock_process_label'),'_section',num2str(section)],...
                    [0,0]);
                    sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                    sections_arch.signals=[sections_arch.signals,tempsignals];
                end
            end



            if den(3)~=0
                a3sum=a3mul;
            end

            if den(3)==0&&den(2)~=0
                sections_arch.body_blocks=[sections_arch.body_blocks,...
                hdldatatypeassignment(a2mul,a2sum,sumrounding,sumsaturation)];
            elseif den(2)==0
            else
                [tempbody,tempsignals]=hdlfilteradd(dendelaylist(1),a2mul,a2sum,...
                sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                sections_arch.signals=[sections_arch.signals,tempsignals];
            end


            if den(2)==0&&den(3)==0
                sections_arch.body_blocks=[sections_arch.body_blocks,...
                hdldatatypeassignment(scaled_input.input,a1sum,sumrounding,sumsaturation)];
            else

                [tempbody,tempsignals]=hdlfiltersub(scaled_input.input,dendelaylist(2),a1sum,...
                sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                sections_arch.signals=[sections_arch.signals,tempsignals];

            end

            if~(num(3)==0||num(2)==0)
                [tempbody,tempsignals]=hdlfilteradd(b2mul,numdelaylist(1),b2sum,...
                sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                sections_arch.signals=[sections_arch.signals,tempsignals];
            end

            if num(1)==0
                b1sum=numdelaylist(2);
            elseif num(2)==0&&num(3)==0
                if force_extra_quantization
                    sections_arch.body_blocks=[sections_arch.body_blocks,...
                    hdldatatypeassignment(b1mul,b1sum,sumrounding,sumsaturation)];
                else
                    b1sum=b1mul;
                end
            else
                [tempbody,tempsignals]=hdlfilteradd(b1mul,numdelaylist(2),b1sum,...
                sumrounding,sumsaturation);
                sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
                sections_arch.signals=[sections_arch.signals,tempsignals];
            end


            section_result.input=b1sum;

        else
            error(message('HDLShared:hdlfilter:other_order',filterorders(section)));
        end

        if~strcmpi(hdlsignalsltype(section_result.input),outputtcsltype)&&...
            length(scales)>=section+1&&~(scales(section+1)==1&&this.OptimizeScaleValues)

            [tempname,stagecast]=hdlnewsignal(['stageout_typeconvert',num2str(section)],...
            'filter',-1,hdlsignaliscomplex(section_result.input),numChannels,...
            outputtcvtype,outputtcsltype);
            sections_arch.signals=[sections_arch.signals,makehdlsignaldecl(stagecast)];
            tempbody=hdldatatypeassignment(section_result.input,stagecast,productrounding,productsaturation);
            sections_arch.body_blocks=[sections_arch.body_blocks,tempbody];
            section_result.input=stagecast;
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



