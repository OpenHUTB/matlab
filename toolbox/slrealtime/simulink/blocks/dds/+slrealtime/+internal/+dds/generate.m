function generate(modelName,buildInfo)






    if~slrealtime.internal.dds.utils.BlockProperties.systemhasblocks(modelName)
        return;
    end


    if~dig.isProductInstalled('DDS Blockset')
        error(getString(message('slrealtime:dds:needDDSBlockset')));
    end
    fullpathToUtility=which('dds.internal.isInstalledAndLicensed');
    if~isempty(fullpathToUtility)

        [value,~]=dds.internal.isInstalledAndLicensed();
        if~value



            error(message('dds:toolstrip:NotLicensed'));
        end
    else

        return;
    end




    bdir=pwd;

    xmlFiles=slrealtime.internal.dds.eprosima.generateIDLAndXMLFiles(modelName,buildInfo,bdir);


    slrealtime.internal.dds.eprosima.createVendorArtifacts(xmlFiles,buildInfo,bdir);


    serviceGenInfo=slrealtime.internal.dds.eprosima.getDataForServicegen(modelName,...
    bdir,buildInfo,xmlFiles);

    filesPathsGenOrAdded=slrealtime.internal.dds.eprosima.generateServices(serviceGenInfo);
    for idx=1:numel(filesPathsGenOrAdded)
        [~,~,ext]=fileparts(filesPathsGenOrAdded{idx});
        if startsWith(ext,'.h','IgnoreCase',true)
            buildInfo.addIncludeFiles(filesPathsGenOrAdded{idx});
        elseif startsWith(ext,'.c','IgnoreCase',true)
            buildInfo.addSourceFiles(filesPathsGenOrAdded{idx});
        end
    end
    location=fullfile((matlabroot),'toolbox','slrealtime','simulink',...
    'blocks','dds','dist');
    buildInfo.addIncludePaths(location);
    buildInfo.addLinkFlags({'-lfastrtps -lfastcdr'});

end
