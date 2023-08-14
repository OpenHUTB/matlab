function toolstripValidateButtonCB(this)











    if isempty(this.SessionSource),return;end




    progressDlg=uiprogressdlg(...
    this.getUIFigure(),...
    'Indeterminate','on',...
    'Message',this.ValidatingMsg_msg,...
    'Title',this.ValidatingTitle_msg);
    c=onCleanup(@()delete(progressDlg));



    for i=1:numel(this.BindingData)
        this.BindingData{i}.Valid=true;
    end

    sourceFile=this.SessionSource(1).SourceFile;
    try
        try


            slrtApp=slrealtime.Application(sourceFile);
            params=slrtApp.getParameters();
            paramBlockPaths=cellfun(@(x)strrep(x,newline,' '),{params.BlockPath},'UniformOutput',false);
            paramNames={params.BlockParameterName};
            sigs=slrtApp.getSignals();
            sigBlockPaths=cellfun(@(x)strrep(x,newline,' '),{sigs.BlockPath},'UniformOutput',false);
            sigPortIdxs=[sigs.PortIndex];




            for nParam=1:numel(paramBlockPaths)
                if iscell(paramBlockPaths{nParam})
                    paramBlockPaths{nParam}={paramBlockPaths{nParam}{:}};%#ok
                end
            end
            for nSig=1:numel(sigBlockPaths)
                if iscell(sigBlockPaths{nSig})
                    sigBlockPaths{nSig}={sigBlockPaths{nSig}{:}};%#ok
                end
            end

            for idx=1:numel(this.BindingData)
                if this.isBindingParameter(idx)



                    validateParameter(this,idx,paramBlockPaths,paramNames);
                else



                    validateSignal(this,idx,sigBlockPaths,sigPortIdxs);


                    if~this.BindingData{idx}.Valid,continue;end


                    if~isempty(this.BindingData{idx}.SignalName)
                        inst=slrealtime.Instrument(sourceFile);%#ok
                        str=evalc('inst.addSignal(this.BindingData{idx}.SignalName)');
                        this.BindingData{idx}.UseName=isempty(str);
                    else
                        this.BindingData{idx}.UseName=true;
                    end
                end
            end
        catch


            load_system(sourceFile);
            [~,modelName]=fileparts(sourceFile);

            params=struct('BlockPath',{},'BlockParameterName',{});
            keepLooping=true;
            while(keepLooping)
                keepLooping=false;
                try
                    params=slrealtime.internal.ApplicationTree.getParametersFromModel(modelName);
                catch ME
                    if this.handleUpdateDiagramOrRethrow(ME)


                        keepLooping=true;
                    else


                        this.errorDlg('slrealtime:appdesigner:ValidateError',...
                        getString(message('slrealtime:appdesigner:UpdateDiagramRequired')));
                        return;
                    end
                end
            end
            paramBlockPaths={params.BlockPath};
            paramNames={params.BlockParameterName};




            for nParam=1:numel(paramBlockPaths)
                if iscell(paramBlockPaths{nParam})
                    paramBlockPaths{nParam}={paramBlockPaths{nParam}{:}};%#ok
                end
            end



            signals=slrealtime.internal.ApplicationTree.getSignalsFromModel(modelName);
            named_signals=signals(arrayfun(@(x)~isempty(x.SignalLabel),signals));

            for idx=1:numel(this.BindingData)
                if this.isBindingParameter(idx)



                    validateParameter(this,idx,paramBlockPaths,paramNames);
                else



                    try
                        if iscell(this.BindingData{idx}.BlockPath)
                            this.BindingData{idx}.Valid=all(cellfun(@(x)~isempty(find_system(x,'FirstResultOnly','on','MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices)),this.BindingData{idx}.BlockPath));
                        else
                            this.BindingData{idx}.Valid=~isempty(find_system(this.BindingData{idx}.BlockPath,'FirstResultOnly','on','MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices));
                        end
                    catch
                        this.BindingData{idx}.Valid=false;
                    end


                    if~this.BindingData{idx}.Valid,continue;end


                    if~isempty(this.BindingData{idx}.SignalName)
                        idxs=find(strcmp(this.BindingData{idx}.SignalName,{named_signals.SignalLabel}));
                        if numel(idxs)>1
                            this.BindingData{idx}.UseName=false;
                        else
                            this.BindingData{idx}.UseName=true;
                        end
                    end
                end
            end
        end
    catch ME
        this.errorDlg('slrealtime:appdesigner:ValidateError',ME.message);
        return;
    end



    this.refreshStyles();

    this.infoDlg('slrealtime:appdesigner:ValidateComplete');
end

function validateParameter(this,idx,paramBlockPaths,paramNames)
    if iscell(this.BindingData{idx}.BlockPath)
        bindingBP=strrep({this.BindingData{idx}.BlockPath{:}},newline,' ');%#ok
        v=cellfun(@(x)iscell(x)&&all(size(x)==size(bindingBP)),paramBlockPaths);
        blockPathMatches=cellfun(@(x)all(strcmp(x,bindingBP)),paramBlockPaths(v));
        paramNameMatches=strcmp(paramNames(v),this.BindingData{idx}.ParamName);
        this.BindingData{idx}.Valid=any(blockPathMatches&paramNameMatches);
    else
        bindingBP=strrep(this.BindingData{idx}.BlockPath,newline,' ');
        this.BindingData{idx}.Valid=any(strcmp(paramBlockPaths,bindingBP)&strcmp(paramNames,this.BindingData{idx}.ParamName));
    end
end

function validateSignal(this,idx,sigBlockPaths,sigPortIdxs)
    if iscell(this.BindingData{idx}.BlockPath)
        bindingBP=strrep({this.BindingData{idx}.BlockPath{:}},newline,' ');%#ok
        v=cellfun(@(x)iscell(x)&&all(size(x)==size(bindingBP)),sigBlockPaths);
        blockPathMatches=cellfun(@(x)all(strcmp(x,bindingBP)),sigBlockPaths(v));
        sigPortIdxMatches=sigPortIdxs(v)==this.BindingData{idx}.PortIndex;
        this.BindingData{idx}.Valid=any(blockPathMatches&sigPortIdxMatches);
    else
        bindingBP=strrep(this.BindingData{idx}.BlockPath,newline,' ');
        this.BindingData{idx}.Valid=any(strcmp(sigBlockPaths,bindingBP)&sigPortIdxs==this.BindingData{idx}.PortIndex);
    end
end
