classdef simscapeBlockParameterSet<handle



    events(ListenAccess=public,NotifyAccess=private)
isChanged
    end

    properties(SetAccess=private,GetAccess=public)
        names string
values
    end

    methods(Access=public)
        function theSimscapeBlockParameterSet=simscapeBlockParameterSet
        end

        function addParameter(theSimscapeBlockParameterSet,aName,aValue)
            if~ischar(aName)&&~isstring(aName)
                pm_error('physmod:ee:library:NotString',getString(message('physmod:ee:library:comments:utils:simscapeBlockParameterSet:error_ParameterName')));
            end
            ndex=getParameterIndex(theSimscapeBlockParameterSet,string(aName));
            if isempty(ndex)
                theSimscapeBlockParameterSet.names(end+1)=string(aName);
                theSimscapeBlockParameterSet.values{end+1}=aValue;
                notify(theSimscapeBlockParameterSet,'isChanged');
            else
                currentValue=theSimscapeBlockParameterSet.values{ndex};
                if~(isequal(currentValue,aValue)&&isa(currentValue,class(aValue)))
                    theSimscapeBlockParameterSet.values{ndex}=aValue;
                    notify(theSimscapeBlockParameterSet,'isChanged');
                end
            end
        end

        function deleteParameter(theSimscapeBlockParameterSet,aName)
            if~ischar(aName)&&~isstring(aName)
                pm_error('physmod:ee:library:NotString',getString(message('physmod:ee:library:comments:utils:simscapeBlockParameterSet:error_ParameterName')));
            end
            ndex=theSimscapeBlockParameterSet.getParameterIndex(string(aName));
            if isempty(ndex)
                pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:simscapeBlockParameterSet:error_ParameterName')));
            else
                theSimscapeBlockParameterSet.names(ndex)=[];
                theSimscapeBlockParameterSet.values(ndex)=[];
                notify(theSimscapeBlockParameterSet,'isChanged');
            end
        end

        function updateBlockParameters(theSimscapeBlockParameterSet,aBlock)
            if ishandle(aBlock)
                name=get_param(aBlock,'Name');
                parent=get_param(aBlock,'Parent');
                blockName=[parent,'/',name];
            else
                blockName=aBlock;
            end
            for ii=1:length(theSimscapeBlockParameterSet.names)
                if isfield(get_param(blockName,'ObjectParameters'),theSimscapeBlockParameterSet.names{ii})
                    set_param(blockName,theSimscapeBlockParameterSet.names{ii},theSimscapeBlockParameterSet.values{ii});
                else
                    warning(getString(message('physmod:ee:library:comments:utils:simscapeBlockParameterSet:warning_ParameterNotExist',theSimscapeBlockParameterSet.names{ii})));
                end
            end
        end
    end

    methods(Access=private)
        function index=getParameterIndex(theSimscapeBlockParameterSet,aName)
            if~ischar(aName)&&~isstring(aName)
                pm_error('physmod:ee:library:NotString',getString(message('physmod:ee:library:comments:utils:simscapeBlockParameterSet:error_ParameterName')));
            end
            index=[];
            for ii=1:length(theSimscapeBlockParameterSet.names)
                if theSimscapeBlockParameterSet.names(ii)==string(aName)
                    index(end+1)=ii;%#ok<AGROW>
                end
            end
        end
    end
end