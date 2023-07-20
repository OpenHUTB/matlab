



classdef MLScript<handle

    properties(Access=private)






        fScriptInfo=[];


        fRootFunctionID=[];


        fFIDs=[];
    end

    methods

        function rootId=getRootFunctionID(aObj)
            assert(numel(aObj.fRootFunctionID)==1,...
            ' Invalid root function ID');
            rootId=aObj.fRootFunctionID;
        end


        function scriptInfo=getScripts(aObj)
            scriptInfo=aObj.fScriptInfo;
        end


        function fids=getFIDs(aObj)
            fids=aObj.fFIDs;
        end


        function flag=isEmpty(aObj)
            flag=isempty(aObj.fFIDs);
        end

    end

    methods





        function obj=MLScript(chartObject,mlData)

            if mlData.hasInferenceData()&&~mlData.isEmpty()
                obj.populateFromCoderData(mlData);
            else



                obj.populateFromChartObject(chartObject);
            end

        end

    end

    methods(Access=private)


        function populateFromCoderData(aObj,mlData)

            assert(~mlData.isEmpty());

            aObj.fScriptInfo=slci.mlutil.ScriptInfo;
            mlscripts=mlData.getScripts();

            assert(isempty(aObj.fFIDs));
            aObj.fFIDs=mlscripts.getFunctions();

            numFIDs=numel(aObj.fFIDs);
            for k=1:numFIDs

                fid=aObj.fFIDs(k);



                assert(mlscripts.isUserVisible(fid));
                aObj.fScriptInfo.addIsUserVisible(...
                fid,...
                true);

                assert(mlscripts.hasScriptID(fid));
                aObj.fScriptInfo.addScriptID(...
                fid,...
                mlscripts.getScriptID(fid));

                assert(mlscripts.hasScriptText(fid));
                aObj.fScriptInfo.addScriptText(...
                fid,...
                mlscripts.getScriptText(fid));

                assert(mlscripts.hasFunctionName(fid));
                aObj.fScriptInfo.addFunctionName(...
                fid,...
                mlscripts.getFunctionName(fid));

                assert(mlscripts.hasScriptPath(fid));
                aObj.fScriptInfo.addScriptPath(...
                fid,...
                mlscripts.getScriptPath(fid));

            end
            aObj.fRootFunctionID=mlData.getRootFunctionID();

        end

        function populateFromChartObject(aObj,chartObject)


            fid=int32(1);
            aObj.fRootFunctionID=fid;
            aObj.fFIDs=fid;


            aObj.fScriptInfo=slci.mlutil.ScriptInfo;

            aObj.fScriptInfo.addFunctionName(fid,'');
            aObj.fScriptInfo.addScriptID(fid,int32(1));
            aObj.fScriptInfo.addScriptText(fid,chartObject.script);
            scriptPath=['#',Simulink.ID.getStateflowSID(chartObject)];
            aObj.fScriptInfo.addScriptPath(fid,scriptPath);
            aObj.fScriptInfo.addIsUserVisible(fid,true);
        end

    end


end
