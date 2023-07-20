classdef jc_0774_a<slcheck.subcheck
    methods
        function obj=jc_0774_a()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='jc_0774_a';
        end

        function result=run(this)

            result=false;


            sfTObj=this.getEntity();

            if isempty(sfTObj)
                return;
            end

            if~isa(sfTObj,'Stateflow.Transition')
                return;
            end

            if~isprop(sfTObj,'LabelString')
                return;
            end



            srcObj=sfTObj.source;


            DestinationObj=sfTObj.Destination;







            labelstring=strtrim(regexprep(sfTObj.labelString,'[{}/]',''));







            if~isempty(labelstring)||...
                isempty(srcObj)||...
                isempty(DestinationObj)
                return;
            end













            if~isConditionalTransitionSrc(srcObj)||...
                isConditionalTransitionSrc(DestinationObj)

                return;
            end



            rdObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(rdObj,'SID',sfTObj);
            result=this.setResult(rdObj);

        end
    end
end

function bool=isConditionalTransitionSrc(sfJunction)



    bool=false;

    if isempty(sfJunction)
        return;
    end





    if~isa(sfJunction,'Stateflow.Junction')
        return;
    end

    sourcedTransitions=sfJunction.sourcedTransitions;

    if isempty(sourcedTransitions)
        return;
    end

    for tCount=1:numel(sourcedTransitions)

        section=Advisor.Utils.Stateflow...
        .getAbstractSyntaxTree(sourcedTransitions(tCount));

        if isempty(section)
            continue;
        end

        if~isempty(section.conditionSection)
            bool=true;
            return;
        end
    end
end