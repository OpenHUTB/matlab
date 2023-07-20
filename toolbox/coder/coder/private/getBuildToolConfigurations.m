function[buildToolConfigs,default]=getBuildToolConfigurations()




    buildToolConfigs={};
    default=[];

    if isBuildToolEnabled

        try

            existingConfigs=linkfoundation.xmakefile.XMakefileConfiguration.getConfigurations();
            if existingConfigs.Count>0
                values=existingConfigs.values();
                for index=1:existingConfigs.length
                    config=values{index};

                    if config.isOperational(true)
                        buildToolConfigs{end+1}=config.Configuration;%#ok
                    end
                end
            end


            default=linkfoundation.xmakefile.XMakefileConfiguration.getActiveConfiguration();

        catch
            return;
        end

    end

end
