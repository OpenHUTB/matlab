function nesl_makelibrary_tool(packageName,mdlName,outputDir,depErrFlag)












    import simscape.compiler.sli.internal.*;

    pm_assert(nargin>=3);
    packageName=pm_charvector(packageName);
    pm_assert(startsWith(packageName,'+'));

    if nargin<4
        depErrFlag=false;
    end





    warnstat=warning;
    warning('off','Simulink:ShadowedModelName');
    warning('off','Simulink:Engine:MdlFileShadowing');
    warning('off','physmod:pm_sli:PmSli:LibraryEntry:InvalidLibraryName');


    warnCleanup=onCleanup(@()warning(warnstat));


    setappdata(0,'pmGlobals',lGetGlobals);



    libDataStructure=nesl_createlibrarystructure(fullfile(pwd,packageName),...
    depErrFlag);


    isLoaded=bdIsLoaded(mdlName);
    openAfterBuild=isLoaded&&strcmpi(get_param(mdlName,'Open'),'on');
    if isLoaded
        bdclose(mdlName);
    end


    hSlLibrary=new_system(mdlName,'library');
    libLoc=[20,20,420,220];



    simulinkVersion=ver('Simulink');
    set_param(hSlLibrary,...
    'ModelVersionFormat',...
    [num2str(pm.util.versionToNumber(simulinkVersion.Version)),'.%<AutoIncrement:0>']);

    set_param(hSlLibrary,'Location',libLoc);


    defaultFontName='Helvetica';
    set_param(hSlLibrary,'DefaultBlockFontName',defaultFontName,...
    'DefaultAnnotationFontName',defaultFontName,...
    'DefaultLineFontName',defaultFontName);


    libObj=lGetSubLibraryObj(libDataStructure);
    if~isempty(libObj)
        annotation=libObj.Annotation;
        if~isempty(annotation)

            add_block('built-in/Note',[mdlName,'/',annotation],...
            'FontWeight','bold','FontName','auto','FontSize','-1',...
            'Position',[40,40]);
        end
    end


    set_param(hSlLibrary,'EnableLBRepository','on');


    isbuildinglib(1);
    buildingLibCleanup=onCleanup(@()isbuildinglib(0));


    lTraverseLibTree(libDataStructure,hSlLibrary);


    nesl_libautolayout(hSlLibrary);


    nesl_slpostprocess(hSlLibrary,libDataStructure);


    nesl_version_forwarding(hSlLibrary,libDataStructure,packageName(2:end));


    pmsl_deletemodel=pmsl_private('pmsl_deletemodel');
    pmsl_deletemodel(fullfile(outputDir,mdlName));
    pmsl_modelextension=pmsl_private('pmsl_modelextension');


    libName=[mdlName,'.',pmsl_modelextension()];
    fullModelFile=fullfile(outputDir,libName);
    try
        save_system(mdlName,fullModelFile);
    catch ME


        msgids={'Simulink:LoadSave:FileWriteError',...
        'Simulink:LoadSave:RenameError'};
        if any(strcmp(ME.identifier,msgids))
            newException=pm_exception(...
            'physmod:ne_sli:nesl_makelibrary_tool:CannotSaveLibrary',...
            libName,outputDir);
            newException=newException.addCause(ME);
            newException.throwAsCaller();
        end

        ME.rethrow();
    end
    fileattrib(fullModelFile,'-w -w -w');
    close_system(mdlName);

    if openAfterBuild


        thisDir=cd(outputDir);
        C=onCleanup(@()cd(thisDir));
        open_system(mdlName);



        clear('C');
    end
end

function lTraverseLibTree(libraryItemObj,hSlParent)

    persistent DISPATCH;

    if isempty(DISPATCH)
        DISPATCH=struct('domain',@lInvestigateDomainObj,...
        'library',@lInvestigateLibObj,...
        'element',@lInvestigateElemObj);
    end

    fNames=fieldnames(libraryItemObj);
    for idx=1:numel(fNames)
        item=libraryItemObj.(fNames{idx});
        if isstruct(item)
            lInvestigateLibObj(item,fNames{idx},hSlParent);
        elseif isa(item,'simscape.ComponentModel')
            lInvestigateComponentObj(item,hSlParent);
        elseif isprop(item,'item_type')
            fcn=DISPATCH.(item.item_type);
            fcn(item,hSlParent);
        elseif isa(item,'simscape.Variant')
            lInvestigateVariant(item,hSlParent);
        else

        end
    end
end


function subLibObj=lGetSubLibraryObj(libObj)

    subLibObj=[];

    fNames=fieldnames(libObj);
    if any(strcmp(fNames,'lib'))
        subLibObj=libObj.lib;
    end
end

function lInvestigateLibObj(libObj,libName,hSlParent)


    subLibObj=lGetSubLibraryObj(libObj);
    if isempty(subLibObj)
        subLibObj=simscape.Library('');
    end


    templ_struct=lCreateLibTemplate(subLibObj.Name);


    hSlObj=lProcessLibTemplate(hSlParent,templ_struct);

    if subLibObj.ShowIcon
        getImage=ne_private('ne_imagefilefromsourcefile');
        imageExists=getImage(fullfile(subLibObj.Source,'lib.m'));
        if imageExists
            oldPos=get_param(hSlObj,'Position');
            icon=nesl_geticon(fullfile(subLibObj.Source,'lib.m'));
            icon.setupIcon(hSlObj)
            set_param(hSlObj,'DropShadow','off');
            curPos=get_param(hSlObj,'Position');
            scale=(oldPos(4)-oldPos(2))/(curPos(4)-curPos(2));
            newPos=[curPos(1:2),curPos(1:2)+scale*(curPos(3:4)-curPos(1:2))];
            set_param(hSlObj,'Position',newPos);
        end
    end

    if subLibObj.ShowName
        set_param(hSlObj,'ShowName','on');
    else
        set_param(hSlObj,'ShowName','off');
    end

    annotation=subLibObj.Annotation;
    if~isempty(annotation)

        add_block('built-in/Note',[getfullname(hSlObj),'/',annotation],...
        'FontWeight','bold','FontName','auto','FontSize','-1',...
        'Position',[40,40]);
    end


    lTraverseLibTree(libObj,hSlObj);

    if subLibObj.Hidden
        delete_block(hSlObj);
    end



end

function hNewLibBlk=lProcessLibTemplate(hSlParent,templ_struct)


    hNewLibBlk=add_block('built-in/SubSystem',[getfullname(hSlParent),'/',...
    templ_struct.libName]);

    set_param(hNewLibBlk,'Tag','simscape_sublibrary');


    if isfield(templ_struct,'MaskDisplay')&&~isempty(templ_struct.MaskDisplay),
        set_param(hNewLibBlk,'MaskDisplay',templ_struct.MaskDisplay)
    end

    fields=fieldnames(templ_struct);



    for i=1:length(fields),
        if(~any(strcmp(fields{i},{'libName','libLocation','MaskDisplay',...
            'blockTemplates','libDestination','libAnnotation'}))),
            set_param(hNewLibBlk,fields{i},templ_struct.(fields{i}));
        end
    end
end

function lInvestigateDomainObj(domainObj,hSlParent)%#ok<INUSD>



end

function lInvestigateComponentObj(hCompMdl,hSlParent)
    if simscape.internal.build.is_library_component(hCompMdl.Path)
        cs=simscape.schema.loadComponentSchema(hCompMdl.Path);
        info=cs.metaInfo();

        fixedName=nesl_conditionblockname(sprintf(info.Descriptor));

        newBlockName=[getfullname(hSlParent),'/',strrep(fixedName,'/','//')];

        block=add_block('built-in/SimscapeBlock',newBlockName,'MakeNameUnique','on');

        lValidateBlockName(block,fixedName,info.File);

        nesl_setupblock(block,{info.DotPath},{info.Name});
    end

end

function lInvestigateElemObj(hElemObj,hSlParent)

    fixedName=nesl_conditionblockname(hElemObj.descriptor);

    newBlockName=[getfullname(hSlParent),'/',strrep(fixedName,'/','//')];

    block=add_block('built-in/SimscapeBlock',newBlockName,'MakeNameUnique','on');

    lValidateBlockName(block,fixedName,hElemObj.info.SourceFile);

    nesl_setupblock(block,{hElemObj.info.Path},{hElemObj.name});

end

function lInvestigateVariant(variant,hParent)
    fixedName=nesl_conditionblockname(variant.Name);
    newBlockName=[getfullname(hParent),'/',strrep(fixedName,'/','//')];

    hBlock=add_block('built-in/SimscapeBlock',newBlockName,'MakeNameUnique','on');

    lValidateBlockName(hBlock,fixedName,variant.Source);
    components={variant.Variants(:).source};
    componentNames={variant.Variants(:).name};

    nesl_setupblock(hBlock,components,componentNames);

end





function pm=lGetGlobals
    pm.HIDE='h';
    pm.SHOW='s';


    pm.LITERAL='&';
    pm.EVAL='@';










    pm.INMASK=1;
    pm.DEFAULT_VAL=2;
    pm.FIELD_TYPE=3;
    pm.EVAL_FLAG=4;
    pm.VAR_NAME=5;
    pm.VAR_LABEL=6;
    pm.MASK_VAR_HIDE=7;
    pm.MASK_VAR_TUN=8;



    pm.MASK_PARAM={pm.SHOW,'','edit',pm.EVAL,'','','off','off'};

end

function tStruct=lCreateLibTemplate(name)
    multiLnName=nesl_conditionblockname(name);
    tStruct.libName=multiLnName;
    tStruct.libAnnotation=name;
    tStruct.MaskDisplay='disp(get_param(gcb,''Name''))';
    tStruct.MaskInitialization='';
    tStruct.ShowName='off';
    tStruct.FontSize='-1';
    tStruct.FontName='auto';
    tStruct.Position='[0 0 100 40]';
    tStruct.DropShadow='on';
end

function lValidateBlockName(hSlObj,fixedName,sourceFile)
    blockName=get_param(hSlObj,'name');
    if~strcmpi(blockName,fixedName)
        subLibName=get_param(get_param(hSlObj,'Parent'),'Name');
        otherBlock=[getfullname(get_param(hSlObj,'Parent')),'/',fixedName];
        otherSourceFile=simscape.compiler.sli.internal.sourcefilefromblock(otherBlock);
        pm_error('physmod:ne_sli:nesl_makelibrary_tool:DuplicateBlocks',...
        fixedName,subLibName,sourceFile,otherSourceFile);
    end
end



