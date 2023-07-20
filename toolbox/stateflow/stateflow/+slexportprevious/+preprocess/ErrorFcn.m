function ErrorFcn(obj)




    if isR2010bOrEarlier(obj.ver)


        machine=getStateflowMachine(obj);
        if isempty(machine)
            return;
        end

        c=find_system(obj.modelName,'MatchFilter',@Simulink.match.allVariants,'LookUnderReadProtectedSubsystems','on','LookUnderMasks','on','ReferenceBlock','','MaskType','Stateflow');

        for i=1:numel(c)
            chart=c{i};
            set_param(chart,'ErrorFcn','');
        end
    end

end
