


function summary=processReportSummary(reportContext,reportType)
    summary=reportContext.Report.summary;


    if isfield(summary,'date')
        summary.date=datestr(summary.date);
    else
        summary.date="";
    end

    if~isfield(summary,'toolboxLicenses')
        summary.toolboxLicenses="";
    end


    if isfield(summary,'OutputFileName')&&~isempty(summary.OutputFileName)
        if reportContext.IsErt
            summary.outputFilePath=fullfile(summary.buildDirectory,summary.OutputFileName);
        else
            summary.outputFilePath=fullfile(summary.outDirectory,summary.OutputFileName);
        end
    elseif isfield(summary,'directory')&&~isempty(summary.directory)

        summary.outputFilePath=summary.directory;
    else
        summary.outputFilePath='';
    end

    if isfield(summary,'codingTarget')&&strcmp(summary.codingTarget,'MEX')
        try
            summary.isJITMex=coder.internal.isJITMex(summary.outputFilePath);
        catch
            summary.isJITMex=false;
        end
    end


    summary.versionInfo=makeProductString(reportContext,reportType);


    if isprop(reportContext.Config,'HardwareImplementation')
        summary.procInfo=reportContext.Config.HardwareImplementation.ProdHWDeviceType;
    else
        summary.procInfo=[];
    end


    if isprop(reportContext.Config,'Toolchain')
        buildToolsInfo=coder.make.internal.getBuildToolsInfo(...
        reportContext.Config);
        summary.toolchainInfo=buildToolsInfo.ToolchainInfo.Name;
    else
        summary.toolchainInfo='';
    end


    if isprop(reportContext.Config,'BuildConfiguration')
        summary.buildConfiguration=reportContext.Config.BuildConfiguration;
    else
        summary.buildConfiguration='';
    end
end

function str=makeProductString(reportContext,reportType)
    try
        products=reportType.getProductsUsed(reportContext);
        if iscellstr(products)%#ok<ISCLSTR>
            products=cellfun(@ver,products);
        end
    catch
        products=[];
    end
    str='';
    if~isempty(products)
        for i=1:length(products)
            str=sprintf('%s%s %s %s',str,products(i).Name,products(i).Version,products(i).Release);
            if i~=length(products)
                str=sprintf('%s, ',str);
            end
        end
    end
end