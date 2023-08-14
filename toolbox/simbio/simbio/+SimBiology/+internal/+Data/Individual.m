classdef Individual<hgsetget











    properties(Access=public)
        CategoricalCovariates={};
        ContinuousCovariates={};
        Name='';
    end

    properties(SetAccess=private)
        Doses={};
        Responses=[];
        Type='individual';
VarNamer
    end

    properties(SetAccess=private,GetAccess=private)
        CategoricalValues=SimBiology.internal.Data.TimeValue.empty;
        ContinuousValues=SimBiology.internal.Data.TimeValue.empty;
    end

    properties(Dependent,SetAccess=private)
ReservedNames
    end


    methods

        function reservedNames=get.ReservedNames(obj)
            catLabels=obj.CategoricalCovariates;
            contLabels=obj.ContinuousCovariates;
            reservedNames=[catLabels,contLabels];
        end

        function obj=Individual(varargin)
            if nargin>0
                set(obj,varargin{:});
            end
        end



        function addCategoricalCovariate(obj,name,time,value)
            obj.CategoricalCovariates{end+1}=name;
            covariate=SimBiology.internal.Data.TimeValue;
            covariate.Time=time;
            covariate.Value=value;
            obj.CategoricalValues(end+1)=covariate;
        end

        function value=getCategoricalCovariate(obj,name)
            allNames=obj.CategoricalCovariates;
            index=find(strcmp(name,allNames));

            if~isempty(index)&&length(index)==1
                value=obj.CategoricalValues(index);
            else
                error(message('SimBiology:sbionmimport:IntervalDose_InvalidCategoricalCovariate',name));
            end
        end



        function addContinuousCovariate(obj,name,time,value)
            obj.ContinuousCovariates{end+1}=name;
            covariate=SimBiology.internal.Data.TimeValue;
            covariate.Time=time;
            covariate.Value=value;
            obj.ContinuousValues(end+1)=covariate;
        end

        function value=getContinuousCovariate(obj,name)
            allNames=obj.ContinuousCovariates;
            index=find(strcmp(name,allNames));

            if~isempty(index)&&length(index)==1
                value=obj.ContinuousValues(index);
            else
                error(message('SimBiology:sbionmimport:IntervalDose_InvalidContinuousCovariate',name));
            end
        end



        function[out,timeLabel,dvLabel,doseLabel,rateLabel,contCovLabel,catCovLabel]=getDataMap(obj)

            time=[];
            numDoses=length(obj.Doses);
            numResponses=length(obj.Responses);
            numContinuousCovariates=length(obj.ContinuousCovariates);
            numCategoricalCovariates=length(obj.CategoricalCovariates);

            for i=1:numDoses
                dt=obj.Doses{i}.getData.Time;
                time=vertcat(time,dt);%#ok<AGROW>
            end

            for i=1:numResponses
                rt=obj.Responses(i).Data.Time;
                time=vertcat(time,rt);%#ok<AGROW>
            end

            for i=1:numContinuousCovariates
                dc=obj.ContinuousValues(i).Time;
                time=vertcat(time,dc);%#ok<AGROW>
            end

            for i=1:numCategoricalCovariates
                dc=obj.CategoricalValues(i).Time;
                time=vertcat(time,dc);%#ok<AGROW>
            end


            time=unique(time);
            doses=zeros(length(time),numDoses);
            rates=zeros(length(time),numDoses);
            responses=nan(length(time),numResponses);
            continuousCovariates=nan(length(time),numContinuousCovariates);
            categoricalCovariates=categorical(nan(length(time),numCategoricalCovariates));











            appendedData=false;

            for i=1:numDoses

                doseData=obj.Doses{i}.getData;
                doseTime=doseData.Time;
                dose=doseData.Amount;
                rate=doseData.Rate;



                for j=1:length(doseTime)
                    timeIdx=(time==doseTime(j));
                    emptyIdx=(doses(:,i)==0);
                    idx=find(timeIdx&emptyIdx,1,'first');
                    if~isempty(idx)
                        doses(idx,i)=dose(j);
                        rates(idx,i)=rate(j);
                    else

                        appendedData=true;
                        time(end+1)=doseTime(j);%#ok<AGROW>


                        tDoses=zeros(1,numDoses);
                        tDoses(1,i)=dose(j);
                        doses(end+1,:)=tDoses;%#ok<AGROW>


                        tRate=zeros(1,numDoses);
                        tRate(1,i)=rate(j);
                        rates(end+1,:)=tRate;%#ok<AGROW>


                        responses(end+1,:)=nan;%#ok<AGROW>
                        continuousCovariates(end+1,:)=nan;%#ok<AGROW>


                        categoricalCovariates(end+1,:)=categorical(nan);%#ok<AGROW>
                    end
                end
            end

            for i=1:numResponses

                responseData=obj.Responses(i).Data;
                responseTime=responseData.Time;
                responseValue=responseData.Value;



                for j=1:length(responseTime)
                    timeIdx=(time==responseTime(j));
                    emptyIdx=(isnan(responses(:,i)));
                    idx=find(timeIdx&emptyIdx,1,'first');
                    if~isempty(idx)
                        responses(idx,i)=responseValue(j);
                    else

                        appendedData=true;
                        time(end+1)=responseTime(j);%#ok<AGROW>


                        tResponses=nan(1,numResponses);
                        tResponses(1,i)=responseValue(j);
                        responses(end+1,:)=tResponses;%#ok<AGROW>


                        doses(end+1,:)=0;%#ok<AGROW>


                        rates(end+1,:)=0;%#ok<AGROW>


                        continuousCovariates(end+1,:)=nan;%#ok<AGROW>


                        categoricalCovariates(end+1,:)=categorical(nan);%#ok<AGROW>
                    end
                end
            end


            for ic=1:numContinuousCovariates

                covariate=obj.ContinuousValues(ic);
                covTime=covariate.Time;
                covValue=covariate.Value;



                for jt=1:length(covTime)
                    timeIdx=(time==covTime(jt));
                    emptyIdx=(isnan(continuousCovariates(:,ic)));
                    idx=find(timeIdx&emptyIdx,1,'first');
                    if~isempty(idx)
                        continuousCovariates(idx,ic)=covValue(jt);
                    else

                        appendedData=true;
                        time(end+1)=covTime(jt);%#ok<AGROW>


                        tCovariates=nan(1,numContinuousCovariates);
                        tCovariates(1,ic)=covValue(jt);
                        continuousCovariates(end+1,:)=tCovariates;%#ok<AGROW>


                        doses(end+1,:)=0;%#ok<AGROW>


                        rates(end+1,:)=0;%#ok<AGROW>


                        responses(end+1,:)=nan;%#ok<AGROW>


                        categoricalCovariates(end+1,:)=categorical(nan);%#ok<AGROW>
                    end
                end
            end


            for ic=1:numCategoricalCovariates

                covariate=obj.CategoricalValues(ic);
                covTime=covariate.Time;
                covValue=covariate.Value;



                for jt=1:length(covTime)
                    timeIdx=(time==covTime(jt));
                    emptyIdx=(isundefined(categoricalCovariates(:,ic)));
                    idx=find(timeIdx&emptyIdx,1,'first');
                    if~isempty(idx)
                        categoricalCovariates(idx,ic)=covValue(jt);
                    else

                        appendedData=true;
                        time(end+1)=covTime(jt);%#ok<AGROW>


                        tCovariates=categorical(nan(1,numCategoricalCovariates));
                        tCovariates(1,ic)=covValue(jt);
                        categoricalCovariates(end+1,:)=tCovariates;%#ok<AGROW>


                        doses(end+1,:)=0;%#ok<AGROW>


                        rates(end+1,:)=0;%#ok<AGROW>


                        responses(end+1,:)=nan;%#ok<AGROW>


                        continuousCovariates(end+1,:)=nan;%#ok<AGROW>
                    end
                end
            end


            if(appendedData)

                [~,sortIdx]=sort(time);
                time=time(sortIdx);
                doses=doses(sortIdx,:);
                rates=rates(sortIdx,:);
                responses=responses(sortIdx,:);
                continuousCovariates=continuousCovariates(sortIdx,:);
                categoricalCovariates=categoricalCovariates(sortIdx,:);
            end

            if size(time,2)~=1
                time=time';
            end


            timeLabel=obj.VarNamer.getName('Time',obj.ReservedNames);
            doseLabel=cell(1,numDoses);
            rateLabel=cell(1,numDoses);
            dvLabel=cell(1,numResponses);
            contCovLabel=cell(1,numContinuousCovariates);
            catCovLabel=cell(1,length(obj.CategoricalCovariates));

            out=containers.Map('KeyType','char','ValueType','any');
            out(timeLabel)=time;
            for i=1:numDoses
                cpt=obj.Doses{i}.Compartment+1;




                doseLabel{i}=obj.VarNamer.getName('Dose',obj.ReservedNames,cpt);
                rateLabel{i}=obj.VarNamer.getName('Rate',obj.ReservedNames,cpt);




                out(doseLabel{i})=doses(:,i);
                out(rateLabel{i})=rates(:,i);
            end


            for i=1:numResponses
                cpt=obj.Responses(i).Compartment+1;
                dvLabel{i}=obj.VarNamer.getName('Response',obj.ReservedNames,cpt);
                out(dvLabel{i})=responses(:,i);
            end


            for i=1:numContinuousCovariates
                contCovLabel{i}=obj.ContinuousCovariates{i};
                out(obj.ContinuousCovariates{i})=continuousCovariates(:,i);
            end




            for i=1:numCategoricalCovariates
                catCovLabel{i}=obj.CategoricalCovariates{i};
                out(obj.CategoricalCovariates{i})=removecats(categoricalCovariates(:,i));
            end
        end



        function out=addDose(obj,dose)
            obj.Doses=[obj.Doses,{dose}];
            out=dose;
        end



        function out=addResponse(obj,response)
            obj.Responses=[obj.Responses,response];
            out=response;
        end

    end
end