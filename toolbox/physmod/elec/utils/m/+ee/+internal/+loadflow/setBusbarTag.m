function setBusbarTag




    modelName=get_param(bdroot,'Name');

    SimscapeLogType=get_param(modelName,'SimscapeLogType');
    loggingAll=strcmp(SimscapeLogType,'all');
    loggingLocal=strcmp(SimscapeLogType,'local');
    logSimulationDataOn=strcmp(get_param(gcb,'LogSimulationData'),'on');

    if loggingAll||(loggingLocal&&logSimulationDataOn)

        DirtyFlag=get_param(modelName,'Dirty');


        simlogName=get_param(modelName,'SimscapeLogName');
        if strcmp(get_param(bdroot,'ReturnWorkspaceOutputs'),'off')
            fullSimlogPath=simlogName;
            simlogExists=evalin('base',['exist(''',simlogName,''',''var'')']);
        else
            ReturnWorkSpaceOutputsName=get_param(bdroot,'ReturnWorkspaceOutputsName');
            fullSimlogPath=[ReturnWorkSpaceOutputsName,'.',simlogName];
            simlogExists=evalin('base',['exist(''',ReturnWorkSpaceOutputsName,''',''var'')']);
        end

        if simlogExists

            simlog=evalin('base',fullSimlogPath);
            simulinkBlkName=get_param(gcb,'Name');
            blkNameNoLineReturn=strrep(simulinkBlkName,newline,'_');
            blkName=matlab.lang.makeValidName(blkNameNoLineReturn);
            if simlog.hasPath(blkName)
                node=eval(['simlog.',blkName]);
            else
                node=simscape.logging.findNode(simlog,gcb);
            end

            if~isempty(node)&&node.N1.V.isFrequency


                node_Vt=node.Vt.series.values;
                Vt=node_Vt(1);
                node_ph=node.ph.series.values('deg');
                ph=node_ph(1);

                if~strcmp(get_param(gcb,'n_nodes'),'ee.enum.connectors.busbar_number_of_connections.one')

                    node_P=node.P.series.values('W');
                    P=node_P(1,:);

                    node_Q=node.Q.series.values('W');
                    Q=node_Q(1,:);

                    maxVA=max(abs([P,Q]));


                    if maxVA>1e6
                        unitsP='MW';
                        unitsQ='Mvar';
                        scale=1e-6;
                    elseif maxVA>1e3
                        unitsP='kW';
                        unitsQ='kvar';
                        scale=1e-3;
                    else
                        unitsP='W';
                        unitsQ='var';
                        scale=1;
                    end


                    set_param(gcb,'Tag',[num2str(Vt,'%5.3f'),' pu\n',num2str(ph,'%4.2f'),' deg\n'...
                    ,num2str(P*scale,'%7.1f'),' ',unitsP,'\n',num2str(Q*scale,'%7.1f'),' ',unitsQ])
                else

                    set_param(gcb,'Tag',[num2str(Vt,'%4.2f'),' pu\n',num2str(ph,'%3.1f'),' deg'])
                end
            end
        end
        set_param(modelName,'Dirty',DirtyFlag);
    end

end