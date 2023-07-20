


function[algLoops,totalLoops]=getAlgLoopInfo(objName)



    import Simulink.Structure.*;

    AlgebraicLoop.empty(0);
    algLoops=AlgebraicLoop.empty(0);

    mdl=get_param(bdroot(objName),'Name');
    modelObj=get_param(mdl,'object');

    if(~strcmp(get_param(mdl,'BlockDiagramType'),'model'))
        localCleanup(mdl);
        DAStudio.error('Simulink:utility:invalidInputArgs',mdl);
    end

    simStatus=get_param(mdl,'SimulationStatus');
    if~strcmpi(simStatus,'paused')
        init(modelObj,'COMMAND_LINE','UpdateBDOnly','on','SuppressAlgLoopCompFailure','on');
    end

    isModel=strcmp(get_param(objName,'Type'),'block_diagram');
    isBlock=strcmp(get_param(objName,'Type'),'block');

    if(isModel||isBlock)


        hLoops=findAlgLoops(modelObj);
        totalLoops=length(hLoops);

        if totalLoops<1
            localCleanup(mdl);
            return;
        end

        if isBlock
            objs=get_param(objName,'Object');
            loopId=objs.getAlgebraicLoopId;

            if(loopId<1)
                localCleanup(mdl);
                return;
            end

            for i=1:totalLoops
                loopObj=get_param(hLoops(i),'Object');
                if(loopObj.getAlgebraicLoopId==loopId)
                    hblks=loopObj.getSortedList;
                    if ismember(get_param(objName,'handle'),hblks)
                        loopSelected=hLoops(i);
                        break;
                    end
                end
            end
            hLoops=loopSelected;
        end

        nLoops=length(hLoops);

        if nLoops>0
            for mm=1:nLoops
                hLoop=hLoops(mm);
                algLoops(mm,1)=AlgebraicLoop(modelObj,hLoop);
            end
        end

    else
        MSLException(message('Simulink:utility:invalidInputArgs',mdl)).throw;
    end
end


function localCleanup(mdl)

    if strcmpi(get_param(mdl,'SimulationStatus'),'paused')

        modelObj=get_param(mdl,'object');
        modelObj.term;
    end
end




function hLoops=findAlgLoops(obj)

    hLoops=[];

    hBList=obj.getSortedList;

    n=length(hBList);

    if n<1

        return;
    end

    index=[];
    for i=1:n
        isAlgSub=false;

        bo=get_param(hBList(i),'Object');
        isSubSystem=strcmp(bo.BlockType,'SubSystem');
        isSynthesized=bo.isSynthesized;

        if(isSubSystem&&isSynthesized)
            isAlgSub=strcmp(bo.getSyntReason,'SL_SYNT_BLK_REASON_ALGLOOP');
        end

        if isAlgSub
            topHLoops=hBList(i);
            hLoops=[hLoops;topHLoops];
            index=[index;i];
        end
    end



    for ik=1:length(hBList)

        bo=get_param(hBList(ik),'Object');
        if strcmp(bo.BlockType,'SubSystem')

            subHLoops=findAlgLoops(bo);
            hLoops=[hLoops;subHLoops];
        end
    end

end

