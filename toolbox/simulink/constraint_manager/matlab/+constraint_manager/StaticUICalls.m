

classdef StaticUICalls

    methods(Static=true,Access='public')

        function onSaveConstraints(blockHandle,environment)
            constraint_manager('Save',blockHandle,environment);
        end

        function onLoadMATFileConstraint(blockHandle,environment)
            [fileName,filePath]=uigetfile({'*.mat';},'Select MAT file');
            product='';

            [sharedConstraintList,matFileName]=constraint_manager.SharedConstraintsHelper.loadMATFileConstraints(fileName);
            if~isempty(sharedConstraintList)
                constraint_manager('LoadMATFileConstraint',environment,blockHandle,matFileName,filePath,sharedConstraintList);
            end
        end

        function[newMATFileInfo]=onAddNewMATFile(blockHandle,environment)
            [filename,path]=uiputfile({'*.mat';},'Browse MAT file');
            newMATFileInfo={};
            if(filename~=0)
                matFilePathWithFileName=[path,filename];
                splitted_filename=strsplit(filename,'.');
                filename=splitted_filename{1};
                newMATFileInfo=struct('MATFileName',filename,'MATFilePath',matFilePathWithFileName);
            end
            if strcmp(environment,"MASKEDITOR")
                aDialog=maskeditor('Get',blockHandle);
            else
                aDialog=constraint_manager('Get',blockHandle);
            end

            aDialog.show();
        end

        function isValid=validatePortConstraintWordlength(wordlength)
            isValid=true;
            if isempty(wordlength)
                return;
            end
            try
                evaluatedWordlength=eval(wordlength);
                if~isvector(evaluatedWordlength)
                    isValid=false;
                end
                mustBeInteger(evaluatedWordlength);
                mustBePositive(evaluatedWordlength);
            catch exp
                isValid=false;
            end
        end
    end
end
