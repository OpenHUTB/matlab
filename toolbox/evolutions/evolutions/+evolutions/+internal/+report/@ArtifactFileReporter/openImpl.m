function result=openImpl(reporter,impl,varargin)





    if isempty(varargin)
        key=['y9JEffe7JeANBotzBoJPE3cpZXXU0hTT+D4wkHLP837JcLP3q08v7y3c4kWr'...
        ,'wTYLUoSonJY60KubF9uu4tKg2h7E7YoBPrGbxrAf/2w1cgqCCzUtFNkb7YJI'...
        ,'ICNDc1WoCzi5OIrMARw0dUBoiuWz8gZMKIm+03xp26ARCgHSkWOyX7D967nZ'...
        ,'+pIX7UHgnkYoad5H6G3ClWgGAIj5Bi/1fdIv5TZEOV5zH7o2ANCs5z+6ngc2'...
        ,'q2jMS9sSbDPLQ6ZZZ2DfL9GBhZjY3lgM1TZU1Nbo1WZTrIGVRifDUAE6EUuc'...
        ,'eAnRuc4='];
    else
        key=varargin{1};
    end
    result=open(impl,key,reporter);
end




