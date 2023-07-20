function h=addAlgorithmProperty(h,apname,apvalue)




    if nargin>1
        apname=convertStringsToChars(apname);
    end

    if nargin>2
        if isstring(apvalue)
            apvalue=cellstr(apvalue);
        end
    end



    key=h.Key;
    if isempty(key)


        DAStudio.error('CoderFoundation:AlgorithmParameters:EmptyKey');
    end

    apset=h.getAlgorithmParameters();
    if(isempty(apset))


        h.addAlgorithmParams(apname,apvalue);
    else

        ap=apset.(apname);
        ap.Value=apvalue;


        algPropertyList={{apname,apvalue}};
        h.addAlgorithmParameters(algPropertyList);

    end

end


