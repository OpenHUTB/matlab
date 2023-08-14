classdef jc_0736_b<slcheck.subcheck
    methods
        function obj=jc_0736_b()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='jc_0736_b';
        end
        function result=run(this)
            result=false;

            sfObj=this.getEntity();

            if isempty(sfObj)
                return;
            end

            if~isa(sfObj,'Stateflow.Transition')
                return;
            end

            labelStringHighlight=sfObj.LabelString;
            labelString=sfObj.LabelString;

            offset=0;

            if isempty(labelString)
                return;
            end

            [asts,~]=Advisor.Utils.Stateflow...
            .getAbstractSyntaxTree(sfObj);


            sections=asts.sections;



            if isempty(sections)
                return
            end


            for secCount=1:numel(sections)

                section=sections{secCount};

                if isa(section,'Stateflow.Ast.ConditionActionSection')
                    sectionLimiter='{';
                elseif isa(section,'Stateflow.Ast.ConditionSection')
                    sectionLimiter='[';
                elseif isa(section,'Stateflow.Ast.TransitionActionSection')
                    sectionLimiter='/';
                else
                    continue
                end

                roots=section.roots;

                if isempty(roots)
                    continue;
                end




                for rootTypeCount=1:numel(roots)

                    root=roots{rootTypeCount};



                    if isempty(strtrim(root.sourceSnippet))
                        continue;
                    end

                    if isa(root,'Stateflow.Ast.PreProcessedCond')||...
                        isa(root,'Stateflow.Ast.PreProcessed')
                        break;
                    end

                end




                if isa(root,'Stateflow.Ast.PreProcessedTrigger')
                    continue
                end


                if isempty(root.sourceSnippet)
                    continue;
                end


                startIndex=root.treeStart;




                for iCount=startIndex:-1:1

                    if strcmp(labelString(iCount),sectionLimiter)
                        break;
                    end

                end



                trueIndex=iCount-1;



                if~isSpaceInIndex(labelString,trueIndex)
                    continue;
                end

                LSLength=length(labelStringHighlight);


                labelStringHighlight=Advisor.Utils.Naming.formatFlaggedName(...
                labelStringHighlight,false,...
                [iCount+offset-1,...
                iCount+offset],'');

                offset=offset+length(labelStringHighlight)-LSLength;

            end

            if 0==offset
                return;
            end

            RDObj=createRDObj(sfObj,labelStringHighlight);

            if isempty(RDObj)
                return;
            end

            result=this.setResult(RDObj);

        end
    end
end


function bool=isSpaceInIndex(labelString,index)





    bool=false;
    if isempty(labelString)
        return;
    end


    if index<1
        return;
    end

    if isempty(regexp(labelString(index),'[ \b\f\t]','once'))
        return;
    end

    bool=true;

end

function RDObj=createRDObj(sfObj,higlightedText)

    MAText=ModelAdvisor.Text(higlightedText);
    MAText.RetainReturn=true;
    MAText.RetainSpaceReturn=true;
    RDObj=ModelAdvisor.ResultDetail;
    ModelAdvisor.ResultDetail.setData(RDObj,'SID',sfObj,'Expression',MAText.emitHTML);
end