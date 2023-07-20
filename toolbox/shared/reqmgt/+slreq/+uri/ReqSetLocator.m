classdef ReqSetLocator<handle









    properties(Access=private)
attemptedReqSets

    end

    methods(Access=private)

        function this=ReqSetLocator()
            this.init();
        end

        function init(this)
            this.attemptedReqSets=containers.Map('KeyType','char','ValueType','char');
        end

        function result=easyKey(~,storedUri,refPath)




            separator='!';
            result=sprintf('%s%c%s',storedUri,separator,refPath);
        end
    end

    methods(Static)

        function singletonLocator=getInstance()
            persistent locator;
            if isempty(locator)
                locator=slreq.uri.ReqSetLocator();
            end
            singletonLocator=locator;
        end

        function reset()

            slreq.uri.ReqSetLocator.getInstance.init();
        end

    end

    methods

        function reqSetPath=findReqSetFile(this,storedUri,srcPath)

            key=this.easyKey(storedUri,srcPath);

            if isKey(this.attemptedReqSets,key)

                reqSetPath=this.attemptedReqSets(key);

            else

                reqSetName=slreq.uri.getReqSetShortName(storedUri);
                reqSetFileName=[reqSetName,'.slreqx'];
                if rmiut.isCompletePath(storedUri)

                    if isfile(storedUri)
                        reqSetPath=storedUri;
                        this.attemptedReqSets(key)=reqSetPath;
                        return;
                    else

                        storedUri=reqSetFileName;
                    end
                end


                reqSetPath=which(reqSetFileName);

                if isempty(reqSetPath)

                    reqSetPath=slreq.uri.ResourcePathHandler.getFullPath(storedUri,srcPath);
                end



                if isempty(reqSetPath)
                    referrer=slreq.uri.getShortNameExt(srcPath);
                    if isImproperlyRegisteredUUID(storedUri)
                        dataLinkSet=slreq.data.ReqData.getInstance.getLinkSet(srcPath);
                        if~isempty(dataLinkSet)

                            wasDirty=dataLinkSet.dirty;


                            slreq.data.DataModelObj.checkLicense(['allow ',dataLinkSet.filepath]);
                            onCleanup=@()slreq.data.DataModelObj.checkLicense('clear');%#ok<NASGU>
                            dataLinkSet.removeRegisteredRequirementSet(storedUri);




                            if~wasDirty
                                slreq.data.ReqData.getInstance.forceDirtyFlag(dataLinkSet,false);
                            end
                        else



                        end
                    else

                        rmiut.warnNoBacktrace('Slvnv:slreq:UnableToLocateReqSetReferencedBy',storedUri,referrer);
                    end
                end


                this.attemptedReqSets(key)=reqSetPath;
            end

            function tf=isImproperlyRegisteredUUID(reqSetName)









                uuidLength=36;
                if length(reqSetName)==uuidLength&&sum(reqSetName=='-')==4
                    tf=~isempty(regexp(reqSetName,'^[a-z0-9\-]+$','once'));
                else
                    tf=false;
                end
            end

        end

        function clearFailedAttempts(this)




            allKeys=keys(this.attemptedReqSets);
            for i=1:numel(allKeys)
                oneKey=allKeys{i};
                if isempty(this.attemptedReqSets(oneKey))
                    remove(this.attemptedReqSets,oneKey);
                end
            end
        end

    end

end
