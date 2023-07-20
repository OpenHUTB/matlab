function jmaab_db_0126

    rec=Advisor.Utils.getDefaultCheckObject('mathworks.jmaab.db_0126',false,@CheckAlgo,'None');

    rec.SupportExclusion=true;

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';

    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParametersLayoutGrid([2,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({styleguide_license,'Stateflow'});

    rec.setReportStyle('ModelAdvisor.Report.TableStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.TableStyle'});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end




function[resultDetail]=CheckAlgo(system)


    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    resultDetail=[];

    flv=mdlAdvObj.getInputParameterByName('Follow links');
    lum=mdlAdvObj.getInputParameterByName('Look under masks');

    SFCharts=Advisor.Utils.Stateflow.sfFindSys...
    (system,flv.value,lum.value,{'-isa','Stateflow.Chart'},true);

    if isempty(SFCharts)
        return;
    end

    SFCharts=mdlAdvObj.filterResultWithExclusion(SFCharts);

    if isempty(SFCharts)
        return;
    end


    for cCount=1:numel(SFCharts)


        eventObj=SFCharts{cCount}.find('-isa','Stateflow.Event',...
        'Scope','Local');

        if isempty(eventObj)
            continue;
        end



        sfObj=SFCharts{cCount}.find('-isa','Stateflow.State','-or',...
        '-isa','Stateflow.Transition','-or',...
        '-isa','Stateflow.TruthTable');
        if isempty(sfObj)
            continue;
        end





        eventIds=cell(1,numel(eventObj));
        eventPaths=cell(1,numel(eventObj));

        for eventCount=1:numel(eventObj)

            eventIds{eventCount}=eventObj(eventCount).Id;

            eventPaths{eventCount}=eventObj(eventCount).getParent;
        end


        eventMap=containers.Map(eventIds,eventPaths);











        smallestScope=cell(1,numel(eventIds));
        eventScopeMap=containers.Map(eventIds,smallestScope);















        for sfoCount=1:numel(sfObj)


            sfEvent=getEventsInSFObject(sfObj(sfoCount));

            if isempty(sfEvent)
                continue;
            end

            eventBroadcast=doesEventUseSendSyntax(sfObj(sfoCount));
            for eventCount=1:numel(sfEvent)

                if~eventScopeMap.isKey(sfEvent(eventCount))
                    continue;
                end
                if isempty(eventScopeMap(sfEvent(eventCount)))


                    eventScopeMap(sfEvent(eventCount))=getParent(sfObj(sfoCount));

                else




                    currentObj=eventScopeMap(sfEvent(eventCount));
                    currentScope=strsplit(currentObj.getFullName,'/');



                    newScope=strsplit(sfObj(sfoCount).getFullName,'/');



                    commonLevels=intersect(newScope,currentScope,'stable');
                    levelDiff=(numel(currentScope)-numel(commonLevels));
                    obj=currentObj;
                    for it=1:levelDiff
                        obj=obj.getParent;
                    end
                    eventScopeMap(sfEvent(eventCount))=obj;
                end
            end
        end






        for eventCount=1:numel(eventObj)



            definedObj=eventMap(eventObj(eventCount).Id);
            smallestScopeObj=eventScopeMap(eventObj(eventCount).Id);

            if isempty(smallestScopeObj)
                continue;
            end

            if definedObj.Id==smallestScopeObj.Id
                continue;
            end


            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'Custom',...
            DAStudio.message('ModelAdvisor:jmaab:db_0126_col1'),...
            eventObj(eventCount),...
            DAStudio.message('ModelAdvisor:jmaab:db_0126_col2'),...
            smallestScopeObj);

            resultDetail=[resultDetail,vObj];


        end

    end

end

function parentObj=getParent(obj)





    if isa(obj,'Stateflow.Transition')
        parentObj=obj.getParent;
    else
        parentObj=obj;
    end
end

function event=getEventsInSFObject(sfObj)



    event=[];





    tempIds=sf('ResolvedSymbolsIn',sfObj.Id);
    resolvedSymbolIds=unique(tempIds);


    if isempty(resolvedSymbolIds)
        return;
    end


    for idCount=1:numel(resolvedSymbolIds)


        if 7~=sf('get',resolvedSymbolIds(idCount),'.isa')
            continue;
        end

        event=[event;resolvedSymbolIds(idCount)];
    end
end


function result=doesEventUseSendSyntax(obj)

    if isa(obj,'Stateflow.State')
        ls=obj.LabelString;
    elseif isa(obj,'Stateflow.TruthTable')
        ls=obj.ActionTable(:,2);
    elseif isa(obj,'Stateflow.Transition')
        ls=obj.LabelString;
    end

    regexpstr='.*(send)\(.*\,.*)';
    if iscell(ls)
        result=any(cellfun(@(x)~isempty(regexp(x,regexpstr,'once')),ls));
    else
        result=~isempty(regexp(ls,regexpstr,'once'));
    end
end