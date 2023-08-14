function jmaab_na_0042





    rec=Advisor.Utils.getDefaultCheckObject('mathworks.jmaab.na_0042',false,@CheckAlgo,'None');

    rec.setReportStyle('ModelAdvisor.Report.TableStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.TableStyle'});


    paramFollowLinks=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    paramLookUnderMasks=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');

    paramLookUnderMasks.ColSpan=[3,4];

    rec.setInputParametersLayoutGrid([1,4]);
    rec.setInputParameters({paramFollowLinks,paramLookUnderMasks});


    rec.setLicense({styleguide_license,'Stateflow'});
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});
end


function violations=CheckAlgo(system)


    violations=[];

    ma=Simulink.ModelAdvisor.getModelAdvisor(system);


    FL=Advisor.Utils.getStandardInputParameters(ma,'find_system.FollowLinks');
    LUM=Advisor.Utils.getStandardInputParameters(ma,'find_system.LookUnderMasks');








    chartArray=Advisor.Utils.Stateflow.sfFindSys(system,FL.Value,LUM.Value,{'-isa','Stateflow.Chart'});
    chartArray=ma.filterResultWithExclusion(chartArray);

    for idx=1:length(chartArray)
        chartObj=chartArray{idx};
        statesTransitions=chartObj.find('-isa','Stateflow.State','-or','-isa','Stateflow.Transition');
        SLFunctions=chartObj.find('-isa','Stateflow.SLFunction');

        if isempty(SLFunctions)
            continue;
        end

        fnUsageMap=containers.Map();
        for ifn=1:length(SLFunctions)
            fn.failStatus=true;
            fn.usageCount=0;
            fnUsageMap(SLFunctions(ifn).Name)=fn;
        end

        result=[];

        for jdx=1:length(statesTransitions)
            sfitem=statesTransitions(jdx);

            if isempty(strtrim(sfitem.LabelString))
                continue;
            end


            [ast,resolvedSymbols]=Advisor.Utils.Stateflow.getAbstractSyntaxTree(sfitem);

            if isempty(ast)
                continue;
            end








            prevTreeStart=[];


            sections=ast.sections;
            for i=1:length(sections)
                roots=sections{i}.roots;
                for j=1:length(roots)
                    root=roots{j};


                    if ismember(root.treeStart,prevTreeStart)
                        continue;
                    end

                    prevTreeStart=[prevTreeStart;root.treeStart];%#ok<AGROW>

                    if Advisor.Utils.Stateflow.isActionLanguageC(chartObj)
                        [out,fnUsageMap]=iCheckEventBroadcastC(roots{j},fnUsageMap,sfitem);
                        result=[result;out];%#ok<AGROW>
                    elseif Advisor.Utils.Stateflow.isActionLanguageM(chartObj)
                        [out,fnUsageMap]=iCheckEventBroadcastM(roots{j},resolvedSymbols,fnUsageMap,sfitem);
                        result=[result;out];%#ok<AGROW>
                    end
                end
            end
        end


        for i=1:length(result)
            current=result(i);
            if isKey(fnUsageMap,current.fnName)&&fnUsageMap(current.fnName).usageCount<=1
                violations=[violations;createResultDetail(current.sfitem,current.reason)];%#ok<AGROW>
            end
        end



        for i=1:length(SLFunctions)
            current=SLFunctions(i);

            if isKey(fnUsageMap,current.Name)&&...
                fnUsageMap(current.Name).failStatus&&...
                fnUsageMap(current.Name).usageCount<=1
                violations=[violations;createResultDetail(current,DAStudio.message('ModelAdvisor:jmaab:na_0042_multiple'))];%#ok<AGROW>
            end
        end

    end
end


function[result,fnUsageMap]=iCheckEventBroadcastC(ast,fnUsageMap,sfitem)

    result=[];

    if(isa(ast,'Stateflow.Ast.UserFunction'))


        sfHandle=idToHandle(sfroot,ast.id);
        if isempty(sfHandle)
            return;
        end

        fnName=sfHandle.Name;

        if~ismember(fnName,fnUsageMap.keys)
            return;
        end

        fcnData=fnUsageMap(fnName);
        fcnData.usageCount=fcnData.usageCount+1;
        fnUsageMap(fnName)=fcnData;

        if fnUsageMap(fnName).usageCount>1
            return;
        end

        inputs=ast.children;

        if isempty(inputs)
            return;
        end

        bOneLocalInput=false;

        for idx=1:length(inputs)
            inp=inputs{idx};
            if~isa(inp,'Stateflow.Ast.Identifier')
                continue;
            end
            if inp.id==Advisor.Utils.Stateflow.filterSymbolIds(inp.id,'data')
                data=idToHandle(sfroot,inp.id);
                if~(strcmp(data.Scope,'Local')||strcmp(data.Scope,'Input'))
                    res.indices=[ast.treeStart,ast.treeEnd];
                    res.fnName=fnName;
                    res.reason=DAStudio.message('ModelAdvisor:jmaab:na_0042_local');
                    res.sfitem=sfitem;
                    result=[result,res];%#ok<AGROW>
                    return;
                end

                bOneLocalInput=bOneLocalInput||strcmp(data.Scope,'Local');
            end
        end

        if~bOneLocalInput
            res.indices=[ast.treeStart,ast.treeEnd];
            res.fnName=fnName;
            res.reason=DAStudio.message('ModelAdvisor:jmaab:na_0042_mixture');
            res.sfitem=sfitem;
            result=[result,res];
            return;
        end

        fcnData.failStatus=false;
        fnUsageMap(fnName)=fcnData;

    end


    children=ast.children;
    for i=1:length(children)
        [res,fnUsageMap]=iCheckEventBroadcastC(children{i},fnUsageMap,sfitem);
        result=[result;res];%#ok<AGROW>
    end
end



function[result,fnUsageMap]=iCheckEventBroadcastM(astRoot,resolvedSymbols,fnUsageMap,sfitem)

    result=[];

    if isempty(astRoot.sourceSnippet)
        return;
    end

    fcns=fnUsageMap.keys;

    resolvedData=Advisor.Utils.Stateflow.filterSymbolIds(resolvedSymbols,'data');
    resolvedData=idToHandle(sfroot,resolvedData);


    treeObject=Advisor.Utils.Stateflow.createMtreeObject(astRoot.sourceSnippet);
    for fcnIndex=1:length(fcns)

        fcn=fcns{fcnIndex};
        if~ismember(fcn,fnUsageMap.keys)
            continue;
        end

        callTrees=treeObject.mtfind('String',fcn);

        if callTrees.isempty
            continue;
        end

        if length(callTrees.indices)>1
            fcnData=fnUsageMap(fcn);
            fcnData.usageCount=fcnData.usageCount+length(callTrees.indices);
            fnUsageMap(fcn)=fcnData;
            continue;
        end


        for treeIndex=callTrees.indices
            fcnData=fnUsageMap(fcn);
            fcnData.usageCount=fcnData.usageCount+1;
            fnUsageMap(fcn)=fcnData;
            if fnUsageMap(fcn).usageCount>1
                continue;
            end

            thisTree=callTrees.select(treeIndex);
            if strcmp(thisTree.Parent.kind,'CALL')
                argTree=thisTree.Parent;
                argTree=argTree.Right.Full;
                args=argTree.mtfind('Kind','ID').strings;
                resData=cellfun(@(x)getResolvedDataForInput(x,resolvedData),args,'UniformOutput',false);

                if isempty(resData)
                    continue;
                end

                bInputOrLocal=all(ismember(resData,{'Input','Local'}));
                bOneLocalInput=any(ismember(resData,'Local'));
                if~bInputOrLocal

                    res.indices=[astRoot.treeStart+thisTree.Parent.lefttreepos-1...
                    ,astRoot.treeStart+thisTree.Parent.righttreepos-1];
                    res.fnName=fcn;
                    res.reason=DAStudio.message('ModelAdvisor:jmaab:na_0042_local');
                    res.sfitem=sfitem;
                    result=[result,res];%#ok<AGROW>
                elseif~bOneLocalInput
                    res.indices=[astRoot.treeStart+thisTree.Parent.lefttreepos-1...
                    ,astRoot.treeStart+thisTree.Parent.righttreepos-1];
                    res.fnName=fcn;
                    res.reason=DAStudio.message('ModelAdvisor:jmaab:na_0042_mixture');
                    res.sfitem=sfitem;
                    result=[result,res];%#ok<AGROW>
                else
                    fcnData=fnUsageMap(fcn);
                    fcnData.failStatus=false;
                    fnUsageMap(fcn)=fcnData;
                end
            end
        end

    end
end


function viola=createResultDetail(sfItem,sourceSnippet)
    viola=ModelAdvisor.ResultDetail;

    ModelAdvisor.ResultDetail.setData(viola,'Custom',...
    DAStudio.message('ModelAdvisor:jmaab:na_0042_col_path'),sfItem,...
    DAStudio.message('ModelAdvisor:jmaab:na_0042_col_reason'),sourceSnippet);
end


function res=getResolvedDataForInput(in,resolvedData)
    res='';
    for idx=1:length(resolvedData)
        if strcmp(in,resolvedData(idx).Name)
            res=resolvedData(idx).Scope;
            return;
        end
    end
end
