

classdef StateflowFunctionCallGraph<handle


    properties(Access=private)
        fSfFnCallMap=[];
    end

    methods(Access=protected)

        function out=dfsVisit(aObj,fnSIDs,vidx,visited,srcidx)
            out=false;
            if visited(vidx)
                if strcmpi(fnSIDs{vidx},fnSIDs{srcidx})
                    out=true;
                end
                return;
            else
                visited(vidx)=1;
                v=aObj.getChildren(fnSIDs{vidx});
                for j=1:numel(v)
                    vidx=strcmpi(fnSIDs,v{j});
                    if~any(vidx)
                        continue;
                    end
                    out=aObj.dfsVisit(fnSIDs,vidx,visited,srcidx);
                    if out
                        return;
                    end
                end
            end
        end
    end

    methods(Access=public,Hidden)

        function g=getGraph(this)
            g=this.fSfFnCallMap;
        end
    end

    methods


        function obj=StateflowFunctionCallGraph()
            obj.fSfFnCallMap=containers.Map('KeyType','char',...
            'ValueType','any');
        end


        function addDirectedEdge(aObj,aParentGfSfId,aChildGfSfId)

            parentGfnUDDObj=idToHandle(sfroot,aParentGfSfId);
            parentGfnSID=Simulink.ID.getStateflowSID(parentGfnUDDObj,...
            parentGfnUDDObj.Chart.Path);

            childGfnUDDObj=idToHandle(sfroot,aChildGfSfId);
            childGfnSID=Simulink.ID.getStateflowSID(childGfnUDDObj,...
            childGfnUDDObj.Chart.Path);

            if aObj.fSfFnCallMap.isKey(parentGfnSID)
                hasChild=any(strcmpi(aObj.fSfFnCallMap(parentGfnSID),childGfnSID));
                if~hasChild
                    newvalues=[aObj.fSfFnCallMap(parentGfnSID),childGfnSID];
                    aObj.fSfFnCallMap(parentGfnSID)=newvalues;
                end
            else
                aObj.fSfFnCallMap(parentGfnSID)={childGfnSID};
            end
        end


        function out=hasSource(aObj,fnSID)
            out=aObj.fSfFnCallMap.isKey(fnSID);
        end


        function out=getChildren(aObj,fnSID)
            out=aObj.fSfFnCallMap(fnSID);
        end


        function out=isRecursive(aObj,srckey)
            out=false;
            fnSIDs=aObj.fSfFnCallMap.keys();
            if aObj.hasSource(srckey)
                uidx=strcmpi(fnSIDs,srckey);
                v=aObj.getChildren(srckey);
                for j=1:numel(v)
                    visited=zeros(1,numel(fnSIDs));
                    visited(uidx)=1;
                    vidx=strcmpi(fnSIDs,v{j});






                    if~any(vidx)
                        continue;
                    end


                    out=aObj.dfsVisit(fnSIDs,vidx,visited,uidx);
                    if out
                        break;
                    end
                end
            end
        end
    end
end
