function[out]=getCodeSummary(obj)


    if~Simulink.report.ReportInfo.featureReportV2
        out={...
        message('RTW:report:SystemTargetFile').getString,[obj.SysTargetFile];...
        message('RTW:report:HardwareDeviceType').getString,obj.HardwareDeviceType;...
        message('RTW:report:SimulinkCoderVersion').getString,...
        obj.CoderVersion;...
        message('RTW:report:SourceCodeGeneratedOn').getString,...
        obj.TimeStamp;...
        ['<span id="sourceLocationTitle">',message('RTW:report:SourceCodeGeneratedAt').getString,'</span>'],...
        '<span id="sourceLocation" style="display:none"><script>document.write(top.getCodeLocation())</script></span>';...
        message('RTW:report:SummaryBuildTypeLabel').getString,...
        obj.BuildType;
        };
    else


        rptFolder=obj.ReportFolder;
        pathList=split(rptFolder,filesep);
        codeLoc=fullfile(pathList{1:end-2});
        if isunix
            codeLoc=['/',codeLoc];
        end
        out={...
        message('RTW:report:SystemTargetFile').getString,[obj.SysTargetFile];...
        message('RTW:report:HardwareDeviceType').getString,obj.HardwareDeviceType;...
        message('RTW:report:SimulinkCoderVersion').getString,...
        obj.CoderVersion;...
        message('RTW:report:SourceCodeGeneratedOn').getString,...
        obj.TimeStamp;...
        ['<span id="sourceLocationTitle">',message('RTW:report:SourceCodeGeneratedAt').getString,'</span>'],...
        sprintf('<span id="sourceLocation">%s</span>',codeLoc);...
        message('RTW:report:SummaryBuildTypeLabel').getString,...
        obj.BuildType;
        };
    end
end
