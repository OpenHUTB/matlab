function SMtoUse=getCodetableFile(kernelsPath,computeCapability)















    AvailSMFiles=dir(fullfile(kernelsPath,'*.mat'));

    AvailSMText=regexp({AvailSMFiles.name},'^PTX_sm_(\d+).mat$','tokens','once');

    falseMatch=cellfun(@isempty,AvailSMText);
    AvailSMText(falseMatch)=[];
    AvailSMFiles(falseMatch)=[];

    AvailSMs=cellfun(@str2double,AvailSMText)/10;
    [AvailSMs,order]=sort(AvailSMs);
    AvailSMFiles=AvailSMFiles(order);


    idx=find(AvailSMs<=computeCapability,1,'last');


    assert(~isempty(idx),'emitter:oldarch',...
    'Requested code-table for unsupported compute-capability: %g',computeCapability);

    SMtoUse=AvailSMFiles(idx).name;

end

