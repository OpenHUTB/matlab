function configureSourceAndHarnessModelCoverage(srcModelH,harnessH,fromMdlFlag,modelRefHarness,sldvAnalysisOptions,componentUnderTest)




    if~fromMdlFlag
        if strcmpi(sldvAnalysisOptions.Mode,'TestGeneration')
            configureMainCoverage(srcModelH,harnessH,modelRefHarness,componentUnderTest);
            newCovMetric='e';


            if strcmpi(sldvAnalysisOptions.getDerivedModelCoverageObjectives(),'MCDC')
                newCovMetric=[newCovMetric,'dcm'];
            elseif strcmpi(sldvAnalysisOptions.getDerivedModelCoverageObjectives(),'ConditionDecision')
                newCovMetric=[newCovMetric,'dc'];
            elseif strcmpi(sldvAnalysisOptions.getDerivedModelCoverageObjectives(),'Decision')
                newCovMetric=[newCovMetric,'d'];
            end
            if strcmpi(sldvAnalysisOptions.IncludeRelationalBoundary,'on')
                if slavteng('feature','RelationalBoundary')
                    newCovMetric=[newCovMetric,'b'];
                end
            end
            if~strcmpi(sldvAnalysisOptions.TestConditions,'DisableAll')||...
                ~strcmpi(sldvAnalysisOptions.TestObjectives,'DisableAll')
                newCovMetric=[newCovMetric,'o'];
            end

            covMetric=get_param(srcModelH,'CovMetricSettings');




            if~isempty(strfind(covMetric,'s'))
                newCovMetric=[newCovMetric,'s'];
            end
            set_param(harnessH,'covMetricSettings',newCovMetric);
        else
            set_param(harnessH,'RecordCoverage','off');
        end


        hAcs=getActiveConfigSet(harnessH);
        hAcs.setPropEnabled('ExpressionFolding',true);
        hAcs.setPropEnabled('BlockReduction',true);
        set_param(harnessH,'ExpressionFolding','off');
        set_param(harnessH,'BlockReduction','off');
    else
        set_param(harnessH,'covPath','/');
        configureMainCoverage(srcModelH,harnessH,modelRefHarness,componentUnderTest);
        if slavteng('feature','RelationalBoundary')
            newCovMetric='dcmb';
        else
            newCovMetric='dcm';
        end
        covMetric=get_param(srcModelH,'CovMetricSettings');
        if~isempty(strfind(covMetric,'t'))
            newCovMetric=[newCovMetric,'t'];
        end
        if~isempty(strfind(covMetric,'r'))
            newCovMetric=[newCovMetric,'r'];
        end
        if~isempty(strfind(covMetric,'z'))
            newCovMetric=[newCovMetric,'z'];
        end

        if~isempty(strfind(covMetric,'s'))
            newCovMetric=[newCovMetric,'s'];
        end
        newCovMetric=[newCovMetric,'oe'];
        set_param(harnessH,'covMetricSettings',newCovMetric);
    end
end

function configureMainCoverage(srcModelH,harnessH,modelRefHarness,componentUnderTest)


...
...
...
...
...
...
...




    if~modelRefHarness
        set_param(harnessH,'CovScope','Subsystem');
        idx=strfind(componentUnderTest,'/');
        componentUnderTestRelative=componentUnderTest(idx(1):end);
        set_param(harnessH,'CovPath',componentUnderTestRelative);
    end



    [~,mdlBlks]=find_mdlrefs(srcModelH,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'AllLevels',false);
    if modelRefHarness
        set_param(harnessH,'covModelRefEnable','on');
        set_param(harnessH,'RecordCoverage','off');
    elseif~isempty(mdlBlks)
        set_param(harnessH,'covModelRefEnable','on');
        set_param(harnessH,'RecordCoverage','on');
    else
        set_param(harnessH,'covModelRefEnable','off');
        set_param(harnessH,'RecordCoverage','on');
    end

    set_param(harnessH,'CovExternalEmlEnable','on');
    set_param(harnessH,'CovSFcnEnable','on');
    set_param(harnessH,'CovHtmlReporting','on');
    set_param(harnessH,'CovHTMLOptions','-aTS=1 -bRG=1 -bTC=0 -hTR=0 -nFC=0 -scm=1 -bcm=1');
end
