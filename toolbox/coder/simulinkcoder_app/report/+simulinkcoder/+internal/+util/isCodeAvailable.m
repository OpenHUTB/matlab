function[bool,info,ref]=isCodeAvailable(mdl,ref)




    if~bdIsLoaded(mdl)
        bool=false;
        info='';
        return
    end

    if nargin<2
        ref=false;
    end

    try
        [rptInfo,ref]=simulinkcoder.internal.util.getReportInfo(mdl,ref);


        folder=rptInfo.BuildDirectory;
        if~isempty(folder)&&rptInfo.BuildSuccess
            bool=true;
            info=rptInfo;
        else
            bool=false;
            info=message('SimulinkCoderApp:report:NoCode',mdl).getString;
        end

    catch ME
        bool=false;
        info=message('SimulinkCoderApp:report:NoCode',mdl).getString;
    end