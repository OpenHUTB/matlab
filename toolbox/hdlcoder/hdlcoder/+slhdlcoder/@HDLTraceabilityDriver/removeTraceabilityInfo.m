

function removeTraceabilityInfo(HDLCoder)


    topLevelNames=HDLCoder.findTopLevelHDLNames;
    model=topLevelNames{1};


    slprj=fullfile(pwd,'slprj','hdl',model,'tmwinternal');
    if exist(slprj,'dir')
        success=rmdir(slprj,'s');
        if~success
            error(message('hdlcoder:engine:cannotdeletedir',slprj));
        end
    end


    htmlDir=fullfile(HDLCoder.hdlGetCodegendir,'html',model);
    if exist(htmlDir,'dir')
        success=rmdir(htmlDir,'s');

        if~success
            error(message('hdlcoder:engine:cannotdeletedir',htmlDir));
        end
    end


