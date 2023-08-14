classdef(Sealed)CodeView_C<simulinkcoder.internal.CodeViewBase



    properties(Constant)
        Tag='CodeView';
    end
    methods
        function title=getTitle(obj)
            title=message('SimulinkCoderApp:report:CodeView_C_Title').getString;
        end
        function cv=createSource(obj)
            cv=simulinkcoder.internal.CodeView(obj.studio);
        end
    end
end

