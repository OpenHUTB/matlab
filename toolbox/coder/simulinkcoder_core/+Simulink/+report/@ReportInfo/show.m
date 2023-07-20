

function urlAppend=show(obj,varargin)

    urlAppend=[];


    import matlab.internal.lang.capability.Capability
    if~matlab.ui.internal.hasDisplay||~Capability.isSupported(Capability.ModalDialogs)
        return;
    end

    obj.checkoutLicense();

    if rtw.report.ReportInfo.featureReportV2&&isa(obj,'rtw.report.ReportInfo')...
        &&~isa(obj,'Simulink.ModelReference.ProtectedModel.Report')
        urlAppend=loc_show_V2(obj,varargin{:});
    else
        loc_show_V1(obj,varargin{:});
    end
end

function urlAppend=loc_show_V2(obj,varargin)
    urlAppend=[];

    url=obj.getURL;
    if~isempty(varargin)
        blocks=varargin{1};
        inputLocs=varargin{2};
        urlAppend=sprintf('&sid=%s&inputLocs=%s',blocks,inputLocs);
        url=sprintf('%s%s',url,urlAppend);
    end

    if rtwprivate('rtwinbat')
        disp('# Code Generation Report is not launched in BaT or during test execution. The report will be launched in internal browser.');
        return
    end

    if isempty(obj.Dlg)





        dlgs=DAStudio.ToolRoot.getOpenDialogs;
        reportDlg=[];
        keyStr='RTW:report:DocumentTitle';
        expectedStr=DAStudio.message(keyStr,'');
        for k=1:numel(dlgs)
            dlg=dlgs(k);
            src=dlg.getSource;
            if isa(src,'rtw.report.Web')
                if contains(src.Title,expectedStr)

                    reportDlg=dlg;
                    break;
                end
            end
        end

        if isempty(reportDlg)
            w=rtw.report.Web;
            w.Url=url;
            w.Title=obj.getTitle;
            w.WebKit=true;
            w.HelpArgs={'rtw','validate_generated_code'};
        else
            w=reportDlg.getSource;
            w.Url=url;
        end

        if bdIsLoaded(obj.ModelName)
            obj.Dlg=w;
        end
    else
        w=obj.Dlg;
        w.Url=url;
    end
    w.debug=obj.debugReportV2;
    if(w.debug)
        w.Url=strrep(url,'index.html','index-debug.html');
    end
    w.show;
end

function loc_show_V1(obj,url)
    narginchk(1,2);
    if(nargin<2)
        url=obj.getReportFileFullName;
    end
    if~isfile(url)&&~isfile(obj.getReportFileFullName)
        DAStudio.error('RTW:report:ReportNotGenerated',obj.ModelName);
    end
    bOpenInExternalBrowser=false;


    bIsSameReportAsDisplay=obj.isSameReportAsDisplay;
    if obj.featureOpenInStudio
        obj.openInStudio(url);
    elseif obj.featureOpenInApp
        if rtwprivate('rtwinbat')
            disp('# Code Generation Report is not launched in BaT or during test execution. The report will be launched in internal browser.');
            return
        end
        obj.openInApp(url);
    else
        Simulink.report.ReportInfo.openURL(url,obj.getTitle,obj.getHelpMethod,bOpenInExternalBrowser);
    end
    if obj.IsERTTarget
        codeMetricsRpt=obj.getPage('CodeMetrics');
        rtw.report.CodeMetrics.insertReport(obj,codeMetricsRpt,bIsSameReportAsDisplay);
    end


    if~bOpenInExternalBrowser
        hSrc=rtw.report.ReportInfo.getBrowserDocument();
        modelFile=obj.ModelFile;
        if exist(modelFile,'file')
            hSrc.ModelFileNameAtBuild=modelFile;
        end
        hSrc.BuildDir=obj.getBuildDir();

        hSrc.IsTestHarness=obj.IsTestHarness;
        hSrc.HarnessName=obj.getActiveModelName;
        hSrc.HarnessOwner=obj.HarnessOwner;
        hSrc.OwnerFileName=obj.OwnerFileName;
    end
end

