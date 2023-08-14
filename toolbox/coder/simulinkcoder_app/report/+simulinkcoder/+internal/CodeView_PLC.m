classdef(Sealed)CodeView_PLC<simulinkcoder.internal.CodeViewBase



    properties(Constant)
        Tag='CodeView_PLC';
    end
    methods
        function title=getTitle(obj)
            title=message('SimulinkCoderApp:report:CodeView_PLC_Title').getString;
        end
        function cv=createSource(obj)
            cv=simulinkcoder.internal.CodeView(obj.studio);
        end
    end
end

