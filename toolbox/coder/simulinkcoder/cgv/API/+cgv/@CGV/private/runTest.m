


function this=runTest(this,inputIndex)

    execType=this.ExecEnv.Obj.ExecType;
    this.MetaData(inputIndex).ver=ver;
    this.MetaData(inputIndex).hostname=evalc('!hostname');
    timeNow=clock;

    dateTime=sprintf('%4d%02d%02d-%02d%02d%02d',floor(timeNow));

    ms=timeNow(6)-floor(timeNow(6));
    dateTime=[dateTime,sprintf('-%03d',floor(ms*1000))];
    this.MetaData(inputIndex).dateTime=dateTime;
    this.MetaData(inputIndex).warnings={};




    try
        this.OutputData(inputIndex).filename;
    catch ME %#ok<NASGU>
        this.OutputData(inputIndex).filename=[];
    end

    if isempty(this.OutputData(inputIndex).filename)
        [~,nameOnly,~]=fileparts(this.InputData(inputIndex).pathAndName);
        name=[this.ModelName,'_',execType,'_'...
        ,nameOnly,'_',dateTime,'_output.mat'];
        this.OutputData(inputIndex).filename=name;



        this.OutputData(inputIndex).filename=name;
    end
    this.OutputData(inputIndex).actual=[];
    this.OutputData(inputIndex).errorPlotFile{1}=[];

    if ispc
        this.MetaData(inputIndex).username=evalc('!echo %user%');
    else
        this.MetaData(inputIndex).username=evalc('!whoami');
    end
    try


        if~isempty(this.OutputDataName)
            evalin('base',['clear ',this.OutputDataName,';']);
        end

        this.ExecEnv.Obj.setupTarget();



        st=tic;
        this.MetaData(inputIndex).inputData=this.InputData(inputIndex).pathAndName;
        metadataMdl=fullfile(this.UserDir,[this.ModelName,'.slx']);
        if~exist(metadataMdl,'file')
            metadataMdl(end-2:end)='mdl';
        end
        this.MetaData(inputIndex).model=metadataMdl;

        [simout]=this.ExecEnv.Obj.run(this,inputIndex);



        this.MetaData(inputIndex).status='completed';

        Basefile=fullfile(this.OutputDir,this.OutputData(inputIndex).filename);
        this.OutputData(inputIndex).actual=simout;
        save(Basefile,'simout');
        this.MetaData(inputIndex).runtime=toc(st);


        saveMetaData(this,inputIndex);


        if~isempty(this.InputData(inputIndex).baselineFile)
            baselineFile=this.InputData(inputIndex).baselineFile;
            try
                basedata=load(char(baselineFile));
                if~isfield(basedata,'simout')
                    DAStudio.error('RTW:cgv:BadBaseline',baselineFile);
                end

                baseline=basedata.simout;
                toleranceFile=this.InputData(inputIndex).toleranceFile;
                if isempty(toleranceFile)
                    [~,~,mismatchNames,mismatchFigures]=cgv.CGV.compare(simout,baseline,...
                    'plot','mismatch');
                else
                    [~,~,mismatchNames,mismatchFigures]=cgv.CGV.compare(simout,baseline,...
                    'plot','mismatch','toleranceFile',toleranceFile);
                end
                if isempty(mismatchFigures)
                    this.MetaData(inputIndex).status='passed';
                else
                    this.MetaData(inputIndex).status='failed';
                end
                for figNdx=1:length(mismatchFigures)
                    figHndl=mismatchFigures{figNdx};


                    figFile=sprintf('input_%d_figure_%d',inputIndex,figNdx);
                    figFullName=fullfile(this.OutputDir,[figFile,'.png']);
                    saveas(figHndl,figFullName);
                    this.OutputData(inputIndex).errorPlotFile{figNdx}=figFullName;
                    this.OutputData(inputIndex).signalName{figNdx}=mismatchNames{figNdx};
                    close(figHndl);
                end
            catch ME

                if strcmp(ME.identifier,'RTW:cgv:BadBaseline')||...
                    strcmp(ME.identifier,'RTW:cgv:InvalidToleranceFile')
                    rethrow(ME);
                end


                this.MetaData(inputIndex).status='failed';
            end
        end

    catch ME
        this.MetaData(inputIndex).status='error';
        this.MetaData(inputIndex).ErrorDetails=ME;

        saveMetaData(this,inputIndex);
        this.OutputData(inputIndex).filename=[];
    end
end



