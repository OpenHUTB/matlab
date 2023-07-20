







classdef DataBuilder


    methods(Static)





        function oStruct=newDataStructure(type,varargin)

            switch type
            case 'FcnArgElement'
                oStruct=legacycode.lct.spec.FunctionArg(varargin{:});

            case 'Data'
                oStruct=legacycode.lct.spec.Data(varargin{:});

            case 'BusElement'
                oStruct=legacycode.lct.types.BusElement();

            case 'DataTypeElement'
                oStruct=legacycode.lct.types.Type(varargin{:});

            case 'DataTypes'
                oStruct=legacycode.lct.types.TypeTable();

            case 'FcnElement'
                oStruct=legacycode.lct.spec.Function(varargin{:});

            case 'FcnArgs'
                oStruct=legacycode.lct.util.IdObjectSet();

            case 'Info'
                oStruct=legacycode.lct.LCTSpecInfo();

            case 'DimsInfo'
                oStruct=legacycode.lct.spec.DimInfo();

            case 'ExprInfo'
                oStruct=legacycode.lct.spec.ExprInfo(varargin{:});

            otherwise
                oStruct=[];
            end
        end

    end

end


