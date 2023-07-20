


classdef ModelFileNameSanitiser<handle

    properties(SetAccess=private,GetAccess=public)
        OriginalFilePath;
        SanitisedFilePath;
        TempDir;
    end


    methods(Access=public)

        function obj=ModelFileNameSanitiser(filePath)
            obj.OriginalFilePath=filePath;
            obj.SanitisedFilePath=obj.getFileToMerge(filePath);
        end

    end


    methods(Access=private)

        function newFile=getFileToMerge(obj,modelFile)

            if obj.isValidModelFileName(modelFile)
                newFile=modelFile;
            else
                obj.TempDir=tempname;
                mkdir(obj.TempDir);

                newName=obj.getValidModelFileName(modelFile);
                newFile=fullfile(obj.TempDir,newName);

                copyfile(modelFile,newFile)
            end

        end

        function isValid=isValidModelFileName(obj,modelFile)

            [~,name,ext]=fileparts(modelFile);

            if(strcmp([name,ext],obj.getValidModelFileName(modelFile)))
                isValid=true;
                return;
            end

            isValid=false;
        end

        function validName=getValidModelFileName(~,modelFile)

            modelFormat=Simulink.loadsave.identifyFileFormat(modelFile);
            if strcmpi(modelFormat,'opcmdl')
                modelFormat='mdl';
            end

            if(isempty(modelFormat))
                slxmlcomp.internal.error('engine:InvalidModelFile',modelFile);
            end

            [~,name,ext]=fileparts(modelFile);

            if(~ismember(ext,{'.slx','.mdl'}))
                nameToAdjust=[name,ext];
            else
                nameToAdjust=name;
            end

            validName=[matlab.lang.makeValidName(nameToAdjust),'.',modelFormat];

        end
    end

end

