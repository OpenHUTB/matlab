function output=newEmbeddedReportViewer(mode,varargin)


    mode=validatestring(mode,{'fromBrowser','fromMatlab'});

    ip=inputParser();
    ip.addParameter('VirtualReport',[],@(s)isa(s,'codergui.internal.VirtualReport'));
    ip.addParameter('ReportFile','',@ischar);
    ip.addParameter('ExistingClientId','',@ischar);
    ip.addParameter('Start',true,@islogical);
    ip.parse(varargin{:});
    opts=ip.Results;

    if strcmp(mode,'fromMatlab')
        reportViewer=newReportViewer();
        output=reportViewer;
    else
        if~isempty(opts.ExistingClientId)
            reportViewer=codergui.ReportViewer.byId(opts.ExistingClientId);
            assert(strcmp(opts.ExistingClientId,reportViewer.Client.Id));
        else
            reportViewer=newReportViewer();
        end
        output=reportViewer.Client.Id;
    end

    if opts.Start
        reportViewer.Client.init();
    end

    if~isempty(opts.ReportFile)
        reportFileArg=opts.ReportFile;
    elseif~isempty(opts.VirtualReport)
        reportFileArg=opts.VirtualReport;
    else
        return;
    end

    if reportViewer.Client.ClientLoaded
        reportViewer.ReportFile=reportFileArg;
    else


        initListener=addlistener(reportViewer.Client,...
        'ClientLoaded','PostSet',@applyReportChange);
    end

    function applyReportChange(varargin)
        reportViewer.ReportFile=reportFileArg;
        delete(initListener);
    end
end

function reportViewer=newReportViewer()
    reportViewer=codergui.ReportViewer('ClientFactory',@codergui.ReportServices.embeddedClientFactory);
end

