function summaryTable=getNodeDvDtSummary(node,tau,startTime,endTime)


















    if nargin<2
        pm_error('physmod:ee:library:InsufficientInputs','ee_getNodeDvDtSummary',2);
    end
    validateattributes(node,{'simscape.logging.Node'},{'scalar'},'ee_getNodeDvDtSummary','node',1);
    validateattributes(tau,{'numeric'},{'scalar','real','positive'},'ee_getNodeDvDtSummary','tau',2);


    if~exist('startTime','var')
        startTime=[];
    else
        validateattributes(startTime,{'numeric'},{'scalar','real'},mfilename,'startTime',3);
    end
    if~exist('endTime','var')
        endTime=[];
    else
        validateattributes(endTime,{'numeric'},{'scalar','real'},mfilename,'endTime',4);
    end



    if~(startTime<endTime)
        pm_error('physmod:simscape:compiler:patterns:checks:LessThan','startTime','endTime');
    end

    nodes=ee.internal.getTerminalVoltages(node);
    maxdvdt=zeros(1,length(nodes));
    blocks=strings(1,length(nodes));
    terminals=strings(1,length(nodes));
    for ii=1:length(nodes)
        t=nodes(ii).time;
        if isempty(startTime)
            startTime=t(1);
        else
            startTime=max([startTime,t(1)]);
        end
        if isempty(endTime)
            endTime=t(end);
        else
            endTime=min([endTime,t(end)]);
        end



        if~(endTime>t(1))
            pm_error('physmod:simscape:compiler:patterns:checks:GreaterThan','endTime',getString(message('physmod:ee:library:comments:utils:getNodeDvDtSummary:error_TheSimulationStartTime')));
        elseif~(startTime<endTime)
            pm_error('physmod:simscape:compiler:patterns:checks:LessThan','startTime',getString(message('physmod:ee:library:comments:utils:getNodeDvDtSummary:error_TheSimulationStopTime')));
        end

        t_interp=startTime:tau:endTime;
        v_interp=interp1(t,nodes(ii).values,t_interp);
        dvdt=gradient(v_interp,t_interp);
        maxdvdt(ii)=max(abs(dvdt));
        strComponents=strsplit(nodes(ii).path,'.');
        blocks(ii)=strjoin(strComponents(1:end-2),'.');
        terminals(ii)=strComponents{end-1};
    end

    summaryTable=table(blocks(:),terminals(:),maxdvdt(:),'VariableNames',...
    {'LoggingNode','Terminal','max_abs_dvdt'});
    summaryTable(summaryTable.max_abs_dvdt==0,:)=[];
    summaryTable=sortrows(summaryTable,3,'descend');
