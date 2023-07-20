function FailingExpressions=GetFailingExpressions(system,mdladvObj,CVerifyHandle,MVerifyHandle)

    FailingExpressions=[];


    m=get_param(system,'Object');
    chartArray=m.find('-isa','Stateflow.Chart');


    chartArray=mdladvObj.filterResultWithExclusion(chartArray);

    for ii=1:length(chartArray)
        chartObj=chartArray(ii);
        StatesTransitions=chartObj.find('-isa','Stateflow.State','-or','-isa','Stateflow.Transition');
        StatesTransitions=StatesTransitions.find('IsExplicitlyCommented',0);
        for jj=1:length(StatesTransitions)
            obj=StatesTransitions(jj);

            [asts,resolvedSymbolIds]=Advisor.Utils.Stateflow.getAbstractSyntaxTree(obj);
            if isempty(asts)
                continue;
            end


            FETemp.sfObj=obj;
            FETemp.indices=[];
            FETemp.indicesUnknown=[];


            sections=asts.sections;
            for i=1:length(sections)
                roots=sections{i}.roots;
                for j=1:length(roots)

                    if Advisor.Utils.Stateflow.isActionLanguageC(chartObj)
                        [indicesTemp,indicesUnknownTemp]=feval(CVerifyHandle,system,roots{j},chartObj);
                        FETemp.indices=[FETemp.indices;indicesTemp];
                        FETemp.indicesUnknown=[FETemp.indicesUnknown;indicesUnknownTemp];
                    elseif Advisor.Utils.Stateflow.isActionLanguageM(chartObj)
                        [indicesTemp,indicesUnknownTemp]=feval(MVerifyHandle,system,roots{j},resolvedSymbolIds);
                        FETemp.indices=[FETemp.indices;indicesTemp];
                        FETemp.indicesUnknown=[FETemp.indicesUnknown;indicesUnknownTemp];
                    end

                end
            end


            FailingExpressions=[FailingExpressions;FETemp];%#ok<AGROW>           

        end
    end



end