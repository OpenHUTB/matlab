function targetInfoStruct=getMATLABCodeGenTarget()





    prefname='MATLABCodeGenTarget';
    codeGenTarget=linkfoundation.xmakefile.XMakefilePreferences.getPreference(prefname);
    if isempty(codeGenTarget)
        [targetBoard,boardRegistry]=getTargetBoard;
    else
        if~isfield(codeGenTarget,'Tag')||~isfield(codeGenTarget,'BoardName')||...
            ~isfield(codeGenTarget,'AdaptorRegistryFunc')||...
            error(message('ERRORHANDLER:pjtgenerator:IncorrectMATLABCodeGenTargetPrefValue',prefname));
        end
        [targetBoard,boardRegistry]=getTargetBoard(codeGenTarget.Tag,...
        codeGenTarget.BoardName,codeGenTarget.AdaptorRegistryFunc);
    end


    targetRegistryFileObj=linkfoundation.util.File(fullfile(boardRegistry.UDRepository,targetBoard.UDFileName));
    targetRegistryFile=targetRegistryFileObj.FullPathName;
    if~targetRegistryFileObj.exists()
        error(message('ERRORHANDLER:pjtgenerator:MissingBoardRegistryFile',...
        targetRegistryFile));
    end


    try
        targetInfoStruct=load(targetRegistryFile);
        targetInfoStruct=targetInfoStruct.ud;
    catch origEx
        newExc=MException('ERRORHANDLER:pjtgenerator:BoardRegistryFileLoadError',DAStudio.message('ERRORHANDLER:pjtgenerator:BoardRegistryFileLoadError',targetRegistryFile));
        lf_throwPjtGenError(newExc,origEx);
    end




    function[targetBoard,boardRegistry]=getTargetBoard(targetTag,targetName,targetRegistryFunc)
        if(nargin==0)
            targetTag='eclipseidetgtpref';
            targetName='Custom';
            targetRegistryFunc='registerEclipseIDE';
        end

        adaptorName=linkfoundation.util.convertTPTagToAdaptorName(targetTag);
        adaptorRegistry=linkfoundation.pjtgenerator.AdaptorRegistry.manageInstance('get','EmbeddedIDELink');

        targetRegistryFuncHdl=eval(['@',targetRegistryFunc]);
        adaptorRegistry.registerAdaptor(targetRegistryFuncHdl);

        registryRoot=adaptorRegistry.getRegistryRoot(adaptorName);

        boardRegistry=linkfoundation.pjtgenerator.BoardRegistry.manageInstance('get',targetTag);
        boardRegistry.RegistryRoot=registryRoot;

        targetBoard=boardRegistry.getBoardInfoByDisplayName(targetName);
    end

end