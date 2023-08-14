function continuousIntegrators(obj)





    if isR2006aOrEarlier(obj.ver)
        contIntBlks=slexportprevious.utils.findBlockType(obj.modelName,'Integrator');

        if~isempty(contIntBlks)
            for i=1:length(contIntBlks)
                blk=contIntBlks{i};
                externalReset=get_param(blk,'ExternalReset');
                if strcmpi(externalReset,'level hold')
                    set_param(blk,'ExternalReset','level');
                end
            end
        end
    end
