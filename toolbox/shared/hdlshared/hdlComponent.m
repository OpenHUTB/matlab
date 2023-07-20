function hdl_arch=hdlComponent(instance_name,component_name,inputsignals,outputsignals,input_names,output_names,declare_component)











    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];

    hdl_arch.component_decl='';
    hdl_arch.component_config='';
    hdl_arch.body_component_instances='';

    if(declare_component)
        if hdlgetparameter('isverilog')


            [component_ports,component_declarations]=localVerilogComponentPorts(inputsignals,outputsignals,input_names,output_names);
        elseif hdlgetparameter('isvhdl')
            [component_ports,component_declarations]=localVhdlComponentPorts(inputsignals,outputsignals,input_names,output_names);
            hdl_arch.component_decl=[hdl_arch.component_decl,...
            '  COMPONENT ',component_name,'\n',...
            component_ports,...
            '    END COMPONENT;\n\n'];
            if hdlgetparameter('inline_configurations')
                hdl_arch.component_config=[hdl_arch.component_config,...
                '  FOR ALL : ',component_name,'\n',...
                '    USE ENTITY work.',component_name,'(rtl);\n\n'];
            end
        else
            error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
        end
    end


    if hdlgetparameter('isvhdl')
        instance=localvhdlinstance(instance_name,component_name,inputsignals,outputsignals,input_names,output_names);
    elseif hdlgetparameter('isverilog')
        instance=localveriloginstance(instance_name,component_name,inputsignals,outputsignals,input_names,output_names);
    end
    hdl_arch.body_component_instances=[hdl_arch.body_component_instances,instance];




    function[ports,declarations]=localVhdlComponentPorts(inputsignals,outputsignals,input_names,output_names)

        ports='   PORT( ';
        declarations='';
        firstone=1;
        portlist=[inputsignals,outputsignals];
        names=[input_names,output_names];
        for n=1:length(portlist)
            name=names{n};
            vtype=hdlsignalvtype(portlist(n));
            sltype=hdlsignalsltype(portlist(n));
            vector=hdlsignalvector(portlist(n));


            if strcmp(sltype,'boolean')
                comment='';
            else
                comment=[hdlgetparameter('comment_char'),' ',sltype];
            end

            if(n>length(inputsignals))
                portdir='OUT';
            else
                portdir='IN ';
            end

            if firstone
                ports=[ports,sprintf('%-32s:   %s   %s; %s\n',name,portdir,vtype,comment)];
                firstone=0;
            else
                ports=[ports,sprintf('         %-32s:   %s   %s; %s\n',name,portdir,vtype,comment)];
            end

        end


        lastsemi=find(ports==';');
        ports(lastsemi(end))=' ';

        ports=[ports,'         );\n'];



        function[ports,declarations]=localVerilogComponentPorts(inputsignals,outputsignals,input_names,output_names)

            ports='\n               (\n                ';
            declarations='';

            portlist=[inputsignals,outputsignals];
            names=[input_names,output_names];
            for n=1:length(portlist)
                name=names{n};
                vtype=hdlsignalvtype(portlist(n));
                sltype=hdlsignalsltype(portlist(n));
                vector=hdlsignalvector(portlist(n));
                [size,bp,signed]=hdlwordsize(sltype);

                if size==0
                    vtype='wire [63:0]';
                end


                if strcmp(sltype,'boolean')
                    comment_str='';
                else
                    comment_str=[hdlgetparameter('comment_char'),sltype];
                end

                dtype='';
                lenvtype=length(vtype);
                if strcmp(vtype(1:3),'reg')&&lenvtype>4
                    dtype=vtype(4:end);
                elseif strcmp(vtype(1:4),'wire')&&lenvtype>5
                    dtype=vtype(5:end);
                end

                if(n>length(inputsignals))
                    declarations=[declarations,'  output'];
                else
                    declarations=[declarations,'  input '];
                end
                declarations=[declarations,...
                sprintf(' %s %s; %s\n',dtype,name,comment_str)];
                ports=[ports,name,',\n                '];
            end


            ports=[ports(1:end-19),'\n                );\n\n'];
            declarations=[declarations,'\n'];


            function instance=localveriloginstance(instance_name,component_name,inputsignals,outputsignals,input_names,output_names)

                portnames=[input_names,output_names];
                signalname=hdlsignalname([inputsignals,outputsignals]);
                portmap='';
                for n=1:length(portnames)
                    portmap=[portmap,...
                    '    .',portnames{n},'(',signalname{n},')',...
                    ',\n'];
                end
                portmap=portmap(1:end-3);

                instance=['  ',component_name,' ',instance_name,'\n',...
                '    (\n',...
                portmap,...
                '\n    );\n\n'];



                function instance=localvhdlinstance(instance_name,component_name,inputsignals,outputsignals,input_names,output_names)

                    portnames=[input_names,output_names];
                    signalname=hdlsignalname([inputsignals,outputsignals]);
                    portmap='';
                    for n=1:length(portnames)
                        portmap=[portmap,...
                        sprintf('              %-32s',portnames{n}),...
                        ' => ',signalname{n},',\n'];
                    end
                    portmap=portmap(1:end-3);

                    instance=['  ',instance_name,': ',component_name,'\n',...
                    '    PORT MAP (\n',...
                    portmap,...
                    '      );\n\n'];


