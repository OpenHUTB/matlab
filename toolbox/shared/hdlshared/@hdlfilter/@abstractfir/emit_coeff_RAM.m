function[hdl_arch,Coeff_output]=emit_coeff_RAM(this,clock,clock_enable,coeff_data_in,user_write_address,user_write_enable,coeffs_en,ce,pairs)














    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];
    hdl_arch.component_decl='';
    hdl_arch.component_config='';
    hdl_arch.body_component_instances='';
    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals=[indentedcomment,'  RAM Signals\n'];
    hdl_arch.body_blocks=[indentedcomment,' --------------------------- RAM Logic ------------------------\n\n'];
    hdl_arch.body_output_assignments='';

    fl=getfilterlengths(this);
    firlen=fl.firlen;
    coeff_len=fl.coeff_len;

    bdt=hdlgetparameter('base_data_type');



    count_j=0;
    RAM_implementation_matrix=[0,0];
    Section_matrix=[];
    RAM_address_map=[];
    RAM_address_number=[];
    for count_i=1:numel(pairs)
        if(count_i==1)&&strcmpi(this.Implementation,'serialcascade')
            Section_matrix(count_i,:)=pairs{count_i};

            Section_matrix(1,1)=Section_matrix(1,1)-1;
            RAM_address_map=[RAM_address_map,0:(pairs{1}(1)-2)];
            RAM_address_number=[RAM_address_number,(pairs{1}(1)-1)];
        else
            Section_matrix(count_i,:)=pairs{count_i};
            RAM_address_map=[RAM_address_map,repmat(0:(pairs{count_i}(1)-1),[1,pairs{count_i}(2)])];
            RAM_address_number=[RAM_address_number,repmat(pairs{count_i}(1),[1,pairs{count_i}(2)])];
        end
        RAM_size=2.^ceil(log2(pairs{count_i}(1)));
        Index=ismember(RAM_implementation_matrix(:,1),RAM_size);
        if(any(Index))
            RAM_implementation_matrix(Index,2)=RAM_implementation_matrix(Index,2)+pairs{count_i}(2);
        else
            count_j=count_j+1;
            RAM_implementation_matrix(count_j,:)=[RAM_size,pairs{count_i}(2)];
        end
    end


    [number_of_RAM_types,cols]=size(RAM_implementation_matrix);
    clear cols;
    RAM_count=0;

    RAM_logic_output=zeros(1,sum(RAM_implementation_matrix(:,2)));
    RAM_write_enable=zeros(1,sum(RAM_implementation_matrix(:,2)));
    RAM_select=zeros(1,sum(RAM_implementation_matrix(:,2)));
    addr_bits=zeros(1,sum(RAM_implementation_matrix(:,2)));
    RAM_logic_write_address=zeros(1,sum(RAM_implementation_matrix(:,2)));
    RAM_logic_read_address=zeros(1,sum(RAM_implementation_matrix(:,2)));

    for count_i=1:number_of_RAM_types
        for count_j=1:RAM_implementation_matrix(count_i,2)
            RAM_count=RAM_count+1;


            logic_outputsltype=hdlsignalsltype(coeff_data_in);
            [output_insize,output_inbp,output_insigned]=hdlgetsizesfromtype(logic_outputsltype);

            logic_outputvtype=hdlgettypesfromsizes(output_insize,output_inbp,output_insigned);

            [~,RAM_logic_output(RAM_count)]=hdlnewsignal(['RAM_',num2str(RAM_count),'_logic_output'],'filter',-1,0,0,logic_outputvtype,logic_outputsltype);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(RAM_logic_output(RAM_count))];


            if(sum(RAM_implementation_matrix(:,2))>1)
                [~,RAM_select(RAM_count)]=hdlnewsignal(['Coeff_RAM_',num2str(RAM_count),'_select'],'filter',-1,0,0,bdt,'boolean');
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(RAM_select(RAM_count))];
            end

            [~,RAM_write_enable(RAM_count)]=hdlnewsignal(['Coeff_RAM_',num2str(RAM_count),'_write_enable'],'filter',-1,0,0,bdt,'boolean');
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(RAM_write_enable(RAM_count))];


            addr_bits(RAM_count)=max(log2(RAM_implementation_matrix(count_i,1)),1);

            [wraddrvtype,wraddrsltype]=hdlgettypesfromsizes(addr_bits(RAM_count),0,0);
            [~,RAM_logic_write_address(RAM_count)]=hdlnewsignal(['RAM_',num2str(RAM_count),'_logic_write_address'],'filter',-1,0,0,wraddrvtype,wraddrsltype);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(RAM_logic_write_address(RAM_count))];


            [~,RAM_logic_read_address(RAM_count)]=hdlnewsignal(['RAM_',num2str(RAM_count),'_logic_read_address'],'filter',-1,0,0,wraddrvtype,wraddrsltype);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(RAM_logic_read_address(RAM_count))];
        end
    end
    clear RAM_count;






    if(sum(RAM_implementation_matrix(:,2))>1)







        [~,translated_ram_write_address]=hdlnewsignal('translated_ram_write_address','filter',-1,0,0,hdlsignalvtype(RAM_logic_write_address(1)),hdlsignalsltype(RAM_logic_write_address(1)));
        hdlregsignal(translated_ram_write_address);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(translated_ram_write_address)];



        [translate_body,translate_signals,translate_constants]=hdllookuptable(user_write_address,translated_ram_write_address,...
        [0:(sum(Section_matrix(:,1).*Section_matrix(:,2))-1)],...
        RAM_address_map);

        hdl_arch.signals=[hdl_arch.signals,translate_signals];
        hdl_arch.constants=[hdl_arch.constants,translate_constants];
        hdl_arch.body_blocks=[hdl_arch.body_blocks,translate_body];
    elseif(sum(RAM_implementation_matrix(:,2))==1)
        translated_ram_write_address=user_write_address;
    end



    RAM_count=0;
    counter_slice_body_total='';
    address_slice_body_total='';
    ram_sel_body_total='';
    ram_en_body_total='';
    last_lower_bound=0;
    for count_i=1:number_of_RAM_types
        for count_j=1:RAM_implementation_matrix(count_i,2)
            RAM_count=RAM_count+1;

            address_slice_body=hdldatatypeassignment(translated_ram_write_address,RAM_logic_write_address(RAM_count),'fix',0);
            address_slice_body_total=[address_slice_body_total,address_slice_body];

            if(sum(RAM_implementation_matrix(:,2))>1)
                if(RAM_count==1)
                    ram_sel_body=hdlcompareval(user_write_address,RAM_select(RAM_count),'<',RAM_address_number(RAM_count));
                    ram_sel_body_total=[ram_sel_body_total,ram_sel_body];
                    last_lower_bound=RAM_select(RAM_count);
                elseif(RAM_count==sum(RAM_implementation_matrix(:,2)))
                    ram_sel_body=hdlcompareval(user_write_address,RAM_select(RAM_count),'>=',sum(RAM_address_number(1:RAM_count-1)));
                    ram_sel_body_total=[ram_sel_body_total,ram_sel_body];
                else
                    [~,last_lower_bound_bar]=hdlnewsignal(['address_compare_',num2str(RAM_count-1),'_bar'],'filter',-1,0,0,bdt,'boolean');
                    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(last_lower_bound_bar)];
                    ram_sel_body=hdlbitop(last_lower_bound,last_lower_bound_bar,'NOT');
                    ram_sel_body_total=[ram_sel_body_total,ram_sel_body];
                    [~,new_lower_bound]=hdlnewsignal(['address_compare_',num2str(RAM_count)],'filter',-1,0,0,bdt,'boolean');
                    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(new_lower_bound)];
                    ram_sel_body=hdlcompareval(user_write_address,new_lower_bound,'<',sum(RAM_address_number(1:RAM_count)));
                    ram_sel_body_total=[ram_sel_body_total,ram_sel_body];
                    ram_sel_body=hdlbitop([last_lower_bound_bar,new_lower_bound],RAM_select(RAM_count),'AND');
                    ram_sel_body_total=[ram_sel_body_total,ram_sel_body];
                    last_lower_bound=new_lower_bound;
                end

                ram_en_body=hdlbitop([user_write_enable,RAM_select(RAM_count)],RAM_write_enable(RAM_count),'AND');
                ram_en_body_total=[ram_en_body_total,ram_en_body];
            else

                ram_en_body=hdlsignalassignment(user_write_enable,RAM_write_enable(RAM_count));
                ram_en_body_total=[ram_en_body_total,ram_en_body];
            end


            counter_slice_body=hdldatatypeassignment(ce.ram_out,RAM_logic_read_address(RAM_count),'fix',0);
            counter_slice_body_total=[counter_slice_body_total,counter_slice_body];
        end
    end

    RAM_comment=[indentedcomment,'  ----- RAM_logic_write_address (Address Translation Logic) ------ \n\n'];
    hdl_arch.body_blocks=[hdl_arch.body_blocks,RAM_comment];
    hdl_arch.body_blocks=[hdl_arch.body_blocks,address_slice_body_total];
    RAM_comment=[indentedcomment,'  ----- RAM_logic_write_enable ------ \n\n'];
    hdl_arch.body_blocks=[hdl_arch.body_blocks,RAM_comment];
    hdl_arch.body_blocks=[hdl_arch.body_blocks,ram_sel_body_total];
    hdl_arch.body_blocks=[hdl_arch.body_blocks,ram_en_body_total];
    RAM_comment=[indentedcomment,'  ----- RAM_logic_read_address ------ \n\n'];
    hdl_arch.body_blocks=[hdl_arch.body_blocks,RAM_comment];
    hdl_arch.body_blocks=[hdl_arch.body_blocks,counter_slice_body_total];




    data_in_sltype=hdlsignalsltype(coeff_data_in);
    [data_in_insize,data_in_inbp,data_in_insigned]=hdlgetsizesfromtype(data_in_sltype);

    RAM_comment=[indentedcomment,'  ----- Generating Coeff_RAM_data_in ------ \n\n'];
    hdl_arch.body_blocks=[hdl_arch.body_blocks,RAM_comment];

    if hdlgetparameter('filter_input_type_std_logic')==1

        data_in_vtype=hdlgetporttypesfromsizes(data_in_insize,data_in_inbp,data_in_insigned);
        [~,Coeff_RAM_data_in]=hdlnewsignal(['Coeff_RAM_data_in'],'filter',-1,0,0,data_in_vtype,data_in_sltype);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(Coeff_RAM_data_in)];
        if~strcmpi(hdlsignalvtype(coeff_data_in),data_in_vtype)

            hdl_typecovert=hdlfinalassignment(coeff_data_in,Coeff_RAM_data_in);
            hdl_arch.body_blocks=[hdl_arch.body_blocks,hdl_typecovert];
        else
            hdl_assignment=hdlsignalassignment(coeff_data_in,Coeff_RAM_data_in);
            hdl_arch.body_blocks=[hdl_arch.body_blocks,hdl_assignment];
        end
    else

        data_in_vtype=hdlgettypesfromsizes(data_in_insize,data_in_inbp,data_in_insigned);


        [~,Coeff_RAM_data_in]=hdlnewsignal(['Coeff_RAM_data_in'],'filter',-1,0,0,data_in_vtype,data_in_sltype);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(Coeff_RAM_data_in)];
        hdl_typecovert=hdldatatypeassignment(coeff_data_in,Coeff_RAM_data_in,this.RoundMode,this.OverflowMode);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,hdl_typecovert];
    end









































































































































































    RAM_comment=[indentedcomment,'  ----- Shadow_RAM_select logic (For Shadow Functionality) ------ \n\n'];
    hdl_arch.body_blocks=[hdl_arch.body_blocks,RAM_comment];
    [~,Shadow_RAM_address_select]=hdlnewsignal('Shadow_RAM_address_select','filter',-1,0,0,bdt,'boolean');
    hdlregsignal(Shadow_RAM_address_select);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(Shadow_RAM_address_select)];
    [~,Shadow_RAM_address_select_bar]=hdlnewsignal('Shadow_RAM_address_select_bar','filter',-1,0,0,bdt,'boolean');
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(Shadow_RAM_address_select_bar)];
    shadow_select_bar_body=hdlbitop(Shadow_RAM_address_select,Shadow_RAM_address_select_bar,'NOT');
    hdl_arch.body_blocks=[hdl_arch.body_blocks,shadow_select_bar_body];
    [~,Shadow_RAM_address_select_mux]=hdlnewsignal('Shadow_RAM_address_select_mux','filter',-1,0,0,bdt,'boolean');
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(Shadow_RAM_address_select_mux)];
    shadow_select_mux_body=hdlmux([Shadow_RAM_address_select_bar,Shadow_RAM_address_select],Shadow_RAM_address_select_mux,coeffs_en,{'='},1,'when-else');
    hdl_arch.body_blocks=[hdl_arch.body_blocks,shadow_select_mux_body];



    if strcmpi(hdlgetparameter('filter_storage_type'),'SingleportRAMs')



        [~,Shadow_RAM_output_select]=hdlnewsignal('Shadow_RAM_output_select','filter',-1,0,0,bdt,'boolean');
        hdlregsignal(Shadow_RAM_output_select);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(Shadow_RAM_output_select)];

        [shregs_bdy,tempsignals]=hdlunitdelay([Shadow_RAM_address_select_mux,Shadow_RAM_address_select],[Shadow_RAM_address_select,Shadow_RAM_output_select],...
        ['Shadow_Select_register',hdlgetparameter('clock_process_label')],[0,0]);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,shregs_bdy];
        hdl_arch.signals=[hdl_arch.signals,tempsignals];




        for count_i=1:number_of_RAM_types
            hRam(count_i)=hdl.singlePortRam('entityName',[hdlgetparameter('filter_name'),'_RAM_type_',num2str(count_i)],'fullFileName',[hdlGetCodegendir,'/',hdlgetparameter('filter_name'),'_RAM_type_',num2str(count_i),hdlgetparameter('filename_suffix')]);
        end

        RAM_count=0;
        RAM_write_enable_A=0;
        RAM_write_enable_B=0;
        RAM_logic_address_A=zeros(1,sum(RAM_implementation_matrix(:,2)));
        RAM_logic_address_B=zeros(1,sum(RAM_implementation_matrix(:,2)));
        RAM_address_A=zeros(1,sum(RAM_implementation_matrix(:,2)));
        RAM_address_B=zeros(1,sum(RAM_implementation_matrix(:,2)));
        RAM_output_A=zeros(1,sum(RAM_implementation_matrix(:,2)));
        RAM_output_B=zeros(1,sum(RAM_implementation_matrix(:,2)));
        RAM_logic_output_A=zeros(1,sum(RAM_implementation_matrix(:,2)));
        RAM_logic_output_B=zeros(1,sum(RAM_implementation_matrix(:,2)));
        out_typeconvert='';
        out_write_enable='';
        RAM_comment=[indentedcomment,'  ----- Coeff_RAM_read_address and Coeff_RAM_write_address (Muxing to determine target RAM) ------ \n\n'];
        hdl_arch.body_blocks=[hdl_arch.body_blocks,RAM_comment];

        for count_i=1:number_of_RAM_types
            for count_j=1:RAM_implementation_matrix(count_i,2)
                RAM_count=RAM_count+1;




                addr_bits(RAM_count)=max(log2(RAM_implementation_matrix(count_i,1)),1);
                if hdlgetparameter('filter_input_type_std_logic')==1
                    [wraddrvtype,wraddrsltype]=hdlgetporttypesfromsizes(addr_bits(RAM_count),0,0);
                else
                    [wraddrvtype,wraddrsltype]=hdlgettypesfromsizes(addr_bits(RAM_count),0,0);
                end
                [~,RAM_logic_address_A(RAM_count)]=hdlnewsignal(['RAM_',num2str(RAM_count),'_logic_address_A'],'filter',-1,0,0,hdlsignalvtype(RAM_logic_write_address(RAM_count)),hdlsignalsltype(RAM_logic_write_address(RAM_count)));
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(RAM_logic_address_A(RAM_count))];
                [~,RAM_logic_address_B(RAM_count)]=hdlnewsignal(['RAM_',num2str(RAM_count),'_logic_address_B'],'filter',-1,0,0,hdlsignalvtype(RAM_logic_write_address(RAM_count)),hdlsignalsltype(RAM_logic_write_address(RAM_count)));
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(RAM_logic_address_B(RAM_count))];

                [~,RAM_address_A(RAM_count)]=hdlnewsignal(['Coeff_RAM_',num2str(RAM_count),'_address_A'],'filter',-1,0,0,wraddrvtype,wraddrsltype);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(RAM_address_A(RAM_count))];
                [~,RAM_address_B(RAM_count)]=hdlnewsignal(['Coeff_RAM_',num2str(RAM_count),'_address_B'],'filter',-1,0,0,wraddrvtype,wraddrsltype);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(RAM_address_B(RAM_count))];


                addr_mux_A_bdy=hdlmux([RAM_logic_read_address(RAM_count),RAM_logic_write_address(RAM_count)],RAM_logic_address_A(RAM_count),Shadow_RAM_address_select,{'='},1,'when-else');
                hdl_arch.body_blocks=[hdl_arch.body_blocks,addr_mux_A_bdy];
                addr_mux_B_bdy=hdlmux([RAM_logic_write_address(RAM_count),RAM_logic_read_address(RAM_count)],RAM_logic_address_B(RAM_count),Shadow_RAM_address_select,{'='},1,'when-else');
                hdl_arch.body_blocks=[hdl_arch.body_blocks,addr_mux_B_bdy];


                if hdlgetparameter('filter_input_type_std_logic')==1
                    if~strcmpi(hdlsignalvtype(RAM_logic_address_A(RAM_count)),wraddrvtype)

                        hdl_typecovert=hdlfinalassignment(RAM_logic_address_A(RAM_count),RAM_address_A(RAM_count));
                        hdl_arch.body_blocks=[hdl_arch.body_blocks,hdl_typecovert];
                        hdl_typecovert=hdlfinalassignment(RAM_logic_address_B(RAM_count),RAM_address_B(RAM_count));
                        hdl_arch.body_blocks=[hdl_arch.body_blocks,hdl_typecovert];

                    else
                        hdl_assignment=hdlsignalassignment(RAM_logic_address_A(RAM_count),RAM_address_A(RAM_count));
                        hdl_arch.body_blocks=[hdl_arch.body_blocks,hdl_assignment];
                        hdl_assignment=hdlsignalassignment(RAM_logic_address_B(RAM_count),RAM_address_B(RAM_count));
                        hdl_arch.body_blocks=[hdl_arch.body_blocks,hdl_assignment];
                    end
                else
                    hdl_typecovert=hdldatatypeassignment(RAM_logic_address_A(RAM_count),RAM_address_A(RAM_count),this.RoundMode,this.OverflowMode);
                    hdl_arch.body_blocks=[hdl_arch.body_blocks,hdl_typecovert];
                    hdl_typecovert=hdldatatypeassignment(RAM_logic_address_B(RAM_count),RAM_address_B(RAM_count),this.RoundMode,this.OverflowMode);
                    hdl_arch.body_blocks=[hdl_arch.body_blocks,hdl_typecovert];
                end



                outputsltype=hdlsignalsltype(coeff_data_in);
                [output_insize,output_inbp,output_insigned]=hdlgetsizesfromtype(outputsltype);
                if hdlgetparameter('filter_output_type_std_logic')==1

                    outputvtype=hdlgetporttypesfromsizes(output_insize,output_inbp,output_insigned);
                else

                    outputvtype=hdlgettypesfromsizes(output_insize,output_inbp,output_insigned);
                end

                [~,RAM_output_A(RAM_count)]=hdlnewsignal(['Coeff_RAM_',num2str(RAM_count),'_output_A'],'filter',-1,0,0,outputvtype,outputsltype);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(RAM_output_A(RAM_count))];
                [~,RAM_output_B(RAM_count)]=hdlnewsignal(['Coeff_RAM_',num2str(RAM_count),'_output_B'],'filter',-1,0,0,outputvtype,outputsltype);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(RAM_output_B(RAM_count))];
                [~,RAM_logic_output_A(RAM_count)]=hdlnewsignal(['RAM_',num2str(RAM_count),'_logic_output_A'],'filter',-1,0,0,hdlsignalvtype(RAM_logic_output(RAM_count)),hdlsignalsltype(RAM_logic_output(RAM_count)));
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(RAM_logic_output_A(RAM_count))];
                [~,RAM_logic_output_B(RAM_count)]=hdlnewsignal(['RAM_',num2str(RAM_count),'_logic_output_B'],'filter',-1,0,0,hdlsignalvtype(RAM_logic_output(RAM_count)),hdlsignalsltype(RAM_logic_output(RAM_count)));
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(RAM_logic_output_B(RAM_count))];

                output_mux_bdy=hdlmux([RAM_logic_output_A(RAM_count),RAM_logic_output_B(RAM_count)],RAM_logic_output(RAM_count),Shadow_RAM_output_select,{'='},1,'when-else');
                out_typeconvert=[out_typeconvert,output_mux_bdy];

                if(strcmpi(hdlsignalvtype(RAM_logic_output_A(RAM_count)),hdlsignalvtype(RAM_output_A(RAM_count)))==1)
                    hdl_out_typecovert=hdlsignalassignment(RAM_output_A(RAM_count),RAM_logic_output_A(RAM_count));
                    out_typeconvert=[out_typeconvert,hdl_out_typecovert];
                    hdl_out_typecovert=hdlsignalassignment(RAM_output_B(RAM_count),RAM_logic_output_B(RAM_count));
                    out_typeconvert=[out_typeconvert,hdl_out_typecovert];
                elseif(hdlgetparameter('filter_output_type_std_logic')==1)
                    hdl_out_typecovert=hdldatatypeassignment(RAM_output_A(RAM_count),RAM_logic_output_A(RAM_count),this.RoundMode,this.OverflowMode);
                    out_typeconvert=[out_typeconvert,hdl_out_typecovert];
                    hdl_out_typecovert=hdldatatypeassignment(RAM_output_B(RAM_count),RAM_logic_output_B(RAM_count),this.RoundMode,this.OverflowMode);
                    out_typeconvert=[out_typeconvert,hdl_out_typecovert];
                else
                    hdl_out_typecovert=hdlfinalassignment(RAM_output_A(RAM_count),RAM_logic_output_A(RAM_count));
                    out_typeconvert=[out_typeconvert,hdl_out_typecovert];
                    hdl_out_typecovert=hdlfinalassignment(RAM_output_B(RAM_count),RAM_logic_output_B(RAM_count));
                    out_typeconvert=[out_typeconvert,hdl_out_typecovert];
                end

                [~,RAM_write_enable_A(RAM_count)]=hdlnewsignal(['Coeff_RAM_',num2str(RAM_count),'_write_enable_A'],'filter',-1,0,0,bdt,'boolean');
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(RAM_write_enable_A(RAM_count))];
                [~,RAM_write_enable_B(RAM_count)]=hdlnewsignal(['Coeff_RAM_',num2str(RAM_count),'_write_enable_B'],'filter',-1,0,0,bdt,'boolean');
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(RAM_write_enable_B(RAM_count))];
                out_write_enable_bdy=hdlbitop([RAM_write_enable(RAM_count),Shadow_RAM_address_select_bar],RAM_write_enable_A(RAM_count),'AND');
                out_write_enable=[out_write_enable,out_write_enable_bdy];
                out_write_enable_bdy=hdlbitop([RAM_write_enable(RAM_count),Shadow_RAM_address_select],RAM_write_enable_B(RAM_count),'AND');
                out_write_enable=[out_write_enable,out_write_enable_bdy];



                declare_component=0;
                if(count_j==1)

                    hdl_ram_type_code(count_i)=hRam(count_i).emit_ram(...
...
                    [clock,clock_enable,Coeff_RAM_data_in,RAM_address_A(RAM_count),RAM_write_enable_A(RAM_count)],...
...
                    RAM_output_A(RAM_count),...
...
...
                    [hdlsignalname([clock,clock_enable]),{'data_in','address','write_enable'}],...
...
'data_out'...
                    );
                    declare_component=1;
                end

                hdl_ram_code_A(RAM_count)=hdlComponent(...
...
                ['Coeff_RAM_',num2str(RAM_count),'_A'],...
...
                hdl_ram_type_code(count_i).component_name,...
...
                [clock,clock_enable,Coeff_RAM_data_in,RAM_address_A(RAM_count),RAM_write_enable_A(RAM_count)],...
...
                RAM_output_A(RAM_count),...
...
                [hdlsignalname([clock,clock_enable]),{'data_in','address','write_enable'}],...
...
                {'data_out'},...
...
declare_component...
                );

                hdl_ram_code_B(RAM_count)=hdlComponent(...
...
                ['Coeff_RAM_',num2str(RAM_count),'_B'],...
...
                hdl_ram_type_code(count_i).component_name,...
...
                [clock,clock_enable,Coeff_RAM_data_in,RAM_address_B(RAM_count),RAM_write_enable_B(RAM_count)],...
...
                RAM_output_B(RAM_count),...
...
                [hdlsignalname([clock,clock_enable]),{'data_in','address','write_enable'}],...
...
                {'data_out'},...
...
0...
                );

                hdl_arch.component_decl=[hdl_arch.component_decl,hdl_ram_code_A(RAM_count).component_decl,hdl_ram_code_B(RAM_count).component_decl];
                hdl_arch.component_config=[hdl_arch.component_config,hdl_ram_code_A(RAM_count).component_config,hdl_ram_code_B(RAM_count).component_config];
                hdl_arch.body_component_instances=[hdl_arch.body_component_instances,hdl_ram_code_A(RAM_count).body_component_instances,hdl_ram_code_B(RAM_count).body_component_instances];
            end
        end

        RAM_comment=[indentedcomment,'  ----- Passing Write Enable to correct RAM ------ \n\n'];
        hdl_arch.body_blocks=[hdl_arch.body_blocks,RAM_comment];
        hdl_arch.body_blocks=[hdl_arch.body_blocks,out_write_enable];

        RAM_comment=[indentedcomment,'  ----- Choose correct RAM outputs (Typeconvert RAM outputs,if needed) ------ \n\n'];
        hdl_arch.body_blocks=[hdl_arch.body_blocks,RAM_comment];
        hdl_arch.body_blocks=[hdl_arch.body_blocks,out_typeconvert];

        Coeff_output=[];
        RAM_count=0;

        [number_of_section_types,cols]=size(Section_matrix);
        for count_i=1:number_of_section_types
            for count_j=1:Section_matrix(count_i,2)
                RAM_count=RAM_count+1;

                Coeff_output=[Coeff_output,repmat(RAM_logic_output(RAM_count),[1,Section_matrix(count_i,1)])];

            end
        end




    elseif strcmpi(hdlgetparameter('filter_storage_type'),'DualportRAMs')


        [shregs_bdy,tempsignals]=hdlunitdelay(Shadow_RAM_address_select_mux,Shadow_RAM_address_select,...
        ['Shadow_Select_register',hdlgetparameter('clock_process_label')],0);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,shregs_bdy];
        hdl_arch.signals=[hdl_arch.signals,tempsignals];




        for count_i=1:number_of_RAM_types
            hRam(count_i)=hdl.simpleDualPortRam('entityName',[hdlgetparameter('filter_name'),'_RAM_type_',num2str(count_i)],'fullFileName',[hdlGetCodegendir,'/',hdlgetparameter('filter_name'),'_RAM_type_',num2str(count_i),hdlgetparameter('filename_suffix')]);
        end

        RAM_count=0;


        RAM_concat_write_address=zeros(1,sum(RAM_implementation_matrix(:,2)));
        RAM_concat_read_address=zeros(1,sum(RAM_implementation_matrix(:,2)));
        RAM_write_address=zeros(1,sum(RAM_implementation_matrix(:,2)));
        RAM_read_address=zeros(1,sum(RAM_implementation_matrix(:,2)));




        out_typeconvert='';
        RAM_comment=[indentedcomment,'  ----- Coeff_RAM_read_address and Coeff_RAM_write_address (Adding MSB from Shadow Select logic) ------ \n\n'];
        hdl_arch.body_blocks=[hdl_arch.body_blocks,RAM_comment];

        for count_i=1:number_of_RAM_types
            for count_j=1:RAM_implementation_matrix(count_i,2)
                RAM_count=RAM_count+1;




                addr_bits(RAM_count)=max(log2(RAM_implementation_matrix(count_i,1)),1)+1;
                [concat_wraddrvtype,concat_wraddrsltype]=hdlgettypesfromsizes(addr_bits(RAM_count),0,0);

                if hdlgetparameter('filter_input_type_std_logic')==1
                    [wraddrvtype,wraddrsltype]=hdlgetporttypesfromsizes(addr_bits(RAM_count),0,0);
                else
                    wraddrvtype=concat_wraddrvtype;
                    wraddrsltype=concat_wraddrsltype;
                end
                [~,RAM_concat_write_address(RAM_count)]=hdlnewsignal(['RAM_',num2str(RAM_count),'_concat_write_address'],'filter',-1,0,0,concat_wraddrvtype,concat_wraddrsltype);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(RAM_concat_write_address(RAM_count))];
                [~,RAM_concat_read_address(RAM_count)]=hdlnewsignal(['RAM_',num2str(RAM_count),'_concat_read_address'],'filter',-1,0,0,concat_wraddrvtype,concat_wraddrsltype);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(RAM_concat_read_address(RAM_count))];

                [~,RAM_write_address(RAM_count)]=hdlnewsignal(['Coeff_RAM_',num2str(RAM_count),'_write_address'],'filter',-1,0,0,wraddrvtype,wraddrsltype);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(RAM_write_address(RAM_count))];
                [~,RAM_read_address(RAM_count)]=hdlnewsignal(['Coeff_RAM_',num2str(RAM_count),'_read_address'],'filter',-1,0,0,wraddrvtype,wraddrsltype);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(RAM_read_address(RAM_count))];

                concat_read=hdlsliceconcat([Shadow_RAM_address_select_bar,RAM_logic_read_address(RAM_count)],{[],[]},RAM_concat_read_address(RAM_count));
                hdl_arch.body_blocks=[hdl_arch.body_blocks,concat_read];
                concat_write=hdlsliceconcat([Shadow_RAM_address_select,RAM_logic_write_address(RAM_count)],{[],[]},RAM_concat_write_address(RAM_count));
                hdl_arch.body_blocks=[hdl_arch.body_blocks,concat_write];


                if hdlgetparameter('filter_input_type_std_logic')==1
                    if~strcmpi(concat_wraddrvtype,wraddrvtype)

                        hdl_typecovert=hdlfinalassignment(RAM_concat_write_address(RAM_count),RAM_write_address(RAM_count));
                        hdl_arch.body_blocks=[hdl_arch.body_blocks,hdl_typecovert];
                        hdl_typecovert=hdlfinalassignment(RAM_concat_read_address(RAM_count),RAM_read_address(RAM_count));
                        hdl_arch.body_blocks=[hdl_arch.body_blocks,hdl_typecovert];

                    else
                        hdl_assignment=hdlsignalassignment(RAM_concat_write_address(RAM_count),RAM_write_address(RAM_count));
                        hdl_arch.body_blocks=[hdl_arch.body_blocks,hdl_assignment];
                        hdl_assignment=hdlsignalassignment(RAM_concat_read_address(RAM_count),RAM_read_address(RAM_count));
                        hdl_arch.body_blocks=[hdl_arch.body_blocks,hdl_assignment];
                    end
                else
                    hdl_typecovert=hdldatatypeassignment(RAM_concat_write_address(RAM_count),RAM_write_address(RAM_count),this.RoundMode,this.OverflowMode);
                    hdl_arch.body_blocks=[hdl_arch.body_blocks,hdl_typecovert];
                    hdl_typecovert=hdldatatypeassignment(RAM_concat_read_address(RAM_count),RAM_read_address(RAM_count),this.RoundMode,this.OverflowMode);
                    hdl_arch.body_blocks=[hdl_arch.body_blocks,hdl_typecovert];
                end



                outputsltype=hdlsignalsltype(coeff_data_in);
                [output_insize,output_inbp,output_insigned]=hdlgetsizesfromtype(outputsltype);
                if hdlgetparameter('filter_output_type_std_logic')==1

                    outputvtype=hdlgetporttypesfromsizes(output_insize,output_inbp,output_insigned);
                else

                    outputvtype=hdlgettypesfromsizes(output_insize,output_inbp,output_insigned);
                end

                [~,RAM_output(RAM_count)]=hdlnewsignal(['Coeff_RAM_',num2str(RAM_count),'_output'],'filter',-1,0,0,outputvtype,outputsltype);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(RAM_output(RAM_count))];

                if(strcmpi(hdlsignalvtype(RAM_logic_output(RAM_count)),hdlsignalvtype(RAM_output(RAM_count)))==1)
                    hdl_out_typecovert=hdlsignalassignment(RAM_output(RAM_count),RAM_logic_output(RAM_count));
                    out_typeconvert=[out_typeconvert,hdl_out_typecovert];
                elseif(hdlgetparameter('filter_output_type_std_logic')==1)
                    hdl_out_typecovert=hdldatatypeassignment(RAM_output(RAM_count),RAM_logic_output(RAM_count),this.RoundMode,this.OverflowMode);
                    out_typeconvert=[out_typeconvert,hdl_out_typecovert];
                else
                    hdl_out_typecovert=hdlfinalassignment(RAM_output(RAM_count),RAM_logic_output(RAM_count));
                    out_typeconvert=[out_typeconvert,hdl_out_typecovert];
                end


                declare_component=0;
                if(count_j==1)

                    hdl_ram_type_code(count_i)=hRam(count_i).emit_ram(...
...
                    [clock,clock_enable,Coeff_RAM_data_in,RAM_write_address(RAM_count),RAM_write_enable(RAM_count),RAM_read_address(RAM_count)],...
...
                    RAM_output(RAM_count),...
...
...
                    [hdlsignalname([clock,clock_enable]),{'data_in','write_address','write_enable','read_address'}],...
...
'read_data_out'...
                    );
                    declare_component=1;
                end

                hdl_ram_code(RAM_count)=hdlComponent(...
...
                ['Coeff_RAM_',num2str(RAM_count)],...
...
                hdl_ram_type_code(count_i).component_name,...
...
                [clock,clock_enable,Coeff_RAM_data_in,RAM_write_address(RAM_count),RAM_write_enable(RAM_count),RAM_read_address(RAM_count)],...
...
                RAM_output(RAM_count),...
...
                [hdlsignalname([clock,clock_enable]),{'data_in','write_address','write_enable','read_address'}],...
...
                {'read_data_out'},...
...
declare_component...
                );

                hdl_arch.component_decl=[hdl_arch.component_decl,hdl_ram_code(RAM_count).component_decl];
                hdl_arch.component_config=[hdl_arch.component_config,hdl_ram_code(RAM_count).component_config];
                hdl_arch.body_component_instances=[hdl_arch.body_component_instances,hdl_ram_code(RAM_count).body_component_instances];
            end
        end

        RAM_comment=[indentedcomment,'  ----- Choose correct RAM outputs (Typeconvert RAM outputs,if needed) ------ \n\n'];
        hdl_arch.body_blocks=[hdl_arch.body_blocks,RAM_comment];
        hdl_arch.body_blocks=[hdl_arch.body_blocks,out_typeconvert];

        Coeff_output=[];
        RAM_count=0;

        [number_of_section_types,cols]=size(Section_matrix);
        for count_i=1:number_of_section_types
            for count_j=1:Section_matrix(count_i,2)
                RAM_count=RAM_count+1;

                Coeff_output=[Coeff_output,repmat(RAM_logic_output(RAM_count),[1,Section_matrix(count_i,1)])];

            end
        end
    end
    hdl_arch.signals=[hdl_arch.signals,indentedcomment,'  RAM Signals End\n'];
    hdl_arch.body_blocks=[hdl_arch.body_blocks,indentedcomment,' --------------------------- RAM Logic Ends------------------------\n\n'];
end







