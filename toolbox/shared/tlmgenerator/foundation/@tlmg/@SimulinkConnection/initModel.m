function initModel(this)




    try

        this.DirtyState=this.Model.Dirty;
        this.BlockReductionOpt=this.Model.BlockReductionOpt;
        this.ConditionallyExecuteInputs=this.Model.ConditionallyExecuteInputs;


        this.Model.BlockReductionOpt='off';
        this.Model.ConditionallyExecuteInputs='off';



        [iph,oph]=this.getTopPortBlockHandles;
        allph=zeros(1,(numel(iph)+numel(oph)));
        isTopLevel=strcmp(this.Subsystem,this.System);
        for ii=1:numel(iph)
            if(~isTopLevel)
                set_param(iph{ii}.Outport,'CacheCompiledBusStruct','on');
            end
            allph(ii)=iph{ii}.Outport;
        end
        for jj=1:numel(oph)
            set_param(oph{jj}.Inport,'CacheCompiledBusStruct','on');
            allph(numel(iph)+jj)=oph{jj}.Inport;
        end



        if~this.isModelCompiled
            this.Model.init('HDL');
        end





        set_param(0,'CurrentSystem',this.ModelName);



        starttime=evalin('base',get_param(this.ModelName,'StartTime'));
        stoptime=evalin('base',get_param(this.ModelName,'StopTime'));
        runtime=stoptime-starttime;
        for ii=1:numel(allph)
            cst=get_param(allph(ii),'CompiledSampleTime');
            if~isa(cst,'cell')
                cst={cst};
            end

            for jj=1:numel(cst)

                if(cst{jj}(1)==0)
                    fixedStep=get_param(this.ModelName,'FixedStep');
                    if(strcmpi(fixedStep,'Auto'))
                        continue;
                    else
                        cst{jj}(1)=eval(fixedStep);
                    end
                end
                numsamples=runtime/cst{jj}(1);
                if(numsamples>10000)
                    l_me=MException('TLMGenerator:SimulinkConnection:LargeSamples',...
                    ['Found signal that will result in a very large number of samples during vector capture (%d).',...
                    ' The maximum number of samples the TLM testbench will run is 10000. Please adjust the run time or the sample rates.\n'],numsamples);
                    throw(l_me);
                end
            end
        end

    catch me
        fprintf('Failure to init the model ''%s''.\n',this.ModelName);
        this.termModel;
        rethrow(me);
    end

end




