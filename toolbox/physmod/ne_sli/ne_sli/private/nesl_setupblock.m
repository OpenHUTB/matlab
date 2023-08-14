function nesl_setupblock(block,components,componentNames)





    import simscape.compiler.sli.internal.*;

    pm_assert(numel(components)==numel(componentNames));

    assert(strcmp(get_param(block,'BlockType'),'SimscapeBlock'));
    lSetup(block,components,componentNames);

end


function lCommonSetup(hSlObj,templ_struct,cs,info)



    h=hSlObj;
    fields=fieldnames(templ_struct.slBlockProps);

    for idx=1:length(fields)
        set_param(h,fields{idx},templ_struct.slBlockProps.(fields{idx}));
    end



    maybeImageFile=string(simscape.schema.internal.libraryBlockIconPath(cs));



    lSetupBlockIcon(hSlObj,maybeImageFile);




    lResizeBlockFromInfo(info,hSlObj,maybeImageFile,false);





    if lShouldPermuteImage(info)
        set_param(hSlObj,'Orientation','down');
        set_param(hSlObj,'NamePlacement','normal');
    end

end


function lSetup(block,components,componentNames)

    lGenerateDialogSchemaFiles(block,components);


    cs=physmod.schema.internal.blockComponentSchema(block,components{1});
    info=cs.info();


    if simscape.versioning.internal.enabled
        depver=simscape.versioning.internal.dependentversions(...
        info.File);
        gendir=ne_private('ne_gendir');
        [pthstr,name]=gendir(info.File);
        if~exist(pthstr,'dir')
            mkdir(pthstr);
        end
        save(fullfile(pthstr,[name,'.pmver']),'depver');
    end


    if numel(components)==1&&...
        ~simscape.internal.build.is_library_component(info.DotPath)
        delete_block(block);
        return;
    end


    simscape.engine.sli.internal.setupmask(...
    block,components,componentNames);

    templ_struct=lCreateDefaultTemplate();
    lCommonSetup(block,templ_struct,cs,info);

    set_param(block,'SourceFile',components{1});
    ph=get_param(block,'PortHandles');
    nPorts=numel(ph.LConn)+numel(ph.RConn);
    if(nPorts<1)
        pm_error('physmod:ne_sli:nesl_makelibrary_tool:NoPorts',...
        info.DotPath);
    end


    iconKey=SLBlockIcon.getEffectiveBlockIconKey(block);
    DVG.Registry.refreshIcon(iconKey);

end

function lGenerateDialogSchemaFiles(block,components)
    for idx=1:numel(components)

        cs=physmod.schema.internal.blockComponentSchema(block,components{idx});


        nesl_generatedialogschemafile(cs.info());
    end
end

function lResizeBlockFromInfo(info,hBlock,maybeImageFile,useBlockAspectRatio)





    NOMINAL_SIZE_ICON=40;
    NOMINAL_SIZE_NOICON=60;

    guiInfo.info.GuiFile=fullfile(...
    fileparts(info.File),'/gui/',[info.Name,'.m']);
    guiInfoStruct=nesl_readguifile(guiInfo);




    if(isfield(guiInfoStruct,'blocksize')&&...
        isfield(guiInfoStruct.blocksize,'width')&&...
        isfield(guiInfoStruct.blocksize,'height'))

        posVals=get_param(hBlock,'Position');
        posVals(3)=posVals(1)+guiInfoStruct.blocksize.width;
        posVals(4)=posVals(2)+guiInfoStruct.blocksize.height;
        set_param(hBlock,'Position',posVals);
        return;
    end




    if~ismissing(maybeImageFile)
        baseBlkSize=NOMINAL_SIZE_ICON;
    else
        baseBlkSize=NOMINAL_SIZE_NOICON;
    end

    if isfield(guiInfoStruct,'blocksize')&&isfield(guiInfoStruct.blocksize,...
        'sideScale')
        baseBlkSize=guiInfoStruct.blocksize.sideScale*baseBlkSize;
    elseif~ismissing(maybeImageFile)&&~isempty(info.Scale)

        baseBlkSize=info.Scale*baseBlkSize;
    end









    if useBlockAspectRatio
        posVals=get_param(hBlock,'Position');

        width=posVals(3)-posVals(1);
        height=posVals(4)-posVals(2);
        aspectRatio=width/height;
        if(aspectRatio<1)
            new_width=aspectRatio*baseBlkSize;
            new_height=baseBlkSize;
        else
            new_width=baseBlkSize;
            new_height=baseBlkSize/aspectRatio;
        end
        posVals(3)=posVals(1)+new_width;
        posVals(4)=posVals(2)+new_height;
        set_param(hBlock,'Position',posVals);
    else
        blkSizeBuckets=lGenSizeBuckets(baseBlkSize);

        posVals=get_param(hBlock,'Position');
        curAspect=(posVals(3)-posVals(1))/(posVals(4)-posVals(2));
        nBuckets=numel(blkSizeBuckets);


        new_height=blkSizeBuckets{nBuckets}.height;
        new_width=blkSizeBuckets{nBuckets}.width;


        for bucketIdx=1:nBuckets
            if(blkSizeBuckets{bucketIdx}.lbound<=curAspect&&...
                blkSizeBuckets{bucketIdx}.ubound>curAspect)
                new_height=blkSizeBuckets{bucketIdx}.height;
                new_width=blkSizeBuckets{bucketIdx}.width;
                break;
            end
        end

        posVals(3)=posVals(1)+new_width;
        posVals(4)=posVals(2)+new_height;
        set_param(hBlock,'Position',posVals);
    end
end

function blkSizeBuckets=lGenSizeBuckets(blkSizePix)



    bucketBases=[.5,(2/3),1.0,1.5,2.0];
    nBuckets=numel(bucketBases);
    bounds=[0.0,100.0];

    blkSizeBuckets={};
    for idx=1:nBuckets
        baseRatio=bucketBases(idx);
        if idx==1
            item.lbound=bounds(1);
        else
            item.lbound=blkSizeBuckets{idx-1}.ubound;
        end

        if idx==nBuckets
            item.ubound=bounds(2);
        else
            item.ubound=baseRatio+0.5*(bucketBases(idx+1)-baseRatio);
        end

        if baseRatio<1.0
            item.width=ceil(blkSizePix*baseRatio);
            item.height=blkSizePix;
        else
            item.width=blkSizePix;
            item.height=ceil(blkSizePix/baseRatio);
        end

        blkSizeBuckets{end+1}=item;%#ok<AGROW>
    end
end

function permuteImage=lShouldPermuteImage(info)
    permuteImage=false;
    if~info.PortsOnAllFourSides
        sides={info.Members.ConnectionPorts.Side,info.Members.Inputs.Side,...
        info.Members.Outputs.Side};
        permuteImage=any(strcmp(sides,'top'))||...
        any(strcmp(sides,'bottom'));
    end
end

function lSetupBlockIcon(hSlObj,maybeImageFile)

    if~ismissing(maybeImageFile)






        pos=get_param(hSlObj,'Position');
        [h,w]=nesl_imageaspectratio(maybeImageFile);
        pm_assert(h~=0&&w~=0,['Can not read image size from ',...
        char(maybeImageFile)]);

        width=40;
        height=width*h/w;
        set_param(hSlObj,'Position',...
        [pos(1),pos(2),pos(1)+width,pos(2)+height]);
    end
end


function tStruct=lCreateDefaultTemplate()

    tStruct.classProps.FactoryBlock='Factory Generic';

    rtmCallBacks={'LoadFcn',...
    'CopyFcn',...
    'PreCopyFcn',...
    'PreDeleteFcn',...
    'DeleteFcn',...
    'PreSaveFcn',...
    'PostSaveFcn',...
'ModelCloseFcn'
    };

    rtmCallBackStrings=strcat('simscape.compiler.sli.internal.callback(''',rtmCallBacks,''',gcbh);');
    rtmCBParams=cell(1,2*numel(rtmCallBacks));
    rtmCBParams(1:2:end)=rtmCallBacks;
    rtmCBParams(2:2:end)=rtmCallBackStrings;


    tStruct.slBlockProps=struct(...
    'FontName','auto',...
    'FontSize','-1',...
    'DialogController','NetworkEngine.DynNeDlgSource',...
    rtmCBParams{:}...
    );
end







