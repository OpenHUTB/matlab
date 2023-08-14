function disp(h)










    try
        numObjs=numel(h);

        tgtInfoList(numObjs)=h(numObjs).targetinfo;

        for i=1:numObjs-1
            tgtInfoList(i)=h(i).targetinfo;
        end
    catch
        error(message('ERRORHANDLER:autointerface:CannotGetTargetInfo'));
    end

    if length(h)==1
        proc_displayOneProc(h,tgtInfoList);
    else
        proc_displayMultiProc(h,tgtInfoList);
    end

