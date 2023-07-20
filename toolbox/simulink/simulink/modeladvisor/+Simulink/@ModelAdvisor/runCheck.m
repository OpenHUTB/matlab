function success=runCheck(this,varargin)







    PerfTools.Tracer.logMATLABData('MAGroup','Run Check',true);


    Simulink.ModelAdvisor.getActiveModelAdvisorObj(this);

    success=false;

    this.StartInTaskPage=false;

    if nargin>1
        checkList=varargin{1};
        if nargin>2
            overwriteHTML=varargin{2};
        else
            overwriteHTML=true;
        end

        oldState=this.CmdLine;

        if nargin>3
            fromTaskAdvisorNode=varargin{3};
        else
            fromTaskAdvisorNode='';




            this.CmdLine=true;
        end



        if this.runInBackground
            setupParallelRun(this,fromTaskAdvisorNode.ID);
            return;
        end
        this.run(checkList,overwriteHTML,fromTaskAdvisorNode);


        this.CmdLine=oldState;
    else
        oldState=this.CmdLine;
        this.CmdLine=true;

        this.run;


        this.CmdLine=oldState;
    end

    success=true;

    PerfTools.Tracer.logMATLABData('MAGroup','Run Check',false);

    function setupParallelRun(this,id)
        this.setStatus(DAStudio.message('ModelAdvisor:engine:ParallelJobInitializing'));
        this.Database.saveMASessionData;
        parallelRun=ModelAdvisor.ParallelRun.getInstance();
        parallelRun.startRun(this,id);