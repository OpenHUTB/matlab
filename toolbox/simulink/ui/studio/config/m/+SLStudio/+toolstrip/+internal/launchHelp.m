function launchHelp(cbinfo,~)
    if isa(cbinfo.domain,'StateflowDI.SFDomain')&&...
        SFStudio.internal.isReqTable(cbinfo)
        sfhelp('req_table_properties');
    elseif isa(cbinfo.domain,'StateflowDI.SFDomain')&&...
        SFStudio.isStateflowLicensed('test')
        doc('stateflow/');
    else
        doc('simulink');
    end
end
