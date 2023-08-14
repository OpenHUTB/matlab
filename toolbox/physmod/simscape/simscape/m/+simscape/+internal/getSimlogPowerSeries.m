function cellOut=getSimlogPowerSeries(simlog,ancestorNodeName,cellOut)











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

                if strcmp(thisNode.id,'power_dissipated')

                    t=thisNode.series.time;
                    powerValues=thisNode.series.values('W');


                    cellOut{end+1,1}=thisNodeName;%#ok<AGROW>
                    cellOut{end,2}=[t,powerValues];
                    cellOut{end,3}=thisNode.getSource;
                else

                    cellOut=simscape.internal.getSimlogPowerSeries(thisNode,thisNodeName,cellOut);
                end
            else




                for jdx=1:sum(size(thisNode))-sum(size(thisNode)==1)

                    if strcmp(thisNode(jdx).id,'power_dissipated')

                        t=thisNode.series.time;
                        powerValues=thisNode.series.values('W');


                        cellOut{end+1,1}=thisNodeName;%#ok<AGROW>
                        cellOut{end,2}=[t,powerValues];
                        cellOut{end,3}=thisNode.getSource;
                    else

                        cellOut=simscape.internal.getSimlogPowerSeries(thisNode(jdx),thisNodeName,cellOut);
                    end
                end
            end
        end
    end

end