function[errorCount,errors]=checkLinks(srcName,check,show)




    if builtin('_license_checkout','Simulink_Requirements','quiet')
        error(message('Slvnv:reqmgt:licenseCheckoutFailed'));
    end


    errorCount=0;
    errors={};

    if isempty(srcName)
        rmicheck.internal.Checker.cachedResults('');
        return;
    end

    if nargin==1
        check='all';
    end

    if strcmp(check,'fixDoors')


        lastCheckData=rmicheck.internal.Checker.cachedResults(srcName);
        if~isempty(lastCheckData)
            if lastCheckData.doorsCount>0
                rmicheck.internal.Checker.doorsFixAll(srcName);
            end
        else
            msgString=getString(message('Slvnv:reqmgt:mdlAdvCheck:StaleMaReport'));
            msgTitle=getString(message('Slvnv:reqmgt:mdlAdvCheck:DoorsFixAll'));
            errordlg(msgString,msgTitle,'modal');
        end
        return;
    end

    if nargin<3
        show=strcmp(check,'all');
    end

    filterSettings=rmi.settings_mgr('get','filterSettings');
    if filterSettings.enabled&&filterSettings.filterConsistency
        filters=filterSettings;
    else
        filters=[];
    end

    if~rmiml.hasLinks(srcName,filters)
        if strcmp(check,'all')
            if slreq.hasData(srcName)
                error(message('Slvnv:consistency:NoLinksToCheck',srcName));
            else

                loaded=rmiml.loadIfExists(srcName);
                if~loaded
                    error(message('Slvnv:rmiml:ReqFileNotFound',srcName));
                end

                edit(srcName);
                if~rmiml.hasLinks(srcName,filters)
                    error(message('Slvnv:consistency:NoLinksToCheck',srcName));
                end
            end
        else
            return;
        end
    end

    checker=rmicheck.internal.Checker(srcName,'linktype_rmi_matlab',@rmiml.getReqData);

    faultCounters=rmicheck.internal.Checker.cachedResults(srcName);
    if isempty(faultCounters)
        [faultCounters,stats]=checker.checkSource(check,filters);
    else
        [faultCounters,stats]=checker.checkSource(check,filters,faultCounters);
    end
    rmicheck.internal.Checker.cachedResults(srcName,faultCounters);

    [errorCount,errors]=rmicheck.internal.Checker.packErrors(check,faultCounters);


    reportSpec.filepath=getReportFilePath(srcName,check);
    reportSpec.titleTemplateId='Slvnv:consistency:InconsistenciesInMatlabCodeLinks';
    reportSpec.srcItemHeaderId='Slvnv:consistency:MCodeLocation';
    reportSpec.srcItemFormatter=@resolveSrcItemInfo;
    reportSpec.checker=checker;
    reportSpec.doShow=show;


    reportWriter=rmicheck.internal.ReportWriter('linktype_rmi_matlab',srcName,reportSpec);
    reportWriter.writeResultsToFile(check,faultCounters,stats);
end

function out=resolveSrcItemInfo(in)

    if in(1)==in(2)
        out=getString(message('Slvnv:reqmgt:mdlAdvCheck:LineNumberN',...
        num2str(in(1))));
    else
        out=getString(message('Slvnv:reqmgt:mdlAdvCheck:LineNumbersNN',...
        num2str(in(1)),num2str(in(2))));
    end
end

function rptPath=getReportFilePath(srcName,check)
    if strcmp(check,'all')

        if rmisl.isSidString(srcName)

            rptPath=['rmiml/',strrep(srcName,':','_'),'.html'];
        else

            [~,name,ext]=fileparts(srcName);
            rptPath=['rmiml/',strrep([name,ext],'.','_'),'.html'];
        end
    else


        rptPath=rmiml.mdlAdvRptPath(srcName,check);
    end
end



