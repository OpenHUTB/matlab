function cvdisplay(ssid,varargin)





    if nargin>3
        scriptId=sf('find','all','script.name',[ssid,'.m']);
        if sf('ishandle',scriptId)
            sf('Open',scriptId,varargin{1},varargin{2});
        else
            if matlab.desktop.editor.isEditorAvailable
                fileName=which(ssid);
                eObj=matlab.desktop.editor.openDocument(fileName);
                lineNum=matlab.desktop.editor.indexToPositionInLine(eObj,varargin{1});
                matlab.desktop.editor.openAndGoToLine(fileName,lineNum+1);
            end
        end
    else
        modelName=Simulink.ID.getModel(ssid);
        try
            modelH=get_param(modelName,'Handle');
        catch %#ok<CTCH>
            modelH=[];
        end
        if isempty(modelH)
            try
                open_system(modelName);
            catch %#ok<CTCH>
                error(message('Slvnv:simcoverage:cvdisplay:LoadError',modelName));
            end
        end

        uddHandle=Simulink.ID.getHandle(ssid);
        isStateflow=contains(class(uddHandle),'Stateflow.');

        if isStateflow&&...
            sf('get',uddHandle.Id,'.autogen.source')&&...
            Stateflow.STT.StateEventTableMan.isStateTransitionTable(sf('get',uddHandle.Id,'.autogen.source'))
            handle=uddHandle.Id;
            openSF(handle,varargin);


        elseif~isStateflow&&...
            ~strcmp(get_param(uddHandle,'Type'),'block_diagram')&&...
            sfprivate('is_truth_table_chart_block',uddHandle)
            handle=sfprivate('block2chart',uddHandle);
            openSF(handle,varargin);
        else
            if nargin>1
                ssid=sprintf('%s:%s-%s',ssid,num2str(varargin{1}),num2str(varargin{2}));
            else
                ssid=sprintf('%s',ssid);
            end

            SlCov.CovStyle.selectObject(ssid);
        end
    end

    function openSF(handle,pars)

        if numel(pars)>1
            sf('Open',handle,pars{1},pars{2});
        else
            sf('Open',handle);
        end
