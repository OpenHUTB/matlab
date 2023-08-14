

function utils=processUtils(datamgr)


    resultTableReader=datamgr.getReader('RESULTS');


    utils=struct('verStatus',[],...
    'notProcessed',[]);


    pUtilsReport=slci.internal.Profiler('SLCI','Utils','','');



    if resultTableReader.hasObject('UtilsStatus')
        try
            [utils.matlabFunc,utils.verStatus,utils.notProcessed]=...
            slci.report.getFunctionCallTable(datamgr);
        catch exception
            disp(exception.message)
            disp(exception.stack(1))
            pUtilsReport.stop();
            DAStudio.error('Slci:report:FunctionCallDataError');
        end
    else
        utils.matlabFunc=[];
        utils.verStatus=[];
        utils.notProcessed=[];
    end

    pUtilsReport.stop();



end