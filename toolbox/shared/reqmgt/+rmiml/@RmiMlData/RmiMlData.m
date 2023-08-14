



classdef(Sealed=true)RmiMlData<rmidata.RmiData

    properties





fileMethodsMap
    end


    methods(Static=true)


        function singleObj=getInstance(varargin)
            mlock;
            persistent localRMIData;
            if isempty(localRMIData)||~isvalid(localRMIData)
                if nargin==0
                    localRMIData=rmiml.RmiMlData();
                    reqmgt('init');
                end
            end
            singleObj=localRMIData;
        end


        function result=isInitialized()
            result=~isempty(rmiml.RmiMlData.getInstance('dontinit'));
        end



        function reset()
            if rmiml.RmiMlData.isInitialized()
                data=rmiml.RmiMlData.getInstance;
                delete(data);
            end
        end


        function rename(oldKey,newKey)
            mlData=rmiml.RmiMlData.getInstance();
            if isKey(mlData.statusMap,oldKey)
                if exist(oldKey,'file')==2

                    mlData.statusMap(newKey)=num2str(now);
                else

                    mlData.statusMap(newKey)=mlData.statusMap(oldKey);
                end
                remove(mlData.statusMap,oldKey);
            end
        end

    end


    methods(Access='private')


        function obj=RmiMlData
            obj=obj@rmidata.RmiData();
            obj.statusMap=containers.Map('KeyType','char','ValueType','char');
            obj.fileMethodsMap=containers.Map('KeyType','char','ValueType','any');
        end

        function promptAndWriteToStorage(this,fPath,reloadingFrom)
            if rmiml.promptToSave(fPath,reloadingFrom)
                storageName=rmimap.StorageMapper.getInstance.getStorageFor(fPath);
                this.writeToStorage(fPath,storageName);
            end
        end

    end


    methods

        function restoreId(this,srcName,id,range)
            this.repository.rangeIdRecycler(srcName,id,range);
        end

        function id=rangeToId(this,fPath,selection,shouldCreate)
            if nargin<4
                shouldCreate=false;
            end
            [id,isNew]=this.repository.rangeToId(fPath,selection,shouldCreate);
            if isempty(id)




                return;
            end

            if~isKey(this.statusMap,fPath)
                this.register(fPath);
            end
            if isNew

                this.setDirty(fPath,true);
            end
            if iscell(id)

                id=id{1};
                warning('Using first of multiple items for range %d:%d in %s',...
                selection(1),selection(end),fPath);
            end

            [id,remainder]=strtok(id,'=');
            if shouldCreate&&~isempty(remainder)

                selectionString=sprintf('%d:%d',selection(1),selection(end));
                disp(['RMI WARNING: '...
                ,getString(message('Slvnv:rmiml:PartialRangeMatch',selectionString,remainder(2:end)))]);
                matchedRange=sscanf(remainder,'=%d:%d');
                if selection(1)<matchedRange(1)
                    selection(2)=matchedRange(1)-1;
                elseif selection(2)>matchedRange(2)
                    selection(1)=matchedRange(2)+1;
                else
                    fprintf(1,'RMI ERROR: confused by range overlap in %s:\n\tneeded %s, found %s\n',...
                    fPath,selectionString,remainder(2:end));
                end
                id=this.rangeToId(fPath,selection,shouldCreate);
            end
        end




        function newId=newRangeId(this,srcKey,range)
            newId=this.repository.newRangeId(srcKey,range);

            if~isKey(this.statusMap,srcKey)
                this.register(srcKey);
            end
            this.setDirty(srcKey,true);
        end



        function register(this,fPath)
            this.statusMap(fPath)='loaded';
        end
        function unregister(this,fPath)
            remove(this.statusMap,fPath);
        end

        function range=idToRange(this,fPath,id)

            if id(1)=='@'
                id=id(2:end);
            end
            range=this.repository.idToRange(fPath,id);
        end


        function out=get(this,fPath,id)
            out=this.repository.getData(fPath,id);
        end


        function out=getAll(this,varargin)
            out={};
            srcName=varargin{1};

            if~this.hasData(srcName)
                if exist(srcName,'file')>0
                    storageFile=rmimap.StorageMapper.getInstance.getStorageFor(srcName);
                    if exist(storageFile,'file')==2

                        this.repository.addRoot(srcName,storageFile);
                        this.statusMap(srcName)='loaded';
                    else






                        return;
                    end
                else




                    return;
                end
            end

            if strcmp(this.statusMap(srcName),'loaded')
                try
                    [isModified,lostIds]=this.repository.verifyTextRanges(srcName);
                catch Mex
                    if strcmp(Mex.identifier,'Simulink:utility:objectDestroyed')



                        isModified=false;
                    else
                        rethrow(Mex);
                    end
                end
                if isModified
                    if~isempty(lostIds)
                        this.storeLostIds(srcName,lostIds);
                    end
                    [isMatlabFunction,mdlName]=rmisl.isSidString(srcName,false);
                    if isMatlabFunction

                        modelH=get_param(mdlName,'Handle');
                        rmidata.RmiSlData.getInstance.saveStorage(modelH,true);
                    else
                        storageFile=rmimap.StorageMapper.getInstance.getStorageFor(srcName);
                        this.writeToStorage(srcName,storageFile);
                    end
                else
                    this.statusMap(srcName)='checked';
                end
            end

            out=this.repository.getAll(varargin{:});
        end


        function set(this,srcName,id,newData)
            this.repository.setData(srcName,id,newData);
            this.statusMap(srcName)=num2str(now);
            [isMatlabFunction,mdlName]=rmisl.isSidString(srcName);
            if isMatlabFunction

                rmidata.RmiSlData.getInstance.setDirty(mdlName,srcName);
            end
        end


        function updateStoredRanges(this,srcName,ids,starts,ends)
            possibleMdlName=this.repository.updateRanges(srcName,ids,starts,ends);
            this.statusMap(srcName)=num2str(now);
            if~isempty(possibleMdlName)

                rmidata.RmiSlData.getInstance.setDirty(possibleMdlName,true);
            end
        end

        function rangeIds=getRangeIds(this,srcName)
            rangeIds=this.repository.getRangeIds(srcName);
        end

        function result=removeId(this,srcName,id)
            result=this.repository.removeId(srcName,id);
        end

        function storeLostIds(this,srcName,recycledIds)
            this.repository.rangeIdRecycler(srcName,recycledIds);
        end

        function writeToStorage(this,fPath,storageName)

            this.repository.saveRoot(fPath,storageName);
            this.statusMap(fPath)='saved';
        end

        function setDirty(this,srcName,state)
            if isKey(this.statusMap,srcName)
                if state
                    this.statusMap(srcName)=num2str(now);
                elseif~any(strcmp(this.statusMap(srcName),{'loaded','checked','saved'}))




                    this.statusMap(srcName)='saved';
                end
            end
        end

        function result=hasData(this,fPath)
            result=isKey(this.statusMap,fPath);
        end

        function result=hasChanges(this,fPath)
            if isKey(this.statusMap,fPath)
                result=any(this.statusMap(fPath)=='.');
            else
                result=false;
            end
        end

        function timestamp=getStatus(this,fPath)
            if isKey(this.statusMap,fPath)
                timestamp=this.statusMap(fPath);
            else
                timestamp='none';
            end
        end

        function varargout=load(this,fPath,reqFile)
            try

                this.repository.addRoot(fPath,reqFile);
                this.statusMap(fPath)='loaded';
                varargout{1}=true;


                if nargout>1
                    varargout{2}='';
                end
            catch Mex
                warning(message('Slvnv:rmiml:FailedToLoad',...
                fPath,reqFile,Mex.message));
                varargout{1}=false;
                if nargout>1
                    varargout{2}=Mex.message;
                end
            end
        end

        function discard(this,fPath,force)
            if nargin<3
                force=false;
            end
            if isKey(this.statusMap,fPath)
                if this.repository.removeRoot(fPath,force)

                    remove(this.statusMap,fPath);
                end
            end
        end

        function storagePath=saveStorage(this,fPath,varargin)
            if isempty(varargin)

                storagePath=rmimap.StorageMapper.getInstance.getStorageFor(fPath);
            else

                storagePath=varargin{1};
                this.statusMap(fPath)=num2str(now);
            end


            if any(this.statusMap(fPath)=='.')
                this.writeToStorage(fPath,storagePath);
            end
        end

        function loadFromFile(this,fPath)

            hasLoadedData=this.hasData(fPath);
            if hasLoadedData
                prevStorage=rmimap.StorageMapper.getInstance.getStorageFor(fPath);
            else
                prevStorage='';
            end

            if~isempty(prevStorage)&&this.hasChanges(fPath)
                this.promptAndWriteToStorage(fPath,prevStorage);
            end



            fileToLoadFrom=rmimap.StorageMapper.getInstance.promptForReqFile(fPath,true);
            [~,~,ext]=fileparts(fileToLoadFrom);
            if~isempty(fileToLoadFrom)&&strcmp(ext,'.req')
                if hasLoadedData
                    this.repository.removeRoot(fPath,true);
                end
                [success,msg]=this.load(fPath,fileToLoadFrom);
                if~success
                    errordlg(msg,...
                    getString(message('Slvnv:rmiml:ErrorLoadingFromFile')),...
                    'modal');

                    if~strcmp(fileToLoadFrom,prevStorage)
                        rmimap.StorageMapper.getInstance.forget(fPath,false);
                        if~isempty(prevStorage)
                            this.load(fPath,prevStorage);
                        end
                    end
                end
            end
        end

        function result=hasLinks(this,fPath)
            if this.hasData(fPath)
                result=this.repository.rootHasLinks(fPath);
            else
                result=false;
            end
        end

        function close(this,fPath)
            if rmisl.isSidString(fPath,false)






            else
                if this.hasChanges(fPath)
                    this.promptAndWriteToStorage(fPath,'');
                end
                this.discard(fPath);
            end
        end

        function[docs,sys,counts]=countDocs(this,srcKey)
            [docs,sys,counts]=this.repository.countDependeeRoots(srcKey);
        end

        function setProp(this,propName,sourceName,rangeIds,linkNo,value)
            for i=1:length(rangeIds)
                reqs=this.get(sourceName,rangeIds{i});
                oneReq=reqs(linkNo(i));
                oneReq.(propName)=value;
                reqs(linkNo(i))=oneReq;
                this.set(sourceName,rangeIds{i},reqs);
            end
        end


        function[extStartPos,extEndPos]=getExtendedBoundsIfMethod(this,textItemId,textContent,startPos,endPos)
            extStartPos=startPos;
            extEndPos=endPos;

            if~isKey(this.fileMethodsMap,textItemId)
                this.cacheAllMethodsInMCode(textItemId,textContent);
            end




            if~isKey(this.fileMethodsMap,textItemId)
                return;
            end




            methodTable=this.fileMethodsMap(textItemId);
            methodNames=this.methodsUnderRange(methodTable,startPos,endPos);
            if~isempty(methodNames)



                [extStartPos,extEndPos]=this.getExtendedMethodBounds(methodTable,methodNames(1));
            end
        end

        function clearMethodPosCache(this,filepath)


            if isKey(this.fileMethodsMap,filepath)
                this.fileMethodsMap.remove(filepath);
            end
        end
    end

    methods(Hidden)
        function methodNames=methodsUnderRange(~,fileMethodTable,startPos,endPos)
            methodNames=[];
            containedMethods=fileMethodTable(fileMethodTable.start>=startPos&fileMethodTable.end<=endPos,'method');
            if~isempty(containedMethods)
                methodNames=containedMethods.method;
            end
        end

        function[extStartPos,extEndPos]=getExtendedMethodBounds(~,fileMethodTable,methodName)
            positions=fileMethodTable(methodName,{'extStart','extEnd'});
            extStartPos=positions.extStart;
            extEndPos=positions.extEnd;
        end

        function cacheAllMethodsInMCode(this,textItemID,textContent)
            parseTree=this.getMtreeFromCode(textContent);
            if isempty(parseTree)
                return;
            end
            allFunctionBlocks=parseTree.mtfind('Kind','FUNCTION');
            allFunctionNames=allFunctionBlocks.Fname;
            allFunctionNameStrings=strings(allFunctionNames);

            extendedStarts=allFunctionBlocks.lefttreepos.';
            extendedEnds=allFunctionBlocks.righttreepos.';










            methodSigStart=allFunctionNames.lefttreepos.';
            methodSigEnd=allFunctionNames.righttreepos.';

            fileMethodTable=table(allFunctionNameStrings',methodSigStart',methodSigEnd',extendedStarts',extendedEnds');
            fileMethodTable.Properties.RowNames=allFunctionNameStrings';
            fileMethodTable.Properties.VariableNames={'method','start','end','extStart','extEnd'};

            this.fileMethodsMap(textItemID)=fileMethodTable;
        end

        function parseTree=getMtreeFromCode(~,textContent)
            textContent=regexprep(textContent,'\r','');
            parseTree=mtree(textContent,'-comments');

            if parseTree.isnull||parseTree.root.iskind('ERR')
                parseTree=[];
                return;
            end
        end
    end

end

