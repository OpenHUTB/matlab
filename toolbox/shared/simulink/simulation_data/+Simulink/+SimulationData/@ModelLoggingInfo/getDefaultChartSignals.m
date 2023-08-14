function res=getDefaultChartSignals(modelBlock,...
    blk,...
    bIncludeOff,...
    res,...
    subPath)






    if isempty(modelBlock)
        bpath=Simulink.BlockPath(blk);
    else
        bpath=Simulink.BlockPath([modelBlock.convertToCell();blk]);
    end


    bUseSearchPath=nargin>4;
    if bUseSearchPath
        if isempty(subPath)
            searchPath={};
        else
            searchPath=textscan(subPath,'%s','Delimiter','.');
            searchPath=searchPath{1};
        end
    end


    spn=get_param(blk,'InstrumentedSignalProps');


    while~isempty(spn)


        curChild=spn;
        while~isempty(curChild)


            for idx=1:length(curChild.Signals)



                if~bIncludeOff&&~curChild.Signals(idx).LogSignal
                    continue;
                end


                if bUseSearchPath
                    curPath=textscan(...
                    curChild.Signals(idx).SigName,...
                    '%s',...
                    'Delimiter','.');
                    curPath=curPath{1};


                    if length(curPath)~=length(searchPath)+1
                        continue;
                    end


                    if~isempty(searchPath)&&...
                        ~isequal(curPath(1:end-1),searchPath)
                        continue;
                    end

                end


                if isempty(res)
                    res=Simulink.SimulationData.SignalLoggingInfo;
                    res.BlockPath=bpath;
                else
                    res(end+1).BlockPath=bpath;%#ok<AGROW>
                end
                res(end).blockPath_.SubPath=...
                curChild.Signals(idx).SigName;
                res(end).loggingInfo_.dataLogging_=...
                logical(curChild.Signals(idx).LogSignal);
                res(end).loggingInfo_.decimateData_=...
                logical(curChild.Signals(idx).Decimate);
                res(end).loggingInfo_.decimation_=...
                double(curChild.Signals(idx).Decimation);
                res(end).loggingInfo_.limitDataPoints_=...
                double(curChild.Signals(idx).LimitDataPoints);





                if curChild.Signals(idx).MaxPoints>0
                    res(end).loggingInfo_.maxPoints_=...
                    double(curChild.Signals(idx).MaxPoints);
                end

                res(end).loggingInfo_.nameMode_=...
                curChild.Signals(idx).UseCustomName;
                res(end).loggingInfo_.loggingName_=...
                curChild.Signals(idx).LogName;
            end


            curChild=curChild.right;
        end


        spn=spn.down;
    end

end
