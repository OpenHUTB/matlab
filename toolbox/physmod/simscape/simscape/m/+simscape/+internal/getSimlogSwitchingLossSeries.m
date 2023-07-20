function cellOut=getSimlogSwitchingLossSeries(simlog)











    switchingLossTypes={'lastTurnOnLoss',...
    'lastTurnOffLoss',...
    'lastReverseRecoveryLoss'};

    switchingLossCellOut=cell(size(switchingLossTypes));

    for idxSwLoss=1:length(switchingLossTypes)
        switchingLossCellOut{idxSwLoss}=getSimlogSeriesForVarName(switchingLossTypes{idxSwLoss},simlog);
    end

    if isempty(switchingLossCellOut)
        cellOut={};
    else
        cellOut=joinSwitchingLossCells(switchingLossCellOut);
    end

end


function cellOut=getSimlogSeriesForVarName(varName,simlog,ancestorNodeName,cellOut)









    if~exist('cellOut','var')
        cellOut={};
    end


    if isa(simlog,'simscape.logging.Node')

        if~exist('ancestorNodeName','var')
            thisNodeName=simlog.id;
        else
            thisNodeName=[ancestorNodeName,'.',simlog.id];
        end


        children=childIds(simlog);

        for idx=1:length(children)

            thisNode=simlog.(children{idx});

            if max(size(thisNode))==1

                if strcmp(thisNode.id,varName)

                    t=thisNode.series.time;
                    varValues=thisNode.series.values('J');


                    cellOut{end+1,1}=thisNodeName;%#ok<AGROW>
                    cellOut{end,2}=[t,varValues];
                    cellOut{end,3}=thisNode.getSource;
                else

                    cellOut=getSimlogSeriesForVarName(varName,thisNode,thisNodeName,cellOut);
                end
            else




                for jdx=1:sum(size(thisNode))-sum(size(thisNode)==1)

                    if strcmp(thisNode(jdx).id,varName)

                        t=thisNode.series.time;
                        varValues=thisNode.series.values('J');


                        cellOut{end+1,1}=thisNodeName;%#ok<AGROW>
                        cellOut{end,2}=[t,varValues];
                        cellOut{end,3}=thisNode.getSource;
                    else

                        cellOut=getSimlogSeriesForVarName(varName,thisNode(jdx),thisNodeName(jdx),cellOut);
                    end
                end
            end
        end
    end


end

function cellOut=joinSwitchingLossCells(switchingLossCellOut)




    cellOut=cell(0,3);
    for idxSwLoss=1:length(switchingLossCellOut)

        thisSwLossCell=switchingLossCellOut{idxSwLoss};
        if~isempty(thisSwLossCell)
            nodeNames=thisSwLossCell(:,1);
            lossTimeSeries=thisSwLossCell(:,2);
            sourceIDs=thisSwLossCell(:,3);

            [lastNode,~]=size(cellOut);
            cellOut(lastNode+1:lastNode+length(nodeNames),1)=nodeNames;
            cellOut(lastNode+1:lastNode+length(nodeNames),2)=lossTimeSeries;
            cellOut(lastNode+1:lastNode+length(nodeNames),3)=sourceIDs;
        end

    end

end