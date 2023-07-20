function emitBitstreamMATFile(matFileName,matFileDestDir,varargin)









    p=inputParser;
    p.addParameter('Processor',[]);
    p.addParameter('ProcessorConfig',[]);
    p.addParameter('Frequency',0);
    p.addParameter('BoardPlugin',[]);
    p.addParameter('ReferenceDesignPlugin',[]);


    p.parse(varargin{:});
    inputArgs=p.Results;


    processor=inputArgs.Processor;
    hPC=inputArgs.ProcessorConfig;
    freq=inputArgs.Frequency;
    boardPlugin=inputArgs.BoardPlugin;
    rdPlugin=inputArgs.ReferenceDesignPlugin;


    matlabVersion=version;
    processorVersion=dnnfpga.processorVersion;


    if hPC.isGenericDLProcessor




        BitstreamBuildInfo=dnnfpga.bitstream.BitstreamBuildInfo(processor,...
        matlabVersion,freq,[],[],hPC,[],processorVersion);

    else

        resources=getResources(matFileDestDir);



        BitstreamBuildInfo=dnnfpga.bitstream.BitstreamBuildInfo(processor,...
        matlabVersion,freq,boardPlugin,rdPlugin,hPC,resources,processorVersion);
    end


    downstream.tool.createDir(matFileDestDir);


    save(fullfile(matFileDestDir,[matFileName,'.mat']),'BitstreamBuildInfo');

end

function resources=getResources(projectFolder)







    synthPrjFolder=dir(fullfile(projectFolder,'*_prj'));

    if isempty(synthPrjFolder)||~any(synthPrjFolder.isdir(:))


        resources=[];
        warning(message('dnnfpga:workflow:ReportNotFound'));
    else

        switch(lower(synthPrjFolder.name))


        case lower('vivado_ip_prj')
            reportPath=fullfile(projectFolder,'vivado_ip_prj','vivado_prj.runs','impl_1');
            reportFile=dir(fullfile(reportPath,'*utilization_placed.rpt'));
            if~isempty(reportFile)
                reportFullPath=fullfile(reportPath,reportFile(end).name);
                resources=dnnfpga.build.parseResourcesFromReport(reportFullPath,'Xilinx');
            else
                resources=[];
                warning(message('dnnfpga:workflow:ReportNotFound'));
            end

        case lower('quartus_prj')
            reportPath=fullfile(projectFolder,'quartus_prj');
            reportFile=dir(fullfile(reportPath,'*fit.summary'));
            if~isempty(reportFile)
                reportFullPath=fullfile(reportPath,reportFile(end).name);
                resources=dnnfpga.build.parseResourcesFromReport(reportFullPath,'Intel');
            else
                resources=[];
                warning(message('dnnfpga:workflow:ReportNotFound'));
            end
        otherwise
            resources=[];
        end
    end
end


