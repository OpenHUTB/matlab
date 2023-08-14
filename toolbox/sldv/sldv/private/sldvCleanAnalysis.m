function sldvCleanAnalysis(testcomp,showUI)



    if nargin==0
        token=Sldv.Token.get();
        testcomp=token.getTestComponent();
        showUI=false;

        if isempty(testcomp)

            return;
        end
    end


    logAll(['\n',getString(message('Sldv:private:sldvclean:CleaningAnalysisArtifacts')),'\n'],testcomp,showUI);

    cwd=pwd;


    ws1=warning('off','MATLAB:DELETE:Permission');
    ws2=warning('off','MATLAB:DELETE:FileNotFound');


    restoreWarnings=onCleanup(@()warning([ws1,ws2]));

    try
        logAll([getString(message('Sldv:private:sldvclean:Step1ChangeOutputDir')),'\n'],testcomp,showUI);
        outdir=mdl_get_output_dir(testcomp);
        cd(outdir);


        if isunix
            kill_cmd='kill-rte-kernel';
        else
            kill_cmd='kill-rte-kernel.bat';
        end

        kill_file=dir(kill_cmd);
        if~isempty(kill_file)
            if isunix
                kill_cmd=['./',kill_cmd];
            end
            logAll([getString(message('Sldv:private:sldvclean:Step2CallingKillCommand')),'\n'],testcomp,showUI);

            [~,~]=system(kill_cmd);
            try
                delete(kill_cmd);
            catch MEx %#ok<NASGU>
            end
            [~,~,~]=rmdir('ALL','s');
            [~,~,~]=rmdir('C-ALL','s');
            logAll([getString(message('Sldv:private:sldvclean:Step3DoneCalling')),'\n'],testcomp,showUI);
        else
            logAll([getString(message('Sldv:private:sldvclean:Step4KillCommand')),'\n'],testcomp,showUI);
        end


        if slavteng('feature','ForceAssertExternalCaller')==0

            logAll([getString(message('Sldv:private:sldvclean:Step5DeletingPSLog')),'\n'],testcomp,showUI);
            log_file=dir('polyspace-dvo.log');
            if~isempty(log_file)
                if slavteng('feature','ForceAssertExternalCaller')==0
                    try
                        delete(log_file(1).name);
                    catch MEx %#ok<NASGU>
                    end
                end
            end


            logAll([getString(message('Sldv:private:sldvclean:Step6DeletingTempDvo')),'\n'],testcomp,showUI);

            tmp_dvos=dir('dv_*.dvo');


            tmp_dvos=[tmp_dvos,dir('_solver_*.dvo')];
            if slavteng('feature','ForceAssertExternalCaller')==0
                try
                    for i=1:length(tmp_dvos)
                        delete(tmp_dvos(i).name);
                    end
                catch MEx %#ok<NASGU>
                end
            end


            logAll([getString(message('Sldv:private:sldvclean:Step6DeletingTempDvof')),'\n'],testcomp,showUI);
            tmp_dvofs=dir('*.dvof');
            if slavteng('feature','ForceAssertExternalCaller')==0
                try
                    for i=1:length(tmp_dvofs)
                        delete(tmp_dvofs(i).name);
                    end
                catch MEx %#ok<NASGU>
                end
            end





            tmp_dvrs=dir('_solver_*.dvr');
            if slavteng('feature','ForceAssertExternalCaller')==0
                try
                    for i=1:length(tmp_dvrs)
                        delete(tmp_dvrs(i).name);
                    end
                catch MEx %#ok<NASGU>
                end
            end


            logAll([getString(message('Sldv:private:sldvclean:Step7DeletingTempDvchk')),'\n'],testcomp,showUI);
            tmp_dvchks=dir('*.dvchk');
            if slavteng('feature','ForceAssertExternalCaller')==0
                try
                    for i=1:length(tmp_dvchks)
                        delete(tmp_dvchks(i).name);
                    end
                catch MEx %#ok<NASGU>
                end
            end


            logAll([getString(message('Sldv:private:sldvclean:Step8DeletingTempProximitydata')),'\n'],testcomp,showUI);
            if slavteng('feature','ForceAssertExternalCaller')==0
                try
                    proximity_files=dir('proximitydata.mat');
                    delete(proximity_files.name);
                    proximity_files=dir('proximitydataReady.mat');
                    delete(proximity_files.name);
                catch MEx %#ok<NASGU>
                end
            end
        end
    catch MEx
        logAll([getString(message('Sldv:private:sldvclean:ErrorInCleaningAnalysis',MEx.message)),'\n'],testcomp,...
        showUI,MEx);
    end

    cd(cwd);

    logAll([getString(message('Sldv:private:sldvclean:EndCleaningAnalysisArtifacts')),'\n'],testcomp,showUI);
end

function logAll(str,testcomp,showUI,varargin)

    if slavteng('feature','ForceAssertExternalCaller')==1
        logger(testcomp,showUI,true,str,varargin{:});
    end
end

function logger(testcomp,showUI,logAll,str,varargin)

    frmtStr=sprintf(str,varargin{:});
    if showUI
        if~isempty(testcomp)
            testcomp.progressUI.appendToLog(frmtStr);
        else
            if logAll
                frmtStr=sldvshareprivate('util_remove_html',frmtStr);
                fprintf(1,frmtStr);
            end
        end
    else
        if logAll
            frmtStr=sldvshareprivate('util_remove_html',frmtStr);
            fprintf(1,'%s',frmtStr);
        end
    end
end


