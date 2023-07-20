function signals=getInstrumentedSignals(mdl)





    signals=[];
    try

        signals=get_param(mdl,'InstrumentedSignals');
    catch
    end

    if(isempty(signals))
        oneSig=struct('Name','','BlockPath','','PortIndex',0);
        signals=repmat(oneSig,0);

        if~verLessThan('MATLAB','9.12')


            blocks=find_system(mdl,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'regexp','on','blocktype','.*');
        else
            blocks=find_system(mdl,'regexp','on','blocktype','.*');
        end
        hdlBlocks=get_param(blocks,'handle');
        for idx=1:length(hdlBlocks)
            phs=get_param(hdlBlocks{idx},'PortHandles');
            for opk=1:length(phs.Outport)
                if(strcmp(get_param(phs.Outport(opk),'datalogging'),'on'))
                    oneSig.Name=get_param(phs.Outport(opk),'name');
                    oneSig.BlockPath=blocks{idx};
                    oneSig.PortIndex=opk;
                    signals(end+1)=oneSig;
                end
            end
        end
    end
end


