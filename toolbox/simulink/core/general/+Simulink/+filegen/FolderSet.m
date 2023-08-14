classdef(Hidden)FolderSet








    properties(Hidden,SetAccess=immutable)



        MarkerFile char;



        Root char;



        ModelCode char;


        TargetRoot char;



        ModelReferenceCode char;



        SharedUtilityCode char;
    end

    methods(Hidden)



        function this=FolderSet(markerFile,...
            rootFolder,...
            modelCodeFolder,...
            targetRoot,...
            modelReferenceCodeFolder,...
            sharedUtilityCodeFolder)

            this.MarkerFile=RTW.reduceRelativePath(markerFile);
            this.Root=RTW.reduceRelativePath(rootFolder);
            this.ModelCode=RTW.reduceRelativePath(modelCodeFolder);
            this.TargetRoot=RTW.reduceRelativePath(targetRoot);
            this.ModelReferenceCode=RTW.reduceRelativePath(modelReferenceCodeFolder);
            this.SharedUtilityCode=RTW.reduceRelativePath(sharedUtilityCodeFolder);
        end



        function absPath=absolutePath(this,pathProp)
            absPath=fullfile(this.Root,this.(pathProp));
        end



        function relPath=relativePathToRoot(this,pathProp)
            if isempty(this.(pathProp))
                relPath='';
                return;
            end

            relPath='..';
            buildDirDepth=length(strfind(this.(pathProp),filesep));
            for i=1:buildDirDepth
                relPath=fullfile(relPath,'..');
            end
        end
    end

    methods




        function markerFile=get.MarkerFile(this)
            markerFile=this.assertNotEmpty(this.MarkerFile);
        end

        function modelCode=get.ModelCode(this)
            modelCode=this.assertNotEmpty(this.ModelCode);
        end

        function targetRoot=get.TargetRoot(this)
            targetRoot=this.assertNotEmpty(this.TargetRoot);
        end

        function modelReferenceCode=get.ModelReferenceCode(this)
            modelReferenceCode=this.assertNotEmpty(this.ModelReferenceCode);
        end

        function sharedUtilityCode=get.SharedUtilityCode(this)
            sharedUtilityCode=this.assertNotEmpty(this.SharedUtilityCode);
        end
    end

    methods(Access=private)
        function value=assertNotEmpty(~,value)
            assert(~isempty(value),'No folder specified for folder property.');
        end

        function printFolderValue(this,label,prop)
            try

                label=pad(label,20,'left');
                folderString=this.(prop);

                expression='\$\(\w+\)';
                dynamicReplacement='${Simulink.filegen.FolderSet.hideToken($0)}';
                folderString=regexprep(folderString,expression,dynamicReplacement);
                fprintf('%s:    %s\n',label,folderString);
            catch
            end
        end
    end

    methods


        function disp(this)

            if isscalar(this)
                instanceToDisplay=this;
            else
                s=size(this);
                sizeString=strjoin(repmat({'%d'},1,length(s)),'x');
                fprintf([sizeString,' FolderSet array.\n\n First element preview:\n\n'],s(:))

                instanceToDisplay=this(1);
            end

            instanceToDisplay.printFolderValue('Model Code','ModelCode');
            instanceToDisplay.printFolderValue('Model Reference Code','ModelReferenceCode');
            instanceToDisplay.printFolderValue('Shared Code','SharedUtilityCode');
            fprintf(newline);
        end
    end

    methods(Hidden,Static)




        function replacement=hideToken(value)
            hiddenTokens=Simulink.filegen.internal.FolderSpecificationTokens.getHiddenTokens();
            name=value(3:end-1);
            if any(contains(hiddenTokens,name))
                replacement='';
            else
                replacement=value;
            end
        end
    end
end
