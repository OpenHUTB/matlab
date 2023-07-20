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

    if nargin<3
        show=strcmp(check,'all');
    end

    filterSettings=rmi.settings_mgr('get','filterSettings');
    if filterSettings.enabled&&filterSettings.filterConsistency
        filters=filterSettings;
    else
        filters=[];
    end


    linkSet=slreq.load(srcName);
    if isempty(linkSet)
        error(message('Slvnv:rmiml:ReqFileNotFound',srcName));
    end

    if~rmide.hasLinks(srcName,filters)
        error(message('Slvnv:consistency:NoLinksToCheck',srcName));
    end

    checker=rmicheck.internal.Checker(srcName,'linktype_rmi_data',@getLinkedItems);
    [faultCounters,stats]=checker.checkSource(check,filters);
    rmicheck.internal.Checker.cachedResults(srcName,faultCounters);

    [errorCount,errors]=rmicheck.internal.Checker.packErrors(check,faultCounters);


    reportSpec.filepath=getReportFilePath(srcName,check);
    reportSpec.titleTemplateId='Slvnv:consistency:InconsistenciesInSLDDLinks';
    reportSpec.srcItemHeaderId='Slvnv:consistency:DDEntry';
    reportSpec.srcItemFormatter=@resolveSrcItemInfo;
    reportSpec.checker=checker;
    reportSpec.doShow=show;


    reportWriter=rmicheck.internal.ReportWriter('linktype_rmi_data',srcName,reportSpec);
    reportWriter.writeResultsToFile(check,faultCounters,stats);
end

function linkedItems=getLinkedItems(srcName)

    uids=rmimap.getNodeIds(srcName,true);
    linkedItems=cell(numel(uids),3);
    linkedItems(:,1)=uids';
    for i=1:numel(uids)
        entryPath=rmide.getEntryPath(srcName,uids{i});
        entryName=entryPath;
        if any(entryPath=='.')
            [~,rest]=strtok(entryPath,'.');
            entryName=rest(2:end);
        end
        linkedItems(i,2:3)={entryName,entryPath};
    end
end

function out=resolveSrcItemInfo(in)


    if any(in=='.')
        [~,rest]=strtok(in,'.');
        out=rest(2:end);
    else
        out=in;
    end
end

function rptPath=getReportFilePath(srcName,~)

    [~,name,ext]=fileparts(srcName);
    rptPath=fullfile(pwd,[strrep([name,ext],'.','_'),'.html']);
end


