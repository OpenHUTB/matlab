classdef importer<matlab.mixin.SetGet&matlab.mixin.Copyable













    properties(Access=private)
        arSchemaVer='';
        file=[];
        dependencies=[];
        arModel;
        needReadUpdate logical=false;
    end

    methods(Access=private)
        function validateFile(obj,filename)%#ok

            if~exist(filename,'file')
                DAStudio.error('MATLAB:load:couldNotReadFile',filename);
            end


            fileContent=fileread(filename);
            regex='xmlns=".*?[r]{0,1}(\d+)\.?(?:\d+)?\.?(?:\*|\d+)"';
            tokens=regexp(fileContent,regex,'tokens');


            if exist(filename,'file')~=2
                DAStudio.error('RTW:autosar:badReadAutosarFile',filename);
            end

            if isempty(tokens)||str2double(tokens{1})<4
                DAStudio.error('autosarstandard:importer:unsupportedSchema',filename);
            end
        end
    end

    methods(Access=public)


        function this=importer(filename)








            if nargin>0
                if iscell(filename)
                    for ii=1:length(filename)
                        if isstring(filename{ii})
                            filename{ii}=convertStringsToChars(filename{ii});
                            this.validateFile(filename{ii});
                        end
                    end
                else
                    filename=convertStringsToChars(filename);
                    this.validateFile(filename);
                end
            end

            if nargin<1
                DAStudio.error('RTW:autosar:badImporterArgument');
            end

            try
                p_importer(this,filename);
            catch Me

                autosar.mm.util.MessageReporter.throwException(Me);
            end
        end


        [modelH,success]=createComponentAsModel(this,ComponentName,varargin);
        [modelH,success]=createCompositionAsModel(importerObj,compositionName,varargin);
        success=createCalibrationComponentObjects(this,ComponentName,varargin);
        compList=getComponentNames(this,compKind);
        updateModel(this,modelName,varargin);
        updateAUTOSARProperties(this,modelName,varargin);
        display(this);
    end

    methods(Hidden,Access=public)
        compList=getApplicationComponentNames(this);
        compList=getSensorActuatorComponentNames(this);
        compList=getCompositionComponentNames(this);
        compList=getCalibrationComponentNames(this);
        p_importUnitsToDatabase(importerObj,filename);
        [mmChangeLoggers,slChangeLoggers]=p_updateModel(this,modelName,varargin);
        [mmChangeLogger,slChangeLogger]=p_component_updateModel(this,modelName,varargin);
        paths=find(this,rootPath,category,varargin);
        intfs=getClientServerInterfaceNames(this);
        obj=saveobj(obj);
        dependencies=getDependencies(this);
        filename=getFile(this);
        setDependencies(this,aDependencies);
        setFile(this,aFilename);
        updateReferences(this,modelName,varargin);

        function schemaVer=getSchemaVer(this)
            schemaVer=this.arSchemaVer;
        end
        function m3iModel=getM3IModel(this)
            m3iModel=this.arModel;
        end
        function setNeedReadUpdate(this,value)
            assert(islogical(value),'needReadUpdate must be a boolean value.');
            this.needReadUpdate=value;
        end
    end

end


