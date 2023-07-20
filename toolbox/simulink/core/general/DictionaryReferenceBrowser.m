




classdef DictionaryReferenceBrowser<FileReferenceBrowser



    properties(GetAccess=protected,SetAccess=private)
Extensions
Mode
ExpectedFileName


BrowseFileRefsName
SelectedFileNotOnPathQString
SelectedFilePathIssueTitle
SelectedFileNotOnPathAddCurrentSession
SelectedFileNotOnPathDoNotAdd
SelectedFileNotOnPathCancel
SelectedFileExistsOnPathQString

SelectedFileHasLowerPrecedence
    end

    properties(GetAccess=protected,SetAccess=private,Dependent)
SelectedFileHasLowerPrecedenceDirty
SelectedFileHasHigherPrecedenceTemporarily
SelectedFilePrecedenceIssueTitle
SelectedFilePrecedenceIssueContinue
SelectedFilePrecedenceIssueCancel
SelectedFileIsLoadedWithMultipleFilesOnPath
    end

    methods
        function obj=DictionaryReferenceBrowser(mode,adapaterSupportedExt,varargin)


            assert(strcmp(mode,'open')|strcmp(mode,'create'));
            obj.Mode=mode;


            allowAllRefTypes=false;
            if~isempty(adapaterSupportedExt)&&(slfeature('SlModelBroker')>0||...
                slfeature('CalibrationWorkflowInDD')>0)
                allowAllRefTypes=true;
            end

            assert(numel(varargin)==0||...
            numel(varargin)==1&&ischar(varargin{1}));
            obj.ExpectedFileName={};
            if~isempty(varargin)
                obj.ExpectedFileName=varargin{1};
            end

            if allowAllRefTypes
                [n,m]=size(adapaterSupportedExt);
                if n>1&&m>1
                    obj.Extensions=adapaterSupportedExt;
                else
                    allExt=adapaterSupportedExt;
                    allExtWithStar=cellfun(@(x)['*',x],allExt,'UniformOutput',false);
                    allExtStr=join(allExtWithStar,';');
                    extensions={allExtStr{1},'All supported files';};
                    for i=1:length(allExtWithStar)
                        extensions(end+1,:)={allExtWithStar{i},[allExtWithStar{i},' files']};%#ok<AGROW>
                    end
                    obj.Extensions=extensions;
                end
            else
                obj.Extensions={'*.sldd','Data Dictionary files (*.sldd)'};
            end


            if strcmp(mode,'open')
                if allowAllRefTypes
                    obj.BrowseFileRefsName='SLDD:sldd:OpenRefFile';
                else
                    obj.BrowseFileRefsName='SLDD:sldd:OpenDataDictionary';
                end
            else
                if allowAllRefTypes
                    obj.BrowseFileRefsName='SLDD:sldd:CreateNewRefFile';
                else
                    obj.BrowseFileRefsName='SLDD:sldd:CreateNewDataDictionary';
                end
            end

            if allowAllRefTypes
                obj.SelectedFileNotOnPathQString='SLDD:sldd:SelectedRefFileNotOnPathQString';
                obj.SelectedFilePathIssueTitle='SLDD:sldd:SelectedRefFilePathIssueTitle';
                obj.SelectedFileExistsOnPathQString='SLDD:sldd:SelectedRefFileExistsOnPathQString';
                obj.SelectedFileHasLowerPrecedence='SLDD:sldd:SelectedRefFileHasLowerPrecedence';
            else
                obj.SelectedFileNotOnPathQString='SLDD:sldd:SelectedDictNotOnPathQString';
                obj.SelectedFilePathIssueTitle='SLDD:sldd:SelectedDictPathIssueTitle';
                obj.SelectedFileExistsOnPathQString='SLDD:sldd:SelectedDictExistsOnPathQString';
                obj.SelectedFileHasLowerPrecedence='SLDD:sldd:SelectedDictHasLowerPrecedence';
            end


            obj.SelectedFileNotOnPathAddCurrentSession='SLDD:sldd:SelectedDictNotOnPathAddCurrentSession';
            obj.SelectedFileNotOnPathDoNotAdd='SLDD:sldd:SelectedDictNotOnPathDoNotAdd';
            obj.SelectedFileNotOnPathCancel='SLDD:sldd:SelectedDictNotOnPathCancel';

        end







        function value=get.SelectedFileHasLowerPrecedenceDirty(obj)%#ok<MANU,STOUT>
            assert(false,'Property not implemented');
        end

        function value=get.SelectedFileHasHigherPrecedenceTemporarily(obj)%#ok<STOUT,MANU>
            assert(false,'Property not implemented');
        end

        function value=get.SelectedFilePrecedenceIssueTitle(obj)%#ok<STOUT,MANU>
            assert(false,'Property not implemented');
        end

        function value=get.SelectedFilePrecedenceIssueContinue(obj)%#ok<MANU,STOUT>
            assert(false,'Property not implemented');
        end

        function value=get.SelectedFilePrecedenceIssueCancel(obj)%#ok<MANU,STOUT>
            assert(false,'Property not implemented');
        end

        function value=get.SelectedFileIsLoadedWithMultipleFilesOnPath(obj)%#ok<MANU,STOUT>
            assert(false,'Property not implemented');
        end
    end

    methods(Access=protected)
        function startingLocation=startingLocationForBrowseButton(obj,currentFileName)


            startingLocation=ddwhich(currentFileName);

            if isempty(startingLocation)
                startingLocation=pwd;



                if strcmp(obj.Mode,'create')&&~isempty(currentFileName)
                    [~,suggestedFilename,~]=fileparts(currentFileName);
                    if~isempty(suggestedFilename)
                        startingLocation=[suggestedFilename,'.sldd'];
                    end
                end
            end
        end

        function[fileName,pathName,filterIndex]=chooseFile(obj,extstr,dialogTitle,startingLocation)


            if strcmp(obj.Mode,'open')
                [fileName,pathName,filterIndex]=uigetfile(extstr,dialogTitle,startingLocation);
            else
                [fileName,pathName,filterIndex]=uiputfile(extstr,dialogTitle,startingLocation);
            end
        end

        function postChooseFile(obj,pathName,fileName)





            if strcmp(obj.Mode,'create')
                path=fullfile(pathName,fileName);
                [~,~,ext]=fileparts(fileName);
                if strcmpi(ext,'.sldd')
                    try
                        if exist(path,'file')
                            Simulink.dd.delete(path);
                        end
                        Simulink.dd.create(path,'SubdictionaryErrorAction','warn');
                    catch e
                        throwAsCaller(e);
                    end
                else
                    tmpModel=mf.zero.Model;
                    errMsg=sl.data.adapter.AdapterManagerV2.createSource(path,'',tmpModel);
                    if errMsg.getId()~=Simulink.data.adapters.AdapterDiagnostic.NoDiagnostic
                        error(errMsg.ErrorMessage);
                    end
                end
            else
                assert(strcmp(obj.Mode,'open'));
                if~isempty(obj.ExpectedFileName)&&~strcmp(obj.ExpectedFileName,fileName)
                    yes=DAStudio.message('SLDD:sldd:AnswerYes');
                    no=DAStudio.message('SLDD:sldd:AnswerNo');
                    btn=questdlg(...
                    DAStudio.message('SLDD:sldd:ReplaceReferencedDataDict',obj.ExpectedFileName,fileName),...
                    DAStudio.message('SLDD:sldd:ReplaceReferencedDataDictQuestion'),...
                    yes,no,no);

                    if strcmp(btn,no)
                        error(no);
                    end
                end
            end
        end

        function[isLoaded,loadedFilePath]=findLoadedFile(~,~)





            isLoaded=false;
            loadedFilePath=[];
        end

        function value=getValueForWidget(~,fileName)




            value=fileName;
        end

        function files=getFilesOnPathMatchingSelectedFile(~,fileName)





            files=which('-all',fileName);
        end
    end
end

function fullpath=ddwhich(filespec)






    [~,~,ext]=fileparts(filespec);

    if isempty(ext)
        filespec=[filespec,'.sldd'];
    end

    fullpath=which(filespec);
end



