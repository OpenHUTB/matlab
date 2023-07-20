function[packageName,slreqPartLocation]=getPackageLocation(artifact,linksetFilePath)


    packageName='';
    slreqPartLocation='';


    [~,fname]=fileparts(linksetFilePath);
    [opcFileName,opcPartName]=slreq.utils.getEmbeddedLinksetName();
    if strcmp(fname,opcFileName)
        [~,mname,mext]=fileparts(artifact);
        if strcmp(mext,'.slx')
            unpackedLocation=get_param(mname,'UnpackedLocation');
            slreqPartLocation=fullfile(unpackedLocation,opcPartName);
            slreqPartDir=fileparts(slreqPartLocation);
            if exist(slreqPartDir,'dir')~=7
                mkdir(slreqPartDir);
            end
            packageName=mname;
        end
    end
end