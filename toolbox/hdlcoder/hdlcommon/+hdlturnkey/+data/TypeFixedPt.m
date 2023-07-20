


classdef TypeFixedPt<hdlturnkey.data.Type


    properties

        Signed=0;
        WordLength=0;
        FractionLength=0;
        Dimension=1;
        BaseType=[];
        SLType=[];
    end

    methods

        function obj=TypeFixedPt(varargin)


            p=inputParser;
            p.addParameter('Signed',0);
            p.addParameter('WordLength',0);
            p.addParameter('FractionLength',0);

            p.parse(varargin{:});
            inputArgs=p.Results;

            obj.Signed=inputArgs.Signed;
            obj.WordLength=inputArgs.WordLength;
            obj.FractionLength=inputArgs.FractionLength;
        end


        function isa=isFixedPtType(~)
            isa=true;
        end
        function isa=isArrayType(obj)
            isa=obj.Dimension>1;
        end
        function isa=isVector(obj)
            isa=obj.isArrayType;
        end
        function isa=isBooleanType(obj)

            isa=strcmpi(obj.SLType,'boolean');
        end
        function isa=isBoolean(obj)
            isa=obj.isBooleanType;
        end

        function isa=isInteger(obj)
            isa=obj.FractionLength==0;
        end

        function slDataType=getSLDataType(obj)









            if obj.isBoolean
                slDataType=obj.SLType;
            else
                slDataType=hdlgetsltypefromsizes(obj.WordLength,obj.FractionLength,obj.Signed);
            end
        end





        function isa=isSingle(obj)
            isa=strcmpi(obj.SLType,'single');
        end
        function isa=isDouble(obj)
            isa=strcmpi(obj.SLType,'double');
        end
        function isa=isHalf(obj)
            isa=strcmpi(obj.SLType,'half');
        end

        function initFromPirType(obj,pirType)

            typeInfo=pirgetdatatypeinfo(pirType);

            if pirType.isArrayType
                obj.Dimension=pirType.Dimension;
                obj.BaseType=pirType.BaseType;
            else
                obj.Dimension=1;
                obj.BaseType=pirType;
            end

            obj.SLType=typeInfo.sltype;
            obj.Signed=typeInfo.issigned;
            obj.WordLength=typeInfo.wordsize;
            obj.FractionLength=typeInfo.binarypoint;

        end

        function[iseq,msgObj]=isTypeEqual(obj,otherType,thisTypeName,otherTypeName)


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


            if~otherType.isFixedPtType
                msgObj=message('hdlcommon:interface:FixptTypeInvalid',...
                thisTypeName,otherTypeName);
                return;
            end

            if obj.isFlexibleWidth
                if otherType.isFlexibleWidth

                    msgObj=message('hdlcommon:interface:FixptTypeWLFlexibleUnsupported');
                    return;
                else

                    if obj.getMaxWordLength<otherType.WordLength
                        msgObj=message('hdlcommon:interface:FixptTypeWLFlexibleMismatch',...
                        otherTypeName,otherType.WordLength,thisTypeName,obj.getMaxWordLength);
                        return;
                    end
                end
            else
                if otherType.isFlexibleWidth

                    if obj.WordLength>otherType.getMaxWordLength
                        msgObj=message('hdlcommon:interface:FixptTypeWLFlexibleMismatch',...
                        thisTypeName,obj.WordLength,otherTypeName,otherType.getMaxWordLength);
                        return;
                    end
                else

                    if~isequal(obj.Signed,otherType.Signed)
                        msgObj=message('hdlcommon:interface:FixptTypeSignMismatch',...
                        thisTypeName,obj.Signed,otherTypeName,otherType.Signed);
                        return;
                    end

                    if~isequal(obj.WordLength,otherType.WordLength)
                        msgObj=message('hdlcommon:interface:FixptTypeWordlengthMismatch',...
                        thisTypeName,obj.WordLength,otherTypeName,otherType.WordLength);
                        return;
                    end

                    if~isequal(obj.FractionLength,otherType.FractionLength)
                        msgObj=message('hdlcommon:interface:FixptTypeFractionMismatch',...
                        thisTypeName,obj.FractionLength,otherTypeName,otherType.FractionLength);
                        return;
                    end
                end
            end

            iseq=true;
        end

        function maxWL=getMaxWordLength(obj)
            maxWL=obj.WordLength;
        end
        function wl=getWordLength(obj)
            wl=obj.WordLength;
        end
    end
end

