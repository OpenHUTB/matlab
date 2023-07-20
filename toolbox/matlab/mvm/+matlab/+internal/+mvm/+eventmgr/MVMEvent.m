

classdef(Sealed=true)MVMEvent<handle



    properties(Hidden=true,SetAccess=private)


        EventTags cell

        FlattenedDetailsFieldsCache string="<init>";
    end
    properties(Hidden=true,Dependent=true)

        FlattenedDetailsFields string
    end

    properties(Hidden=false,SetAccess=private)


        Details struct
    end

    methods(Static=true)
        function listener=subscribe(eventTag,functionHandle)











            listener=matlab.internal.mvm.eventmgr.MVMListener(eventTag,functionHandle);



            fh=@(eventTags,details)matlab.internal.mvm.eventmgr.MVMEvent.invokeListener(listener,eventTags,details);


            id=matlab.internal.mvm.eventmgr.subscribe(eventTag,fh);
            listener.WhenDestroyed=@()matlab.internal.mvm.eventmgr.unsubscribe(id);
        end
    end

    methods

        function value=get.FlattenedDetailsFields(obj)
            if obj.FlattenedDetailsFieldsCache=="<init>"
                obj.FlattenedDetailsFieldsCache=flattenFields(obj.Details,".Details");
            end
            value=obj.FlattenedDetailsFieldsCache;
        end

        function result=subsref(obj,S)
            try
                result=builtin('subsref',obj,S);
            catch
                try
                    result=getByName(obj,S);
                catch E
                    throwAsCaller(E);
                end
            end
        end

        function value=getByName(obj,S)




            realS=S;
            if~isempty(S)&&S(1).type=="."
                lastDotIdx=strlength([S.type])-strlength(strip([S.type],"left","."));
                dotIndexingStr=dotSubsToStr(S(1:lastDotIdx));
                flattenedFieldsIdx=find(obj.FlattenedDetailsFields.endsWith(dotIndexingStr),1);
                if~isempty(flattenedFieldsIdx)
                    realDotIndexingStr=obj.FlattenedDetailsFields(flattenedFieldsIdx);
                    realS=[dotStringToSubs(realDotIndexingStr{1}(2:end)),S(lastDotIdx+1:end)];
                end
            end
            value=builtin('subsref',obj,realS);
        end
    end

    methods(Access=private)
        function e=MVMEvent(tags,details)
            e.EventTags=tags;
            e.Details=details;
        end
    end

    methods(Static=true,Access=private)
        function invokeListener(listener,eventTags,details)


            try

                if isvalid(listener)...
                    &&listener.Enabled...
                    &&(listener.Recursive||(0==listener.ExecutionDepth))...
                    &&~isempty(listener.Callback)
                    noLongerExecuting=onCleanup(@()matlab.internal.mvm.eventmgr.MVMEvent.updateExecutionDepth(listener,-1));
                    matlab.internal.mvm.eventmgr.MVMEvent.updateExecutionDepth(listener,1);
                    mvmevent=matlab.internal.mvm.eventmgr.MVMEvent(eventTags,details);
                    listener.Callback(mvmevent);
                end
            catch E
                warning(E.identifier,'%s',E.message);
            end
        end

        function updateExecutionDepth(listener,depthToAdd)
            if isvalid(listener)
                listener.ExecutionDepth=listener.ExecutionDepth+depthToAdd;
            end
        end

    end
end

function[flattenedFields,queue]=flattenFields(s,parentFieldName,queue)




    flattenedFields=strings(0,1);
    if~isstruct(s)
        return;
    end
    if nargin<3
        queue=[];
    end
    prefix=parentFieldName+".";
    flds=fieldnames(s);
    for idx=1:numel(flds)
        currField=flds{idx};
        queue=[queue;struct('struct',{s.(currField)},'path',prefix+currField)];%#ok<AGROW>
    end
    flattenedFields=prefix+flds;
    while~isempty(queue)
        [currFlattenedFields,queue]=flattenFields(queue(1).struct,queue(1).path,queue(2:end));
        flattenedFields=[flattenedFields;currFlattenedFields];%#ok<AGROW>
    end
end

function str=dotSubsToStr(subs)
    subsCell=struct2cell(subs);
    str=[subsCell{:}];
end

function subs=dotStringToSubs(str)
    subsCell=strsplit(str,'.');
    subsCell(2,:)={'.'};
    subsCell=flipud(subsCell);
    subs=cell2struct(subsCell,{'type','subs'})';
end
