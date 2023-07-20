function simulinkNeedSLUpdatePIDBlks(obj)




    if isR2009bOrEarlier(obj.ver)


        h1=find_system(obj.modelName,...
        'FindAll','on',...
        'LookUnderMasks','all',...
        'ReferenceBlock','simulink_need_slupdate/PID Controller');

        for cnt=1:length(h1)
            set_param(h1(cnt),'ReferenceBlock',sprintf('simulink_extras/Additional\nLinear/PID Controller'));
        end


        h2=find_system(obj.modelName,...
        'MatchFilter',@Simulink.match.allVariants,...
        'FindAll','on',...
        'LookUnderMasks','all',...
        'ReferenceBlock',sprintf('simulink_need_slupdate/PID Controller\n(with Approximate\nDerivative)'));

        for cnt=1:length(h2)
            set_param(h2(cnt),'ReferenceBlock',sprintf('simulink_extras/Additional\nLinear/PID Controller\n(with Approximate\nDerivative)'));
        end

    end
