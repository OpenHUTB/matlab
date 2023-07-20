function[metricsFile]=genGPUStaticMetricsFile(buildDir,outDir,cHrefConverter)







    if nargin<3
        cHrefConverter=[];
    end

    matFile=fullfile(buildDir,'gpu_codegen_info.mat');
    template=fullfile(matlabroot,'toolbox','shared','coder','coder','gpucoder','metrics','static_metrics_template.html');
    metricsFile=fullfile(outDir,'gpu_metrics.html');
    htmlBody=fileread(template);
    rowColors={'style="background-color: #eeeeff"','style="background-color: #ffffff"'};
    rowColorIdx=0;

    useHrefs=~isempty(cHrefConverter);
    kernelHref='#';
    customAttr='';

    kernels=getGPUMetricVar(matFile,'cuda_Kernel');
    htmlTable='';
    if(~isempty(kernels))
        for i=1:numel(kernels)
            curKernel=kernels(i);
            sharedMemStr='0';
            if(~isempty(curKernel.sharedMemory))
                sharedMemStr=sprintf('%d',curKernel.sharedMemory(1).numBytes);
                for j=2:numel(curKernel.sharedMemory)-1
                    sharedMemStr=[sharedMemStr,sprintf(',%d',curKernel.sharedMemory(j).numBytes)];%#ok<*AGROW>
                end
            end

            constantMemStr='0';
            if(~isempty(curKernel.constantMemory))
                constantMemStr=sprintf('%d',curKernel.constantMemory(1).numBytes);
                for j=2:numel(curKernel.constantMemory)-1
                    constantMemStr=[constantMemStr,sprintf(',%d',curKernel.constantMemory(j).numBytes)];
                end
            end

            parentKernel='None';
            if~isempty(curKernel.parentKernelName)
                parentKernel=curKernel.parentKernelName;
            end

            if useHrefs
                kernelHref=[cHrefConverter(curKernel.fileName),'#fcn_',curKernel.functionname];
            else
                customAttr=[' ',codergui.evalprivate('toCustomLinkAttribute','cFunction',curKernel.fileName,curKernel.functionname)];
            end

            htmlTable=[htmlTable,sprintf(['<tr %s><td align="middle" valid="middle" style="border-style:none">'...
            ,'<a href="%s"%s class="code2code">%s</a></td>'...
            ,'<td align="middle" valid="middle" style="border-style:none">[%d,%d,%d]</td>'...
            ,'<td align="middle" valid="middle" style="border-style:none">[%d,%d,%d]</td>'...
            ,'<td align="middle" valid="middle" style="border-style:none">%s</td>'...
            ,'<td align="middle" valid="middle" style="border-style:none">%s</td>'...
            ,'<td align="middle" valid="middle" style="border-style:none">%d</td>'...
            ,'<td align="middle" valid="middle" style="border-style:none">%s</td>'...
            ,'<td align="middle" valid="middle" style="border-style:none">%d</td>'...
            ,'<td align="middle" valid="middle" style="border-style:none">%s</td>'...
            ,'<td align="middle" valid="middle" style="border-style:none">%s</td></tr>'],...
            rowColors{rowColorIdx+1},...
            kernelHref,...
            customAttr,...
            curKernel.functionname,...
            curKernel.threads(1),curKernel.threads(2),curKernel.threads(3),...
            curKernel.blocks(1),curKernel.blocks(2),curKernel.blocks(3),...
            curKernel.inputArgs,curKernel.outputArgs,...
            curKernel.stream,sharedMemStr,curKernel.minBlocksPerSM,...
            constantMemStr,parentKernel)];

            rowColorIdx=mod(rowColorIdx+1,numel(rowColors));
        end
    end
    htmlBody=strrep(htmlBody,'|>CUDA_KERNEL_DATA<|',htmlTable);

    mallocs=getGPUMetricVar(matFile,'cudaMalloc');
    htmlTable='';
    rowColorIdx=0;
    if(~isempty(mallocs))
        for i=1:numel(mallocs)
            curMalloc=mallocs(i);
            htmlTable=[htmlTable,sprintf(['<tr %s><td align="middle" valid="middle" style="border-style:none">%s</td>'...
            ,'<td align="middle" valid="middle" style="border-style:none">%d</td></tr>'],...
            rowColors{rowColorIdx+1},...
            curMalloc.variable,curMalloc.size)];
            rowColorIdx=mod(rowColorIdx+1,numel(rowColors));
        end
    end
    htmlBody=strrep(htmlBody,'|>CUDA_MALLOC_DATA<|',htmlTable);

    mallocMgds=getGPUMetricVar(matFile,'cudaMallocManaged');
    htmlTable='';
    rowColorIdx=0;
    if(~isempty(mallocMgds))
        for i=1:numel(mallocMgds)
            curMallocMgd=mallocMgds(i);
            htmlTable=[htmlTable,sprintf(['<tr %s><td align="middle" valid="middle" style="border-style:none">%s</td>'...
            ,'<td align="middle" valid="middle" style="border-style:none">%d</td></tr>'],...
            rowColors{rowColorIdx+1},...
            curMallocMgd.variable,curMallocMgd.size)];
            rowColorIdx=mod(rowColorIdx+1,numel(rowColors));
        end
    end
    htmlBody=strrep(htmlBody,'|>CUDA_MALLOCMANAGED_DATA<|',htmlTable);

    memcpys=getGPUMetricVar(matFile,'cudaMemcpy');
    htmlTable='';
    rowColorIdx=0;
    if(~isempty(memcpys))
        for i=1:numel(memcpys)
            curMemcpy=memcpys(i);
            htmlTable=[htmlTable,sprintf(['<tr %s><td align="middle" valid="middle" style="border-style:none">%s</td>'...
            ,'<td align="middle" valid="middle" style="border-style:none">%s</td>'...
            ,'<td align="middle" valid="middle" style="border-style:none">%d</td>'...
            ,'<td align="middle" valid="middle" style="border-style:none">%s</td>'...
            ,'<td align="middle" valid="middle" style="border-style:none">%s</td>'...
            ,'<td align="middle" valid="middle" style="border-style:none">%d</td></tr>'],...
            rowColors{rowColorIdx+1},...
            curMemcpy.destinationvariable,curMemcpy.sourcevariable,curMemcpy.size,...
            curMemcpy.direction,curMemcpy.conditionalvariable,curMemcpy.stream)];
            rowColorIdx=mod(rowColorIdx+1,numel(rowColors));
        end
    end
    htmlBody=strrep(htmlBody,'|>CUDA_MEMCPY_DATA<|',htmlTable);

    if~isempty(cHrefConverter)
        legacyScript='<script src="resources/eml_report_loadable_data.js"></script>';
    else
        legacyScript='';
    end
    htmlBody=strrep(htmlBody,'|>LEGACY_REPORT_INCLUDE<|',legacyScript);

    htmlBody=replaceLabelTokens(htmlBody);

    fid=fopen(metricsFile,'w');
    if(fid>0)
        fprintf(fid,'%s',htmlBody);
        fclose(fid);
    else

    end
    [~,base,ext]=fileparts(metricsFile);
    metricsFile=[base,ext];
end

function replaced=replaceLabelTokens(htmlBody)





    replaced=htmlBody;
    tokenMatches=regexp(replaced,'\|>([^<|]+)<\|','match');
    for tokenCell=tokenMatches
        token=tokenCell{1};
        messageId=token(3:length(token)-2);
        replaced=strrep(replaced,token,...
        message(['gpucoder:static_metrics:',messageId]).getString());
    end
end

function[gpuMetricVar]=getGPUMetricVar(matFile,varName)
    gpuMetricVar=[];
    if exist(matFile,'file')
        fileInfo=whos('-file',matFile);
        if(isfield(fileInfo,'name')&&ismember(varName,{fileInfo.name}))
            gpuMetricVarStr=load(matFile,varName);
            gpuMetricVar=gpuMetricVarStr.(varName);
        end
    end
end
