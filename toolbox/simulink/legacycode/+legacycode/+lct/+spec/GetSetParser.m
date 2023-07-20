classdef GetSetParser<legacycode.lct.spec.GlobalParser





    methods(Access=protected)
        function validateDataKind(obj)

            switch obj.DataKind
            case{legacycode.lct.spec.DataKind.Parameter,legacycode.lct.spec.DataKind.DSM}

                return;
            otherwise
                error(message('Simulink:tools:LCTGetSetIODSMParamOnly',obj.OriginalVarSpecExpression));
            end
        end

        function globalDataObj=parseAfterColon(obj)



            [workspaceName,obj.VarSpecExpression]=strtok(obj.VarSpecExpression);
            if isempty(workspaceName)
                error(message('Simulink:tools:LCTGetSetNeedWorkspaceName',obj.OriginalVarSpecExpression));
            end

            [firstExpression,obj.VarSpecExpression]=strtok(obj.VarSpecExpression);
            if isempty(firstExpression)
                error(message('Simulink:tools:LCTGetSetNeedGetMethod',obj.OriginalVarSpecExpression));
            end

            switch obj.DataKind
            case legacycode.lct.spec.DataKind.Parameter
                readExpression=firstExpression;
                writeExpression='';
            case legacycode.lct.spec.DataKind.DSM
                [secondExpression,obj.VarSpecExpression]=strtok(obj.VarSpecExpression);
                readExpression=firstExpression;
                writeExpression=secondExpression;
            otherwise

                assert(false,'Only Support DataKind of Parameter/DSM');
            end

            argSpec=obj.getFunctionArgObject;
            globalDataObj=legacycode.lct.spec.GetSetVar(argSpec,...
            readExpression,...
            writeExpression,...
            obj.OriginalIndex,...
            workspaceName);
        end
    end
end