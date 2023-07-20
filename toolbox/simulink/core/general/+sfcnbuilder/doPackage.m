function adOrig=doPackage(adOrig)




    ad=adOrig;
    wizData=ad.SfunWizardData;
    isBlockSetSDK=0;
    if isfield(wizData,'BlockSetSDK')
        isBlockSetSDK=wizData.BlockSetSDK;
    end

    if~(isfield(ad,'LangExt'))
        ad=sfcnbuilder.sfunbuilderLangExt('ComputeLangExtFromWizardData',ad);
    end
    wizData.LangExt=ad.LangExt;
    [libFileList,srcFileList,objFileList,...
    addIncPaths,addLibPaths,addSrcPaths,...
    preProcList,preProcUndefList]=...
    sfcnbuilder.parseLibCodePaneTextForPackage(ad.SfunWizardData.LibraryFilesText,ad.inputArgs);

    libAndObjFilesWithFullPath=locateFileInPath({libFileList{:},objFileList{:}},...
    {addLibPaths{:},addSrcPaths{:},pwd},...
    filesep);

    if(isBlockSetSDK)




        addSrcPaths=[addSrcPaths(:)',{fullfile(wizData.BlockRootDir,'src')}];
    else
        addSrcPaths=[addSrcPaths(:)',{'./'}];
    end

    srcFilesWithFullPath=locateFileInPath(srcFileList,addSrcPaths,filesep);
    pathTable=struct;
    pathTable.LibAndObjFiles=libAndObjFilesWithFullPath;






    paths=[addSrcPaths(:)',addIncPaths(:)'];
    paths=filterNestedPaths(paths);
    if isfield(ad.SfunWizardData,'BlockSetSDKWithPackaging')&&...
        isequal(ad.SfunWizardData.BlockSetSDKWithPackaging,1)
        paths=cellfun(@(x)makeBlocksetPaths(x,ad.PathName),paths,'UniformOutput',false);
    end
    pathTable.SrcFiles={};
    pathTable.IncPaths=paths;
    pathTable.Artifacts={};
    wizData.PathTable=pathTable;


    wizData.BeginPackaging='1';


    wizData.IsBusUsed=any(strcmp(wizData.InputPorts.Bus,'on'))|any(strcmp(wizData.OutputPorts.Bus,'on'));


    SFBFileList={[wizData.SfunName,'.',wizData.LangExt],...
    [wizData.SfunName,'_wrapper.',wizData.LangExt],...
    [wizData.SfunName,'.tlc'],...
    [wizData.SfunName,'.',mexext]...
    };







    busList={};
    if wizData.IsBusUsed
        SFBFileList=[SFBFileList(:)',{[wizData.SfunName,'_bus.h']}];

        for i=1:length(wizData.InputPorts.Name)

            if strcmp(wizData.InputPorts.Bus{i},'on')


                [busList,SFBFileList]=findBusesWithin(wizData.InputPorts.Busname{i},...
                bdroot(ad.inputArgs),busList,SFBFileList);




            end
        end

        for i=1:length(wizData.OutputPorts.Name)

            if strcmp(wizData.OutputPorts.Bus{i},'on')


                [busList,SFBFileList]=findBusesWithin(wizData.OutputPorts.Busname{i},...
                bdroot(ad.inputArgs),busList,SFBFileList);




            end
        end
    end
    busList=unique(busList);

    busesMATFileName=sprintf(['SFcnBUSES__%s__SFcnBUSES.mat'],wizData.SfunName);
    try
        if~isempty(busList)
            busesStr=sprintf('''%s'',',busList{:});
            busesStr=busesStr(1:end-1);
            evalStr=sprintf('save(''%s'',%s)',busesMATFileName,busesStr);
            evalin('base',evalStr);
            SFBFileList=[SFBFileList(:)',{busesMATFileName}];
        end
    catch

    end



    if(isBlockSetSDK&&isfile(busesMATFileName))
        movefile(busesMATFileName,wizData.BlockRootDir,"f");
        wizData.PathTable.Artifacts=[wizData.PathTable.Artifacts(:)',{fullfile(wizData.BlockRootDir,busesMATFileName)}];
    end

    SFBFileList=unique(SFBFileList);
    wizData.SFBFileList=SFBFileList;
    if(isBlockSetSDK)
        wizData.SFBFileList={};
    end


    wizData.PathName=ad.PathName;


    wizData.ExtTable=getSFcnPackageLayout;


    [wizData.InputPorts,wizData.OutputPorts,wizData.Parameters]...
    =sfcnbuilder.renamePortInfo(wizData.InputPorts,...
    wizData.OutputPorts,...
    wizData.Parameters);

    Parametersv2=wizData.Parameters;
    for i=1:numel(Parametersv2.Name)

        if isvarname(Parametersv2.Value{i})
            if strcmp(Parametersv2.Complexity{i},'complex')
                if isreal(eval(Parametersv2.Value{i}))
                    Parametersv2.Value{i}=char(string(complex(eval(Parametersv2.Value{i}))));
                end
            else
                Parametersv2.Value{i}=char(string(eval(Parametersv2.Value{i})));
            end
        else
            if strcmp(Parametersv2.Complexity{i},'complex')&&isreal(eval(Parametersv2.Value{i}))
                Parametersv2.Value{i}=char(string(complex(eval(Parametersv2.Value{i}))));
            end
        end
    end
    wizData.Parametersv2=Parametersv2;



    set_param(getfullname(ad.inputArgs),'WizardData',wizData);


    if isfile(busesMATFileName)
        delete(busesMATFileName);
    end


    [wizData.InputPorts,wizData.OutputPorts,wizData.Parameters]...
    =sfcnbuilder.i_renamePortDataTypes(wizData.InputPorts,...
    wizData.OutputPorts,...
    wizData.Parameters);

    wizData.BeginPackaging='0';
    fieldsToRemove={'IsBusUsed','LangExt','ExtTable','SFBFileList','PathName','Parametersv2','PackAction'};
    wizData=rmfield(wizData,fieldsToRemove);
    set_param(getfullname(ad.inputArgs),'WizardData',wizData);
end



function[busList,busHeaderList]=findBusesWithin(busName,modelName,busList,busHeaderList)

    busObj='';
    if existsInGlobalScope(modelName,busName)
        busObj=evalinGlobalScope(modelName,busName);
    end


    if~isa(busObj,'Simulink.Bus')
        return
    end


    if strcmp(busObj.DataScope,'Imported')

        busHeaderList=[busHeaderList(:)',{b.HeaderFile}];
    end

    busList=[busList(:)',{busName}];

    for i=1:length(busObj.Elements)

        busDTStr='Bus:';
        busObj.Elements(i).DataType=strrep(busObj.Elements(i).DataType,' ','');
        indicesBus=findstr(busObj.Elements(i).DataType,busDTStr);
        if(~isempty(indicesBus)&&indicesBus(1)==1)
            busObj.Elements(i).DataType=strtrim(strrep(busObj.Elements(i).DataType,'Bus:',''));
        end
        [busList,busHeaderList]=findBusesWithin(busObj.Elements(i).DataType,modelName,busList,busHeaderList);
    end

end



function paths=filterNestedPaths(paths)



    [~,indices]=sort(cellfun('length',paths),'ascend');
    paths=paths(indices);

    n=numel(paths);
    if isequal(n,1)
        if isfile(paths{1})
            [p,~,~]=fileparts(paths{1});
            paths{1}=p;
        end
        return
    end




    indicesToRemove=[];
    for i=2:n


        if isfile(paths{i})
            [p,~,~]=fileparts(paths{i});
            paths{i}=p;
        end


        if any(contains(paths{i},paths(1:i-1)))
            indicesToRemove=[indicesToRemove,i];
        end
    end
    paths(indicesToRemove)=[];
end

function pathEntry=makeBlocksetPaths(pathEntry,blocksetRoot)


    if contains(pathEntry,blocksetRoot)

        return
    elseif isfolder(fullfile(blocksetRoot,pathEntry))

        pathEntry=fullfile(blocksetRoot,pathEntry);
        return;
    else


    end

end

function fullFileLocation=locateFileInPath(fileNames,possiblePaths,fileSeparator,fileQuotes)
















    fullFileLocation={};

    if isempty(fileNames)||(~iscell(fileNames)&&~ischar(fileNames))
        return;
    end

    if nargin<4
        fileQuotes='';
    end

    numFiles=0;
    numPaths=0;

    if ischar(fileNames)
        numFiles=1;
        fileNames={fileNames};
    else
        numFiles=length(fileNames);
    end

    [fullFileLocation{1:numFiles}]=deal(fileNames{1:numFiles});

    if ischar(possiblePaths)
        numPaths=1;
        possiblePaths={possiblePaths};
    elseif iscell(possiblePaths)
        numPaths=length(possiblePaths);
    else
        return;
    end

    for fileNameIdx=1:numFiles
        for pathIdx=1:numPaths
            fullFileName=[possiblePaths{pathIdx},fileSeparator,fileNames{fileNameIdx}];
            if(exist(fullFileName)>=2)
                fullFileLocation{fileNameIdx}=[fileQuotes,fullFileName,fileQuotes];
                break;
            end
        end
    end

end
