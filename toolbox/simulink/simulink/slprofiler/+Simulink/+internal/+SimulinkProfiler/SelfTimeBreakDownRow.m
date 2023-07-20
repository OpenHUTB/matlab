classdef SelfTimeBreakDownRow<handle
    properties
        timeStr;
        location;
        numCalls;
    end

    properties(Transient)
        execNodeLabel=DAStudio.message('Simulink:Profiler:ExecNode');
        timeLabel=DAStudio.message('Simulink:Profiler:Time');
        callsLabel=DAStudio.message('Simulink:Profiler:Calls');
    end

    methods
        function this=SelfTimeBreakDownRow(timeStr,location,numCalls)
            this.timeStr=timeStr;
            this.location=location;
            this.numCalls=sprintf('%d',numCalls);
        end

        function propValue=getPropValue(obj,propName)
            switch propName
            case obj.execNodeLabel
                propValue=obj.location;
            case obj.timeLabel
                propValue=obj.timeStr;
            case obj.callsLabel
                propValue=obj.numCalls;
            otherwise
                propValue='default';
            end
        end


        function isValid=isValidProperty(obj,propName)
            switch propName
            case obj.timeLabel
                isValid=true;
            case obj.execNodeLabel
                isValid=true;
            case obj.callsLabel
                isValid=true;
            otherwise
                isValid=false;
            end
        end

        function tf=isReadonlyProperty(~,~)
            tf=true;
        end

        function ch=getChildren(~,~)
            ch=[];
        end


        function tf=isHierarchical(~)
            tf=false;
        end

    end

end