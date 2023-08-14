













classdef(Abstract)HDLTargetDriverBase<handle

    properties

        hD=[];

    end


    properties(Access=protected)


        WorkflowName='';


        CurrentDir='';


        hPlatformList=[];


        hRDList=[];

    end

    methods

        function obj=HDLTargetDriverBase(hDIDriver,workflowName)

            if nargin<2
                workflowName='';
            end

            obj.hD=hDIDriver;
            obj.WorkflowName=workflowName;

        end

    end

    methods


        function workflowName=getWorkflowName(obj)
            workflowName=obj.WorkflowName;
        end

    end


    methods



        function rd=getReferenceDesign(obj)
            rd='';
            if obj.isRDListLoaded
                rd=obj.hRDList.getReferenceDesign;
            end
        end
        function setReferenceDesign(obj,rd)
            if obj.isRDListLoaded
                obj.hRDList.setReferenceDesign(rd);
            end
        end
        function rds=getReferenceDesignAll(obj)
            rds={''};
            if obj.isRDListLoaded
                rds=obj.hRDList.getReferenceDesignAll;
            end
        end

        function ver=getRDToolVersion(obj)
            ver='';
            if obj.isRDListLoaded
                ver=obj.hRDList.getRDToolVersion;
            end
        end
        function setRDToolVersion(obj,rd)
            if obj.isRDListLoaded
                obj.hRDList.setRDToolVersion(rd);
            end
        end
        function verList=getRDToolVersionAll(obj)
            verList={''};
            if obj.isRDListLoaded
                verList=obj.hRDList.getRDToolVersionAll;
            end
        end
        function isMatch=isRDToolVersionMatch(obj)
            isMatch=false;
            if obj.isRDListLoaded
                isMatch=obj.hRDList.isRDToolVersionMatch;
            end
        end

        function ignore=getIgnoreRDToolVersionMismatch(obj)
            ignore=false;
            if obj.isRDListLoaded
                ignore=obj.hRDList.getIgnoreRDToolVersionMismatch;
            end
        end
        function setIgnoreRDToolVersionMismatch(obj,ignore)
            if obj.isRDListLoaded
                obj.hRDList.setIgnoreRDToolVersionMismatch(ignore);
            end
        end

        function rdPath=getReferenceDesignPath(obj)
            rdPath='';
            if obj.isRDListLoaded
                rdPath=obj.hRDList.getReferenceDesignPath;
            end
        end
        function setReferenceDesignPath(obj,rdPath)%#ok<INUSD>
        end
        function isNeed=needReferenceDesignPath(~)
            isNeed=false;
        end

        function hRD=getReferenceDesignPlugin(obj)
            hRD=[];
            if obj.isRDListLoaded
                hRD=obj.hRDList.getRDPlugin;
            end
        end

        function ret=isRDListLoaded(obj)
            ret=~isempty(obj.hRDList);
        end
        function validateCell=validateRDPlugin(obj)
            validateCell=obj.hRDList.validateRDPlugin;
        end

        function reloadPlatformList(obj)
            obj.hPlatformList.buildAvailablePlatformList;
        end

    end


    methods

        function lockCurrentDir(obj)
            obj.CurrentDir=pwd;
        end
        function dir=getCurrentDir(obj)
            dir=obj.CurrentDir;
        end


        function setIPPlatformList(obj,hPlatformList)
            obj.hPlatformList=hPlatformList;
        end
        function boardList=getIPPlatformNameList(obj)
            boardList=obj.hPlatformList.getNameList;
        end
        function[isIn,hP]=isInIPPlatformList(obj,boardName)
            [isIn,hP]=obj.hPlatformList.isInList(boardName);
        end
        function boardName=getBoardName(obj)
            boardName=obj.hD.get('Board');
        end
        function hTurnkey=getTurnkeyObject(obj)
            hTurnkey=obj.hD.hTurnkey;
        end
        function hBoard=getBoardObject(obj)
            hBoard=obj.getTurnkeyObject.hBoard;
        end
    end

end
