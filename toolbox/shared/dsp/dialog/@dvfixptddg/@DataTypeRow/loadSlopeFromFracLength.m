function slope=loadSlopeFromFracLength(this,prop)







    if nargin<2
        prop='FracLength';
    end

    try
        fl=eval(this.(prop));
        slope=['2^',num2str(-fl)];
    catch
        fl=fliplr(deblank(fliplr(deblank(this.(prop)))));
        if strncmp(fl,'-log2(',6)&&...
            strcmp(fl(end),')')




            a=findstr(fl,'(');
            a=[a(:),ones(length(a),1)];
            b=findstr(fl,')');
            b=[b(:),-ones(length(b),1)];
            c=[a;b];
            c=sortrows(c);
            parens=cumsum(c(:,2));
            matches=find(parens==0);
            if isequal(length(matches),1)&&isequal(c(matches,1),length(fl))
                slope=fl(7:end-1);
            else
                slope=['2^-(',fl,')'];
            end
        else
            slope=['2^-(',fl,')'];
        end
    end
