




classdef BlkRepRule<Sldv.xform.RepRule




    properties(Access=public)

        FileName='';




        ReplacementPath='';










        ParameterMap=[];






        IsReplaceableCallBack=[];






        PostReplacementCallBack=[];




        InlinedWithNewSubsys=false;


        InlineOnlyMode=false;







        PathTranslationInfo=[];
    end

    properties(Access=public,Hidden)














        ReplacementMode='Normal';




















        CopyOrigDialogParams=false;



        UseOriginalBlockAsReplacement=false;


        IsActive=true;


        IsBuiltin=false;



        IsAuto=false;


        Priority=0;




        RunTimeParamsToCapture={};




        IgnoreUnderSelfModifMaskedSubsystemCheck=false;
    end

    properties(Access=public,Hidden,Dependent)

        fileName;
        replacementMode;
        replacementPath;
        parameterMap;
        copyOrigDialogParams;
        isReplaceableCallBack;
        postReplacementCallBack;
    end

    properties(Access=protected)


        ReplacementLib='';



        ReplacementBlk='';




        PopupParamsReplacementBlk=[];




        ReplacementBlockUpdatedOnInstance=false;



        AllParamNamesOnReplacementBlock={};


        OpenedModels={};
    end

    methods
        function obj=BlkRepRule
            obj=obj@Sldv.xform.RepRule;
        end

        function set.FileName(obj,val)
            if all(exist(val,'file')~=[2,6])&&all(exist(['private/',val],'file')~=[2,6])
                if~strcmp(val,'blkrep_rule_subsystem_stubbing')
                    error(message('Sldv:xform:BlkRepRule:setFileName'));
                end
            end
            obj.FileName=val;
        end

        function set.ReplacementMode(obj,val)
            if obj.UseOriginalBlockAsReplacement %#ok<MCSUP>
                error(message('Sldv:xform:BlkRepRule:setReplacementMode:CannotSetToNonDefault'));
            end
            if isempty(obj.FileName)%#ok<MCSUP>
                error(message('Sldv:xform:BlkRepRule:setReplacementMode:NoFileNameReplacementMode'));
            end
            if~strcmp(val,'Stub')&&isempty(obj.ReplacementPath)%#ok<MCSUP>
                error(message('Sldv:xform:BlkRepRule:setReplacementMode:NoReplacementPathForMode'));
            end
            if~strcmp(val,'Normal')&&~strcmp(val,'Stub')
                error(message('Sldv:xform:BlkRepRule:setReplacementMode:InvalidParameter',obj.FileName));%#ok<MCSUP>
            end
            obj.ReplacementMode=val;
        end

        function set.ReplacementPath(obj,val)
            if obj.UseOriginalBlockAsReplacement %#ok<MCSUP>
                error(message('Sldv:xform:BlkRepRule:setReplacementMode:CannotSetReplacementPath'));
            end
            if isempty(obj.FileName)%#ok<MCSUP>
                error(message('Sldv:xform:BlkRepRule:setReplacementPath:NoFileNameReplacementPath'));
            end
            if isempty(obj.BlockType)
                error(message('Sldv:xform:BlkRepRule:setReplacementPath:NoBlockType',obj.FileName));%#ok<MCSUP>
            end

            index=find(val=='/');
            replacementLib=val(1:index(1)-1);
            replacementBlk=val(index(end)+1:end);
            relativeReplacementBlk=['.',val(index(1):end)];



            if~contains(replacementLib,'simulink')&&...
                ~contains(replacementLib,'Simulink')&&...
                ~contains(replacementLib,'built-in')
                obj.checkReplacementBlock(val,replacementLib,replacementBlk);
            elseif isempty(find_system('SearchDepth',0,'Name','simulink'))
                obj.addToOpenedModelsList('simulink');
                Sldv.load_system('simulink');
            end

            obj.ReplacementLib=replacementLib;%#ok<MCSUP>
            obj.ReplacementBlk=relativeReplacementBlk;%#ok<MCSUP>
            obj.ReplacementPath=val;
        end

        function set.ParameterMap(obj,val)
            if obj.UseOriginalBlockAsReplacement %#ok<MCSUP>
                error(message('Sldv:xform:BlkRepRule:setReplacementMode:CannotSetParameterMap'));
            end
            if isempty(obj.FileName)%#ok<MCSUP>
                error(message('Sldv:xform:BlkRepRule:setParameterMap:NoFileNameParameterMap'));
            end
            if isempty(obj.ReplacementPath)%#ok<MCSUP>
                error(message('Sldv:xform:BlkRepRule:setParameterMap:NoReplacementPathForParameter'));
            end
            obj.checkParameterMap(val);
            obj.ParameterMap=val;
        end

        function set.IsReplaceableCallBack(obj,val)
            if isempty(obj.FileName)%#ok<MCSUP>
                error(message('Sldv:xform:BlkRepRule:setIsReplaceableCallBack:NoFileNameIsReplaceableCallback'));
            end
            if isempty(val)
                error(message('Sldv:xform:BlkRepRule:setIsReplaceableCallBack:Empty',obj.FileName));%#ok<MCSUP>
            end
            functionInfo=functions(val);
            if isempty(functionInfo.file)
                error(message('Sldv:xform:BlkRepRule:setIsReplaceableCallBack:NoCallBack',obj.FileName));%#ok<MCSUP>
            end
            if nargout(val)~=1||nargin(val)<1||nargin(val)>2
                error(message('Sldv:xform:BlkRepRule:setIsReplaceableCallBack:WrongArgument',obj.FileName));%#ok<MCSUP>
            end
            obj.IsReplaceableCallBack=val;
        end

        function set.PostReplacementCallBack(obj,val)
            if isempty(obj.FileName)%#ok<MCSUP>
                error(message('Sldv:xform:BlkRepRule:setPostReplacementCallBack:NoFileNamePostReplacementCallBack'));
            end
            if~isempty(val)
                if nargout(val)~=0||nargin(val)<1||nargin(val)>4
                    error(message('Sldv:xform:BlkRepRule:setPostReplacementCallBack:WrongArgument',obj.FileName));%#ok<MCSUP>
                end
            end
            obj.PostReplacementCallBack=val;
        end

        function set.RunTimeParamsToCapture(obj,val)
            if isempty(obj.FileName)%#ok<MCSUP>
                error(message('Sldv:xform:BlkRepRule:setRunTimeParamsToCapture:NoFileNameRunTimeParamsToCapture'));
            end
            if isempty(obj.BlockType)
                error(message('Sldv:xform:BlkRepRule:setRunTimeParamsToCapture:NoBlockType',obj.FileName));%#ok<MCSUP>
            end
            if~isempty(val)&&any(strcmp(obj.BlockType,{'ModelReference','SubSystem'}))
                error(message('Sldv:xform:BlkRepRule:setRunTimeParamsToCapture:WrongBlockType'));
            end
            obj.RunTimeParamsToCapture=val;
        end

        function set.fileName(obj,val)
            obj.FileName=val;
        end

        function value=get.fileName(obj)
            value=obj.FileName;
        end

        function set.replacementMode(obj,val)
            obj.ReplacementMode=val;
        end

        function value=get.replacementMode(obj)
            value=obj.ReplacementMode;
        end

        function set.replacementPath(obj,val)
            obj.ReplacementPath=val;
        end

        function value=get.replacementPath(obj)
            value=obj.ReplacementPath;
        end

        function set.parameterMap(obj,val)
            obj.ParameterMap=val;
        end

        function value=get.parameterMap(obj)
            value=obj.ParameterMap;
        end

        function set.copyOrigDialogParams(obj,val)
            obj.CopyOrigDialogParams=val;
        end

        function value=get.copyOrigDialogParams(obj)
            value=obj.CopyOrigDialogParams;
        end

        function set.isReplaceableCallBack(obj,val)
            obj.IsReplaceableCallBack=val;
        end

        function value=get.isReplaceableCallBack(obj)
            value=obj.IsReplaceableCallBack;
        end

        function set.postReplacementCallBack(obj,val)
            obj.PostReplacementCallBack=val;
        end

        function value=get.postReplacementCallBack(obj)
            value=obj.PostReplacementCallBack;
        end
    end

    methods(Hidden)
        function status=canReplace(obj,blockInfo)
            if obj.IsActive
                try

                    if nargin(obj.IsReplaceableCallBack)==2
                        status=obj.IsReplaceableCallBack(blockInfo.BlockH,blockInfo);
                    else
                        status=obj.IsReplaceableCallBack(blockInfo.BlockH);
                    end



                    if(~(isscalar(status)&&(status==1||status==0)))
                        errorString=getString(message('Sldv:xform:BlkRepRule:setIsReplaceableCallBack:WrongArgument',obj.FileName));
                        blockInfo.ReplacementInfo.PreReplacementMsgs{end+1}=getString(message('Sldv:xform:RepRule:ErrorDuringExaction',obj.FileName,errorString));
                        status=false;
                    end

                catch Mex
                    blockInfo.ReplacementInfo.PreReplacementMsgs{end+1}=getString(message('Sldv:xform:RepRule:ErrorDuringExaction',obj.FileName,Mex.message));
                    status=false;
                end
                if status&&~strcmp(obj.ReplacementPath,'built-in/Subsystem')&&...
                    ~strcmp(obj.ReplacementMode,'Stub')






                    status=obj.preReplacementCheck(blockInfo);
                end
                if status&&blockInfo.ReplacementInfo.UnderSelfModifMaskException






                    status=obj.isSafeToReplaceUnderSelfModifMask(blockInfo);
                end
                if status
                    blockInfo.ReplacementInfo.IsReplaceable=true;
                    blockInfo.ReplacementInfo.Rule=obj;
                else
                    if~isempty(blockInfo.ReplacementInfo.PreReplacementMsgs)
                        for idx=1:length(blockInfo.ReplacementInfo.PreReplacementMsgs)
                            warning('Sldv:BLOCKREPLACEMENT:ReplacementTestFcn',...
                            blockInfo.ReplacementInfo.PreReplacementMsgs{idx});
                        end
                    end
                end
            else
                status=false;
            end
        end

        replaceBlock(obj,blockInfo,inlineOnlyMode)


        function loadReplacementLib(obj)


            if obj.UseOriginalBlockAsReplacement||strcmp(obj.ReplacementMode,'Stub')
                return;
            end
            val=obj.ReplacementPath;
            index=find(val=='/');
            replacementLib=val(1:index(1)-1);
            if~isempty(replacementLib)
                if isempty(find_system('type','block_diagram','name',replacementLib))
                    try
                        obj.addToOpenedModelsList(replacementLib);
                        Sldv.load_system(replacementLib);
                    catch Mex
                        newExc=MException('Sldv:xform:BlkRepRule:setReplacementPath:CannotLoadReplacementLib',...
                        getString(message('Sldv:BLOCKREPLACEMENT:UnableToLoadReplacementLib',replacementLib,obj.FileName)));
                        newExc=newExc.addCause(Mex);
                        throw(newExc);
                    end
                end
            end
        end

        function closeOpenedModels(obj)
            cellfun(@(x)closeModel(x),obj.OpenedModels);
            obj.OpenedModels={};

            function closeModel(mdl)
                try
                    Sldv.close_system(mdl,0);
                catch
                end
            end
        end
    end

    methods(Access=protected)
        updateReplacementBlock(obj,blockInfo)




        updateStubBlock(obj,blockInfo)



        parseParameterMap(obj,blockInfo)




        setParameterMap(obj,blockInfo,setAdditionalMaskParamForMdlRef)




        safeRunPostReplacementCallBack(obj,blockInfo)



        function refreshPopupParams(obj)
            if~isempty(obj.ParameterMap)&&...
                isempty(obj.PopupParamsReplacementBlk)
                paramsReplacementBlk=...
                Sldv.xform.maskUtils.deriveAllParameters(obj.ReplacementPath);
                popupParams.('DVBlkRepRulePopupChecked')={};
                for idx=1:length(paramsReplacementBlk)
                    if strcmp(paramsReplacementBlk(idx).('Type'),'popup')
                        popupParams.(paramsReplacementBlk(idx).Name)=...
                        paramsReplacementBlk(idx).('TypeOptions');
                    end
                end
                obj.PopupParamsReplacementBlk=popupParams;
            end
        end

        function addToOpenedModelsList(obj,replacementLib)
            try
                if~bdIsLoaded(replacementLib)
                    obj.OpenedModels{end+1}=replacementLib;

                end
            catch
            end
        end
    end

    methods(Static,Access=protected)
        [x,y]=findLocation(libName,spacing,width)



        fixAttributesFormatString(blockH)




        function fixMaskParameterEvalSettings(afterReplacementH)
            if strcmp(get_param(afterReplacementH,'BlockType'),'SubSystem')&&...
                strcmp(get_param(afterReplacementH,'Mask'),'on')
                maskObject=get_param(afterReplacementH,'MaskObject');
                for idx=1:length(maskObject.Parameters)
                    if ischar(maskObject.Parameters(idx).Value)&&...
                        exist(maskObject.Parameters(idx).Value,'file')==4
                        curParamToSet=maskObject.Parameters(idx);
                        curParamToSet.Evaluate='off';
                    end
                end
            end
        end
    end

    methods(Static,Access=?Sldv.xform.BlkReplacer,Hidden)
        checkLinkStatus(blockToBreakLink,blockInfo)


    end

    methods(Access=private)

        checkReplacementBlock(obj,ReplacementPath,ReplacementLib,ReplacementBlk)



        checkParameterMap(obj,ParameterMap)



        status=preReplacementCheck(obj,blockInfo)




        status=isSafeToReplaceUnderSelfModifMask(obj,blockInfo)

        replaceBlockWithLibraryLink(obj,blockInfo)



    end
end
