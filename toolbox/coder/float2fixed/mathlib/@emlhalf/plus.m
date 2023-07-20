%#codegen

function obj=plus(this,x)
    coder.inline('never');
    coder.allowpcode('plain');

    if isa(x,'emlhalf')
        x_half=x;
    else
        x_half=emlhalf(x);
    end

    if isa(this,'emlhalf')
        this_half=this;
    else
        this_half=emlhalf(this);
    end

    if(numel(this)==1)

        tmp=coder.nullcopy(zeros(size(x),'uint16'));

        [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this_half.Value);

        for ii=1:numel(x)
            [bSign,bExponent,bMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),x_half.Value(ii));

            [cSign,cExponent,cMantissa]=coder.customfloat.scalar.plus(CustomFloatType(16,10),aSign,aExponent,aMantissa,...
            bSign,bExponent,bMantissa,true);

            tmp(ii)=storedInteger(bitconcat(cSign,cExponent,cMantissa));
        end
    elseif(numel(x)==1)

        tmp=coder.nullcopy(zeros(size(this),'uint16'));

        [bSign,bExponent,bMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),x_half.Value);

        for ii=1:numel(this)
            [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this_half.Value(ii));

            [cSign,cExponent,cMantissa]=coder.customfloat.scalar.plus(CustomFloatType(16,10),aSign,aExponent,aMantissa,...
            bSign,bExponent,bMantissa,true);

            tmp(ii)=storedInteger(bitconcat(cSign,cExponent,cMantissa));
        end
    else
        s1=size(this);
        s2=size(x);

        if all(s1==s2)

            tmp=coder.nullcopy(zeros(s1,'uint16'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this_half.Value(ii));
                [bSign,bExponent,bMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),x_half.Value(ii));

                [cSign,cExponent,cMantissa]=coder.customfloat.scalar.plus(CustomFloatType(16,10),aSign,aExponent,aMantissa,...
                bSign,bExponent,bMantissa,true);

                tmp(ii)=storedInteger(bitconcat(cSign,cExponent,cMantissa));
            end
        elseif(s1(1)==s2(1))&&((s1(2)==1)||(s2(2)==1))
            if(s1(2)==1)

                tmp=coder.nullcopy(zeros(s2,'uint16'));

                for jj=1:s2(1)
                    [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this_half.Value(jj));

                    for ii=1:s2(2)
                        [bSign,bExponent,bMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),x_half.Value(jj,ii));

                        [cSign,cExponent,cMantissa]=coder.customfloat.scalar.plus(CustomFloatType(16,10),aSign,aExponent,aMantissa,...
                        bSign,bExponent,bMantissa,true);

                        tmp(jj,ii)=storedInteger(bitconcat(cSign,cExponent,cMantissa));
                    end
                end
            else

                tmp=coder.nullcopy(zeros(s1,'uint16'));

                for jj=1:s1(1)
                    [bSign,bExponent,bMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),x_half.Value(jj));

                    for ii=1:s1(2)
                        [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this_half.Value(jj,ii));

                        [cSign,cExponent,cMantissa]=coder.customfloat.scalar.plus(CustomFloatType(16,10),aSign,aExponent,aMantissa,...
                        bSign,bExponent,bMantissa,true);

                        tmp(jj,ii)=storedInteger(bitconcat(cSign,cExponent,cMantissa));
                    end
                end
            end
        elseif(s1(2)==s2(2))&&((s1(1)==1)||(s2(1)==1))
            if(s1(1)==1)

                tmp=coder.nullcopy(zeros(s2,'uint16'));

                for jj=1:s2(2)
                    [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this_half.Value(jj));

                    for ii=1:s2(1)
                        [bSign,bExponent,bMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),x_half.Value(ii,jj));

                        [cSign,cExponent,cMantissa]=coder.customfloat.scalar.plus(CustomFloatType(16,10),aSign,aExponent,aMantissa,...
                        bSign,bExponent,bMantissa,true);

                        tmp(ii,jj)=storedInteger(bitconcat(cSign,cExponent,cMantissa));
                    end
                end
            else

                tmp=coder.nullcopy(zeros(s1,'uint16'));

                for jj=1:s1(2)
                    [bSign,bExponent,bMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),x_half.Value(jj));

                    for ii=1:s1(1)
                        [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this_half.Value(ii,jj));

                        [cSign,cExponent,cMantissa]=coder.customfloat.scalar.plus(CustomFloatType(16,10),aSign,aExponent,aMantissa,...
                        bSign,bExponent,bMantissa,true);

                        tmp(ii,jj)=storedInteger(bitconcat(cSign,cExponent,cMantissa));
                    end
                end
            end
        else
            assert(true,'Dimensions mismatch.');
        end
    end

    obj=emlhalf.typecast(tmp);
end