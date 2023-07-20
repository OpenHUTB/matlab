classdef(Sealed)CodeView_HDL<simulinkcoder.internal.CodeViewBase



    properties(Constant)
        Tag='CodeView_HDL';
    end
    methods
        function title=getTitle(obj)
            title=message('SimulinkCoderApp:report:CodeView_HDL_Title').getString;
        end
        function cv=createSource(obj)
            cv=simulinkcoder.internal.HDLCodeView(obj.studio);
        end
    end
end

