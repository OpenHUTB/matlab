









classdef LoggingInfo


    properties(Dependent=true,Access=public)



        DataLogging;



        NameMode;



        LoggingName;



        DecimateData;



        Decimation;



        LimitDataPoints;



        MaxPoints;

    end


    methods


        function this=LoggingInfo(rhs)

            if nargin>0
                if isa(rhs,'Simulink.SimulationData.LoggingInfo')||...
                    isa(rhs,'Simulink.LoggingInfo')||...
                    isa(rhs,'Stateflow.SigLoggingInfo')
                    this.dataLogging_=rhs.DataLogging;
                    this.decimateData_=rhs.DecimateData;
                    this.decimation_=rhs.Decimation;
                    this.limitDataPoints_=rhs.LimitDataPoints;
                    this.maxPoints_=rhs.MaxPoints;


                    if ischar(rhs.NameMode)
                        if isequal(rhs.NameMode,'SignalName')
                            this.nameMode_=true;
                        else

                            this.nameMode_=false;
                        end
                    else
                        this.nameMode_=rhs.NameMode;
                    end
                    this.loggingName_=rhs.LoggingName;

                else
                    DAStudio.error(...
                    'Simulink:Logging:LoggingInfoInvalidConstruct');
                end
            else
                this.dataLogging_=true;
                this.decimateData_=false;
                this.decimation_=2;
                this.limitDataPoints_=false;
                this.maxPoints_=5000;
                this.nameMode_=false;
                this.loggingName_='';
            end
        end


        function this=set.DataLogging(this,val)

            if~Simulink.SimulationData.LoggingInfo.verifyProperty(...
                'DataLogging',val)
                DAStudio.error(...
                'Simulink:Logging:LoggingInfoInvalidSetScalar',...
                'DataLogging');
            end
            this.dataLogging_=logical(val);

        end
        function val=get.DataLogging(this)
            val=logical(this.dataLogging_);
        end


        function this=set.DecimateData(this,val)

            if~Simulink.SimulationData.LoggingInfo.verifyProperty(...
                'DecimateData',val)
                DAStudio.error(...
                'Simulink:Logging:LoggingInfoInvalidSetScalar',...
                'DecimateData');
            end
            this.decimateData_=logical(val);

        end
        function val=get.DecimateData(this)
            val=logical(this.decimateData_);
        end


        function this=set.Decimation(this,val)

            if~Simulink.SimulationData.LoggingInfo.verifyProperty(...
                'Decimation',val)
                DAStudio.error(...
                'Simulink:Logging:LoggingInfoInvalidSetScalar',...
                'Decimation');
            end
            this.decimation_=double(val);

        end
        function val=get.Decimation(this)
            val=this.decimation_;
        end


        function this=set.LimitDataPoints(this,val)

            if~Simulink.SimulationData.LoggingInfo.verifyProperty(...
                'LimitDataPoints',val)
                DAStudio.error(...
                'Simulink:Logging:LoggingInfoInvalidSetScalar',...
                'LimitDataPoints');
            end
            this.limitDataPoints_=logical(val);

        end
        function val=get.LimitDataPoints(this)
            val=logical(this.limitDataPoints_);
        end


        function this=set.MaxPoints(this,val)

            if~Simulink.SimulationData.LoggingInfo.verifyProperty(...
                'MaxPoints',val)
                DAStudio.error(...
                'Simulink:Logging:LoggingInfoInvalidSetScalar',...
                'MaxPoints');
            end
            this.maxPoints_=double(val);

        end
        function val=get.MaxPoints(this)
            val=this.maxPoints_;
        end


        function this=set.NameMode(this,val)

            if~Simulink.SimulationData.LoggingInfo.verifyProperty(...
                'NameMode',val)
                DAStudio.error(...
                'Simulink:Logging:LoggingInfoInvalidSetScalar',...
                'NameMode');
            end
            this.nameMode_=logical(val);

        end
        function val=get.NameMode(this)
            val=logical(this.nameMode_);
        end


        function this=set.LoggingName(this,val)

            if~Simulink.SimulationData.LoggingInfo.verifyProperty(...
                'LoggingName',val)
                DAStudio.error(...
                'Simulink:Logging:LoggingInfoInvalidSetString',...
                'LoggingName');
            end
            this.loggingName_=val;

        end
        function val=get.LoggingName(this)
            val=this.loggingName_;
        end

    end


    methods(Static=true,Access=private)


        function bValid=verifyProperty(propName,val)%#ok<INUSD>







            persistent logInfoRef;
            if isempty(logInfoRef)
                logInfoRef=Simulink.LoggingInfo;
            end


            bValid=true;
            try
                eval(sprintf('logInfoRef.%s = val;',propName));
            catch me %#ok<NASGU>
                bValid=false;
            end

        end
    end


    methods(Hidden=true)


        function s=get_struct(this)
            s.DataLogging=logical(this.dataLogging_);
            s.NameMode=this.nameMode_;
            s.LoggingName=this.loggingName_;
            s.DecimateData=this.decimateData_;
            s.Decimation=this.decimation_;
            s.LimitDataPoints=this.limitDataPoints_;
            s.MaxPoints=this.maxPoints_;
        end

    end


    properties(Hidden=true)
        dataLogging_;
        nameMode_;
        loggingName_;
        decimateData_;
        decimation_;
        limitDataPoints_;
        maxPoints_;
    end
end





