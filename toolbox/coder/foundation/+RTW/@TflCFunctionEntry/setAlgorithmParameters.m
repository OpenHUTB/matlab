function h=setAlgorithmParameters(h,apset)




    key=h.Key;
    if isempty(key)


        DAStudio.error('CoderFoundation:AlgorithmParameters:EmptyKey');
    end

    old_apset=h.getAlgorithmParameters();
    if(isempty(old_apset))
        if(isempty(apset))
            return;
        else

            DAStudio.error('CoderFoundation:AlgorithmParameters:InvalidKeyAPSet',h.Key);
        end
    else

        if(~(strcmpi(class(apset),class(old_apset))))
            DAStudio.error('CoderFoundation:AlgorithmParameters:InvalidKeyAPSetClass',...
            h.Key,class(apset),class(old_apset));
        end
    end

    h.AlgorithmParams=[];

    apnames=properties(apset);
    for i=1:length(apnames)
        ap=apset.(apnames{i});
        isDefault=ap.isValueDefault();
        if(~isDefault||ap.Primary)
            h.addAlgorithmParams(ap.Name,ap.Value);
        end
    end
end
