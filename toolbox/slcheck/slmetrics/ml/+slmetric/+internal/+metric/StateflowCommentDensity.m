classdef StateflowCommentDensity<slmetric.metric.Metric



    methods
        function this=StateflowCommentDensity()

            this.ID='mathworks.metrics.StateflowCommentDensity';
            this.CompileContext='None';
            this.Version=1;
            this.ComponentScope=[...
            Advisor.component.Types.Chart];
            this.AggregationMode=slmetric.AggregationMode.None;
            this.Name=...
            DAStudio.message('slcheck:metric:StateflowCommentDensity_Name');
            this.Description=...
            DAStudio.message('slcheck:metric:StateflowCommentDensity_Desc');
            this.ValueName=...
            DAStudio.message('slcheck:metric:StateflowCommentDensity_ValueLabel');
            this.MeasuresNames={...
            DAStudio.message('slcheck:metric:StateflowCommentDensity_MeasuresLabell'),...
            DAStudio.message('slcheck:metric:StateflowCommentDensity_MeasuresLabel2')};


        end

        function res=algorithm(this,component)



            res=slmetric.metric.Result();
            res.MetricID=this.ID;
            res.ComponentID=component.ID;
            res.Measures=[0,0];
            res.Value=0;



            chartObj=Advisor.component.getComponentSource(component);

            if~isempty(chartObj)
                codeLines=0;
                commentLines=0;
                commentDesnity=0;
                if isa(chartObj,'Stateflow.Chart')

                    [newCodeLines,newCommentLines]=this.handleStates(chartObj);
                    codeLines=codeLines+newCodeLines;
                    commentLines=commentLines+newCommentLines;

                    [newCodeLines,newCommentLines]=this.handleTransitions(chartObj);
                    codeLines=codeLines+newCodeLines;
                    commentLines=commentLines+newCommentLines;

                    commentDesnity=commentLines/codeLines;
                end
                res.Measures=[codeLines,commentLines];
                res.Value=commentDesnity;
            else
                res.Measures=[0,0];
                res.Value=0;
            end

        end
    end

    methods(Access=private,Static)


        function[loc,cloc]=handleStates(chart)
            loc=0;
            cloc=0;
            states=chart.find('-isa','Stateflow.State',...
            '-and','Chart',chart);

            if(isempty(states))
                return;
            end

            states=states(arrayfun(@(o)(~isCommented(o)),states));

            for n=1:length(states)
                state=states(n);
                if strcmp(chart.ActionLanguage,'MATLAB')
                    [nloc,ncloc]=slmetric.internal.metric.StateflowCommentDensity.getLOCByString(state.LabelString,false);
                else
                    [nloc,ncloc]=slmetric.internal.metric.StateflowCommentDensity.getLOCByString(state.LabelString,true);
                end

                loc=loc+nloc-1;
                cloc=cloc+ncloc;

            end
        end


        function[loc,cloc]=handleTransitions(chart)





            loc=0;
            cloc=0;
            trans=chart.find('-isa','Stateflow.Transition',...
            '-and','Chart',chart);

            if(isempty(trans))
                return;
            end

            trans=trans(arrayfun(@(o)(~isCommented(o)),trans));

            for n=1:length(trans)
                t=trans(n);



                if isa(t.Subviewer,'Stateflow.TruthTable')
                    continue;
                end
                if strcmp(chart.ActionLanguage,'MATLAB')
                    [nloc,ncloc]=slmetric.internal.metric.StateflowCommentDensity.getLOCByString(t.LabelString,false);
                else
                    [nloc,ncloc]=slmetric.internal.metric.StateflowCommentDensity.getLOCByString(t.LabelString,true);
                end
                loc=loc+nloc;
                cloc=cloc+ncloc;

            end

        end

        function[loc,cloc]=getLOCByString(codeString,bCLanguage)


            loc=0;
            cloc=0;




            if strcmp('?',strtrim(codeString))
                return;
            end







            lines=strip(splitlines(string(codeString)));
            for i=1:length(lines)
                line=lines(i);
                line=strtrim(line);
                line=erase(line,'{');
                line=erase(line,'}');
                line=erase(line,'(');
                line=erase(line,')');
                line=erase(line,'[');
                line=erase(line,']');
                line=erase(line,';');


                if line.endsWith(':')
                    line="";
                end


                if~bCLanguage
                    line=erase(line,'end');
                else
                    line=erase(line,'*/');
                    line=erase(line,'/*');
                end
                lines(i)=line;
            end
            lines=lines(arrayfun(@(x)strlength(x)>0,lines));
            loc=length(lines);


            if bCLanguage



                [codeString,ncloc]=slmetric.internal.metric.StateflowCommentDensity.getMultiLineComments(codeString);
                cloc=cloc+ncloc;



                regularExpression='(?-s)//.*';
                [codeString,ncloc]=slmetric.internal.metric.StateflowCommentDensity.getSingleLineComment(codeString,regularExpression);
                cloc=cloc+ncloc;


                regularExpression='(?-s)%.*';
                [~,ncloc]=slmetric.internal.metric.StateflowCommentDensity.getSingleLineComment(codeString,regularExpression);
                cloc=cloc+ncloc;


            else
                regularExpression='(?-s)%.*';
                [~,cloc]=slmetric.internal.metric.StateflowCommentDensity.getSingleLineComment(codeString,regularExpression);
            end
        end



        function[codeString,cloc]=getSingleLineComment(codeString,regularExpression)


            [startIndex,endIndex]=regexpi(codeString,regularExpression);
            cloc=length(startIndex);
            charCount=0;
            for count=1:cloc
                endIndex(count)=endIndex(count)-charCount;
                startIndex(count)=startIndex(count)-charCount;
                charCount=charCount+endIndex(count)-startIndex(count)+1;
                codeString(startIndex(count):endIndex(count))=[];
            end

        end

        function[codeString,cloc]=getMultiLineComments(codeString)



            cloc=0;
            startList=strfind(codeString,'/*');
            endList=strfind(codeString,'*/');
            iter=1;
            lengthOfList=length(startList);
            count=1;
            startIndex=zeros(1,lengthOfList);
            stopIndex=zeros(1,lengthOfList);











            if length(startList)==length(endList)
                while iter<=lengthOfList

                    if iter==lengthOfList
                        cloc=cloc+slmetric.internal.metric.StateflowCommentDensity.getCommentCount(codeString,startList(iter),endList(iter));
                        startIndex(count)=startList(iter);
                        stopIndex(count)=endList(iter);
                        break
                    end
                    if(endList(iter)<startList(iter+1)&&endList(iter)>startList(iter))
                        cloc=cloc+slmetric.internal.metric.StateflowCommentDensity.getCommentCount(codeString,startList(iter),endList(iter));
                        startIndex(count)=startList(iter);
                        stopIndex(count)=endList(iter);
                        count=count+1;

                        iter=iter+1;
                    else
                        iterNested=iter;
                        while startList(iterNested)<endList(iter)
                            iterNested=iterNested+1;
                            if iterNested>lengthOfList
                                break;
                            end
                        end
                        iterNested=iterNested-1;
                        cloc=cloc+slmetric.internal.metric.StateflowCommentDensity.getCommentCount(codeString,startList(iter),endList(iterNested));
                        startIndex(count)=startList(iter);
                        stopIndex(count)=endList(iterNested);
                        count=count+1;
                        iter=iterNested+1;
                    end
                end
            end
            charCount=0;
            for m=1:count-1
                stopIndex(m)=stopIndex(m)+1-charCount;
                startIndex(m)=startIndex(m)-charCount;
                charCount=charCount+stopIndex(m)-startIndex(m)+1;
                codeString(startIndex(m):stopIndex(m))=[];

            end
        end

        function cloc=getCommentCount(codeString,startCount,endCount)



            commentSection=codeString(startCount:endCount+1);
            if commentSection
                commentSection=erase(commentSection,'/*');
                commentSection=erase(commentSection,'*/');
                lines=strip(splitlines(strtrim(commentSection)));
                lines=lines(arrayfun(@(x)strlength(x)>0,lines));
                cloc=length(lines);
            else
                cloc=0;
            end
        end

    end



end

