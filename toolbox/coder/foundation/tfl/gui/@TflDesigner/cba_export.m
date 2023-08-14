function cba_export(varargin)









    me=TflDesigner.getexplorer;
    rt=me.getRoot;

    if isempty(me)||me.getRoot.iseditorbusy||...
        strcmpi(me.getaction('FILE_EXPORT').Enabled,'off')==1
        return;
    end

    me.getRoot.iseditorbusy=true;
    me.getaction('FILE_EXPORT').Enabled='off';

    me.setStatusMessage(DAStudio.message('RTW:tfldesigner:SavingInProgressStatusMsg'));

    tableNode=rt.currenttreenode;

    if(rt==tableNode)||~strcmpi(tableNode.Type,'TflTable')
        me.getRoot.iseditorbusy=false;
        me.getaction('FILE_EXPORT').Enabled='on';
        dp=DAStudio.DialogProvider;
        dp.errordlg(DAStudio.message('RTW:tfldesigner:ErrorSelectTableDialog'),...
        DAStudio.message('RTW:tfldesigner:ErrorText'),true);
        me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ErrorSelectTableDialog'));
        return;
    end


    me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ValidationInProgressStatusMsg'));

    invalidentries=tableNode.validateChildren;

    if~isempty(invalidentries)
        TflDesigner.setcurrentlistnode(invalidentries);
        me.getaction('FILE_EXPORT').Enabled='off';
        resume=DAStudio.message('RTW:tfldesigner:NoText');

        if(length(invalidentries)==length(tableNode.children))
            dp=DAStudio.DialogProvider;
            dp.errordlg(DAStudio.message('RTW:tfldesigner:StopSaveAsNoValidEntriesMsg',tableNode.Name),...
            DAStudio.message('RTW:tfldesigner:ErrorText'),true);
        else
            msg=DAStudio.message('RTW:tfldesigner:ContinueSavingWithInvalidEntriesMsg',tableNode.Name);
            resume=questdlg(msg,DAStudio.message('RTW:tfldesigner:ValidationText'),...
            DAStudio.message('RTW:tfldesigner:YesText'),...
            DAStudio.message('RTW:tfldesigner:NoText'),...
            DAStudio.message('RTW:tfldesigner:NoText'));
        end
        if(strcmpi(resume,DAStudio.message('RTW:tfldesigner:NoText')))
            tableNode.firehierarchychanged;
            me.getRoot.iseditorbusy=false;
            me.getaction('FILE_EXPORT').Enabled='on';
            return;
        end
    end

    if nargin==0
        [filename,dirname]=uiputfile(...
        {'*.m','MATLAB Files (*.m)'},...
        DAStudio.message('RTW:tfldesigner:SelectionLocationDialogTitle'),...
        fullfile(tableNode.path,[tableNode.Name,'.m']));
        if isempty(filename)||logical(sum(filename)==0)
            me.getRoot.iseditorbusy=false;
            me.getaction('FILE_EXPORT').Enabled='on';
            return;
        else
            [~,name,~]=fileparts(filename);
            tableNode.Name=name;
        end
    else
        dirname=varargin{1};
    end


    me.setStatusMessage(DAStudio.message('RTW:tfldesigner:GeneratingMATLABFileStatusMsg'));

    if~isempty(tableNode.object.AllEntries)
        try
            [~,nm,~]=fileparts(tableNode.Name);

            exp=['clear(''',nm,''')'];
            evalin('base',exp);
            tableNode.object.serialize(fullfile(dirname,[nm,'.m']));
            me.getRoot.iseditorbusy=false;
            me.getaction('FILE_EXPORT').Enabled='on';
            if isempty(invalidentries)
                tableNode.isDirty=false;
            end
            tableNode.okToClose=true;
            me.setStatusMessage(DAStudio.message('RTW:tfldesigner:FinishedMATLABFileGenerationStatusMsg'));
        catch ME
            dp=DAStudio.DialogProvider;
            me.getRoot.iseditorbusy=false;
            me.getaction('FILE_EXPORT').Enabled='on';
            dp.errordlg(DAStudio.message('RTW:tfldesigner:ErrorGeneratingFileStatusMsg',ME.message),...
            DAStudio.message('RTW:tfldesigner:ErrorText'),true);
            me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ErrorGeneratingFileStatusMsg',ME.message));
            return;
        end
    else
        me.setStatusMessage(DAStudio.message('RTW:tfldesigner:FinishedMATLABFileGenerationStatusMsg'));
    end

    tableNode.firehierarchychanged;




