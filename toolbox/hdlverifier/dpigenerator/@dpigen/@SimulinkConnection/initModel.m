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


























    catch me
        fprintf('Failure to init the model ''%s''.\n',this.ModelName);
        this.termModel;
        rethrow(me);
    end




