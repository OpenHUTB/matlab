function removeSignalLogging(name)





    if nargin<1
        name=gcs;
    end



    nets=find_system(name,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','FollowLinks','on','LookUnderMasks','on','DataLogging','on');
    if isempty(nets)
        dnnfpga.disp(['No signal loggings in ',name,' ! ']);
    else
        fprintf("\n");
        for net=nets'
            if strcmp(get_param(net,'DataLogging'),'on')
                set_param(net,'DataLogging','off');
                fprintf(".");
            end
        end
        fprintf("\n");
        dnnfpga.disp(['Removed signal loggings in ',name,' ! ']);
    end
end
