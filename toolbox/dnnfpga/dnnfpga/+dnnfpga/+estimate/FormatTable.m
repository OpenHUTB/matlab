classdef FormatTable<handle




    methods(Static)
        function format=getPerformanceTableFormat()


            format.head='\n\n              <strong>Deep Learning Processor %s Performance Results</strong>\n\n';
            format.line='                         -------------             -------------              ---------        ---------       ---------\n';
            format.category='                   <strong>LastFrameLatency(cycles)   LastFrameLatency(seconds)       FramesNum      Total Latency     Frames/s</strong>\n';
            format.network='<strong>%-24s</strong> %9.0f        %17.5f           %13.0d %18.0d   %14.1f\n';
            format.txt='<strong>%-24s</strong> %9.0f        %17.5f \n';


            format.footnote=' * The clock frequency of the DL processor is: %dMHz\n\n\n';
        end

        function format=getResourceTableFormat()


            format.head='\n\n              <strong>Deep Learning Processor Estimator Resource Results</strong>\n\n';
            format.category='                             <strong>DSPs          Block RAM*     LUTs(CLB/ALUT)  </strong>\n';
            format.line='                        -------------    -------------    ------------- \n';
            format.category2='                             <strong>DSPs          Block RAM*     </strong>\n';
            format.line2='                        -------------    -------------    \n';
            format.total='<strong>%-17s</strong>%16.0f %16.0f    %13.0f\n';

            format.totalpct='<strong>%-17s</strong>%14.0f(%3.0f%%) %10.0f(%3.0f%%)    %7.0f(%3.0f%%)\n';
            format.txt='<strong>%-17s</strong>%19.0f %16.0f \t\t \n';


            msg=message('dnnfpga:dnnfpgadisp:BlockRAMFootnote','* Block RAM');
            format.footnote=strcat(msg.getString,'\n');
        end

        function format=getParsedInformationFormat()


            format.head='\n\n              <strong>Deep Learning Processor Bitstream Build Info</strong>\n\n';
            format.line='------------------        ----------      ------------    ------------\n';
            format.category='<strong>Resource                   Utilized           Total        Percentage</strong>\n';
            format.resource='<strong>%-24s</strong> %10.0f        %10.0f          %6.2f\n';
        end

        function printPerformanceTable(PerfomanceTable,format,name,freq,frames,totalLatency,fps)
            RowNames=PerfomanceTable.Row;
            if strcmp(name,'profiler')
                fprintf(format.head,'Profiler');
            elseif strcmp(name,'estimator')
                fprintf(format.head,'Estimator');
            end
            fprintf(format.category)
            fprintf(format.line);

            for i=1:length(RowNames)
                RowName=RowNames{i};
                isModule=RowName(1:4);
                switch isModule
                case '____'

                    latency=PerfomanceTable.('Latency(cycles)')(RowName);
                    latencys=PerfomanceTable.('Latency(seconds)')(RowName);
                    RowName=sprintf('    %s',RowName(5:end));
                    fprintf(format.txt,RowName,latency,latencys);
                otherwise
                    latency=PerfomanceTable.('Latency(cycles)')('Network');
                    latencys=PerfomanceTable.('Latency(seconds)')('Network');

                    fprintf(format.network,RowName,latency,latencys,frames,totalLatency,fps);
                end
            end
            fprintf(format.footnote,freq);
        end

        function printResourceTable(ResourceTable,format,verbosity,resource,available)
            RowNames=ResourceTable.Row;
            fprintf(format.head)
            fprintf(format.category)
            fprintf(format.line);
            if(available)
                fprintf(format.total,"Available",resource.TotalDSP,...
                resource.TotalRAM,resource.TotalLUT);
                fprintf(format.line);
            end

            for i=1:length(RowNames)
                RowName=RowNames{i};
                isModule=RowName(1:4);
                switch isModule
                case '____'
                    if(verbosity>1)
                        DSP=ResourceTable.('DSP')(RowName);
                        blockRAM=ResourceTable.('blockRAM')(RowName);
                        RowName=sprintf('    %s',RowName(5:end));
                        fprintf(format.txt,RowName,DSP,blockRAM);
                    end
                case 'Avai'
                    continue;
                otherwise
                    DSP=ResourceTable.('DSP')(RowName);
                    blockRAM=ResourceTable.('blockRAM')(RowName);
                    LUT=ResourceTable.('LUT')(RowName);
                    if(available)
                        fprintf(format.totalpct,RowName,...
                        DSP,ceil(100*DSP/resource.TotalDSP),...
                        blockRAM,ceil(100*blockRAM/resource.TotalRAM),...
                        LUT,ceil(100*LUT/resource.TotalLUT));
                    else
                        fprintf(format.total,RowName,...
                        DSP,...
                        blockRAM,...
                        LUT);
                    end
                end
            end
            fprintf(format.footnote);
        end

        function printParsedInformation(info,format,metric)




            fprintf(format.head);

            switch metric
            case 'Resources'
                resources=info;

                fprintf(format.category)
                fprintf(format.line)

                fprintf(format.resource,'LUTs (CLB/ALM)*',resources.LUT(1),resources.LUT(2),100*resources.LUT(1)/resources.LUT(2));
                fprintf(format.resource,'DSPs',resources.DSP(1),resources.DSP(2),100*resources.DSP(1)/resources.DSP(2));
                fprintf(format.resource,'Block RAM',resources.BlockRAM(1),resources.BlockRAM(2),100*resources.BlockRAM(1)/resources.BlockRAM(2));

                if isfield(resources,'BlockMemoryBits')
                    fprintf(format.resource,'Block Memory Bits',resources.BlockMemoryBits(1),resources.BlockMemoryBits(2),100*resources.BlockMemoryBits(1)/resources.BlockMemoryBits(2));
                end


                msg=message('dnnfpga:dnnfpgadisp:LUTFootnote','* LUT');
                fprintf(msg.getString());
                fprintf('\n');
            end

            fprintf('\n');

        end
    end
end
