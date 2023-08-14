function[jsonStruct,sdiRunID]=import2Repository(varargin)





    namesInUse={};

    Simulink.sdi.internal.startConnector();


    jsonStruct=[];
    sdiRunID=[];

    eng=sdi.Repository(true);
    if ischar(varargin{1})
        fileName=varargin{1};

        aFile=iofile.STAMatFile(fileName);
    elseif isa(varargin{1},'iofile.File')
        aFile=varargin{1};
    else

        return;
    end

    tempWhich=which(aFile.FileName);
    fileLastModifiedDate='';
    fileInfo=dir(tempWhich);
    if~isempty(fileInfo)
        fileLastModifiedDate=fileInfo.date;
    end

    if(nargin==1)


        aList=whos(aFile);

        if~isempty(aList)
            downselectstruct(length(aList))=struct('name',[],'children',[]);
        end


        for id=1:length(aList)
            downselectstruct(id).name=aList(id).name;
            downselectstruct(id).children='all';
        end
        startingTreeOrder=0;
    elseif(nargin==2)

        downselectstruct=varargin{2};
        startingTreeOrder=0;
    elseif(nargin>=3)


        downselectstruct=varargin{2};

        if isempty(downselectstruct)

            aList=whos(aFile);
            clear downselectstruct;
            if~isempty(aList)
                downselectstruct(length(aList))=struct('name',[],'children',[]);
            end


            for id=1:length(aList)
                downselectstruct(id).name=aList(id).name;
                downselectstruct(id).children='all';
            end
        end

        startingTreeOrder=varargin{3};

        if nargin==4
            namesInUse=varargin{4};
        end
    end





    jsonStruct={};

    signalData=import(aFile);

    if~isempty(signalData.Data)


        idxChar=cellfun(@ischar,signalData.Data);


        if any(idxChar)


            signalData.Data(idxChar)=[];
            signalData.Names(idxChar)=[];
        end


        if isempty(signalData.Data)
            return;
        end




        item{length(signalData.Names)}=[];

        rowMajorNotation=false;
        if isa(aFile,'iofile.FromFilePreviewMatFile')
            rowMajorNotation=true;
        end

        if~isempty(namesInUse)

            aStrUtil=sta.StringUtil();
            for k=1:length(namesInUse)
                aStrUtil.addNameContext(namesInUse{k});
            end
        end

        for kSig=1:length(signalData.Names)


            chkIfSignalNameExistsInDownSelect=strcmp(signalData.Names{kSig},{downselectstruct(:).name});

            if any(chkIfSignalNameExistsInDownSelect)

                if~isempty(namesInUse)
                    signalData.Names{kSig}=aStrUtil.getUniqueName(signalData.Names{kSig});
                    aStrUtil.addNameContext(signalData.Names{kSig});
                end



                itemFactory=starepository.factory.createSignalItemFactory(signalData.Names{kSig},signalData.Data{kSig});


                item{kSig}=itemFactory.createSignalItem;

                if isa(item{kSig},'starepository.ioitem.DataArray')
                    item{kSig}.rowMajorNotation=rowMajorNotation;
                end
                item{kSig}.FileModifiedDate=fileLastModifiedDate;

                trimItem(item{kSig},downselectstruct(chkIfSignalNameExistsInDownSelect).children);
            end


        end

        cellEmpty=cellfun(@isempty,item);
        item(cellEmpty)=[];


        repoOut=eng.safeTransaction(@initRepository,item,aFile.FileName,startingTreeOrder);
        jsonStruct=repoOut.jsonStruct;
        sdiRunID=repoOut.runID;

        Simulink.sdi.internal.flushStreamingBackend();
    end
end

function repoOut=initRepository(item,fileName,startingTreeOrder)

    runTimeRange.Start=[];
    runTimeRange.Stop=[];

    runID=Simulink.sdi.createRun;
    Simulink.sdi.internal.moveRunToApp(runID,'sta',true);

    parentSigID=0;

    jsonStruct={};

    repoOut.jsonStruct=jsonStruct;
    repoOut.runID=runID;


    if~isempty(item)


        for k=1:length(item)

            sigStruct=initializeRepository(item{k},fileName,k,runID,parentSigID,...
            runTimeRange);
            jsonStruct=[jsonStruct,sigStruct];

        end


        cellEmpty=cellfun(@isempty,jsonStruct);
        jsonStruct(cellEmpty)=[];
        repoUtil=starepository.RepositoryUtility();


        for kStruct=1:length(jsonStruct)

            jsonStruct{kStruct}.TreeOrder=startingTreeOrder+kStruct;



            setMetaDataByName(repoUtil,jsonStruct{kStruct}.ID,'TreeOrder',startingTreeOrder+kStruct);

            IS_COMPLEX=isfield(jsonStruct{kStruct},'ComplexID');
            if IS_COMPLEX
                setMetaDataByName(repoUtil,jsonStruct{kStruct}.ComplexID,'TreeOrder',startingTreeOrder+kStruct);
            end


            if ischar(jsonStruct{kStruct}.ParentID)&&strcmp(jsonStruct{kStruct}.ParentID,'input')

                exSource=sta.ExternalSource();

                if IS_COMPLEX
                    exSource.SignalID=jsonStruct{kStruct}.ComplexID;
                else
                    exSource.SignalID=jsonStruct{kStruct}.ID;
                end

                jsonStruct{kStruct}.ExternalSourceID=exSource.ID;
            end
        end

        repoOut.jsonStruct=jsonStruct;
        repoOut.runID=runID;
    end

end


