function varargout=workspaceddg_cb(hDialog,action,hWS,newValue)




    varargout={};

    switch(action)
    case 'mapDataSourceToValue'
        narginchk(4,4);
        nargoutchk(1,1);
        if(~isempty(hDialog)),DAStudio.error('Simulink:dialog:ShouldBeEmpty','hDialog');end
        varargout{1}=mapDataSourceToValue_l(newValue);

    case 'dataSource'
        narginchk(4,4);
        dataSource_l(hDialog,hWS,newValue);

    case 'WorkspaceFileBrowser'
        narginchk(3,3);
        fileBrowser_l(hDialog,hWS);

    case 'reload'
        narginchk(3,3);
        reload_l(hDialog,hWS);
        [warningMsg,warningId]=lastwarn;
        if strcmp(warningId,'Simulink:Parameters:OnlyAutoSCForModelWSAutosarParamInModel')||...
            strcmp(warningId,'Simulink:Parameters:OnlyAutoSCForModelWSAutosarParamMFile')||...
            strcmp(warningId,'Simulink:Parameters:OnlyAutoSCForModelWSAutosarParamMCode')
            warndlg(Diagnostic.Utils.remove_links(warningMsg),'Warning');
        end

    case 'saveToSource'
        narginchk(3,3);
        saveToSource_l(hDialog,hWS);

    case 'postApply'
        narginchk(3,3);

        if strcmp(hWS.DataSource,'MATLAB Code')
            hWS.MATLABCode=hDialog.getWidgetValue('MATLABCode');
        end

        hDialog.refresh;
        varargout={'',1};
    case 'MATLABCode'
        narginchk(3,3);
        if isempty(hDialog.getWidgetValue('MATLABCode'))
            hDialog.setEnabled('reload',0);
        else
            hDialog.setEnabled('reload',1);
        end

    otherwise
        DAStudio.error('Simulink:dialog:UnexpectedAction',action);
    end
end



function value=mapDataSourceToValue_l(dataSource)


    switch(dataSource)
    case 'Model File'
        value=0;
    case 'MAT-File'
        value=1;
    case 'MATLAB File'
        value=2;
    case 'MATLAB Code'
        value=3;
    otherwise
        DAStudio.error('Simulink:dialog:UnexpectedDataSrc',dataSource);
    end
end

function dataSource_l(hDialog,hWS,newValue)


    if newValue~=0
        mdlName=hWS.ownerName;
        dictBd=get_param(mdlName,'DictionarySystem');
        params=dictBd.Parameter.toArray;
        for param=params
            if param.Argument&&~strcmp(param.StorageClass,'Auto')&&...
                ~strcmp(param.StorageClass,'Model default')
                hDialog.apply;
                DAStudio.error('Simulink:Data:DisableDataSrc_ModelArgumentsWithStorageClass',mdlName);
            end
        end
    end

    hDialog.apply;

    if newValue==0
        source='Model File';
    elseif newValue==1
        source='MAT-File';
    elseif newValue==2
        source='MATLAB File';
    else
        assert(newValue==3);
        source='MATLAB Code';
    end


    hWS.DataSource=source;


    es=DAStudio.EventDispatcher;
    es.broadcastEvent('ReadonlyChangedEvent',hWS);
end

function fileBrowser_l(hDialog,hWS)


    hDialog.apply;
    ds=hDialog.getWidgetValue('dataSource');
    assert(ds==1||ds==2);
    if ds==1
        MATfiles=DAStudio.message('MATLAB:uistring:uiopen:MATfiles');
        [filename,pathname]=uigetfile({'*.mat',MATfiles},DAStudio.message('Simulink:tools:MASelectMatFile'));
    else
        MATLABfiles=DAStudio.message('MATLAB:uistring:uiopen:MATLABFiles');
        [filename,pathname]=uigetfile({'*.m',MATLABfiles},DAStudio.message('Simulink:tools:MASelectMATLABFile'));
    end

    if ischar(filename)&&~isempty(filename)&&ischar(pathname)

        [~,~,ext]=fileparts(filename);
        if strcmp(ext,'.m')==0&&strcmp(ext,'.mat')==0
            DAStudio.error('Simulink:dialog:WorkspaceCannotImportFromNonMATMATLABFile',filename);
        end

        hWS.FileName=[pathname,filename];

        es=DAStudio.EventDispatcher;
        es.broadcastEvent('ReadonlyChangedEvent',hWS);
    end
end

function reload_l(hDialog,hWS)



    hDialog.apply;


    try
        hWS.reload;
    catch err
        errMsg=err.message;
        errMsg=Diagnostic.Utils.remove_links(errMsg);
        [~,msg]=slprivate('getAllErrorIdsAndMsgs',err);
        if length(msg)>1
            for idx=1:length(msg)
                errMsg=[errMsg,newline,'-->',Diagnostic.Utils.remove_links(msg{idx})];%#ok<AGROW>
            end
        end
        errordlg(errMsg,DAStudio.message('Simulink:dialog:ReInitSrcFailed'));
    end
end

function saveToSource_l(hDialog,hWS)



    hDialog.apply;


    try

        slprivate('slsaveVarsguicallwrapper','saveToSource',hWS);
    catch err
        errordlg(err.message,DAStudio.message('Simulink:dialog:SaveToSourceFailed'));
    end
end



function relativepath=getRelativePath_l(fullpath)%#ok
    currentpath=[pwd,filesep];
    p=0;

    for k=1:length(currentpath)
        if fullpath(k)==currentpath(k)
            if fullpath(k)==filesep
                p=k;
            end
        else
            break;
        end
    end
    assert(p>0);
    filesepindices=strfind(currentpath(p+1:end),filesep);
    prefixpath='';
    if~isempty(filesepindices)
        for k1=1:length(filesepindices)
            prefixpath=strcat(prefixpath,['..',filesep;]);
        end
    else

        prefixpath=['.',filesep];
    end
    relativepath=strcat(prefixpath,fullpath(p+1:end));
end




