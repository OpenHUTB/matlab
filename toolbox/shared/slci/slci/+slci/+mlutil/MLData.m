




classdef MLData<handle

    properties(Access=private)


        fFIDToInference=[];


        fScriptInfo=[];


        fFIDs=[];


        fRootFID=[];


        fOptions=struct('IncludeNonUserVisibleFunctions',true);


        fHasInferenceData=false;
    end

    methods





        function obj=MLData(chartUDDObject,blkHdl,options)

            assert(isa(chartUDDObject,'Stateflow.EMChart'),...
            'Invalid Input Argument');


            obj.fFIDToInference=containers.Map('KeyType','int32',...
            'ValueType','Any');
            obj.fScriptInfo=slci.mlutil.ScriptInfo;


            assert(nargin>0);
            if nargin==3
                assert(isequal(fieldnames(options),fieldnames(obj.fOptions)));
                obj.fOptions=options;
            elseif nargin==1
                blkHdl=[];
            end

            coderInferenceData=slci.mlutil.extractInferenceData(...
            chartUDDObject,blkHdl);
            if~isempty(coderInferenceData)
                obj.populate(coderInferenceData);
                obj.fHasInferenceData=true;
            end

        end


        function scriptTable=getScripts(aObj)
            scriptTable=aObj.fScriptInfo;
        end


        function inference=getInference(aObj)
            inference=aObj.fFIDToInference;
        end


        function rootId=getRootFunctionID(aObj)
            assert(numel(aObj.fRootFID)==1);
            rootId=aObj.fRootFID;
        end


        function ids=getFunctions(aObj)
            ids=aObj.fFIDs;
        end


        function flag=isEmpty(aObj)
            flag=isempty(aObj.getFunctions());
        end


        function hasInference=hasInferenceData(aObj)
            hasInference=aObj.fHasInferenceData;
        end

    end

    methods(Access=private)

        function populate(aObj,coderInferenceData)

            aObj.populateFIDs(coderInferenceData);

            aObj.populateScripts(coderInferenceData);

            aObj.populateFunctions(coderInferenceData);

        end


        function populateFIDs(aObj,coderInferenceData)



            rootId=coderInferenceData.RootFunctionIDs;
            assert(numel(rootId)==1);
            aObj.fRootFID=rootId;

            numFunctionIds=numel(coderInferenceData.Functions);
            fIds=1:numFunctionIds;
            assert(any(fIds==aObj.fRootFID));

            aObj.fFIDs=aObj.getFIDsToInclude(fIds,coderInferenceData);






            if(~any(aObj.fFIDs==aObj.fRootFID))
                aObj.fFIDs=[];
                aObj.fRootFID=[];
            end

        end


        function populateScripts(aObj,coderInferenceData)

            for k=aObj.fFIDs
                fid=int32(k);
                fcnInfo=coderInferenceData.Functions(fid);
                scrInfo=coderInferenceData.Scripts(fcnInfo.ScriptID);

                aObj.fScriptInfo.addFunctionName(fid,fcnInfo.FunctionName);
                aObj.fScriptInfo.addScriptID(fid,fcnInfo.ScriptID);
                aObj.fScriptInfo.addScriptText(fid,scrInfo.ScriptText);
                aObj.fScriptInfo.addScriptPath(fid,scrInfo.ScriptPath);
                aObj.fScriptInfo.addIsUserVisible(fid,scrInfo.IsUserVisible);
            end
        end


        function populateFunctions(aObj,coderInferenceData)

            for k=aObj.fFIDs
                fid=int32(k);
                assert(~isKey(aObj.fFIDToInference,fid),...
                ['Duplicate function ID ',sprintf('%ld',fid)]);
                aObj.fFIDToInference(fid)=slci.mlutil.FunctionInference(...
                fid,...
                coderInferenceData,...
                aObj.fScriptInfo);
            end
        end



        function fIdsToInclude=getFIDsToInclude(aObj,fIds,coderInferenceData)
            fIdsToInclude=[];
            for i=1:numel(fIds)
                if aObj.isFIDToInclude(fIds(i),coderInferenceData)
                    fIdsToInclude=[fIdsToInclude,fIds(i)];%#ok<AGROW>
                end
            end
        end





        function bool=isFIDToInclude(aObj,fId,coderInferenceData)
            bool=false;
            fcnInfo=coderInferenceData.Functions(fId);
            if fcnInfo.ScriptID>0&&...
                ~fcnInfo.IsExtrinsic&&...
                ~fcnInfo.IsAutoExtrinsic&&...
                isempty(fcnInfo.ClassName)
                scriptInfo=coderInferenceData.Scripts(fcnInfo.ScriptID);
                if scriptInfo.IsUserVisible||...
                    aObj.fOptions.IncludeNonUserVisibleFunctions
                    scrPath=scriptInfo.ScriptPath;
                    [~,~,fileExt]=fileparts(scrPath);
                    if~strcmp(fileExt,'.p')
                        bool=true;
                    end
                end
            end
        end

    end

end
