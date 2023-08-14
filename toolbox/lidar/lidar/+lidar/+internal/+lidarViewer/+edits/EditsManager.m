






classdef EditsManager<handle

    properties(Access=private)

EditMap


        Edits cell



EditName




CustomEditFunc


Listeners

ApplyEditOnAllFrames
    end

    events



PointCloudChanging



PointCloudChanged

ExternalTrigger
    end

    properties(Constant,Access=private)


        PackageRoot="lidar.lidarViewer"
    end


    methods



        function this=EditsManager()

            this.setUp();
            wireUpListeners(this);
        end


        function clear(this)

            this.Edits={};
            this.EditMap=[];
            this.EditName=[];
            this.CustomEditFunc=[];
            this.Listeners=[];
        end


        function generateScript(this,editStack)


            codeGenerator=vision.internal.calibration.tool.MCodeGenerator;

            codeGenerator.addHeader('LidarViewer');

            isTemporal=false;
            for i=1:numel(editStack)
                if editStack{i}.IsTemporal
                    isTemporal=true;
                end
            end

            if isTemporal
                codeGenerator.addLine('function [ptCldOut, frameIndices] = processPtCld(ptCldIn)');
                codeGenerator.addComment('Temporal point cloud edit algorithm.');
                codeGenerator.addReturn();

                mainComment=getString(message('lidar:lidarViewer:scriptFuncDescTemporal'));
                codeGenerator.addComment(mainComment(1:75));
                codeGenerator.addComment(mainComment(76:127));
                codeGenerator.addComment(mainComment(128:207));
                codeGenerator.addComment(mainComment(208:305));
                codeGenerator.addComment(mainComment(306:end));
                codeGenerator.addReturn();

                codeGenerator.addLine('frameIndices = [];');
                codeGenerator.addReturn();
                this.ApplyEditOnAllFrames=true;
            else
                codeGenerator.addLine('function ptCldOut = processPtCld(ptCldIn)');
                codeGenerator.addComment('Spatial point cloud edit algorithm');
                codeGenerator.addReturn();

                mainComment=getString(message('lidar:lidarViewer:scriptFuncDescSpatial'));
                codeGenerator.addComment(mainComment(1:74));
                codeGenerator.addComment(mainComment(75:105));
                codeGenerator.addComment(mainComment(106:182));
                codeGenerator.addComment(mainComment(183:end));
                codeGenerator.addReturn();
                this.ApplyEditOnAllFrames=false;
            end

            for i=1:numel(editStack)
                addOperationToScript(this,editStack{i},codeGenerator,i);
            end

            codeGenerator.addLine('end');

            content=codeGenerator.CodeString;


            editorDoc=matlab.desktop.editor.newDocument(content);
            editorDoc.smartIndentContents;
            editorDoc.goToLine(1);

            this.ApplyEditOnAllFrames=false;
        end
    end




    methods

        function[pointCloudOut,selectedFrames]=applyEdits(this,editName,ptCldIn,params)





            if params.IsClass

                editObj=this.getEditObj(editName);


                [pointCloudOut,selectedFrames]=doProcess(editObj,ptCldIn,params);
            else

                [~,funcName,~]=fileparts(editName);
                if nargout(str2func(funcName))==1
                    selectedFrames=[];
                    pointCloudOut=feval(funcName,ptCldIn);
                else
                    [pointCloudOut,selectedFrames]=feval(funcName,ptCldIn);
                end
            end


        end


        function setUpEditOperation(this,editName,ptCldIn,isTemporal,dispObjAxes,figToDisplayDialogs,varargin)




            editObj=this.getEditObj(editName);
            if isTemporal



                selectedFrameIdx=1:varargin{1};
                editObj.setSelectedFrameIndices(selectedFrameIdx);
            end

            if strcmp(editName,getString(message('lidar:lidarViewer:Crop')))

                setUpEditOperation(editObj,ptCldIn,dispObjAxes,figToDisplayDialogs)
            else

                setUpEditOperation(editObj,ptCldIn)
            end
        end


        function setUpAlgorithmConfigurePanel(this,editName,editPanel,isTemporal)



            editObj=this.getEditObj(editName);


            configurePanel(editObj,editPanel,isTemporal)
        end
    end




    methods

        function[spatialEditNames,temporalEditNames]=getEditNames(this)

            spatialEditNames={};
            temporalEditNames={};
            editNames=this.EditName.keys;
            for i=1:numel(editNames)
                if~this.EditName(editNames{i})
                    spatialEditNames{end+1}=editNames{i};
                else
                    temporalEditNames{end+1}=editNames{i};
                end
            end
        end


        function toUpdate=importCustomEdit(this,fig,isTemporal)



            [toUpdate,editObj]=...
            lidar.internal.lidarViewer.edits.helper.importAlgorithmFromFile(...
            this.EditMap.keys,this,fig,isTemporal);


            this.bringAppToFront();

            if toUpdate&&this.isEditNameValid(editObj.EditName)
                algoName=editObj.EditName;
                this.Edits{end+1}=editObj;
                this.EditMap(algoName)=this.EditMap.Count+1;


                this.EditName(class(editObj))=isTemporal;


                wireUpListeners(this);
            end
        end


        function openTemplateEditor(this,isTemporal,isClass)



            if~isTemporal
                if isClass
                    fileName=fullfile(toolboxdir('lidar'),'lidar','+lidar',...
                    '+internal','SpatialEditAlgorithmExample.m');
                else
                    fileName=fullfile(toolboxdir('lidar'),'lidar','+lidar',...
                    '+internal','mySpatialAlgorithm.m');
                end
            else
                if isClass
                    fileName=fullfile(toolboxdir('lidar'),'lidar','+lidar',...
                    '+internal','TemporalEditAlgorithmExample.m');
                else
                    fileName=fullfile(toolboxdir('lidar'),'lidar','+lidar',...
                    '+internal','myTemporalAlgorithm.m');
                end
            end

            fid=fopen(fileName);
            contents=fread(fid,'*char');
            fclose(fid);


            matlab.desktop.editor.newDocument(contents');
        end


        function toUpdate=updateEditMap(this)





            this.getEditNamesFromPackageRoot();


            wireUpListeners(this);


            toUpdate=true;
        end
    end


















    methods

        function isValid=importCustomFunction(this,isTemporal,numFrames)



            [filename,pathname]=uigetfile('*.m',...
            getString(message('lidar:lidarViewer:MFileMessage')));


            this.bringAppToFront();

            if isequal(filename,0)||isequal(pathname,0)

                isValid=false;
            else

                isValid=this.validateImportedFunction(isTemporal,numFrames,filename,pathname);
            end

            if~isValid
                return
            end


            this.CustomEditFunc(fullfile(pathname,filename))=isTemporal;




        end


        function[spatialFuncNames,temporalFuncNames]=getCustomFuncNames(this)

            spatialFuncNames={};
            temporalFuncNames={};
            funcNames=this.CustomEditFunc.keys;
            for i=1:numel(funcNames)
                if~this.CustomEditFunc(funcNames{i})
                    spatialFuncNames{end+1}=funcNames{i};
                else
                    temporalFuncNames{end+1}=funcNames{i};
                end
            end
        end
    end




    methods(Access=private)

        function wireUpListeners(this)


            this.Listeners={};
            for i=1:numel(this.Edits)
                this.Listeners{end+1}=event.listener(this.Edits{i},'PointCloudChanging',@(~,evt)notify(this,'PointCloudChanging',evt));
                this.Listeners{end+1}=event.listener(this.Edits{i},'PointCloudChanged',@(~,evt)notify(this,'PointCloudChanged',evt));
            end
        end


        function editObj=getEditObj(this,editName)

            key=this.EditMap.values({editName});
            editObj=this.Edits{key{1}};
        end


        function setUp(this)



            this.getEditNamesFromPackageRoot();
            this.CustomEditFunc=containers.Map();
        end


        function isValid=isEditNameValid(this,editName)


            existingNames=this.EditMap.keys;
            isValid=~any(ismember(existingNames,editName));
        end


        function getEditNamesFromPackageRoot(this)




            package=meta.package.fromName(this.PackageRoot);
            this.Edits={};
            this.EditMap=containers.Map();
            this.EditName=containers.Map();

            for i=1:numel(package.ClassList)
                try

                    editObj=eval(package.ClassList(i).Name);
                    isTemporal=false;
                    if numel(package.ClassList(i).SuperclassList)==2
                        isTemporal=true;
                    end
                    if this.isValidEditAlgorithm(package.ClassList(i),isTemporal)
                        this.EditName(package.ClassList(i).Name)=isTemporal;
                        this.EditMap(editObj.EditName)=this.EditMap.Count+1;
                        this.Edits{end+1}=editObj;
                    end
                catch

                end
            end
        end


        function addOperationToScript(this,edit,codeGenerator,editNum)

            if edit.AlgoParams.IsClass
                addClassOperationToScript(this,edit,codeGenerator,editNum)
            else
                addFunctionOperationToScript(this,edit,codeGenerator,editNum)
            end

        end


        function addClassOperationToScript(this,edit,codeGenerator,editNum)



            if edit.IsTemporal
                this.ApplyEditOnAllFrames=true;
            end


            if editNum~=1
                codeGenerator.addComment('-------------------------------------------------------');
            end
            codeGenerator.addComment(['Perform',' ',edit.Name,' on point cloud']);


            editObj=this.getEditObj(edit.Name);
            codeGenerator.addLine(['editObj = ',class(editObj),'();']);


            fieldName=fieldnames(edit.AlgoParams);
            codeGenerator.addLine('params = struct();');
            for i=1:numel(fieldName)
                if ischar(edit.AlgoParams.(fieldName{i}))

                    codeGenerator.addLine(['params.',fieldName{i},...
                    ' = ','''',edit.AlgoParams.(fieldName{i}),'''',';']);
                elseif iscell(edit.AlgoParams.(fieldName{i}))
                    text=[];
                    for j=1:numel(edit.AlgoParams.(fieldName{i}))
                        text=[text,'[',num2str(edit.AlgoParams.(fieldName{i}){j}),']',','];
                    end
                    codeGenerator.addLine(['params.',fieldName{i},...
                    ' = ',' ','{',text(1:length(text)-1),'}',';']);
                elseif numel(edit.AlgoParams.(fieldName{i}))>1

                    codeGenerator.addLine(['params.',fieldName{i},...
                    ' = ',' ','[',num2str(edit.AlgoParams.(fieldName{i})),']',';']);
                elseif numel(edit.AlgoParams.(fieldName{i}))==1

                    codeGenerator.addLine(['params.',fieldName{i},...
                    ' = ',num2str(edit.AlgoParams.(fieldName{i})),';']);
                else

                    codeGenerator.addLine(['params.',fieldName{i},...
                    ' = ','[]',';']);
                end
            end

            if editNum==1
                input='ptCldIn';
            else
                input='ptCldOut';
            end

            if this.ApplyEditOnAllFrames&&~edit.IsTemporal
                if editNum==1
                    codeGenerator.addLine('ptCldOut = ptCldIn;');
                end
                codeGenerator.addComment(['Apply spatial edit',' ',edit.Name,' on all frames.']);
                codeGenerator.addLine('for i = 1:numel(ptCldOut)');
                codeGenerator.addLine(['ptCldOut(i) = editObj.applyEdits',...
                '(',input,'(i)',',params','); ']);
                codeGenerator.addLine('end');
            else
                codeGenerator.addLine('ptCldOut = ...');
                codeGenerator.addLine(['editObj.applyEdits',...
                '(',input,',params',');']);
            end


            if edit.IsTemporal
                codeGenerator.addLine('frameIndices = unique([frameIndices, params.SelectedFrameIndices],''sorted'');');
            end

            codeGenerator.addReturn();
        end


        function addFunctionOperationToScript(this,edit,codeGenerator,editNum)



            if edit.IsTemporal
                this.ApplyEditOnAllFrames=true;
            end


            [~,funcName,~]=fileparts(edit.Name);
            if editNum~=1
                codeGenerator.addComment('-------------------------------------------------------');
            end
            codeGenerator.addComment(['Perform',' ',funcName,' on point cloud']);

            if editNum==1
                input='ptCldIn';
            else
                input='ptCldOut';
            end

            if edit.IsTemporal
                codeGenerator.addLine(['[ptCldOut, frameIdx] = ',funcName,'(',input,');']);
                codeGenerator.addLine('frameIndices = unique([frameIndices, frameIdx],''sorted'');');
            elseif~edit.IsTemporal&&this.ApplyEditOnAllFrames
                if editNum==1
                    codeGenerator.addLine('ptCldOut = ptCldIn;');
                end
                codeGenerator.addComment(['Apply spatial edit',' ',funcName,' on all frames.']);
                codeGenerator.addLine('for i = 1:numel(ptCldOut)');
                codeGenerator.addLine(['ptCldOut(i) = ',funcName,'(',input,'(i));']);
                codeGenerator.addLine('end');
            else
                codeGenerator.addLine(['ptCldOut = ',funcName,'(',input,');']);
            end
            codeGenerator.addReturn();
        end


        function bringAppToFront(this)

            lidar.internal.lidarViewer.createAndNotifyExtTrigger(this,'bringToFront');
        end


        function isValid=validateImportedFunction(this,isTemporal,numFrames,filename,pathname)



            [filepath,name,~]=fileparts(fullfile(pathname,filename));


            try

                addpath(filepath);

                if~isTemporal
                    isValid=nargout(str2func(name))==1;
                else
                    isValid=nargout(str2func(name))==2;
                end
            catch
                isValid=false;
            end

            if~isValid
                lidar.internal.lidarViewer.createAndNotifyExtTrigger(...
                this,'warningDialog',getString(message('lidar:lidarViewer:InValidEditFunction')),...
                getString(message('lidar:lidarViewer:Warning')));
                return;
            end

            isValid=isValid&&...
            ~any(ismember(this.CustomEditFunc.keys,fullfile(pathname,filename)));

            if~isValid
                lidar.internal.lidarViewer.createAndNotifyExtTrigger(...
                this,'warningDialog',getString(message('lidar:lidarViewer:DuplicateEditFunctionWarning')),...
                getString(message('lidar:lidarViewer:Warning')));
                return;
            end
        end
    end




    methods(Static,Access=private)
        function TF=isValidEditAlgorithm(metaData,isTemporal)



            if~isTemporal
                TF=strcmp(metaData.SuperclassList.Name,...
                'lidar.internal.lidarViewer.edits.EditAlgorithm');
            else
                superClasses={metaData.SuperclassList.Name};
                TF=all(contains({'lidar.internal.lidarViewer.edits.Temporal',...
                'lidar.internal.lidarViewer.edits.EditAlgorithm'},superClasses));
            end
        end
    end
end


