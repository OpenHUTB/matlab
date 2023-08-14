function xilUtils(action,varargin)






    if action=="fixBDExtractedWrapperModel"
        extractedModelH=varargin{1};
        simMode=varargin{2};

        try

            mdlBlkH=get_param([get_param(extractedModelH,'Name'),':1'],'Handle');
        catch
            mdlBlkH=[];
        end
        if~isempty(mdlBlkH)


            if SlCov.CovMode.isSIL(simMode,true)
                codeIf='Model reference';
            else
                codeIf='Top model';
            end
            simMode=SlCov.CovMode.toSimulationMode('SIL');
            isDirtyOff=strcmp(get_param(get_param(mdlBlkH,'Name'),'Dirty'),'off');
            set_param(mdlBlkH,...
            'SimulationMode',simMode,...
            'CodeInterface',codeIf);
            if isDirtyOff
                save_system(extractedModelH);
            end
        end
    end
