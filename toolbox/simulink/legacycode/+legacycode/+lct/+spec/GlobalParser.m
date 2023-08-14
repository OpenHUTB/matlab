classdef(Abstract)GlobalParser<handle








    properties(SetAccess=protected)
        OriginalVarSpecExpression char
        OriginalIndex double


        PortId char
        DataType char
        DataKind legacycode.lct.spec.DataKind=legacycode.lct.spec.DataKind.Unknown
    end

    properties(Access=protected)
        VarSpecExpression char
    end

    methods(Abstract,Access=protected)
        validateDataKind(obj)
        parseAfterColon(obj)
    end

    properties(Dependent,SetAccess=private)
IsInput
IsOutput
IsDSM
IsParam
    end

    properties(Constant,Hidden)
        IORegExpSuffix='(\d)+(\[\d+\])*$';
    end

    methods(Access=public)
        function globalDataObj=parse(obj,varSpecExpression,originalIndex)


            varSpecExpression=char(varSpecExpression);


            obj.PortId='';
            obj.DataType='';
            obj.DataKind=legacycode.lct.spec.DataKind.Unknown;


            obj.OriginalVarSpecExpression=varSpecExpression;
            obj.VarSpecExpression=varSpecExpression;
            obj.OriginalIndex=originalIndex;




            obj.parseDataType;



            obj.validateDataKind;

            obj.validateVarName;
            obj.checkForColon;




            globalDataObj=obj.parseAfterColon;
        end
    end


    methods(Access=protected)
        function argSpec=getFunctionArgObject(obj)

            assert(~isempty(obj.DataType));
            assert(~isempty(obj.PortId));
            argExpr=sprintf('%s %s',obj.DataType,obj.PortId);
            argSpec=legacycode.lct.spec.FunctionArg(argExpr);
        end
    end

    methods(Access=private)
        function parseDataType(obj)

            [obj.DataType,obj.VarSpecExpression]=strtok(obj.VarSpecExpression);



            [obj.PortId,obj.VarSpecExpression]=strtok(obj.VarSpecExpression);

            if obj.PortId(1)==':'
                error(message('Simulink:tools:LCTGlobalIONeedsDataTypeAndPortID',obj.OriginalVarSpecExpression));
            elseif obj.PortId(1)=='u'
                obj.DataKind=legacycode.lct.spec.DataKind.Input;
            elseif obj.PortId(1)=='y'
                obj.DataKind=legacycode.lct.spec.DataKind.Output;
            elseif obj.PortId(1)=='p'
                obj.DataKind=legacycode.lct.spec.DataKind.Parameter;
            elseif numel(obj.PortId)>3&&strcmp(obj.PortId(1:3),'dsm')
                obj.DataKind=legacycode.lct.spec.DataKind.DSM;
            end
        end


        function validateVarName(obj)

            assert(~isempty(obj.PortId));
            portRegExp=['^([uyp]|dsm)',obj.IORegExpSuffix];
            if isempty(regexp(obj.PortId,portRegExp,'once'))
                error(message('Simulink:tools:LCTSizeSpecParserBadSizeSyntaxWithDesc',obj.PortId));
            end
        end

        function checkForColon(obj)

            assert(~isempty(obj.PortId));
            assert(~isequal(obj.DataKind,legacycode.lct.spec.DataKind.Unknown));
            [colonFound,obj.VarSpecExpression]=obj.expectColon(obj.VarSpecExpression);
            if~colonFound
                error(message('Simulink:tools:LCTGlobalIOMissingColon',sprintf('%s %s',obj.DataType,obj.PortId)));
            end
        end
    end

    methods(Static,Access=private)
        function[found,expr]=expectColon(expr)
            colonRegExp='^\s*:';
            [tokStart,tokEnd]=regexp(expr,colonRegExp);
            found=~isempty(tokStart);
            if found
                expr=expr(tokEnd+1:end);
            end
        end
    end

    methods
        function isInput=get.IsInput(obj)
            isInput=obj.DataKind==legacycode.lct.spec.DataKind.Input;
        end

        function isOutput=get.IsOutput(obj)
            isOutput=obj.DataKind==legacycode.lct.spec.DataKind.Output;
        end

        function isDSM=get.IsDSM(obj)
            isDSM=obj.DataKind==legacycode.lct.spec.DataKind.DSM;
        end

        function isParam=get.IsParam(obj)
            isParam=obj.DataKind==legacycode.lct.spec.DataKind.Parameter;
        end
    end
end