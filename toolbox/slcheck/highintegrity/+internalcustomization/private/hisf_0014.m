function hisf_0014

    rec=getNewCheckObject('mathworks.hism.hisf_0014',false,@hCheckAlgo,'None');

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='all';

    rec.setInputParametersLayoutGrid([1,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({HighIntegrity_License,'Stateflow'});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end

function FailingObjs=hCheckAlgo(system)
    FailingObjs={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;



    allTxn=Advisor.Utils.Stateflow.sfFindSys(system,inputParams{1}.Value,inputParams{2}.Value,{'-isa','Stateflow.Transition'},true);
    if isempty(allTxn)
        return;
    end
    allTxn=allTxn(cellfun(@(x)~isempty(x.Source)&&~isempty(x.Destination),allTxn));
    if isempty(allTxn)
        return;
    end
    crossingTxn=allTxn(cellfun(@(x)(x.Source.getParent~=x.Destination.getParent)&&(x.Source~=x.Destination.getParent)&&isa(x.Destination,'Stateflow.Junction'),allTxn));

    for i=1:length(crossingTxn)
        dstJcn=crossingTxn{i}.Destination;
        [~,FailingObjs]=hasPathOutOfParent(dstJcn,FailingObjs,[]);
    end
    FailingObjs=mdladvObj.filterResultWithExclusion(FailingObjs);



    failPath=cellfun(@(x)x.Path,FailingObjs,'UniformOutput',false);
    [~,sortInd]=sort(failPath);

    FailingObjs=FailingObjs(sortInd);
end


function[bResult,failingJcnList]=hasPathOutOfParent(JuT,failingJcnList,traversedJunction)
    bResult=false;




    if any(ismember(traversedJunction,JuT.Id))
        return;
    else
        traversedJunction(end+1)=JuT.Id;
    end


    if any(cellfun(@(x)isequal(x,JuT),failingJcnList))
        bResult=true;
        return;
    else
        outgoingTxn=getSourcedTransitions(JuT);
        for i=1:length(outgoingTxn)
            if(outgoingTxn(i).Destination==outgoingTxn(i).Source)
                continue;
            end

            if isa(outgoingTxn(i).Destination,'Stateflow.State')||...
                isa(outgoingTxn(i).Destination,'Stateflow.AtomicSubchart')||...
                isa(outgoingTxn(i).Destination,'Stateflow.SimulinkBasedState')

                if~isConnectedToSubState(outgoingTxn(i).Destination,JuT)
                    bResult=true;
                    failingJcnList{end+1}=JuT;%#ok<AGROW>
                    return;
                else
                    bResult=false;
                end
            else



                if~isConnectedToSubState(outgoingTxn(i).Destination,JuT)
                    bResult=true;
                    failingJcnList{end+1}=JuT;%#ok<AGROW>
                    return;
                else


                    [bResult,failingJcnList]=hasPathOutOfParent(outgoingTxn(i).Destination,failingJcnList,traversedJunction);
                    if bResult&&~any(cellfun(@(x)isequal(x,JuT),failingJcnList))
                        failingJcnList{end+1}=JuT;%#ok<AGROW>                      
                    end
                end
            end
        end
    end
end

function bResult=isConnectedToSubState(dest_obj,jcn_obj)

    bResult=false;
    while(startsWith(class(dest_obj),'Stateflow'))

        if dest_obj==jcn_obj.getParent


            bResult=true;
            return;
        else

            dest_obj=dest_obj.getParent;
        end
    end
end


function srcTxns=getSourcedTransitions(sfObj)
    srcTxns=[];
    if isa(sfObj,'Stateflow.Function')
        return;
    end
    srcTxns=sfObj.sourcedTransitions;
end