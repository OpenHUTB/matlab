




classdef ImportDataChecker<handle

    properties
        reqSetName;

        docName;

        subDoc;


itemUseSheetNameID






    end

    methods(Static)

        function importOptions=loadStoredImportOptions(reqSetName,docName,subDocName)
            if isempty(subDocName)

                importOptions=slreq.import.loadStoredOptions(reqSetName,docName);
            else

                checker=slreq.import.ImportDataChecker(reqSetName,docName,subDocName);
                importOptions=checker.getOrRepairOptions();
            end
        end



        function out=initStruct(importOptions)
            out=importOptions;

            if~isfield(out,'subDoc')
                out.subDoc='';
            end

            if~isfield(out,'subDocPrefix')
                out.subDocPrefix=false;
            end

            if~isfield(out,'headers')
                out.headers={};
            end

            if~isfield(out,'columns')
                out.columns=[];
            end





        end
    end

    methods(Access=private)



        function items=getTopItems(this)
            reqData=slreq.data.ReqData.getInstance();
            dataReqSet=reqData.loadReqSet(this.reqSetName);

            topItems=dataReqSet.children;

            items=slreq.data.Requirement.empty;
            for ii=1:length(topItems)
                topItem=topItems(ii);


                if~topItem.external
                    continue;
                end


                [topDoc,~]=slreq.internal.getDocSubDoc(topItem.customId);


                if~strcmp(topDoc,this.docName)
                    continue;
                end

                items(end+1)=topItem;%#ok<AGROW>
            end

        end


        function out=isLatestSheet(this)

            reqData=slreq.data.ReqData.getInstance();
            max=reqData.initialTime;
            maxSheetName='';

            topItems=this.getTopItems();
            for ii=1:length(topItems)
                topItem=topItems(ii);


                [~,topSubDoc]=slreq.internal.getDocSubDoc(topItem.customId);

                if topItem.synchronizedOn>max
                    max=topItem.synchronizedOn;
                    maxSheetName=topSubDoc;
                end
            end

            out=strcmp(maxSheetName,this.subDoc);
        end


        function missing=isSubDocMissingMatFile(this)
            possibleOptionsFile=slreq.import.impOptFile(this.reqSetName,this.docName,this.subDoc);
            missing=exist(possibleOptionsFile,'file')==0;
        end



        function out=isExcel(this,foundOptions)
            out=isfield(foundOptions,'headers')||isfield(foundOptions,'columns');
        end




        function out=hasMultipleSheets(this)
            topItems=this.getTopItems();
            out=~isempty(topItems);
        end





        function out=doesMatchAttributeNames(this,foundOptions,subDoc)

            columnNames=foundOptions.headers;
            mappedColumns=foundOptions.columns;
            attributeColumns=foundOptions.attributeColumn;



            [~,idxIntoHeaders]=intersect(mappedColumns,attributeColumns,'stable');


            mappedAttributes=columnNames(idxIntoHeaders);

            actualAttributes=this.itemUseAttributes(subDoc);





            out=any(ismember(mappedAttributes,actualAttributes));
        end
    end

    methods(Access=public)


        function this=ImportDataChecker(reqSetName,docName,subDoc)
            this.reqSetName=reqSetName;
            this.docName=docName;
            this.subDoc=subDoc;

            this.itemUseSheetNameID=containers.Map('KeyType','char','ValueType','logical');



        end







        function importOptions=getOrRepairOptions(this)

            importOptions=slreq.import.loadStoredOptions(this.reqSetName,this.docName,this.subDoc);
            if isempty(importOptions)
                return;
            end

            doWarn=true;
            if this.needsRepair(importOptions)
                this.analyzeTopItems();
                if this.hasDataMismatch(importOptions,doWarn)
                    if this.repairMissingFiles(doWarn)

                        importOptions=slreq.import.loadStoredOptions(this.reqSetName,this.docName,this.subDoc);
                    end
                end
            end
        end
    end

    methods(Access=private)

        function out=needsRepair(this,importOptions)
            out=false;

            if~this.isExcel(importOptions)
                return;
            end

            if this.isSubDocMissingMatFile()
                if~this.hasMultipleSheets()

                else
                    if this.isLatestSheet()


                        this.hasDataMismatch(importOptions,false);
                    else
                        out=true;
                    end
                end
            end
        end







        function analyzeTopItems(this)


            topItems=this.getTopItems();
            for ii=1:length(topItems)
                topItem=topItems(ii);


                [~,topSubDoc]=slreq.internal.getDocSubDoc(topItem.customId);






                childItems=topItem.children;
                if isempty(childItems)
                    continue;
                end



                childItem=childItems(1);



                [childDoc,childSubDoc]=slreq.internal.getDocSubDoc(childItem.customId);

                useSheetName=~isempty(childSubDoc)&&strcmp(childDoc,topSubDoc);

                this.itemUseSheetNameID(topSubDoc)=useSheetName;










            end
        end






        function out=hasDataMismatch(this,foundOptions,doWarn)

            matMatch=struct('match',false,'matchSubDoc',false,'matchSubDocPrefix',false,'matchCustomAttributes',false);

            foundOptions=slreq.import.ImportDataChecker.initStruct(foundOptions);






            matMatch.matchSubDoc=strcmp(foundOptions.subDoc,this.subDoc);

            if isKey(this.itemUseSheetNameID,this.subDoc)
                subDocPrefix=this.itemUseSheetNameID(this.subDoc);
                matMatch.matchSubDocPrefix=(foundOptions.subDocPrefix==subDocPrefix);
            end



            out=(~matMatch.matchSubDoc||~matMatch.matchSubDocPrefix);

            if out&&doWarn
                rmiut.warnNoBacktrace('Slvnv:slreq_import:SyncImportDataIssue',this.reqSetName,this.subDoc);
            end
        end














        function repaired=repairMissingFiles(this,doWarn)

            repaired=false;











            foundSubDocs={};

            topItems=this.getTopItems();
            for ii=1:length(topItems)
                topItem=topItems(ii);


                [topDoc,topSubDoc]=slreq.internal.getDocSubDoc(topItem.customId);




                childItems=topItem.children;
                if isempty(childItems)

                    continue;
                end

                childItem=childItems(1);


                [childDoc,childSubDoc]=slreq.internal.getDocSubDoc(childItem.customId);

                if~strcmp(childDoc,topSubDoc)

                    continue;
                end


                possibleOptionsFile=slreq.import.impOptFile(this.reqSetName,this.docName,topSubDoc);
                if exist(possibleOptionsFile,'file')==2
                    foundSubDocs{end+1}=topSubDoc;%#ok<AGROW>
                end
            end


            if~isempty(foundSubDocs)
                foundSubDoc=foundSubDocs{1};
                foundOptionsFile=slreq.import.impOptFile(this.reqSetName,this.docName,foundSubDoc);
            else

                foundOptionsFile=slreq.import.impOptFile(this.reqSetName,this.docName);
            end

            if exist(foundOptionsFile,'file')~=2


                return;
            end




            foundLoaded=load(foundOptionsFile);
            if isempty(foundLoaded)
                return;
            end

            foundOptions=foundLoaded.importOptions;
            if isempty(foundOptions)
                return;
            end








            missingOptionsFile=slreq.import.impOptFile(this.reqSetName,this.docName,this.subDoc);


            copyfile(foundOptionsFile,missingOptionsFile);



            missingLoaded=load(missingOptionsFile);
            if~isempty(missingLoaded)
                importOptions=missingLoaded.importOptions;

                importOptions.subDoc=this.subDoc;

                if isKey(this.itemUseSheetNameID,this.subDoc)
                    importOptions.subDocPrefix=this.itemUseSheetNameID(this.subDoc);
                end


                save(missingOptionsFile,'importOptions');

                repaired=true;

                if doWarn
                    rmiut.warnNoBacktrace('Slvnv:slreq_import:SyncImportDataRepaired',this.reqSetName,this.subDoc);
                end
            end
        end
    end

end
