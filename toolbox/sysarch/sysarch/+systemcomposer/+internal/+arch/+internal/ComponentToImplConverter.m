classdef ComponentToImplConverter<handle











    properties(Access=protected)
        BlockHandle;
        ModelName;
        DirPath;
        FullModelPath;
        ValidationPassed;
        ModelHandle;
        Template;
        ShouldBeLeaf=true;
    end

    properties(Access=private)
        ParameterValues;
    end

    methods
        function obj=ComponentToImplConverter(blkH,mdlName,dirPath,template)

            if(nargin==2)
                dirPath=string(pwd);
                template=[];
            elseif(nargin==3)
                template=[];
            end

            assert(ishandle(blkH));
            assert(ischar(mdlName)||isstring(mdlName),...
            'modelNames argument must be a char or string array');
            assert(ischar(dirPath)||isstring(dirPath),...
            'dirPaths argument must be a char or string array');
            assert(isempty(template)||ischar(template)||isstring(template),...
            'template argument must be a char or string array');

            obj.BlockHandle=blkH;
            obj.ModelName=convertStringsToChars(mdlName);
            obj.DirPath=convertStringsToChars(dirPath);
            obj.Template=char(template);
            obj.ParameterValues=containers.Map;
        end
    end

    methods(Sealed,Access=public)
        function modelBlockHdl=convertComponentToImpl(obj)
            try
                obj.runValidationChecks();
                obj.runValidationChecksHook();

                if(~obj.ValidationPassed)
                    modelBlockHdl=[];
                    return;
                end
            catch ME
                rethrow(ME);
            end

            obj.ValidationPassed=true;

            try
                obj.createImplModel();

                assert(~isempty(obj.ModelHandle)&&ishandle(obj.ModelHandle));

                obj.postCreateImplModel();

                obj.copyContentsToModel();

                obj.postCopyContentsToModel();
                obj.postCopyContentsToModelHook();

                obj.saveModelBeforeLink();
                obj.linkComponentToModel();

                assert(~isempty(obj.BlockHandle)&&ishandle(obj.BlockHandle));
                modelBlockHdl=obj.BlockHandle;

                obj.postLinkComponentToModel();
                obj.postLinkComponentToModelHook();
            catch ME
                rethrow(ME);
            end
        end
    end

    methods(Sealed,Access=private)
        function tf=isLeafSubsystem(~,blockHandle)

            ssH=find_system(blockHandle,...
            'SearchDepth',1,...
            'BlockType','SubSystem');
            mdlH=find_system(blockHandle,...
            'SearchDepth',1,...
            'BlockType','Model');




            tf=(length(ssH)<=1)&&isempty(mdlH);
        end

        function createImplModel(obj)
            obj.FullModelPath=fullfile(obj.DirPath,[obj.ModelName,'.slx']);
            obj.createImplModelHook();

            try
                save_system(obj.ModelName,obj.FullModelPath);
            catch ME


                close_system(obj.ModelName,0);
                rethrow(ME);
            end
        end

        function postCreateImplModel(obj)
            obj.postCreateImplModelHook();
        end

        function copyContentsToModel(obj)

            if(strcmp(get_param(obj.BlockHandle,'BlockType'),'SubSystem'))
                ddTxn=systemcomposer.internal.DragDropTransaction();
                Simulink.SubSystem.copyContentsToBlockDiagram(obj.BlockHandle,obj.ModelHandle);
                ddTxn.commit();
                save_system(obj.ModelName);
            end
        end

        function postCopyContentsToModel(obj)

            compositionModelFile=[get_param(bdroot(obj.BlockHandle),'Name'),'.slx'];
            if exist(compositionModelFile,'file')==4
                save_system(obj.ModelName);
            end




            obj.ParameterValues=systemcomposer.internal.parameters.arch.sync.copyComponentParametersToModel(obj.BlockHandle,obj.ModelHandle);




            systemcomposer.internal.arch.internal.importProfilesAndCopyStereotypes(obj.BlockHandle,obj.ModelHandle);
        end

        function saveModelBeforeLink(obj)
            if strcmpi(get_param(obj.ModelHandle,'Dirty'),'on')
                save_system(obj.ModelName);
            end
        end

        function linkComponentToModel(obj)
            obj.linkComponentToModelHook;
        end

        function postLinkComponentToModel(obj)



            pathCell=regexp(path,pathsep,'split');
            onPath=any(strcmpi(obj.DirPath,pathCell));
            if~onPath&&~isempty(obj.DirPath)&&~(strcmpi(obj.DirPath,pwd)||strcmpi(obj.DirPath,[pwd,filesep]))
                msg=message('SystemArchitecture:SaveAndLink:NotOnPathWarning',obj.DirPath).string;
                warning('SystemArchitecture:SaveAndLink:NotOnPathWarning',strrep(msg,'\','\\'));
            end


            if blockisa(obj.BlockHandle,'ModelReference')
                instanceParams=get_param(obj.BlockHandle,'InstanceParameters');
                assert(numel(instanceParams)==obj.ParameterValues.Count);
                for i=1:numel(instanceParams)
                    paramName=instanceParams(i).Name;
                    instanceParams(i).Value=obj.ParameterValues(paramName).expr;
                end
                set_param(obj.BlockHandle,'InstanceParameters',instanceParams);
            end
        end

    end


    methods(Access=protected)
        function runValidationChecks(obj)


            targetModelValidator=systemcomposer.internal.TargetModelValidator(obj.ModelName,obj.DirPath);
            throwError=true;
            targetModelValidator.validate(throwError);


            if(obj.ShouldBeLeaf&&~obj.isLeafSubsystem(obj.BlockHandle))
                obj.ValidationPassed=false;
                error('SystemArchitecture:studio:ComponentNotLeaf',...
                DAStudio.message('SystemArchitecture:studio:ComponentNotLeaf'));
            end
        end

        function runValidationChecksHook(~)

        end

        function createImplModelHook(obj)
            if isempty(obj.Template)

                bdH=new_system(obj.ModelName,'Model');
            else

                bdH=Simulink.createFromTemplate(obj.Template,...
                'Name',obj.ModelName,...
                'Folder',obj.DirPath);



                handles=find_system(bdH,...
                'FindAll','on',...
                'SearchDepth',1,...
                'type','Block');
                arrayfun(@(block)delete_block(block),handles);
                handles=find_system(bdH,...
                'FindAll','on',...
                'SearchDepth',1,...
                'type','Line');
                delete(handles);
            end
            obj.ModelHandle=get_param(bdH,'Handle');
        end

        function postCreateImplModelHook(obj)
            obj.migrateInterfaceToDictionary;
        end

        function migrateInterfaceToDictionary(obj)
            try

                systemcomposer.internal.arch.internal.setupSharedInterfaces(...
                obj.BlockHandle,get_param(bdroot(obj.BlockHandle),'Name'),obj.ModelName,'createSLBehavior');

                save_system(obj.ModelName);
            catch ME


                close_system(obj.ModelName,0);
                delete(obj.FullModelPath);
                rethrow(ME);
            end
        end

        function postCopyContentsToModelHook(obj)
            obj.autoLayoutInportsOutports();
        end

        function autoLayoutInportsOutports(obj)



            inportBlocks=find_system(obj.ModelName,'BlockType','Inport');
            if~isempty(inportBlocks)
                set_param(inportBlocks{1},'Position',[100,100,110,110]);
                for i=2:numel(inportBlocks)
                    pos=get_param(inportBlocks{i-1},'Position');
                    pos(2)=pos(2)+25;
                    pos(4)=pos(4)+25;
                    set_param(inportBlocks{i},'Position',pos);
                end
            end

            outportBlocks=find_system(obj.ModelName,'BlockType','Outport');
            if~isempty(outportBlocks)
                set_param(outportBlocks{1},'Position',[500,100,510,110]);
                for i=2:numel(outportBlocks)
                    pos=get_param(outportBlocks{i-1},'Position');
                    pos(2)=pos(2)+25;
                    pos(4)=pos(4)+25;
                    set_param(outportBlocks{i},'Position',pos);
                end
            end
        end

        function linkComponentToModelHook(obj)

            compToModelLinker=systemcomposer.internal.arch.internal.ComponentToModelLinker(obj.BlockHandle,obj.ModelName);
            obj.BlockHandle=compToModelLinker.linkComponentToModel();
        end

        function postLinkComponentToModelHook(~)

        end
    end
end

