classdef StateflowLOCCount<slmetric.metric.Metric



    properties

    end

    methods
        function this=StateflowLOCCount()
            this.ID='mathworks.metrics.StateflowLOCCount';
            this.CompileContext='None';
            this.Version=2;
            this.ComponentScope=[...
            Advisor.component.Types.Chart];
            this.AggregationMode=slmetric.AggregationMode.Sum;
            this.Name=DAStudio.message('slcheck:metric:StateflowLOCCount_Name');
            this.Description=DAStudio.message('slcheck:metric:StateflowLOCCount_Desc');
            this.ValueName=DAStudio.message('slcheck:metric:StateflowLOCCount_ValueLabel');
            this.AggregatedValueName=DAStudio.message('slcheck:metric:StateflowLOCCount_AggregateValueLabel');
            this.setCSH('ma.metricchecks','StateflowLOCCount');
        end

        function res=algorithm(this,component)

            res=slmetric.metric.Result();
            res.MetricID=this.ID;
            res.ComponentID=component.ID;



            chartObj=Advisor.component.getComponentSource(component);










            if~isempty(chartObj)
                mloc=0;
                cloc=0;


                if isa(chartObj,'Stateflow.Chart')
                    [mloc,cloc]=slmetric.internal.metric.StateflowLOCCount.getStateLOC(chartObj);
                    [new_mloc,new_cloc]=slmetric.internal.metric.StateflowLOCCount.getTransitionLOC(chartObj);
                    mloc=mloc+new_mloc;
                    cloc=cloc+new_cloc;



                    [new_mloc,new_cloc]=slmetric.internal.metric.StateflowLOCCount.getThruthTableLOC(chartObj);
                    mloc=mloc+new_mloc;
                    cloc=cloc+new_cloc;

                elseif isa(chartObj,'Stateflow.TruthTableChart')
                    [mloc,cloc]=slmetric.internal.metric.StateflowLOCCount.getThruthTableLOC(chartObj);
                elseif isa(chartObj,'Stateflow.StateTransitionTableChart')
                    [mloc,cloc]=slmetric.internal.metric.StateflowLOCCount.getStateTransitionTableLOC(chartObj);
                end

                res.Measures=[mloc,cloc];
                res.Value=mloc+cloc;
            else
                res.Measures=[0,0];
                res.Value=0;
            end
        end
    end


    methods(Access=private,Static)

        function[mloc,cloc]=getStateLOC(chart)
            mloc=0;
            cloc=0;
            states=chart.find('-isa','Stateflow.State',...
            '-and','Chart',chart);

            states=states(arrayfun(@(o)(~isCommented(o)),states));

            if strcmp(chart.ActionLanguage,'MATLAB')
                for n=1:length(states)
                    state=states(n);
                    [asts,~]=Advisor.Utils.Stateflow.getAbstractSyntaxTree(state);
                    mloc=mloc+slmetric.internal.metric.StateflowLOCCount.getMLOCByAST(asts);
                end
            elseif strcmp(chart.ActionLanguage,'C')
                for n=1:length(states)
                    state=states(n);

                    cloc=cloc+slmetric.internal.metric.StateflowLOCCount.getLOCByString(state.LabelString,true)-1;
                end
            end
        end

        function[mloc,cloc]=getTransitionLOC(chart)
            mloc=0;
            cloc=0;

            trans=chart.find('-isa','Stateflow.Transition',...
            '-and','Chart',chart);

            trans=trans(arrayfun(@(o)(~isCommented(o)),trans));


            if strcmp(chart.ActionLanguage,'MATLAB')
                for n=1:length(trans)
                    t=trans(n);



                    if isa(t.Subviewer,'Stateflow.TruthTable')
                        continue;
                    end

                    [asts,~]=Advisor.Utils.Stateflow.getAbstractSyntaxTree(t);
                    mloc=mloc+slmetric.internal.metric.StateflowLOCCount.getMLOCByAST(asts);
                end
            elseif strcmp(chart.ActionLanguage,'C')
                for n=1:length(trans)
                    t=trans(n);



                    if isa(t.Subviewer,'Stateflow.TruthTable')
                        continue;
                    end

                    cloc=cloc+slmetric.internal.metric.StateflowLOCCount.getLOCByString(t.LabelString,true);
                end
            end
        end

        function[mloc,cloc]=getStateTransitionTableLOC(chart)

            mloc=0;
            cloc=0;

            if isa(chart,'Stateflow.StateTransitionTableChart')
                stt=chart;
                [mloc_new,cloc_new]=slmetric.internal.metric.StateflowLOCCount.getStateLOC(stt);
                mloc=mloc+mloc_new;
                cloc=cloc+cloc_new;

                [mloc_new,cloc_new]=slmetric.internal.metric.StateflowLOCCount.getTransitionLOC(stt);
                mloc=mloc+mloc_new;
                cloc=cloc+cloc_new;
            end
        end

        function[mloc,cloc]=getThruthTableLOC(chart)
            mloc=0;
            cloc=0;



            tts=chart.find('-isa','Stateflow.TruthTable','-and',...
            '-and','Chart',chart);

            tts=tts(arrayfun(@(o)(~isCommented(o)),tts));

            for n=1:length(tts)

                tt=tts(n);


                if tt.isCommented
                    continue;
                end

                cTable=tt.ConditionTable;
                aTable=tt.ActionTable;




                if strcmp(tt.Language,'MATLAB')
                    for row=1:size(cTable,1)-1
                        mloc=mloc+slmetric.internal.metric.StateflowLOCCount.getLOCByString(cTable{row,2},false);
                    end
                elseif strcmp(tt.Language,'C')
                    for row=1:size(cTable,1)-1
                        cloc=cloc+slmetric.internal.metric.StateflowLOCCount.getLOCByString(cTable{row,2},true);
                    end
                end


                if strcmp(tt.Language,'MATLAB')
                    for row=1:size(aTable,1)
                        mloc=mloc+slmetric.internal.metric.StateflowLOCCount.getLOCByString(aTable{row,2},false);
                    end
                elseif strcmp(tt.Language,'C')
                    for row=1:size(aTable,1)
                        cloc=cloc+slmetric.internal.metric.StateflowLOCCount.getLOCByString(aTable{row,2},true);
                    end
                end
            end
        end

        function loc=getLOCByString(s,bCLanguage)



            if strcmp('?',strtrim(s))
                loc=0;
                return;
            end






            if bCLanguage
                lineCommentPrefix='//';
                multiLineCommentPrefix='/\*';
                multiLinecommentPostfix='\*/';
            else
                lineCommentPrefix='%';
                multiLineCommentPrefix='%{';
                multiLinecommentPostfix='%}';
            end



            comment_free=false;
            while(~comment_free)

                startIdx=regexp(s,multiLineCommentPrefix,'once');

                if isempty(startIdx)
                    comment_free=true;
                else
                    endIdx=regexp(s,multiLinecommentPostfix,'once');

                    if isempty(endIdx)


                        s="";
                        comment_free=true;
                    elseif startIdx==1
                        s=s(endIdx+2:end);
                        comment_free=false;
                    else
                        s1=s(1:startIdx-1);
                        s2=s(endIdx+2:end);
                        s=[s1,s2];
                        comment_free=false;
                    end
                end
            end






            lines=strip(splitlines(string(s)));
            lines=lines(arrayfun(@(x)strlength(x)>0,lines));

            for i=1:length(lines)

                line=lines(i);


                startIdx=regexp(line,lineCommentPrefix,'once');
                if~isempty(startIdx)
                    if startIdx==1
                        line=string('');
                    else
                        ca=char(line);
                        line=strip(string(ca(1:startIdx-1)));
                    end

                end


                line=erase(line,'{');
                line=erase(line,'}');
                line=erase(line,'(');
                line=erase(line,')');
                line=erase(line,'[');
                line=erase(line,']');


                line=erase(line,';');


                if line.endsWith(':')
                    line=string('');
                end


                if~bCLanguage
                    line=erase(line,'end');
                end

                lines(i)=line;

            end
            lines=lines(arrayfun(@(x)strlength(x)>0,lines));

            loc=length(lines);

        end

        function loc=getMLOCByAST(asts)
            loc=0;

            for i=1:length(asts.sections)
                section=asts.sections{i};
                for j=1:length(section.roots)
                    root=section.roots{j};
                    loc=loc+slmetric.internal.metric.StateflowLOCCount.getLOCByString(root.sourceSnippet,false);
                end

            end
        end


    end
end

