function compGenConnectivity(this)







    hCD=hdlconnectivity.getConnectivityDirector;


    d={this.outputs};

    if~isempty(this.StepSignal),d{end+1}=this.StepSignal;end
    if~isempty(this.sync_reset),d{end+1}=this.sync_reset;end
    if~isempty(this.cnt_en),d{end+1}=this.cnt_en;end
    if~isempty(this.cnt_dir),d{end+1}=this.cnt_dir;end
    if~isempty(this.load_en)
        d{end+1}=this.load_en;
        d{end+1}=this.load_value;
    end

    hCD.addDriverReceiverRegistered(d,this.outputs,...
    this.clock,this.clockenable);


    hCD.addDriverReceiverPair(this.outputs,this.CounterSignal,'realonly',true);



    if~strcmpi(this.CounterType,'Free Running'),

        stepRegIn={this.CounterSignal};
        if~isempty(this.cnt_en),stepRegIn{end+1}=this.cnt_en;end
        if~isempty(this.cnt_dir),stepRegIn{end+1}=this.cnt_dir;end

    end


    if~isempty(this.cnt_dir)

        if strcmpi(this.CounterType,'Free Running')

            if~isempty(this.posStepSignal),hCD.addDriverReceiverPair(this.posStepSignal,this.StepSignal,'realonly',true);end
            if~isempty(this.negStepSignal),hCD.addDriverReceiverPair(this.negStepSignal,this.StepSignal,'realonly',true);end
            if~isempty(this.StepSignal),hCD.addDriverReceiverPair(this.cnt_dir,this.StepSignal,'realonly',true);end
        else


            if~isempty(this.posStepReg),
                hCD.addDriverReceiverPair(this.posStepReg,this.StepSignal,'realonly',true);
                hCD.addDriverReceiverRegistered(stepRegIn,...
                this.posStepReg,...
                this.clock,this.clockenable);
            end


            if~isempty(this.negStepReg),
                hCD.addDriverReceiverPair(this.negStepReg,this.StepSignal,'realonly',true);
                hCD.addDriverReceiverRegistered(stepRegIn,...
                this.negStepReg,...
                this.clock,this.clockenable);
            end
        end

    else

        if strcmpi(this.CounterType,'Free Running')

            if~isempty(this.posStepSignal)
                hCD.addDriverReceiverPair(this.posStepSignal,this.StepSignal,'realonly',true);
            elseif~isempty(this.negStepSignal)
                hCD.addDriverReceiverPair(this.negStepSignal,this.StepSignal,'realonly',true);
            end

        else


            if~isempty(this.StepReg)&&~isempty(this.StepSignal),
                hCD.addDriverReceiverPair(this.StepReg,this.StepSignal,'realonly',true);
                hCD.addDriverReceiverRegistered(stepRegIn,...
                this.StepReg,...
                this.clock,this.clockenable);
            end

        end
    end

