classdef HGObjectInfo<matlab.mixin.SetGet

    properties(Access=public)
        handle=[];
props
    end




    methods(Access=public)
        function info=getStruct(obj)
            info=arrayfun(@(infoObj)struct('handle',infoObj.convertHandleToDouble(),...
            'props',infoObj.props.getStruct()),obj);
        end
    end

    methods(Access=protected)
        function handleValue=convertHandleToDouble(obj)

            if isempty(obj.handle)
                handleValue=-1;
            else
                handleValue=double(obj.handle);
            end
        end


        function validHandle=returnValidHandle(obj,h)
            if ishandle(h)
                validHandle=handle(h);
            else
                validHandle=obj.getEmptyHandle();
            end
        end
    end




    methods(Access=public)
        function setProps(obj,props)
            if numel(props)==1

                arrayfun(@(infoObj)infoObj.props.set(props),obj);
            else

                arrayfun(@(infoObj,objProps)set(infoObj.props,objProps),obj,props);
            end
        end
    end




    methods(Static,Access=public)
        function convertedLabelString=convertLabelCellArray(labelString)
            if iscell(labelString)&&~isempty(labelString)
                convertedLabelString=labelString{1};
                for i=2:numel(labelString)
                    convertedLabelString=[convertedLabelString,newline,labelString{i}];%#ok<AGROW> 
                end
            else
                convertedLabelString=labelString;
            end
        end
    end

end