function res=getSignalsForStateflow(blk)




    res=struct();


    spn=get_param(blk,'InstrumentedSignalProps');


    while~isempty(spn)


        curChild=spn;
        while~isempty(curChild)


            for idx=1:length(curChild.Signals)



                if~curChild.Signals(idx).LogSignal
                    continue;
                end


                if isequal(length(fieldnames(res)),0)
                    res.sigName=curChild.Signals(idx).SigName;
                else
                    res(end+1).sigName=curChild.Signals(idx).SigName;%#ok<AGROW>
                end
                res(end).decimateData=...
                logical(curChild.Signals(idx).Decimate);
                res(end).decimation=...
                double(curChild.Signals(idx).Decimation);
                res(end).limitDataPoints=...
                logical(curChild.Signals(idx).LimitDataPoints);





                if curChild.Signals(idx).MaxPoints>0
                    res(end).maxPoints=...
                    double(curChild.Signals(idx).MaxPoints);
                else






                    res(end).maxPoints=5000;
                end

                res(end).nameMode=...
                curChild.Signals(idx).UseCustomName;
                res(end).loggingName=...
                curChild.Signals(idx).LogName;
            end


            curChild=curChild.right;
        end


        spn=spn.down;
    end


end
