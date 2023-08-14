function newFiles=hydraulicToIsothermalLiquidPostProcess_private(varargin)




























    oldFiles=processInputs(varargin{:});


    [newFiles,newFilesExists]=getNewFilesNames(oldFiles);

    if sum(newFilesExists)>0



        existingFiles_str=sprintf('\n%s',newFiles{newFilesExists});
        warning(message('physmod:simscape:utils:hydraulicToIsothermalLiquid:FileOverwriteWarning',existingFiles_str));
        OK_selected=choosedialog;
    end

    if sum(newFilesExists)==0||OK_selected==1

        s=suppressWarnings;


        [newModelNames,orig_library_lock,orig_editing_mode]=renameFiles(oldFiles,newFiles);


        updateLinks(oldFiles,newFiles,newModelNames);


        restoreLocksRestrictions(newModelNames,orig_library_lock,orig_editing_mode);


        if~isempty(oldFiles)
            delete(oldFiles{:});
        end


        warning(s);
    else
        newFiles={};
    end

end



function oldFiles=processInputs(varargin)


    if iscell(varargin{:})
        varargin=varargin{:};
    end
    args=pm_cellstr(varargin{:});
    args_content=args{:};
    if isfolder(args_content)



        allFilesStruct=dir(fullfile(args_content,['**',filesep,'*.*']));

        filesKeep=~cellfun(@isempty,regexp({allFilesStruct.name},'\w*(_converted.mdl)$|\w*(_converted.slx)$'))';
        filesStruct=allFilesStruct(filesKeep);

        fileslist_cell=struct2cell(filesStruct);
        oldFiles=cellfun(@fullfile,fileslist_cell(2,:),fileslist_cell(1,:),'UniformOutput',false)';
    else
        try
            oldFiles_input=cell(length(args),1);
            for m=1:length(args)
                oldFiles_input{m}=Simulink.MDLInfo(args{m}).FileName;
            end
            filesKeep_ind=~cellfun(@isempty,regexp({oldFiles_input{:}},'\w*(_converted.mdl)$|\w*(_converted.slx)$'))';
            oldFiles=oldFiles_input(filesKeep_ind);
        catch ME

            msg=message('physmod:simscape:utils:hydraulicToIsothermalLiquid:InvalidInputPostProcess');
            causeException=MException(msg);
            ME=addCause(ME,causeException);
            throwAsCaller(ME);
        end
    end



    try
        load_system(oldFiles);
    catch ME

        msg=message('physmod:simscape:utils:hydraulicToIsothermalLiquid:UnableToLoad');
        causeException=MException(msg);
        ME=addCause(ME,causeException);
        throwAsCaller(ME);
    end
end


function[newFiles,existingFiles]=getNewFilesNames(oldFiles)


    newFiles=strrep(oldFiles,'_converted.mdl','.mdl');
    newFiles=strrep(newFiles,'_converted.slx','.slx');

    existingFiles=isfile(newFiles);

end


function s=suppressWarnings
    s=warning;
    warning('off','Simulink:Engine:MdlFileShadowing');
    warning('off','Simulink:Engine:UnableToLoadBd');
    warning('off','Simulink:Commands:ParamUnknown');
    warning('off','SL_SERVICES:utils:TooManyErrorsErr');
    warning('off','diagram_autolayout:autolayout:layoutRejectedCommandLine');
    warning('off','Simulink:Engine:SaveWithDisabledLinks_Warning');
end


function[newModels,orig_library_lock,orig_editing_mode]=renameFiles(oldFiles,newFiles)




    numFiles=length(oldFiles);
    newModels=cell(numFiles,1);
    orig_library_lock=cell(numFiles,1);
    orig_editing_mode=cell(numFiles,1);
    for m=1:numFiles
        oldFileName=oldFiles{m};
        newFileName=newFiles{m};


        load_system(oldFileName);
        [~,oldModel,~]=fileparts(oldFileName);


        if bdIsDirty(oldModel)
            warning(message('physmod:simscape:utils:hydraulicToIsothermalLiquid:DirtyModelWarning',oldFileName))
        end


        pmsl_validatelibrarylinks(oldModel);


        [~,newModel,~]=fileparts(newFileName);

        bdclose(newModel)
        h=new_system(newModel,'FromFile',oldFileName);
        newModels{m}=newModel;

        save_system(h,newFileName);



        load_system(newModel);
        if strcmp('on',get_param(oldModel,'Shown'))
            open_system(newModel);
        end

        if bdIsLibrary(newModel)

            orig_library_lock{m}=get_param(newModel,'Lock');
            set_param(newModel,'Lock','off')
        else

            orig_editing_mode{m}=get_param(oldModel,'EditingMode');

            try
                set_param(newModel,'EditingMode','full');
            catch ME
                msg=message('physmod:simscape:utils:hydraulicToIsothermalLiquid:FullModeConverterTool');
                causeException=MException(msg);
                ME=addCause(ME,causeException);
                throwAsCaller(ME);
            end
        end
        save_system(newModel);
    end
end


function updateLinks(oldFiles,newFiles,newBlockDiagramNames)





    load_system(newBlockDiagramNames);

    numFilesToUpdate=length(oldFiles);
    for m=1:numFilesToUpdate
        oldFile=oldFiles{m};
        oldFileName=Simulink.MDLInfo(oldFile).BlockDiagramName;
        fileType=Simulink.MDLInfo(oldFile).BlockDiagramType;


        newFile=newFiles{m};
        newFileName=Simulink.MDLInfo(newFile).BlockDiagramName;

        switch fileType
        case 'Library'
            blockType='SubSystem';
            blockParameter='ReferenceBlock';
            blockParameterValue=['^',oldFileName,'/'];
        case 'Subsystem'
            blockType='SubSystem';
            blockParameter='ReferencedSubsystem';
            blockParameterValue=['^',oldFileName];
        case 'Model'
            blockType='ModelReference';
            blockParameter='ModelFile';
            blockParameterValue=['^',oldFileName,'.'];
        end

        linkedOrReferencedBlocks=find_system(newBlockDiagramNames,'MatchFilter',@Simulink.match.allVariants,'LookInsideSubsystemReference','Off',...
        'LookUnderMasks','all','Regexp','on','BlockType',blockType,blockParameter,blockParameterValue);

        for i=1:length(linkedOrReferencedBlocks)
            oldLibraryOrReference=get_param(linkedOrReferencedBlocks{i},blockParameter);
            newLibraryOrReference=strrep(oldLibraryOrReference,oldFileName,newFileName);
            set_param(linkedOrReferencedBlocks{i},blockParameter,newLibraryOrReference);
        end
    end
    save_system(newFiles,[],'SaveDirtyReferencedModels',1)
end


function restoreLocksRestrictions(newFiles,orig_library_lock,orig_editing_mode)
    for m=1:length(newFiles)
        newModel=newFiles{m};
        if bdIsLibrary(newModel)
            if isempty(orig_library_lock{m})
                set_param(newModel,'Lock',orig_library_lock);
            end
        else

            set_param(newModel,'EditingMode',orig_editing_mode{m});
        end
        save_system(newModel,[],'SaveDirtyReferencedModels',1);
    end
end


function OK_selected=choosedialog

    d=msgbox('hydraulicToIsothermalLiquidPostProcess will overwrite existing files. See warning in Command Window for the list of files. Click OK to proceed.',...
    'Warning','warn');



    d.Children(1).Callback=@btn_callback;
    OK_selected=0;


    uiwait(d);

    function btn_callback(src,event)
        OK_selected=1;
        delete(gcf);
    end
end
