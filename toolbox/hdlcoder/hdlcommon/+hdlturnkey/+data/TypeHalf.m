


classdef TypeHalf<hdlturnkey.data.Type


    properties
        Signed=0;
        WordLength=0;
        FractionLength=0;
        Dimension=1;
        BaseType=[];
        SLType='';
    end

    methods

        function obj=TypeHalf()


        end


        function isa=isHalfType(~)
            isa=true;
        end



        function isa=isHalf(obj)
            isa=obj.isHalfType;
        end
        function isa=isDouble(~)
            isa=false;
        end
        function isa=isSingle(~)
            isa=false;
        end
        function isa=isBoolean(~)
            isa=false;
        end
        function isa=isArrayType(obj)
            isa=obj.Dimension>1;
        end
        function slDataType=getSLDataType(~)

            slDataType='half';
        end

        function initFromPirType(obj,pirType)

            typeInfo=pirgetdatatypeinfo(pirType);

            obj.Signed=typeInfo.issigned;
            obj.WordLength=typeInfo.wordsize;
            obj.FractionLength=typeInfo.binarypoint;
            obj.SLType=typeInfo.sltype;
            obj.Dimension=typeInfo.dims;

            if typeInfo.isvector
                obj.BaseType=pirType.BaseType;
            else
                obj.BaseType=pirType;
            end

        end


        function[iseq,msgObj]=isTypeEqual(~,otherType,thisTypeName,otherTypeName)


            if nargin<3
                megObjTypeName=message('hdlcommon:interface:StrOneType');
                thisTypeName=megObjTypeName.getString;
            end
            if nargin<4
                megObjTypeName=message('hdlcommon:interface:StrTheOtherType');
                otherTypeName=megObjTypeName.getString;
            end

            iseq=false;
            msgObj=[];


            if~otherType.isHalfType
                msgObj=message('hdlcommon:interface:HalfTypeInvalid',...
                thisTypeName,otherTypeName);
                return;
            end

            iseq=true;
        end

    end
end

