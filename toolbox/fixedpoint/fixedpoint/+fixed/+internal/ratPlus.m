classdef ratPlus












    properties
        mode=fixed.internal.ratPlusMode.Finite;













        num=fixed.internal.math.fiOne();
        den=fixed.internal.math.fiOne();



        FixedExponent=0;

        isNegative=false;


    end

    methods


        function obj=ratPlus(varargin)

            narginchk(0,2)
            if nargin>0
                obj=rat1Arg(varargin{1});
                if nargin>1
                    obj2=rat1Arg(varargin{2});
                    obj=times(obj,inv(obj2));
                end
            end
        end



        function str=dispString(obj)
            if obj.isnan()
                str='NaN';
            else
                if obj.isinf()
                    str='Inf';
                elseif obj.iszero()
                    str='0';
                else
                    fe=obj.FixedExponent;
                    nStr=valStr(obj.num,fe);
                    dStr=valStr(obj.den,-fe);
                    str=[nStr,' / ',dStr];
                end
                if obj.isNegative()
                    str=['-',str];
                end
            end
        end

        function disp(obj)
            fprintf('    %s\n',dispString(obj));
        end



        function b=isnan(obj)
            b=obj.mode==fixed.internal.ratPlusMode.Nan;
        end



        function b=isinf(obj)
            b=obj.mode==fixed.internal.ratPlusMode.Infinite;
        end



        function b=isinfPos(obj)
            b=obj.isinf&&~obj.isNegative;
        end



        function b=isinfNeg(obj)
            b=obj.isinf&&obj.isNegative;
        end



        function b=isfinite(obj)
            b=obj.mode==fixed.internal.ratPlusMode.Finite;
        end



        function b=isnegative(obj)
            b=(~isnan(obj))&&(~iszero(obj))&&obj.isNegative;
        end



        function b=ispositive(obj)
            b=(~isnan(obj))&&(~iszero(obj))&&~obj.isNegative;
        end


        function b=iszero(obj)
            b=(~isnan(obj))&&0==obj.num;
        end


        function b=iszeroNeg(obj)
            b=iszero(obj)&&obj.isNegative;
        end


        function b=iszeroPos(obj)
            b=iszero(obj)&&~obj.isNegative;
        end



        function y=uminus(obj)
            if obj.isnan()
                y=fixed.internal.ratPlus(nan);
            else
                y=obj;
                y.isNegative=~y.isNegative;
            end
        end




        function y=inv(obj)
            if obj.isnan()
                y=fixed.internal.ratPlus(nan);
            elseif obj.isinf()
                y=fixed.internal.ratPlus(0);
            elseif obj.iszeroPos()
                y=fixed.internal.ratPlus(inf);
            elseif obj.iszeroNeg()
                y=fixed.internal.ratPlus(-inf);
            else
                y=obj;
                y.num=obj.den;
                y.den=obj.num;
                y.FixedExponent=-obj.FixedExponent;
            end
        end




        function y=times(obj,other)
            if obj.isnan()||other.isnan()
                y=fixed.internal.ratPlus(nan);
            elseif obj.isinf()
                y=mulByInf(obj,other);
            elseif other.isinf()
                y=mulByInf(other,obj);
            elseif obj.iszero()||other.iszero()
                y=fixed.internal.ratPlus(0);
            else
                sameSign=obj.isnegative()==other.isnegative();
                y=obj;
                y.isNegative=~sameSign;
                y.num=obj.num*other.num;
                y.den=obj.den*other.den;
                y.FixedExponent=obj.FixedExponent+other.FixedExponent;
                y=fiRatCleanup(y);
            end
        end




        function y=mtimes(obj,other)
            y=times(obj,other);
        end



        function y=plus(obj,other)
            if obj.isnan()||other.isnan()
                y=fixed.internal.ratPlus(nan);
            elseif obj.isinf()
                y=addToInf(obj,other);
            elseif other.isinf()
                y=addToInf(other,obj);
            elseif obj.iszero()
                y=other;
            elseif other.iszero()
                y=obj;
            else
                na=signedFullNum(obj);
                da=fullDen(obj);
                nb=signedFullNum(other);
                db=fullDen(other);
                nSum=(na*db)+(nb*da);
                dSum=da*db;
                isNeg=nSum<0;
                if isNeg
                    nSum=nSum*fixed.internal.math.fiMinusOne;
                end

                y=obj;
                y.isNegative=isNeg;
                y.num=nSum;
                y.den=dSum;
                y.FixedExponent=0;
                y=fiRatCleanup(y);
            end
        end



        function y=minus(obj,other)
            negOther=uminus(other);
            y=plus(obj,negOther);
        end



        function y=rdivide(obj,other)
            invOther=inv(other);
            y=times(obj,invOther);
        end




        function y=mrdivide(obj,other)
            y=rdivide(obj,other);
        end



        function y=ldivide(obj,other)
            y=rdivide(other,obj);
        end



        function y=mldivide(obj,other)
            y=mrdivide(other,obj);
        end









        function b=lt(obj,other)
            r=compare(obj,other);
            b=r.noNan&&r.lt;
        end





        function b=gt(obj,other)
            r=compare(obj,other);
            b=r.noNan&&r.gt;
        end





        function b=le(obj,other)
            r=compare(obj,other);
            b=r.noNan&&(r.lt||r.eq);
        end





        function b=ge(obj,other)
            r=compare(obj,other);
            b=r.noNan&&(r.gt||r.eq);
        end





        function b=ne(obj,other)
            b=~eq(obj,other);
        end





        function b=eq(obj,other)
            r=compare(obj,other);
            b=r.noNan&&r.eq;
        end


        function n=absFullNum(obj)
            n=hAbsFullNum(obj);
        end

        function n=signedFullNum(obj)
            n=hSignedFullNum(obj);
        end

        function d=fullDen(obj)
            d=hFullDen(obj);
        end

        function[y,ratErr]=todouble(obj)






            if obj.isnan()
                y=nan;
                ratErr=fixed.internal.ratPlus(0);
            elseif obj.isinfPos()
                y=inf;
                ratErr=fixed.internal.ratPlus(0);
            elseif obj.isinfNeg()
                y=-inf;
                ratErr=fixed.internal.ratPlus(0);
            else
                if infWhenCastToDouble(obj)
                    if obj.isnegative
                        y=-inf;
                    else
                        y=inf;
                    end
                elseif zeroWhenCastToDouble(obj)
                    if obj.isnegative
                        y=-0;
                    else
                        y=0;
                    end
                else
                    y=quotientDouble(obj);
                end

                if nargout>1
                    ratDbl=fixed.internal.ratPlus(y);
                    ratErr=obj-ratDbl;
                end
            end
        end



        function y=abs(obj)
            if obj.isnegative()
                y=uminus(obj);
            else
                y=obj;
            end
        end
    end
end



function s=valStr(u,fe)

    s=u.Value;
    if fe>0
        feStr=pow2Str(fe);
        if u==fixed.internal.math.fiOne
            s=feStr;
        else
            s=sprintf('(%s * %s)',s,feStr);
        end
    end
end

function s=pow2Str(fe)

    assert(fe>0);

    if fe<=16
        s=mat2str(2^fe,30);
    else
        s=sprintf('2^%d',fe);
    end
end


function y=hAbsFullNum(obj)





    assert(~obj.isinf());
    assert(~obj.isnan());













    y=obj.num;
    if obj.FixedExponent>0
        y=y*fixed.internal.math.fiExactPow2(obj.FixedExponent);
    end
end

function y=hSignedFullNum(obj)







    assert(~obj.isinf());
    assert(~obj.isnan());













    y=absFullNum(obj);
    if obj.isnegative()
        y=y*fixed.internal.math.fiMinusOne;
    end
end

function y=hFullDen(obj)





    assert(~obj.isinf());
    assert(~obj.isnan());













    y=obj.den;
    if obj.FixedExponent<0
        y=y*fixed.internal.math.fiExactPow2(-obj.FixedExponent);
    end
end

function y=rat1Arg(u)
    if isa(u,'fixed.internal.ratPlus')
        y=u;
    else
        y=fixed.internal.ratPlus();
        validateattributes(u,{'numeric','embedded.fi','logical'},{'real','numel',1});

        if fixed.internal.type.isAnyBoolean(u)
            u=double(u);
        end

        if isfinite(u)
            y=rat1ArgFinite(u);
        elseif isnan(u)
            y.mode=fixed.internal.ratPlusMode.Nan;
        else
            y.mode=fixed.internal.ratPlusMode.Infinite;
            y.isNegative=u<0;
        end
    end
end

function[slope,extraFixedExponent]=getSlope(nt)

    sa=nt.SlopeAdjustmentFactor;
    feOrig=nt.FixedExponent;

    if 1.0==sa
        slope=1.0;
        extraFixedExponent=feOrig;
    else
        feMin=-1022;
        feMax=971;

        fe=min(feMax,max(feMin,feOrig));
        extraFixedExponent=feOrig-fe;

        slope=sa*2^fe;
    end
end


function y=rat1ArgFinite(u)

    nt=fixed.internal.type.extractNumericType(u);

    if fixed.internal.type.isTrivialSlopeAdjustBias(nt)
        y=hRat1ArgFinite(u);
    else
        si=stripscaling(u);
        y=fixed.internal.ratPlus(si);

        [slope,extraFixedExponent]=getSlope(nt);
        if slope~=1
            y=y.*fixed.internal.ratRecovery(slope);
        end
        if extraFixedExponent~=0
            rfe=fixed.internal.math.fiExactPow2(extraFixedExponent);
            y=y.*fixed.internal.ratPlus(rfe);
        end
        bias=nt.Bias;
        if 0~=bias
            y=y+signedRatRecovery(bias);
        end
    end
end

function y=signedRatRecovery(u)

    y=fixed.internal.ratRecovery(abs(u));
    if u<0
        y.isNegative=true;
    end

end

function y=hRat1ArgFinite(u)
    y=fixed.internal.ratPlus();
    [num,den]=numDenExact(u);
    y.isNegative=num<0;
    if y.isNegative
        num=num*fixed.internal.math.fiMinusOne();
        num=fixed.internal.type.tightFi(num);
    end
    y.FixedExponent=num.FixedExponent-den.FixedExponent;
    y.num=stripscaling(num);
    y.den=stripscaling(den);
    y=fiRatCleanup(y);
end




function[num,den]=numDenExact(u)

    validateattributes(u,{'numeric','embedded.fi','logical'},{'real','finite','numel',1});

    u2=fixed.internal.type.tightFi(u,2^16);

    nt=fixed.internal.type.extractNumericType(u2);

    if~fixed.internal.type.isTrivialSlopeAdjustBias(nt)
        error(message('fixed:fi:inputsMustBeFixPtBPSOrNumTypeOrInt'));
    end

    fe=nt.FixedExponent;
    if fe<0
        num=stripscaling(u2);
        den=fixed.internal.math.fiExactPow2(-fe);
    else
        num=u2;
        den=fixed.internal.math.fiOne();
    end
end



function y=mulByInf(obj,other)

    assert(obj.isinf());

    if other.iszero()
        y=fixed.internal.ratPlus(nan);
    else
        if obj.isnegative()==other.isnegative()
            y=fixed.internal.ratPlus(inf);
        else
            y=fixed.internal.ratPlus(-inf);
        end
    end
end


function y=addToInf(obj,other)

    assert(obj.isinf());
    assert(~obj.isnan());
    assert(~other.isnan());

    if(~other.isfinite())&&...
        (obj.isinfPos()~=other.isinfPos())

        y=fixed.internal.ratPlus(nan);
    else
        y=obj;
    end
end



function obj=fiRatCleanup(obj)


    if obj.isfinite()

        num=fixed.internal.type.tightFi(obj.num);
        obj.FixedExponent=obj.FixedExponent+num.FixedExponent;
        obj.num=stripscaling(num);

        if 0==num
            obj.den=fixed.internal.math.fiOne();
            obj.FixedExponent=0;
        else
            den=fixed.internal.type.tightFi(obj.den);
            obj.FixedExponent=obj.FixedExponent-den.FixedExponent;
            obj.den=stripscaling(den);
        end

        obj=paragmaticGCD(obj);
    end
end



function obj=paragmaticGCD(obj)

    bothFit=siLessEqFintmax(obj.num)&&siLessEqFintmax(obj.den);

    if bothFit

        intMantNum=double(obj.num);
        intMantDen=double(obj.den);

        g=gcd(intMantNum,intMantDen);
        if g>1
            intMantNum=intMantNum/g;
            intMantDen=intMantDen/g;
            assert(intMantNum==floor(intMantNum));
            assert(intMantDen==floor(intMantDen));

            obj.num=fixed.internal.type.tightFi(intMantNum);
            obj.den=fixed.internal.type.tightFi(intMantDen);
        end
    else
        g=fixed.internal.gcdAnyInt(obj.num,obj.den);
        if g>1
            obj.num=divide(numerictype(obj.num),obj.num,g);
            obj.den=divide(numerictype(obj.den),obj.den,g);

            obj.num=fixed.internal.type.tightFi(obj.num);
            obj.den=fixed.internal.type.tightFi(obj.den);
        end
    end
end




function r=compare(obj,other)

    r.noNan=~isnan(obj)&&~isnan(other);
    r.gt=false;
    r.eq=false;
    r.lt=false;

    if r.noNan
        objZero=iszero(obj);
        objPos=ispositive(obj);
        objNeg=isnegative(obj);

        otherZero=iszero(other);
        otherPos=ispositive(other);
        otherNeg=isnegative(other);

        sameSign=objPos==otherPos;

        if objZero||otherZero
            if objZero
                r.gt=otherNeg;
                r.eq=otherZero;
                r.lt=otherPos;
            else
                r.gt=objPos;
                r.eq=false;
                r.lt=objNeg;
            end

        elseif~sameSign

            r.gt=objPos;
            r.eq=false;
            r.lt=objNeg;

        elseif isinf(obj)

            if isinf(other)

                r.gt=objPos&&~sameSign;
                r.eq=sameSign;
                r.lt=objNeg&&~sameSign;

            else

                r.gt=objPos;
                r.eq=false;
                r.lt=objNeg;

            end

        else
            left=absFullNum(obj).*fullDen(other);
            right=fullDen(obj).*absFullNum(other);

            bgt=left>right;
            beq=left==right;

            r.gt=bgt;
            r.eq=beq;
            r.lt=~bgt&&~beq;
        end
    end
end

function b=infWhenCastToDouble(obj)


    persistent overflowThresholdInclusive

    if isempty(overflowThresholdInclusive)
        s=fixed.internal.type.attribFloatingPoint('double');
        overflowThresholdInclusive=fixed.internal.ratPlus(s.overflowThresholdInclusive);
    end

    b=abs(obj)>=overflowThresholdInclusive;
end

function b=zeroWhenCastToDouble(obj)


    persistent underflowThresholdInclusive

    if isempty(underflowThresholdInclusive)
        s=fixed.internal.type.attribFloatingPoint('double');
        underflowThresholdInclusive=fixed.internal.ratPlus(s.underflowThresholdInclusive);
    end

    b=abs(obj)<=underflowThresholdInclusive;
end

function y=quotientDouble(obj)

    num=absFullNum(obj);
    den=fullDen(obj);

    numLog2UpLim=num.WordLength+num.FixedExponent;
    denLog2LoLim=den.WordLength+den.FixedExponent-2;

    quotLog2UpLim=numLog2UpLim-denLog2LoLim;

    ntQuot=numerictype(0,64,62-quotLog2UpLim);

    y=double(divide(ntQuot,num,den));
    if obj.isnegative()
        y=-y;
    end
end


