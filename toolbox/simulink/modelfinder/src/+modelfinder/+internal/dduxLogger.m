classdef(Hidden)dduxLogger<handle






    properties(Constant,Hidden,Access=protected)

        Product='SL';
        ApplicationComponent='SL_DIAGSRCH';
        EventKey='SL_DIAGSRCH_EXAMPLE_FINDER';



        DDUXKeys={'searchQuery','numberOfResults','uriOfSelectedModel',...
        'searchQueryMatchDetails','rankOfSelectedModel',...
        'uriOfModelsInResultWindow','appParam','apiCalledFrom'};


        ResultSize=10;
    end

    properties(Hidden,Access=private)

        DataID;


        slexDDUXData;
    end


    methods(Hidden)
        function obj=dduxLogger()





            initDDUX(obj);
            obj.DataID=matlab.ddux.internal.DataIdentification(obj.Product,...
            obj.ApplicationComponent,obj.EventKey);
        end

        function collectDDUXData(obj,searchQueryTerms,modelTerm,blocksTerm,nlpEntities,resultStruct,resultsMetadata,selection,isNLPInvocation)







            searchQueryTerms={char(searchQueryTerms)};
            obj.slexDDUXData.searchQuery=strjoin(searchQueryTerms,',');
            obj.slexDDUXData.numberOfResults=int64(numel(resultStruct));
            obj.slexDDUXData.uriOfSelectedModel=obj.getUriOfSelectedModel(resultStruct,selection);
            obj.slexDDUXData.searchQueryMatchDetails=obj.getSearchQueryMatchDetails(resultsMetadata,modelTerm,selection);
            obj.slexDDUXData.rankOfSelectedModel=obj.getRankOfSelectedModel(selection);
            obj.slexDDUXData.uriOfModelsInResultWindow=obj.getUriOfModelsInResultWindow(resultStruct);
            obj.slexDDUXData.appParam=obj.getJSONStringForParams(modelTerm,blocksTerm,nlpEntities,isNLPInvocation);
            obj.slexDDUXData.apiCalledFrom=obj.getAPICallSite(isNLPInvocation);

            obj.logDDUXData();

        end
    end



    methods(Hidden,Access=private)
        function status=logDDUXData(obj)



            status=matlab.ddux.internal.logData(obj.DataID,obj.slexDDUXData);
        end

        function initDDUX(obj)











            obj.slexDDUXData.searchQuery='';
            obj.slexDDUXData.numberOfResults=int64(-1);
            obj.slexDDUXData.uriOfSelectedModel='';
            obj.slexDDUXData.searchQueryMatchDetails='';
            obj.slexDDUXData.rankOfSelectedModel=int64(-1);
            obj.slexDDUXData.uriOfModelsInResultWindow='';
            obj.slexDDUXData.appParam='';
            obj.slexDDUXData.apiCalledFrom='';
        end

        function uriOfModel=getUriOfSelectedModel(obj,resultStruct,selection)






            uriOfModel='-1';
            if selection=='q'

                return;
            end


            idx=str2double(selection);
            if~isnan(idx)
                uriOfModel=resultStruct(idx).link;
                isExample=resultStruct(idx).isExample;
                uriOfModel=obj.processUserValues(isExample,uriOfModel);
            end
        end

        function resultMatchDetails=getSearchQueryMatchDetails(obj,resultsMetadata,modelTerm,selection)





            resultMatchDetails=struct;
            resultMatchDetails.ExampleName=[];
            resultMatchDetails.ModelName=[];
            resultMatchDetails.Annotation=[];
            resultMatchDetails.Description=[];

            if selection=='q'

                resultMatchDetails=jsonencode(resultMatchDetails);
                return;
            end


            idx=str2double(selection);
            if~isnan(idx)
                resultMatchDetails=obj.prepareSearchQueryMatchDetails(resultsMetadata(idx),modelTerm,resultMatchDetails);
            end
            resultMatchDetails=jsonencode(resultMatchDetails);
        end

        function rankOfModel=getRankOfSelectedModel(~,selection)




            rankOfModel=int64(-1);
            if selection=='q'

                return;
            end


            rank=str2double(selection);
            if~isnan(rank)
                rankOfModel=int64(rank);
            end
        end

        function concatenatedURI=getUriOfModelsInResultWindow(obj,resultStruct)




            sizeOfOutput=min(obj.ResultSize,numel(resultStruct));
            concatenatedURI='';
            if(sizeOfOutput)
                cellModelURI={resultStruct(1:sizeOfOutput).link};
                cellIsExample={resultStruct(1:sizeOfOutput).isExample};

                cellModelURI=cellfun(@(x,y)obj.processUserValues(x,y),cellIsExample,cellModelURI,'UniformOutput',false);
                concatenatedURI=strjoin(cellModelURI,';');
            end
        end

        function paramJSONString=getJSONStringForParams(~,modelTerm,blocksTerm,nlpEntities,isNLPInvocation)












            slexFinderObj=modelfinder.internal.queryEngine.instance();


            aNLPEntity=struct;
            aNLPEntity.blocks='';
            aNLPEntity.concepts='';
            aNLPEntity.domains='';
            aNLPEntity.toolboxes='';



            aAPIParamEntity=struct;

            if(isNLPInvocation)
                aNLPEntity.blocks=strjoin(nlpEntities.blocks,',');
                aNLPEntity.concepts=strjoin(nlpEntities.concepts,',');
                aNLPEntity.domains=strjoin(nlpEntities.domains,',');
                aNLPEntity.toolboxes=strjoin(nlpEntities.toolboxes,',');
                aAPIParamEntity.blocks='';
            else
                aAPIParamEntity.blocks=strjoin(string(blocksTerm),',');
            end



            result_struct=struct;
            result_struct.query=strjoin(string(modelTerm),',');
            result_struct.apiParams=aAPIParamEntity;
            result_struct.nerParams=aNLPEntity;
            result_struct.dbVersion=slexFinderObj.getSchemaVersion();

            paramJSONString=string(jsonencode(result_struct));
        end

        function apiCallSite=getAPICallSite(~,isNLPInvocation)


            apiCallSite='ML_CMD_API';

            if(isNLPInvocation)
                apiCallSite='ML_CMD_NLP';
            end
        end

    end



    methods(Hidden,Access=private)

        function resultMatchDetails=prepareSearchQueryMatchDetails(obj,resultMetadata,modelTerm,resultMatchDetails)



            if ischar(modelTerm)
                modelTerm={modelTerm};
            end

            for termIdx=1:numel(modelTerm)
                aTerm=modelTerm{termIdx};
                resultMatchDetails.ExampleName=[resultMatchDetails.ExampleName,obj.getMatchPositionsInStr(resultMetadata.examplename,aTerm)];
                resultMatchDetails.ModelName=[resultMatchDetails.ModelName,obj.getMatchPositionsInStr(resultMetadata.modelname,aTerm)];
                resultMatchDetails.Annotation=[resultMatchDetails.Annotation,obj.getMatchPositionsInStr(resultMetadata.annotation,aTerm)];
                resultMatchDetails.Description=[resultMatchDetails.Description,obj.getMatchPositionsInStr(resultMetadata.description,aTerm)];
            end

            resultMatchDetails.ExampleName=sort(resultMatchDetails.ExampleName);
            resultMatchDetails.ModelName=sort(resultMatchDetails.ModelName);
            resultMatchDetails.Annotation=sort(resultMatchDetails.Annotation);
            resultMatchDetails.Description=sort(resultMatchDetails.Description);
        end

        function matchPositions=getMatchPositionsInStr(~,text,pattern)



            pattern=strtok(pattern,'*');
            text=upper(text);
            pattern=upper(pattern);
            matchPositions=strfind(text,pattern);
        end

        function hashedString=processUserValues(~,isExample,uriOfModel)

            hashedString='';
            if isExample



                hashedString=uriOfModel;
                return;
            end

            fullPathToModel=fullfile(matlabroot,uriOfModel);
            if(isfile(fullPathToModel))


                hashedString=uriOfModel;
                return;
            end

            if(~isfile(fullPathToModel)&&isfile(uriOfModel))










                hashedString=slInternal('hashUsingSHA2',uriOfModel,'true');
                return;
            end
        end

    end

end
