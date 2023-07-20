



classdef ScriptInfo<handle

    properties(Access=private)


        fFIDToFunctionName=[];


        fFIDToScriptID=[];


        fFIDToScriptText=[];


        fFIDToScriptPath=[];


        fFIDToIsUserVisible=[];
    end

    methods


        function flag=hasFunctionName(aObj,fid)
            flag=isKey(aObj.fFIDToFunctionName,fid);
        end


        function fname=getFunctionName(aObj,fid)
            assert(aObj.hasFunctionName(fid),...
            ['Invalid Function ID ',sprintf('%ld',fid)]);
            fname=aObj.fFIDToFunctionName(fid);
        end


        function flag=hasScriptID(aObj,fid)
            flag=isKey(aObj.fFIDToScriptID,fid);
        end


        function sid=getScriptID(aObj,fid)
            assert(aObj.hasScriptID(fid),...
            ['Invalid Function ID ',sprintf('%ld',fid)]);
            sid=aObj.fFIDToScriptID(fid);
        end


        function flag=hasScriptText(aObj,fid)
            flag=isKey(aObj.fFIDToScriptText,fid);
        end


        function text=getScriptText(aObj,fid)
            assert(aObj.hasScriptText(fid),...
            ['Invalid Function ID ',sprintf('%ld',fid)]);
            text=aObj.fFIDToScriptText(fid);
        end


        function flag=hasScriptPath(aObj,fid)
            flag=isKey(aObj.fFIDToScriptPath,fid);
        end


        function path=getScriptPath(aObj,fid)
            assert(aObj.hasScriptPath(fid),...
            ['Invalid Function ID ',sprintf('%ld',fid)]);
            path=aObj.fFIDToScriptPath(fid);
        end


        function flag=hasUserVisible(aObj,fid)
            flag=isKey(aObj.fFIDToIsUserVisible,fid);
        end


        function userVisible=isUserVisible(aObj,fid)
            assert(aObj.hasUserVisible(fid),...
            ['Invalid Function ID ',sprintf('%ld',fid)]);
            userVisible=aObj.fFIDToIsUserVisible(fid);
        end


        function fcnList=getFunctions(aObj)
            fcnList=aObj.getUnion(cell2mat(keys(aObj.fFIDToFunctionName)),...
            cell2mat(keys(aObj.fFIDToScriptID)),...
            cell2mat(keys(aObj.fFIDToScriptText)),...
            cell2mat(keys(aObj.fFIDToScriptPath)),...
            cell2mat(keys(aObj.fFIDToIsUserVisible)));
        end


        function[varargout]=getUnion(~,varargin)
            unionArr=varargin{1};
            for i=2:numel(varargin)
                unionArr=union(unionArr,varargin{i});
            end
            varargout{1}=unionArr;
        end

    end

    methods


        function obj=ScriptInfo()

            obj.fFIDToFunctionName=containers.Map('KeyType','int32',...
            'ValueType','Any');
            obj.fFIDToScriptID=containers.Map('KeyType','int32',...
            'ValueType','Any');
            obj.fFIDToScriptText=containers.Map('KeyType','int32',...
            'ValueType','Any');
            obj.fFIDToScriptPath=containers.Map('KeyType','int32',...
            'ValueType','Any');
            obj.fFIDToIsUserVisible=containers.Map('KeyType','int32',...
            'ValueType','Any');
        end

    end

    methods(Access=public)


        function addScriptID(aObj,fid,sid)
            assert(~aObj.hasScriptID(fid));
            aObj.fFIDToScriptID(fid)=sid;
        end


        function addScriptText(aObj,fid,scriptText)
            assert(~aObj.hasScriptText(fid));
            aObj.fFIDToScriptText(fid)=scriptText;
        end


        function addFunctionName(aObj,fid,functionName)
            assert(~aObj.hasFunctionName(fid));
            aObj.fFIDToFunctionName(fid)=functionName;
        end


        function addScriptPath(aObj,fid,scriptPath)
            assert(~aObj.hasScriptPath(fid));
            aObj.fFIDToScriptPath(fid)=scriptPath;
        end


        function addIsUserVisible(aObj,fid,isUserVisible)
            assert(~aObj.hasUserVisible(fid));
            aObj.fFIDToIsUserVisible(fid)=isUserVisible;
        end

    end

end
