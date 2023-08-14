function varargout=callback(event,handle)











    switch lower(event)
    case 'mask'
        lSscCallback(handle,'');
    case 'loadfcn'
        lLoadBlockWithCorrectVariant(handle);
        lSscCallback(handle,'BLK_POSTLOAD');
    case 'copyfcn'
        lSscCallback(handle,'BLK_POSTCOPY');
    case 'precopyfcn'
        lSscCallback(handle,'BLK_PRECOPY');
    case 'predeletefcn'
        lSscCallback(handle,'BLK_PREDELETE');
    case 'deletefcn'
        lSscCallback(handle,'BLK_POSTDELETE');
    case 'presavefcn'
        lSscCallback(handle,'BLK_PRESAVE');
    case 'postsavefcn'
        lSscCallback(handle,'BLK_POSTSAVE');
    case 'parametereditingmodes'

        varargout{1}=l_get_parameter_editing_modes(get_param(handle,'Handle'));
    case 'blockcompile'
        lSscCallback(handle,'BLK_PRECOMPILE');
    case 'modelcompile'
        lSscCallback(handle,'DOM_INIT');
    case 'modelclosefcn'
        lSscCallback(handle,'MODEL_CLOSE');
    otherwise
        pm_abort('Unknown callback');
    end

    function lSscCallback(hBlock,varargin)



        if isa(hBlock,'Simulink.Block')
            hBlock=hBlock.handle;
        end











        if pm.sli.internal.isDefaultProductInstalled()
            pmsl_rtmcallback(hBlock,varargin{:});
        else
            if~lIsBlockException(hBlock)&&...
                ~lIsBeingDeleted(varargin{1})&&...
                ~lIsModel(hBlock)
                pm_error('physmod:pm_sli:sl:InvalidLicense',...
                pmsl_defaultproduct(),getfullname(hBlock));
            end
        end


        function result=lIsBlockException(hBlock)
            result=pm.sli.isBlockInLibrary(hBlock)||...
            simscape.compiler.sli.internal.isbuildinglib()||...
            pm.simscape.internal.isSimscapeComponentDependent(hBlock);


            function result=lIsBeingDeleted(cbType)
                result=strcmp(cbType,'BLK_PREDELETE')||...
                strcmp(cbType,'BLK_POSTDELETE');


                function result=lIsModel(hBlock)
                    result=strcmp(get_param(hBlock,'Type'),'block_diagram');


                    function editModes=l_get_parameter_editing_modes(hBlk)

                        blkType=get_param(hBlk,'BlockType');
                        if strcmp(blkType,'SimscapeBlock')||strcmp(blkType,'SimscapeComponentBlock')
                            editModes=lGetSimscapeBlockEditingModes(hBlk);
                        else

                            libEntry=pmsl_getblocklibraryentry(hBlk);



                            NeDialogCustom={};
                            if~isempty(libEntry)&&strcmp(libEntry.Name,'nesl_utility')
                                dlgSchema=nesl_utility_createpmschema(hBlk);




                                NeDialogCommon={...
                                'NetworkEngine.PmGuiDropDown',{'ValueBlkParam'},{}...
                                };

                                NeDialogClasses=[NeDialogCustom;NeDialogCommon];


                                maskNames=get_param(hBlk,'MaskNames');


                                editModes=pmsl_geteditingmodes(dlgSchema,NeDialogClasses,maskNames);
                            else

                                pm_abort(sprintf('Invalid block: ''%s''',getfullname(hBlk)));
                            end
                        end



                        function lLoadBlockWithCorrectVariant(hBlk)



                            isSimscapeCoreBlock=strcmp(get_param(hBlk,'BlockType'),'SimscapeBlock');


                            if isSimscapeCoreBlock

                                refBlk=get_param(hBlk,'ReferenceBlock');
                                isRefBlkEmpty=isempty(refBlk);


                                if~bdIsLibrary(bdroot(hBlk))
                                    pm_assert(~isRefBlkEmpty,'Reference block is empty.');
                                    sourceFile=get_param(hBlk,'SourceFile');

                                    if~isempty(which(sourceFile))

                                        lUpdateBlockVariants(hBlk,refBlk);







                                        simscape.gui.sli.internal.update_mask_tunable_values(hBlk);


                                        nesl_setvariant=nesl_private('nesl_setvariant');
                                        nesl_setvariant(hBlk,sourceFile);
                                    end
                                else

                                    if~isRefBlkEmpty
                                        sourceFile=get_param(hBlk,'SourceFile');

                                        if~isempty(which(sourceFile))

                                            lUpdateBlockVariants(hBlk,refBlk);
                                        end
                                    end
                                end

                            end

                            function lUpdateBlockVariants(hBlk,refBlk)


                                [refCompVariants,refCompNames]=simscape.internal.variantsAndNames(refBlk);
                                [compVariants,compNames]=simscape.internal.variantsAndNames(hBlk);



                                if~isequal(compVariants,refCompVariants)||~isequal(compNames,refCompNames)

                                    rootSys=pmsl_bdroot(hBlk);
                                    libraryLockState=get_param(rootSys,'Lock');
                                    if strcmp(get_param(rootSys,'Lock'),'on')
                                        set_param(rootSys,'Lock','off');
                                        C=onCleanup(@()set_param(rootSys,'Lock',libraryLockState));
                                    end
                                    set_param(hBlk,'ComponentVariants',simscape.internal.encodeVariantList(refCompVariants),...
                                    'ComponentVariantNames',simscape.internal.encodeVariantList(refCompNames));
                                end

                                function editModes=lGetSimscapeBlockEditingModes(hBlk)
                                    cs=physmod.schema.internal.blockComponentSchema(hBlk);
                                    maskParams=simscape.schema.internal.restrictedParameters(cs);
                                    editModes=struct('maskName',maskParams,'editingMode',...
                                    repmat({'Authoring Mode parameter'},size(maskParams)));

