classdef ScenarioLog<handle















    properties(Access=private)
        mLog;
        mActorIDs;
    end

    methods(Access=public)
        function obj=ScenarioLog(varargin)
            if(length(varargin)~=2)
                error(message('ssm:scenariosimulation:ScenarioLogConstructorArgsError'));
            end

            p=inputParser;
            p.addParameter('Log',[],@isstruct);
            p.parse(varargin{:});
            results=p.Results;


            if isempty(results.Log.SimulationData)
                error(message('ssm:scenariosimulation:ScenarioLogEmpty'));
            end

            obj.mLog=results.Log;
            obj.mActorIDs=obj.getIds(obj.mLog.SimulationData.Actors);
        end

        function out=get(obj,param,varargin)


























            if~(ischar(param)||isstring(param))
                error(message('ssm:scenariosimulation:FirstParameterTypeError','get'));
            end

            if~isempty(varargin)&&length(varargin)~=2
                error(message("ssm:scenariosimulation:NumInputArgumentsError",'get'));
            end

            validSecondArguments=["Actions","Pose","Velocity","AngularVelocity","WheelPose","Diagnostics"];

            if isempty(varargin)
                switch param
                case 'Time'
                    out=obj.mLog.SimulationData.Time;
                case 'ActorIDs'
                    out=obj.getIds(obj.mLog.SimulationData.Actors)';
                case 'Diagnostics'
                    out=obj.filterMessages(obj.mLog.DiagnosticMessages);
                otherwise
                    if(any(strcmp(validSecondArguments,param)))
                        error(message('ssm:scenariosimulation:ParamExpectsMoreThanOneArgument',param));
                    end

                    error(message('ssm:scenariosimulation:InvalidParameterPassed',param,'get'));
                end
            else
                if~(ischar(varargin{1})||isstring(varargin{1}))
                    error(message('ssm:scenariosimulation:SecondParamTypeCharVectorError','get'));
                end
                switch param
                case 'Actions'
                    switch varargin{1}
                    case 'ActorID'

                        if~(isnumeric(varargin{2})&&isscalar(varargin{2}))
                            error(message('ssm:scenariosimulation:ValueTypeNumericError',varargin{1}));
                        end

                        actorId=varargin{2};
                        if~any(obj.mActorIDs==actorId)
                            error(message('ssm:scenariosimulation:ActorIDNotFoundError',actorId));
                        end

                        time=obj.mLog.SimulationData.Time;
                        out=obj.getActions(obj.mLog.SimulationData.Actions,actorId,time);
                    otherwise
                        error(message('ssm:scenariosimulation:InvalidSecondArgumentInLog',varargin{1},param));
                    end
                case 'Pose'
                    switch varargin{1}
                    case 'ActorID'

                        if~(isnumeric(varargin{2})&&isscalar(varargin{2}))
                            error(message('ssm:scenariosimulation:ValueTypeNumericError',varargin{1}));
                        end

                        actorId=varargin{2};
                        if~any(obj.mActorIDs==actorId)
                            error(message('ssm:scenariosimulation:ActorIDNotFoundError',actorId));
                        end

                        time=obj.mLog.SimulationData.Time;
                        out=obj.getAttribute('Pose',obj.mLog.SimulationData.Actors,actorId,time);
                    otherwise
                        error(message('ssm:scenariosimulation:InvalidSecondArgumentInLog',varargin{1},'Pose'));
                    end
                case 'Velocity'
                    switch varargin{1}
                    case 'ActorID'

                        if~(isnumeric(varargin{2})&&isscalar(varargin{2}))
                            error(message('ssm:scenariosimulation:ValueTypeNumericError',varargin{1}));
                        end

                        actorId=varargin{2};
                        if~any(obj.mActorIDs==actorId)
                            error(message('ssm:scenariosimulation:ActorIDNotFoundError',actorId));
                        end

                        time=obj.mLog.SimulationData.Time;
                        out=obj.getAttribute('Velocity',obj.mLog.SimulationData.Actors,actorId,time);
                    otherwise
                        error(message('ssm:scenariosimulation:InvalidSecondArgumentInLog',varargin{1},'Velocity'));
                    end
                case 'AngularVelocity'
                    switch varargin{1}
                    case 'ActorID'

                        if~(isnumeric(varargin{2})&&isscalar(varargin{2}))
                            error(message('ssm:scenariosimulation:ValueTypeNumericError',varargin{1}));
                        end

                        actorId=varargin{2};
                        if~any(obj.mActorIDs==actorId)
                            error(message('ssm:scenariosimulation:ActorIDNotFoundError',actorId));
                        end

                        time=obj.mLog.SimulationData.Time;
                        out=obj.getAttribute('AngularVelocity',obj.mLog.SimulationData.Actors,actorId,time);
                    otherwise
                        error(message('ssm:scenariosimulation:InvalidSecondArgumentInLog',varargin{1},'AngularVelocity'));
                    end
                case 'WheelPose'
                    switch varargin{1}
                    case 'ActorID'

                        if~(isnumeric(varargin{2})&&isscalar(varargin{2}))
                            error(message('ssm:scenariosimulation:ValueTypeNumericError',varargin{1}));
                        end

                        actorId=varargin{2};
                        if~any(obj.mActorIDs==actorId)
                            error(message('ssm:scenariosimulation:ActorIDNotFoundError',actorId));
                        end

                        time=obj.mLog.SimulationData.Time;
                        out=obj.getAttribute('WheelPose',obj.mLog.SimulationData.Actors,actorId,time);
                    otherwise
                        error(message('ssm:scenariosimulation:InvalidSecondArgumentInLog',varargin{1},'WheelPose'));
                    end
                case 'Diagnostics'
                    switch varargin{1}
                    case 'ActorID'

                        if~(isnumeric(varargin{2})&&isscalar(varargin{2}))
                            error(message('ssm:scenariosimulation:ValueTypeNumericError',varargin{1}));
                        end

                        actorId=varargin{2};
                        if~any(obj.mActorIDs==actorId)
                            error(message('ssm:scenariosimulation:ActorIDNotFoundError',actorId));
                        end





                        out=obj.filterMessages(obj.mLog.DiagnosticMessages);
                    otherwise
                        error(message('ssm:scenariosimulation:InvalidSecondArgumentInLog',varargin{1},'Diagnostics'));
                    end
                otherwise
                    error(message('ssm:scenariosimulation:InvalidParameterPassed',param,'get'));
                end
            end
        end
    end

    methods(Access=private,Static=true)
        function actorIds=getIds(actors)
            actorIds=[];
            for j=1:length(actors)
                x=actors{j};
                ids=zeros(1,length(x));
                for i=1:length(x)
                    ids(i)=x{i}.ActorID;
                end
                actorIds=union(actorIds,ids);
            end
        end

        function out=getAttribute(fieldName,actors,actorId,t)
            out=[];
            idx=1;
            for j=1:length(actors)
                x=actors{j};
                for i=1:length(x)
                    if(x{i}.ActorID==actorId)
                        val=[];
                        val=setfield(val,'Time',t(j));
                        val=setfield(val,fieldName,getfield(x{i},fieldName));
                        if(idx==1)
                            out=val;
                        else
                            out(idx)=val;
                        end
                        idx=idx+1;
                    end
                end
            end
        end

        function actions=getActions(Actions,actorId,t)
            actions=[];
            k=1;
            for j=1:length(Actions)
                x=Actions{j};
                if(isempty(x))
                    continue;
                end
                for i=1:length(x)
                    if(x{i}.ActorAction.ActorID==actorId)
                        actions(k).Time=t(j);
                        actions(k).Actions=x{i};
                        k=k+1;
                    end
                end
            end
        end

        function Messages=filterMessages(Messages)
            for j=1:length(Messages)
                msg=string(Messages(j).Message);

                if(msg.contains('<h>'))
                    msg=msg.extractBetween('<h>','</h>');
                    msg=msg.eraseBetween('<a','>');
                    msg=msg.replace('<a>','');
                    msg=msg.replace('</a>',' ');
                end


                if(msg.contains(newline))
                    msg=msg.erase(newline);
                end
                Messages(j).Message=msg;
            end
        end

    end

end
