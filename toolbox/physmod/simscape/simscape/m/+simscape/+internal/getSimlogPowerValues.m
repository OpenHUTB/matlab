function cellOut=getSimlogPowerValues(simlog,tStart,tEnd,ancestorNodeName,cellOut)












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
            if strcmp(thisNode.id,'power_dissipated')

                t=thisNode.series.time;
                if isempty(tStart)
                    idx1=1;
                else
                    idx1=find(t<=tStart,1,'last');
                    if isempty(idx1)
                        pm_error('physmod:simscape:simscape:internal:powerDissipated:InvalidTimeRange')
                    end
                end
                if isempty(tEnd)
                    idx2=length(t);
                else
                    idx2=find(t>=tEnd,1);
                    if isempty(idx2)||idx1>=idx2
                        pm_error('physmod:simscape:simscape:internal:powerDissipated:InvalidTimeRange')
                    end
                end

                powerValues=thisNode.series.values;
                cumulativeEnergy=trapz(t(idx1:idx2),powerValues(idx1:idx2));

                averagePower=cumulativeEnergy/(t(idx2)-t(idx1));




                cellOut{end+1,1}=thisNodeName;%#ok<AGROW>
                cellOut{end,2}=averagePower;
                cellOut{end,3}=thisNode.getSource;
            else

                cellOut=simscape.internal.getSimlogPowerValues(thisNode,tStart,tEnd,thisNodeName,cellOut);
            end
        end
    end

end
