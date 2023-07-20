










classdef ExportedAppDefinition<hgsetget

    properties(Access=public)
        Model=[];
        Name=''

        Doses=[];
        Plots=[];
        Sliders=[];
        Statistics=[];
        ConfigureRanges=true;

        UseStopTime=true;
        StopTime=10;
        OutputTimes=[];
        SupportOutputTimes=false;
        TimeUnits='seconds';
        ModelDocument='';
        Title='';
    end

    methods
        function obj=ExportedAppDefinition(appDef)


            p=appDef.Sliders;
            pobjs=[];
            for i=1:length(p)
                if isempty(pobjs)
                    pobjs=p(i).Object;
                else
                    pobjs=[pobjs,p(i).Object];
                end
            end


            cs=getconfigset(appDef.Model,'default');
            originalStopTime=cs.StopTime;
            originalTimeUnits=cs.TimeUnits;
            originalStatesToLog=cs.RuntimeOptions.StatesToLog;
            if(appDef.StopTime~=-1)
                cs.StopTime=appDef.StopTime;
                cs.TimeUnits=appDef.StopTimeUnits;
            end


            if isinf(cs.StopTime)
                cs.StopTime=1000;
            end


            if isa(cs.SolverOptions,'SimBiology.ODESolverOptions')
                obj.SupportOutputTimes=true;
                cs.SolverOptions.LogSolverAndOutputTimes=true;
            end

            if~isempty(appDef.StatesToLog)
                cs.RuntimeOptions.StatesToLog=eval(appDef.StatesToLog);
            end


            cleanup=onCleanup(@()restore(cs,originalStopTime,originalTimeUnits,originalStatesToLog));


            variants=sbioselect(appDef.Model,'Type','variant','Name',appDef.VariantsToApply);




            dosesToApply=sbioselect(getdose(appDef.Model),'Name',appDef.DosesToApply);
            dosesToAdjust=createDoses(appDef.Doses);
            doses=vertcat(dosesToAdjust,dosesToApply);


            obj.Name=appDef.Name;
            obj.ModelDocument=appDef.ModelDocument;
            obj.Title=appDef.Title;
            obj.ConfigureRanges=appDef.ConfigureRanges;


            p=appDef.Sliders;
            for i=1:length(p)
                next=SimBiology.simviewer.UISlider(p(i));
                if isempty(obj.Sliders)
                    obj.Sliders=next;
                else
                    obj.Sliders(end+1)=next;
                end
            end


            p=appDef.Doses;
            for i=1:length(p)
                next=SimBiology.simviewer.UIDose(p(i));
                if isempty(obj.Doses)
                    obj.Doses=next;
                else
                    obj.Doses(end+1)=next;
                end
            end




            allStates={};

            p=appDef.Statistics;
            for i=1:length(p)
                next=SimBiology.simviewer.UIStatistic(p(i));
                next.compileExpression();

                if isempty(obj.Statistics)
                    obj.Statistics=next;
                else
                    obj.Statistics(end+1)=next;
                end

                allStates=unique([obj.Statistics.ExpressionTokens]);
            end

            p=appDef.Plots;
            for i=1:length(p)
                next=SimBiology.simviewer.UIPlot(p(i));
                next.compileMathExpressions();

                allStates=[allStates,next.getAllStates()];

                if isempty(obj.Plots)
                    obj.Plots=next;
                else
                    obj.Plots(end+1)=next;
                end
            end

            states=cs.RuntimeOptions.StatesToLog;



            if~isempty(allStates)
                stateObjCell=SimBiology.internal.getObjectFromPQN(appDef.Model,allStates);
                for i=1:numel(allStates)
                    stateObj=stateObjCell{i};
                    if isscalar(stateObj)
                        states(end+1)=stateObj;
                    end
                end

                states=unique(states);
            end

            set(cs.RuntimeOptions,'StatesToLog',states);


            obj.Model=export(appDef.Model,pobjs,doses,variants);


            obj.StopTime=obj.Model.SimulationOptions.StopTime;
            obj.TimeUnits=obj.Model.SimulationOptions.TimeUnits;


            if obj.SupportOutputTimes
                obj.OutputTimes=obj.Model.SimulationOptions.OutputTimes;
                if~isempty(obj.OutputTimes)
                    obj.UseStopTime=false;
                end
            end
        end
    end
end


function doses=createDoses(appDoses)

    doses={};
    for i=1:numel(appDoses)
        appDose=appDoses(i);
        type=appDose.Type;

        if strcmp(type,'repeat')
            doses{end+1}=sbiodose(appDose.Name,appDose.Type,...
            'Target',appDose.Target,...
            'StartTime',appDose.StartTime,...
            'Amount',appDose.Amount,...
            'Rate',appDose.Rate,...
            'Interval',appDose.Interval,...
            'Repeat',appDose.Repeat,...
            'TimeUnits',appDose.TimeUnits,...
            'AmountUnits',appDose.AmountUnits,...
            'RateUnits',appDose.RateUnits);%#ok<*AGROW>
        else
            doses{end+1}=sbiodose(appDose.Name,appDose.Type,...
            'Target',appDose.Target,...
            'Time',appDose.Time,...
            'Amount',appDose.Amount,...
            'Rate',appDose.Rate,...
            'TimeUnits',appDose.TimeUnits,...
            'AmountUnits',appDose.AmountUnits,...
            'RateUnits',appDose.RateUnits);
        end
    end

    doses=[doses{:}]';

end


function restore(cs,originalStopTime,originalTimeUnits,originalStatesToLog)


    set(cs,'StopTime',originalStopTime);
    set(cs,'TimeUnits',originalTimeUnits);
    cs.RuntimeOptions.StatesToLog=originalStatesToLog;

end
