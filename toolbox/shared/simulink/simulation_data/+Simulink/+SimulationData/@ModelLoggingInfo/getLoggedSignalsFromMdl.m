function[res,findSysError]=getLoggedSignalsFromMdl(sys,...
    blkPrefix,...
    bRecurse,...
    variantOpt,...
    commentOpt,...
    linksOpt,...
    maskOpt,...
    bAllSubsystems,...
    bIncludeOff,...
    bIncludeTestPoints,...
    res,...
    subPath,...
    topModelName,...
    bNeverLoadMdl)



























    if nargin<14
        bNeverLoadMdl=false;
    end



    closeMdlObj=Simulink.SimulationData.ModelCloseUtil;%#ok<NASGU>


    bTopSF=...
    Simulink.BlockPath.utIsStateflowChart(sys);
    if bTopSF
        blks={sys};
        bTopSF=true;
    end


    findSysError=[];
    if~bTopSF
        [blks,er]=Simulink.SimulationData.ModelLoggingInfo.utFindBlocksInModel(...
        sys,...
        variantOpt,...
        commentOpt,...
        linksOpt,...
        maskOpt,...
        bAllSubsystems);
        findSysError=[findSysError,er];
    end

    refModelBlks={};
    for i=1:length(blks)



        if~bTopSF





            if strcmp(blks{i},sys)
                continue;
            end


            try
                ph=get_param(blks{i},'PortHandles');
            catch me %#ok<NASGU>






                continue;
            end


            for j=1:length(ph.Outport)


                setting=get_param(ph.Outport(j),'DataLogging');
                bLogging=strcmpi(setting,'on');


                if~bLogging
                    if~bIncludeTestPoints
                        continue;
                    else
                        tp=get_param(ph.Outport(j),'TestPoint');
                        if~strcmpi(tp,'on')
                            continue;
                        end
                    end
                end


                res(end+1).outputPortIndex_=j;%#ok<AGROW>
                res(end).loggingInfo_.dataLogging_=bLogging;
                if isempty(blkPrefix)
                    res(end).BlockPath=blks{i};
                else
                    res(end).BlockPath=...
                    [blkPrefix.convertToCell();blks{i}];
                end
                res(end)=res(end).updateSettingsFromPort(...
                bNeverLoadMdl);

            end
        end


        if(bAllSubsystems||bTopSF)&&...
            Simulink.BlockPath.utIsStateflowChart(blks{i})
            args={blkPrefix,blks{i},bIncludeOff,res};
            if nargin>10&&ischar(subPath)
                args=[args,{subPath}];%#ok<AGROW>
            end
            res=...
            Simulink.SimulationData.ModelLoggingInfo.getDefaultChartSignals(...
            args{:});
        end


        if bRecurse
            bType=get_param(blks{i},'BlockType');
            if strcmp(bType,'ModelReference')&&...
                ~strcmpi(get_param(blks{i},'ProtectedModel'),'on')
                refModelBlks{end+1}=blks{i};%#ok<AGROW>
            end
        end
    end


    for idx=1:length(refModelBlks)
        mdls=Simulink.SimulationData.ModelLoggingInfo.loadMdlForDefaultSignals(...
        refModelBlks{idx},topModelName,[],variantOpt);
        if~iscell(mdls)
            mdls={mdls};
        end
        mblk=Simulink.BlockPath(...
        [blkPrefix.convertToCell();refModelBlks{idx}]);
        for idx2=1:length(mdls)
            [res,er]=Simulink.SimulationData.ModelLoggingInfo.getLoggedSignalsFromMdl(...
            mdls{idx2},...
            mblk,...
            true,...
            variantOpt,...
            commentOpt,...
            linksOpt,...
            maskOpt,...
            bAllSubsystems,...
            bIncludeOff,...
            bIncludeTestPoints,...
            res,...
            [],...
            topModelName,...
            bNeverLoadMdl);
            findSysError=[findSysError,er];%#ok<AGROW>
        end
    end

end
