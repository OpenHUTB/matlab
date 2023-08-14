function res=run(config)

    c=jsondecode(config);
    sltest.assessments.internal.AssessmentsRunner.stop(false);
    if c.isExplore
        if strcmp(c.exploreStrategy,'PatternSearch')
            e=sltest.assessments.internal.PatternSearch(c);
        else
            if strcmp(c.exploreStrategy,'Random')
                e=sltest.assessments.internal.AssessmentsRunner(c);
            else
                if strcmp(c.exploreStrategy,'Custom')
                    if(any(strcmp(superclasses(c.exploreCustomStrategy),'sltest.assessments.internal.AssessmentsRunner')))
                        runner=str2func(c.exploreCustomStrategy);
                        e=runner(c);
                    else
                        error('Invalid custom strategy');
                    end
                end
            end
        end
    else
        e=sltest.assessments.internal.AssessmentsRunner(c);
    end
    e.explore;

    if e.IsExplore

        res=true;
    else
        res=e.Result;
        for idx=1:numel(res)
            res(idx).Result=sltest.assessments.internal.AssessmentResultDB.saveResult(res(idx).Result);
        end
    end

end

