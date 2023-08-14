function validateSPInstall(toolName)



    switch lower(toolName)
    case{'xilinx vivado','xilinx ise'}
        [isInstalled,spName]=hdlturnkey.ishdlzynqspinstalled;
        if~isInstalled
            error(message('hdlcommon:plugin:SupportPackageUninstalled',...
            toolName,spName));
        end
    case{'altera quartus ii','intel quartus pro'}
        [isInstalled,spName]=hdlturnkey.ishdlalterasocspinstalled;
        if~isInstalled
            error(message('hdlcommon:plugin:SupportPackageUninstalled',...
            toolName,spName));
        end
    case{'microsemi libero soc'}
        [isInstalled,spName]=hdlturnkey.ishdlmicrochipspinstalled;
        if~isInstalled
            error(message('hdlcommon:plugin:SupportPackageUninstalled',...
            toolName,spName));
        end

    otherwise
    end

end



