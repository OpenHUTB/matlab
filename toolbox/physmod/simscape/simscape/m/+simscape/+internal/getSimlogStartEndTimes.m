function[tStart,tEnd]=getSimlogStartEndTimes(simlog)








    [tStart,tEnd]=getSimlogMinMaxTimes(simlog,[],[]);

end

function[tStart,tEnd]=getSimlogMinMaxTimes(simlogNode,tStart,tEnd)





    if isa(simlogNode,'simscape.logging.Node')
        children=childIds(simlogNode);
        for idx=1:length(children)
            thisNode=simlogNode.(children{idx});

            if max(size(thisNode))==1
                if strcmp(thisNode.id,'power_dissipated')
                    t=thisNode.series.time;
                    if isempty(tStart)
                        tStart=t(1);
                    else
                        tStart=min([t(1),tStart]);
                    end
                    if isempty(tEnd)
                        tEnd=t(end);
                    else
                        tEnd=max([t(end),tEnd]);
                    end
                else

                    [tStart,tEnd]=getSimlogMinMaxTimes(thisNode,tStart,tEnd);
                end
            else




                for jdx=1:sum(size(thisNode))-sum(size(thisNode)==1)

                    if strcmp(thisNode(jdx).id,'power_dissipated')
                        t=thisNode.series.time;
                        if isempty(tStart)
                            tStart=t(1);
                        else
                            tStart=min([t(1),tStart]);
                        end
                        if isempty(tEnd)
                            tEnd=t(end);
                        else
                            tEnd=max([t(end),tEnd]);
                        end
                    else

                        [tStart,tEnd]=getSimlogMinMaxTimes(thisNode(jdx),tStart,tEnd);
                    end
                end
            end
        end
    end
end


