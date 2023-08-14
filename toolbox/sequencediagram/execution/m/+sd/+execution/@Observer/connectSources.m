function connectSources(obj)




    bdHandle=get_param(obj.name','handle');

    if slsvTestingHook('SequenceDiagramUseTestingBlock')==0

        fw=find_system(bdHandle,'regexp','on','BlockType','ObserverPort|SubSystem');
        for fi=1:length(fw)
            tag=get_param(fw(fi),'Tag');
            if~isempty(tag)



                sources=obj.sources.getByKey(tag);

                for source=sources

                    if isa(source,"sd.execution.DataSource")
                        if isempty(source.sourceBlockName)
                            source.sourceBlockName=string(get_param(fw(fi),'Name'));
                        end
                    else

                        if isa(source,"sd.execution.SignalEventSource")
                            if isempty(source.signalGeneratorName)
                                source.addSourceBlocks(string(get_param(fw(fi),'Name')),string(get_param(fw(fi),'Name')+"/1"));
                            end
                        else
                            if isempty(source.queueBlockName)
                                source.addSourceBlocks(string(get_param(fw(fi),'Name')),string(get_param(fw(fi),'Name')+"/1"));
                            end
                        end
                    end
                end
            end
        end
    else
        mdes=find_system(bdHandle,'regexp','on','BlockType','MATLABDiscreteEventSystem|SubSystem|FromWorkspace');

        for mi=1:length(mdes)
            tag=get_param(mdes(mi),'Tag');
            if~isempty(tag)

                source=obj.sources.getByKey(tag);
                if(~isempty(source))
                    if isa(source,"sd.execution.DataSource")
                        if isempty(source.sourceBlockName)
                            source.sourceBlockName=string(get_param(mdes(mi),'Name'));
                        end
                    else

                        if isa(source,"sd.execution.SignalEventSource")
                            if isempty(source.signalGeneratorName)
                                source.addSourceBlocks(string(get_param(mdes(mi),'Name')),string(get_param(mdes(mi),'Name')+"/1"));
                            end
                        else


                            if isempty(source.serverBlockName)
                                source.serverBlockName=string(get_param(mdes(mi),'Name'));
                            end
                        end
                    end
                end
            end
        end
    end
