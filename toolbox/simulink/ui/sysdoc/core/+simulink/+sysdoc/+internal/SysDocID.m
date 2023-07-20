classdef SysDocID




















    properties(Constant,Access=private)

        SLROOT=slroot;
    end

    properties(SetAccess=immutable)
SysDocIDString
    end

    properties(GetAccess=private,SetAccess=immutable)
EndOfSID
    end

    properties(Access=private)
ModelName
    end

    properties(Dependent,SetAccess=private)
SID
HasParent
Parent
    end

    methods(Access=private)
        function obj=SysDocID(sid)
            import simulink.sysdoc.internal.SysDocID

            assert(ischar(sid))
            assert(~isempty(sid));
            assert(isrow(sid));

            [sysdocIDString,endOfSID,modelName]=...
            SysDocID.constructPropertiesFromSID(sid);

            obj.SysDocIDString=sysdocIDString;
            obj.EndOfSID=endOfSID;
            obj.ModelName=modelName;
        end
    end

    methods(Static)
        function sysDocID=getSysDocIDFromSID(sid)
            sysDocID=simulink.sysdoc.internal.SysDocID(sid);
        end

        function sysDocID=getSysDocIDFromEditor(editor)
            import simulink.sysdoc.internal.SysDocID

            assert(isa(editor,'GLUE2.Editor'));
            assert(isscalar(editor));

            hid=editor.getHierarchyId;
            sid=SysDocID.getSIDFromEditorHID(hid);

            sysDocID=SysDocID.getSysDocIDFromSID(sid);
        end
    end

    methods
        function sid=get.SID(obj)
            sid=[obj.ModelName,obj.EndOfSID];
            assert(Simulink.ID.isValid(sid));
        end

        function parentSysDocID=get.Parent(obj)
            import simulink.sysdoc.internal.SysDocID

            sid=obj.SID;

            parentSID=Simulink.ID.getParent(sid);
            if isempty(parentSID)
                parentSysDocID=SysDocID.empty();
            else
                parentSysDocID=obj.getSysDocIDFromSID(parentSID);
            end
        end
    end

    methods(Static,Access=private)
        function[sysdocIDString,endOfSID,modelName]=constructPropertiesFromSID(sid)

            import simulink.sysdoc.internal.SysDocID

            assert(Simulink.ID.isValid(sid));

            idPrefix='id_';
            sidSeparator=':';
            rootSID='0';

            firstIdx=find(sid==sidSeparator,1);

            if isempty(firstIdx)
                endOfSID='';
                sysdocIDString=strcat(idPrefix,rootSID);
                modelName=sid;
            else
                endOfSID=sid(firstIdx:end);
                sysdocIDString=strcat(idPrefix,sid(firstIdx+1:end));
                sysdocIDString=urlencode(sysdocIDString);
                modelName=sid(1:firstIdx-1);
            end

            assert(~isempty(sysdocIDString))
            assert(~isempty(modelName))

            assert(ischar(sysdocIDString));
            assert(ischar(endOfSID));
            assert(ischar(modelName));

            assert(bdIsLoaded(modelName));
            assert(Simulink.ID.isValid([modelName,endOfSID]));
        end

    end

    methods(Static,Hidden=true)
        function sid=getSIDFromEditorHID(hid)



            import simulink.sysdoc.internal.SysDocID

            assert(isa(hid,'GLUE2.HierarchyId'));
            assert(isscalar(hid));



            assert(GLUE2.HierarchyService.isDiagram(hid));

            slHandle=SLM3I.SLCommonDomain.getSLHandleForHID(hid);

            m3iWrapper=GLUE2.HierarchyService.getM3IObject(hid);
            m3iObj=m3iWrapper.temporaryObject;

            isSimulink=isa(m3iObj,'SLM3I.Diagram');
            isStateflow=isa(m3iObj,'StateflowDI.Subviewer');

            if isSimulink
                sid=Simulink.ID.getSID(slHandle);
            elseif isStateflow
                sfObj=SysDocID.SLROOT.idToHandle(double(m3iObj.backendId));












                sid=Simulink.ID.getStateflowSID(sfObj,slHandle);
            else
                error('Unknown hid type')
            end

        end
    end
end


