classdef GlobalVarParser<legacycode.lct.spec.GlobalParser






    methods(Access=protected)
        function validateDataKind(obj)

            import legacycode.lct.spec.DataKind;
            switch obj.DataKind
            case{DataKind.Input,DataKind.Output,DataKind.Parameter,DataKind.DSM}

                return;
            otherwise
                error(message('Simulink:tools:LCTGlobalIOInputsOutputsOnly',obj.OriginalVarSpecExpression));
            end
        end


        function globalDataObj=parseAfterColon(obj)




            workspaceName='';
            if obj.IsDSM||obj.IsParam
                [workspaceName,obj.VarSpecExpression]=strtok(obj.VarSpecExpression);
            end


            [exprAfterColon,obj.VarSpecExpression]=strtok(obj.VarSpecExpression);
            isExtern=strcmp(exprAfterColon,'extern');
            if isExtern
                [varName,obj.VarSpecExpression]=strtok(obj.VarSpecExpression);
            else
                varName=exprAfterColon;
            end

            isReadOnlyDSM=false;
            if obj.IsDSM
                readOnlyTag=strtok(obj.VarSpecExpression);
                if strcmpi(readOnlyTag,'readonly')
                    isReadOnlyDSM=true;
                elseif~isempty(readOnlyTag)

                    error(message('Simulink:tools:LCTGlobalDSMInvalidReadOnlyTag',obj.OriginalVarSpecExpression,varName));
                end
            end



            isPointer=obj.isPointer(varName);
            if isPointer
                varName=obj.removePointer(varName);
            end


            if isPointer&&~isExtern
                error(message('Simulink:tools:LCTGlobalIOPointerNoExtern',obj.OriginalVarSpecExpression));
            end

            argSpec=obj.getFunctionArgObject;


            if obj.IsDSM
                globalDataObj=legacycode.lct.spec.GlobalDSM(argSpec,...
                varName,isExtern,isPointer,obj.OriginalIndex,workspaceName,...
                isReadOnlyDSM);
            elseif obj.IsParam
                globalDataObj=legacycode.lct.spec.GlobalDSM(argSpec,...
                varName,isExtern,isPointer,obj.OriginalIndex,workspaceName,...
                true);
            else
                globalDataObj=legacycode.lct.spec.GlobalVar(argSpec,...
                varName,isExtern,isPointer,obj.OriginalIndex);
            end
        end
    end

    methods(Static,Access=private)
        function isPointer=isPointer(argExpr)
            out=regexp(argExpr,'^\s*\*\S*\s*$','once');
            isPointer=~isempty(out);
        end
        function str=removePointer(argExpr)
            str=regexprep(argExpr,'^\s*\*','');
        end
    end
end