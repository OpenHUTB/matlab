


classdef TransitionObject<slci.results.StateflowObject

    properties(SetAccess=protected,GetAccess=protected)
        fIsTrivial=false;




        fDestSubsystems={};
    end

    methods(Access=public,Hidden=true)


        function obj=TransitionObject(aSID,aParent,aName)
            if nargin==0
                DAStudio.error('Slci:results:DefaultConstructorError',...
                'TRANSITIONOBJECT');
            end
            aKey=slci.results.TransitionObject.constructKey(aSID);
            obj@slci.results.StateflowObject(aKey,aSID,aName);
            obj.setParent(aParent);
        end

        function setIsTrivial(obj,isTrivial)
            if islogical(isTrivial)
                obj.fIsTrivial=isTrivial;
                if isTrivial
                    obj.setIsVirtual();
                end
            else
                DAStudio.error('Slci:results:InvalidInputArg');
            end
        end

        function isTrivial=getIsTrivial(obj)
            isTrivial=obj.fIsTrivial;
        end

        function setDestSubSystems(obj,destSubsystems)
            if iscell(destSubsystems)
                obj.fDestSubsystems=slci.results.union(obj.fDestSubsystems,...
                destSubsystems);
            else
                DAStudio.error('Slci:results:InvalidInputArg');
            end
        end

        function destSubsystems=getDestSubSystems(obj)
            destSubsystems=obj.fDestSubsystems;
        end

        function aDispName=getDispName(obj,datamgr)
            reader=datamgr.getReader('BLOCK');
            parentObj=reader.getObject(obj.getParent());
            parentName=parentObj.getDispName(datamgr);
            fullName=[parentName,'/',obj.getName()];
            aDispName=slci.internal.encodeString(fullName,'all','encode');
        end


        function computeStatus(obj,varargin)
            computeStatus@slci.results.StateflowObject(obj,varargin);
        end
    end

    methods(Access=private)
        function setIsVirtual(obj)
            obj.addPrimVerSubstatus('VIRTUAL');
            obj.addPrimTraceSubstatus('VIRTUAL');
        end

    end

    methods(Access=public,Static=true,Hidden=true)

        function key=constructKey(aSID)
            key=aSID;
        end

    end


end
