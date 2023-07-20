classdef ApplicationService<matlab.mixin.SetGet



    properties
        Name=''
        Library=''
        LinkFlags=''
    end
    methods(Access={?codertarget.targetservices.TargetService})
        function h=ApplicationService(structVal)
            if isstruct(structVal)&&isfield(structVal,'library')
                h.Library=structVal.library;
                h.Name=structVal.name;
                if isfield(structVal,'linkflags')
                    h.LinkFlags=structVal.linkflags;
                end
            else
                DAStudio.error('codertarget:targetapi:StructureInputInvalid_MissingReqdField','ApplicationService','''library'', ''name''');
            end
        end
    end
    methods(Hidden)
        function out=toStruct(hObj)
            p=struct;
            for jj=1:numel(hObj)
                upperFieldNames=properties('codertarget.targetservices.ApplicationService');
                lowerFieldNames=lower(upperFieldNames);
                for ii=1:numel(upperFieldNames)
                    p(jj).(lowerFieldNames{ii})=hObj(jj).(upperFieldNames{ii});
                end
            end
            out=p;
        end
    end

    methods
        function obj=set.Name(obj,val)
            if~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidStringProperty','Name');
            end
            obj.Name=val;
        end
        function obj=set.Library(obj,val)
            if~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidStringProperty','Library');
            end
            obj.Library=val;
        end
        function obj=set.LinkFlags(obj,val)
            if~iscell(val)&&~ischar(val)
                DAStudio.error('codertarget:targetapi:InvalidCellProperty','LinkFlags');
            elseif iscell(val)
                val=coder.make.internal.cell2str(val);
            end
            obj.LinkFlags=val;
        end
    end
end