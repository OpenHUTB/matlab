classdef ComponentToReferenceConverter<handle











    properties(Access=protected)
        BlockHandle;
        ModelName;
        DirPath;
        FullModelPath;
        ValidationPassed;
        ModelHandle;
        ModelBlockHandle;
        Template;
    end

    properties(Access=private)
        ParameterValues;
    end

    methods(Access=public)
        function obj=ComponentToReferenceConverter(blkH,mdlName,dirPath,template)


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
            obj.ModelBlockHandle=[];
            obj.Template=char(template);
            obj.ParameterValues=containers.Map;
        end
    end

    methods(Sealed,Access=public)
        function modelBlockHdl=convertComponentToReference(obj)

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
                obj.createReferenceModel();

                assert(~isempty(obj.ModelHandle)&&ishandle(obj.ModelHandle));

                obj.postCreateReferenceModel();
                obj.postCreateReferenceModelHook();

                obj.copyContentsToModel();

                obj.postCopyContentsToModel();
                obj.postCopyContentsToModelHook();

                obj.saveModelBeforeLink();
                obj.linkComponentToModel();

                assert(~isempty(obj.ModelBlockHandle)&&ishandle(obj.ModelBlockHandle));
                modelBlockHdl=obj.ModelBlockHandle;

                obj.postLinkComponentToModel();
                obj.postLinkComponentToModelHook();
            catch ME
                rethrow(ME);
            end
        end
    end

    methods(Sealed,Access=private)
        function runValidationChecks(obj)


            targetModelValidator=systemcomposer.internal.TargetModelValidator(obj.ModelName,obj.DirPath);
            throwError=true;
            targetModelValidator.validate(throwError);
        end

        function createReferenceModel(obj)
            obj.FullModelPath=fullfile(obj.DirPath,[obj.ModelName,'.slx']);
            obj.createReferenceModelHook();

            try
                save_system(obj.ModelName,obj.FullModelPath);
            catch ME


                close_system(obj.ModelName,0);
                rethrow(ME);
            end
        end

        function postCreateReferenceModel(obj)


            try
                systemcomposer.internal.arch.internal.setupSharedInterfaces(...
                obj.BlockHandle,get_param(bdroot(obj.BlockHandle),'Name'),obj.ModelName,'saveAsModel');

                systemcomposer.internal.arch.internal.importProfilesAndCopyStereotypes(obj.BlockHandle,obj.ModelHandle);
            catch ex
                close_system(obj.ModelName,0);
                delete(obj.FullModelPath);
                rethrow(ex);
            end
        end

        function copyContentsToModel(obj)

            txn=systemcomposer.internal.SubdomainBlockValidationSuspendTransaction(obj.ModelHandle);
            ddTxn=systemcomposer.internal.DragDropTransaction();

            Simulink.SubSystem.copyContentsToBlockDiagram(obj.BlockHandle,obj.ModelHandle);

            ddTxn.commit();
            txn.commit();

            systemcomposer.internal.arch.internal.processBatchedPluginEvents(obj.ModelName);
        end

        function postCopyContentsToModel(obj)
            try

                refZCModel=get_param(obj.ModelHandle,'SystemComposerModel');
                refRootArch=refZCModel.Architecture.getImpl();
                app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(obj.ModelHandle);
                if isempty(app)
                    return;
                end
                refArchRootPorts=refRootArch.getPorts();
                archPortsToRefresh=[];
                for i=1:length(refArchRootPorts)
                    refArchRootPort=refArchRootPorts(i);


                    piUsage=refArchRootPort.p_InterfaceUsage;
                    if~isempty(piUsage)
                        if(~isempty(piUsage.p_AnonymousInterface)&&isa(piUsage.p_AnonymousInterface,'systemcomposer.architecture.model.interface.CompositeDataInterface'))
                            archPortsToRefresh=[archPortsToRefresh,refArchRootPort];%#ok<AGROW>
                        end
                    end
                end
                if~isempty(archPortsToRefresh)
                    app.refreshOwnedCompositeInterfacePostConvert(archPortsToRefresh);
                end


                obj.ParameterValues=systemcomposer.internal.parameters.arch.sync.copyComponentParametersToModel(obj.BlockHandle,obj.ModelHandle);
            catch


            end
        end

        function saveModelBeforeLink(obj)
            save_system(obj.ModelName);
        end

        function linkComponentToModel(obj)
            obj.linkComponentToModelHook();
        end

        function postLinkComponentToModel(obj)

            pathCell=regexp(path,pathsep,'split');
            onPath=any(strcmpi(obj.DirPath,pathCell));
            if~onPath&&~isempty(obj.DirPath)&&~(strcmpi(obj.DirPath,pwd)||strcmpi(obj.DirPath,[pwd,filesep]))
                msg=message('SystemArchitecture:SaveAndLink:NotOnPathWarning',obj.DirPath).string;
                warning('SystemArchitecture:SaveAndLink:NotOnPathWarning',strrep(msg,'\','\\'));
            end


            if blockisa(obj.ModelBlockHandle,'ModelReference')
                instanceParams=get_param(obj.ModelBlockHandle,'InstanceParameters');
                assert(numel(instanceParams)==obj.ParameterValues.Count);
                for i=1:numel(instanceParams)
                    paramName=instanceParams(i).Name;
                    instanceParams(i).Value=obj.ParameterValues(paramName).expr;
                end
                set_param(obj.ModelBlockHandle,'InstanceParameters',instanceParams);
            end
        end
    end

    methods(Access=protected)
        function runValidationChecksHook(~)

        end

        function createReferenceModelHook(obj)
            if isempty(obj.Template)
                if isequal(get_param(bdroot(obj.BlockHandle),'SimulinkSubDomain'),'SoftwareArchitecture')

                    bdH=new_system(obj.ModelName,'SoftwareArchitecture');
                else

                    bdH=new_system(obj.ModelName,'Architecture');
                end
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

        function postCreateReferenceModelHook(~)

        end

        function postCopyContentsToModelHook(~)
        end

        function linkComponentToModelHook(obj)

            compToModelLinker=systemcomposer.internal.arch.internal.ComponentToModelLinker(obj.BlockHandle,obj.ModelName);
            obj.ModelBlockHandle=compToModelLinker.linkComponentToModel();
        end

        function postLinkComponentToModelHook(~)

        end
    end
end


