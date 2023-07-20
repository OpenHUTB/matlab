function[hFig,img_data]=snapshot(varargin)




















    try
        FROM_OPTIONS={'opened','active'};
        TO_OPTIONS={'clipboard','file','image','figure'};

        settingRecord=Simulink.record.internal.snapshotSettingRecord;

        p=inputParser;
        p.addParameter('from','opened',@(x)validate_from_param(x,FROM_OPTIONS,settingRecord));
        p.addParameter('to','clipboard',@(x)validate_to_param(x,TO_OPTIONS,settingRecord));
        p.addParameter('filename','plots.png',@validate_file);
        p.addParameter('props',{},@iscell);
        p.addParameter('figure',[]);
        p.addParameter('block',gcb);
        p.parse(varargin{:});
        params=p.Results;

        params.filename=validateAndUpdateFileExt(params.filename);

        if isempty(params.block)
            return;
        end
        blockSetting=get_param(params.block,'snapshot');
        if settingRecord.hasFromSet
            blockSetting.area=RecordBlkView.SnapshotArea.ENTIRE_PLOT;
            if isequal(params.from,'active')
                blockSetting.area=RecordBlkView.SnapshotArea.SELECTED_PLOT;
            end
            set_param(params.block,'snapshot',blockSetting);
        else
            if isequal(blockSetting.area,RecordBlkView.SnapshotArea.SELECTED_PLOT)
                params.from='active';
            end
        end

        if settingRecord.hasSendToSet
            blockSetting.sendTo=RecordBlkView.SnapshotSend.CLIPBOARD;
            if isequal(params.to,'file')
                blockSetting.sendTo=RecordBlkView.SnapshotSend.IMAGEFILE;
            elseif isequal(params.to,'figure')
                blockSetting.sendTo=RecordBlkView.SnapshotSend.MATLABFIGURE;
            end
            set_param(params.block,'snapshot',blockSetting);
        else
            if isequal(blockSetting.sendTo,RecordBlkView.SnapshotSend.IMAGEFILE)
                params.to='file';
            elseif isequal(blockSetting.sendTo,RecordBlkView.SnapshotSend.MATLABFIGURE)
                params.to='figure';
            end
        end

        [hFig,img_data]=doSnapshot(params);

    catch me
        me.throwAsCaller();
    end
end

function ret=validate_from_param(x,opts,settingRecord)
    ret=validate_parameter(x,opts);
    if ret
        settingRecord.hasFromSet=true;
    end
end

function ret=validate_to_param(x,opts,settingRecord)
    ret=validate_parameter(x,opts);
    if ret
        settingRecord.hasSendToSet=true;
    end
end


function ret=validate_parameter(x,opts)
    ret=false;
    if isstring(x)&&isscalar(x)
        x=char(x);
    end
    if ischar(x)
        ret=any(strcmpi(opts,x));
    end
end


function ret=validate_file(x)
    ret=ischar(x)||(isstring(x)&&isscalar(x));
end


function fname=validateAndUpdateFileExt(fname)
    fname=char(fname);
    [~,~,ext]=fileparts(fname);
    if isempty(fname)
        error(message('SDI:sdi:InvalidPNGFileName'));
    elseif isempty(ext)
        fname=[fname,'.png'];
    elseif~strcmpi(ext,'.png')
        error(message('SDI:sdi:InvalidPNGFileName'));
    end
end


function[hFig,img_data]=doSnapshot(params)
    hFig=[];
    img_data=[];



    clientID=[];
    studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive();
    studio=studios(1);
    editor=studio.App.getActiveEditor();
    path=Simulink.BlockPath(GLUE2.HierarchyService.getPaths(editor.getCurrentHierarchyId));
    instanceInfo=get_param(params.block,'InstanceInfo');

    structLen=length(instanceInfo);
    for index=1:structLen
        sfullBlockPath=Simulink.BlockPath(instanceInfo(index).fullBlockPath);
        if sfullBlockPath.isequal(path)
            clientID=instanceInfo(index).clientID;
            break;
        end
    end

    if isempty(clientID)
        return;
    end


    bCopyActiveOnly=strcmpi(params.from,'active');
    if bCopyActiveOnly
        copyType='copySubplot';
    else
        copyType='all';
    end


    if strcmpi(params.to,'figure')
        eng=Simulink.sdi.Instance.engine;
        appInfo.recordBlk=params.block;
        hFig=eng.exportPlotToFigure(...
        num2str(clientID),0,copyType,appInfo);
        return;
    end


    if strcmpi(params.to,'image')
        params.filename=[tempname,'.png'];
    elseif strcmpi(params.to,'clipboard')
        params.filename='';
    end


    Simulink.sdi.createSnapshotForStreamoutBlk(int64(str2double(clientID)),bCopyActiveOnly,char(params.filename));


    if strcmpi(params.to,'file')
        sw=warning('off','MATLAB:imagesci:png:tooManyIDATsData');
        tmp=onCleanup(@()warning(sw));
        MAX_TRIES=20;
        nTries=0;
        isFileReady=false;
        while~isFileReady&&nTries<MAX_TRIES
            try
                img_data=imread(params.filename);
                isFileReady=true;
            catch ME %#ok<NASGU>
                isFileReady=false;
                pause(0.1);
            end
            nTries=nTries+1;
            if nTries>MAX_TRIES
                isFileReady=true;
            end
        end
    end


    if strcmpi(params.to,'image')
        pause(0.1);
        if exist(params.filename,'File')
            [hFig,img_data]=getImageFromFile(params.filename,params.props,params.figure);
            delete(params.filename);
        end
    end
end


function[hFig,img_data]=getImageFromFile(fname,props,hFig)


    MAX_TRIES=20;
    for idx=1:MAX_TRIES
        try
            img_data=imread(fname);
            pause(0.2);
            continue
        catch ME %#ok<NASGU>
        end
        if~isempty(img_data)
            break;
        end
    end
    bFigPassedIn=~isempty(hFig);
    if~bFigPassedIn
        hFig=figure(props{:});
    else
        isVisible=hFig.Visible;
    end
    hAxes=axes('Parent',hFig,'Visible',hFig.Visible);




    sw=warning('off','all');
    tmp=onCleanup(@()warning(sw));
    hImg=imshow(img_data,'Parent',hAxes);%#ok<NASGU>
    if bFigPassedIn
        hFig.Visible=isVisible;
    end
end

