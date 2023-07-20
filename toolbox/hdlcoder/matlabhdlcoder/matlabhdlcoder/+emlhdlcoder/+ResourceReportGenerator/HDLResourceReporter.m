classdef HDLResourceReporter<hdlcodingstd.HTMLReporter



    properties(Access=private)
        hPir;
        hHDLDriver;
        hTopFunctionName;
characHandle
    end
    properties(Constant,Access=private)
        reportTitle='Coder:hdl:resrpt_TitleForDesign';
    end

    methods


        function this=HDLResourceReporter(varargin)
            this.hTopFunctionName=varargin{1};
            this.hHDLDriver=hdlcurrentdriver;
            this.hPir=this.hHDLDriver.PirInstance;
            this.characHandle=[];
        end


        function hdlDrv=getHDLDriver(~)
            hdlDrv=this.hHDLDriver;
        end




        function beginBody(this,fid,fcnName)
            i18nstr=message('Coder:hdl:resrpt_Title').getString();
            bodyTitle=sprintf('%s (''%s'')</H1>\n',i18nstr,fcnName);
            beginBody@hdlcodingstd.HTMLReporter(this,fid,bodyTitle);
            fprintf(fid,'<br /><H3><B> Summary </B></H3>');
        end


        function createResourceUtilSummaryTable(~,fid,entries)

            fprintf(fid,'%s','<DIV  class="content_container">');
            fprintf(fid,'%s','<TABLE class="table_header">');


            skip_fields={'I/O Pins_data','DynamicShifters','StaticShifters'};


            for n=1:length(entries)

                entry=entries{n};
                if any(strcmpi(skip_fields,entry{1}))
                    continue;
                end


                if mod(n,2)==0
                    fprintf(fid,'<TR style="background-color: #ffffff">\n');
                else
                    fprintf(fid,'<TR style="background-color: #eeeeff">\n');
                end

                fprintf(fid,'<TD style="border-style: none" ><H4>%s</H4></TD>\n',entry{1});
                fprintf(fid,'<TD style="border-style: none" ><H4>%d</H4></TD>\n',entry{2});
                fprintf(fid,'</TR>\n');
            end

            fprintf(fid,'</TABLE></DIV><br /><br />\n');
        end

        function createDetailedReport(this,p,fid)

            this.characHandle=hdlcoder.characterization.create;
            this.characHandle.doit(p);

            topNtk=p.getTopNetwork();

            ntks=p.Networks;

            for i=length(ntks):-1:1
                thisNtk=ntks(i);

                bom=this.characHandle.getBillOfMaterials(thisNtk);

                skip_bom=isempty(bom);
                isTopNetwork=isequal(topNtk.SimulinkHandle,thisNtk.SimulinkHandle)...
                &&isequal(topNtk.FullPath,thisNtk.FullPath);

                if~isTopNetwork&&skip_bom
                    continue;
                end

                if~skip_bom

                    this.emitBom(fid,'mul_comp',bom);


                    this.emitBom(fid,'addsub_comp',bom);


                    this.emitBom(fid,'reg_comp',bom);


                    this.emitBom(fid,'flipflops',bom);


                    this.emitBom(fid,'mem_comp',bom);


                    this.emitBom(fid,'mux_comp',bom);


                    this.emitBom(fid,'shifters',bom);
                end


                if isTopNetwork
                    [total_pin_count,port_info]=slhdlcoder.HDLTraceabilityDriver.calcIOPinsForDut(p);
                    this.emitPortInfo(fid,total_pin_count,port_info);
                end
            end
            hdlcoder.characterization.destroy(this.characHandle);
        end

        function emitPortInfo(this,fid,total_pin_count,port_info)%#ok<INUSL>
            function generatePortReport(port_data)
                numRows=length(port_data);
                for itr=1:numRows
                    port=port_data(itr);

                    if(port.isarray)
                        data_type=port_data(itr).datatype;%#ok<NASGU>
                        pin_count=port_data(itr).bitlength*port.numberofelements;
                    else
                        data_type=port.datatype;%#ok<NASGU>
                        pin_count=port.bitlength;
                    end

                    parts=strsplit(port.Name,'/');
                    if~isempty(parts)
                        port_Name=parts{end};
                    else
                        port_Name=port.Name;
                    end


                    if port.bitlength==1
                        io_output_string=sprintf('%s \t\t\t\t\t\t\t: %s %s',...
                        port_Name,num2str(pin_count),' bit');
                    else
                        io_output_string=sprintf('%s \t\t\t\t\t\t\t: %s %s',...
                        port_Name,num2str(pin_count),' bits');
                    end
                    fprintf(fid,['<li><H4> ',io_output_string,'</H4></li>\n']);
                end
            end

            header=message('Coder:hdl:resrpt_iobits').getString();
            fprintf(fid,['<h3>',header,' (',num2str(total_pin_count),')</h3>\n']);

            fprintf(fid,'<table>\n');
            fprintf(fid,'<tr><td align="center"></td>\n');



            input_bits=port_info.pin_count.inputs;
            fprintf(fid,'<td>');
            fprintf(fid,'<h3 style="background-color: #eeeeff">%s (%d)</h3>\n',message('Coder:hdl:resrpt_ipbits').getString(),input_bits);
            fprintf(fid,'<ul>');
            generatePortReport(port_info.inputs);
            fprintf(fid,'</ul>\n');
            fprintf(fid,'</td></tr>');
            fprintf(fid,'<tr><td align="center"></td>\n');


            output_bits=port_info.pin_count.outputs;
            fprintf(fid,'<td>');
            fprintf(fid,'<h3 style="background-color: #eeeeff">%s (%d)</h3>\n',message('Coder:hdl:resrpt_opbits').getString(),output_bits);
            fprintf(fid,'<ul>');
            generatePortReport(port_info.outputs);
            fprintf(fid,'</ul>\n');
            fprintf(fid,'</td></tr>');

            fprintf(fid,'</table>\n');
        end

        function emitBom(this,fid,compName,bom)
            switch compName
            case 'mul_comp'
                header='Multipliers';
                compInfoSetName={'mul_comp'};
                listingName={'Multiplier'};
            case 'addsub_comp'
                header='Adders/Subtractors';
                compInfoSetName={'add_comp','sub_comp'};
                listingName={'Adder','Subtractor'};
            case 'reg_comp'
                header='Registers';
                compInfoSetName={'reg_comp'};
                listingName={'Register'};
            case 'mem_comp'
                header='RAMs';
                compInfoSetName={'mem_comp'};
                listingName={'RAM'};
            case 'mux_comp'
                header='Multiplexers';
                compInfoSetName={'mux_comp'};
                listingName={'Multiplexer'};
            case 'flipflops'
                header='Flipflops';
                compInfoSetName={};
                listingName={'Flipflops'};
            case 'shifters'
                header='Shift operators';
                compInfoSetName={'dyn_left_shift_comp','dyn_right_shift_comp',...
                'static_left_shift_comp','static_right_shift_comp'};
                listingName={'Dynamic Left Shift operator','Dynamic Right Shift operator',...
                'Static Left Shift operator','Static Right Shift operator'};
            otherwise
                error('unexpected component type %s',compName)
            end

            switch(lower(compName))
            case 'flipflops'
                assert(~isempty(this.characHandle));
                totalComps=this.characHandle.getTotalFlipflops();
                compInfoSetName={};
            case 'shifters'
                totalComps=this.characHandle.getTotalShiftOps();
            otherwise
                totalComps=sum(cellfun(@(comp_type)bom.getTotalFrequency(comp_type),compInfoSetName));
            end

            if totalComps==0
                return
            end

            fprintf(fid,['<h3>',header,' (',num2str(totalComps),')</h3>\n']);
            fprintf(fid,'<ul>');

            for i=1:length(compInfoSetName)
                compInfoSet=bom.getCompInfoSet(compInfoSetName{i});

                for j=1:length(compInfoSet)
                    compInfo=compInfoSet(j);
                    formattedCompInfo=this.formatCompInfo(listingName{i},compInfo);
                    fprintf(fid,['<li><H4> ',formattedCompInfo,'</H4></li>\n']);
                end

            end

            if isempty(compInfoSetName)
                fprintf(fid,['<li><H4> ',message('hdlcoder:report:number_of_flipflops').getString(),' ',num2str(totalComps),'</H4></li>\n']);
            end
            fprintf(fid,'</ul>\n');
        end


        function formattedCompInfo=formatCompInfo(~,prefix,compInfo)
            numInputs=compInfo.getNumInputs;
            realType=false;
            for i=1:numInputs
                if compInfo.getInputBitwidth(i)==0
                    realType=true;
                    break;
                end
            end


            if(compInfo.getFrequency>1)
                prefix=[prefix,'s'];
            end

            if numInputs==1
                if realType

                    formattedCompInfo=sprintf('real %s \t\t\t\t\t\t\t: %s',...
                    prefix,num2str(compInfo.getFrequency));
                else
                    formattedCompInfo=sprintf('%s-bit %s \t\t\t\t\t\t\t: %s',...
                    num2str(compInfo.getInputBitwidth(1)),prefix,num2str(compInfo.getFrequency));
                end
                return;
            end

            if strfind(lower(prefix),'shift operator')
                if strfind(lower(prefix),'static')

                    formattedCompInfo=sprintf('%s \t\t\t\t\t\t\t: %s',...
                    prefix,num2str(compInfo.getFrequency));
                else

                    formattedCompInfo=sprintf('%s-bit %s \t\t\t\t\t\t\t: %s',...
                    num2str(compInfo.getInputBitwidth(1)),prefix,num2str(compInfo.getFrequency));
                end
                return
            end

            if realType
                if strfind(prefix,'Multiplexer')
                    formattedCompInfo=sprintf('real %s-to-1 Multiplexer \t\t\t\t\t\t\t: %s',...
                    num2str(compInfo.getInputBitwidth(1)),num2str(compInfo.getFrequency));
                    return;
                end

                formattedCompInfo='real ';
                for i=2:numInputs
                    formattedCompInfo=[formattedCompInfo,'x',' real '];%#ok<AGROW>
                end
                formattedCompInfo=sprintf('%s %s \t\t\t\t\t\t\t: %s',...
                formattedCompInfo,prefix,num2str(compInfo.getFrequency));
            else
                if strfind(prefix,'Multiplexer')
                    formattedCompInfo=sprintf('%s-bit %s-to-1 Multiplexer \t\t\t\t\t\t\t: %s',...
                    num2str(compInfo.getInputBitwidth(2)),num2str(compInfo.getInputBitwidth(1)),num2str(compInfo.getFrequency));
                    return;
                end
                bitwidth1=compInfo.getInputBitwidth(1);

                if strfind(prefix,'RAM')
                    bitwidth1=2.^bitwidth1;
                end
                formattedCompInfo=num2str(bitwidth1);

                for i=2:numInputs
                    formattedCompInfo=[formattedCompInfo,'x',num2str(compInfo.getInputBitwidth(i))];%#ok<AGROW>
                end
                formattedCompInfo=sprintf('%s-bit %s \t\t\t\t\t\t\t: %s',...
                formattedCompInfo,prefix,num2str(compInfo.getFrequency));
            end
        end


        function info=doIt(this)
            reportFname=[hdlgetparameter('module_prefix'),'resource_report.html'];
            cgDir=this.hHDLDriver.hdlGetCodegendir;
            fileName=fullfile(cgDir,reportFname);
            fid=fopen(fileName,'w','n','utf-8');

            if fid==-1
                error(message('hdlcoder:matlabhdlcoder:cannotopenfile',fileName));
            end

            link=sprintf('<a href="matlab:web(''%s'')">%s</a>',fileName,reportFname);


            disp(['### ',message('Coder:hdl:resrpt_Generating',link).getString()]);
            fcnName=this.hTopFunctionName;
            this.createHeader(fid,'%s',message(this.reportTitle,fcnName).getString());
            this.beginBody(fid,fcnName);

            p=this.hPir;
            info=getResourceInfo(p);

            this.createResourceUtilSummaryTable(fid,info);
            this.createDetailedReport(p,fid);

            endBody(this,fid);
            fclose(fid);

        end
    end
end



