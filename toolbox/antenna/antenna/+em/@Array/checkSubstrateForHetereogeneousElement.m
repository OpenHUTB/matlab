function checkSubstrateForHetereogeneousElement(obj,propVal)

    tf=arrayfun(@(x)isprop(x,'Substrate'),propVal);
    if all(tf)
        if isa(propVal,'em.BackingStructure')&&isprop(propVal(1).Exciter,'Substrate')&&...
            isDielectricSubstrate(propVal(1).Exciter)
            epsr=arrayfun(@(x)x.Exciter.Substrate.('EpsilonR'),propVal,'UniformOutput',false);
            losstan=arrayfun(@(x)x.Exciter.Substrate.('LossTangent'),propVal,'UniformOutput',false);
            thickness=arrayfun(@(x)x.Exciter.Substrate.('Thickness'),propVal,'UniformOutput',false);
        else
            epsr=arrayfun(@(x)x.Substrate.('EpsilonR'),propVal,'UniformOutput',false);
            losstan=arrayfun(@(x)x.Substrate.('LossTangent'),propVal,'UniformOutput',false);
            thickness=arrayfun(@(x)x.Substrate.('Thickness'),propVal,'UniformOutput',false);
        end
        checkSize(epsr);
        checkValue(epsr);
        checkSize(losstan);
        checkValue(losstan);
        checkSize(thickness);
        checkValue(thickness);
    end
end

function checkSize(s)
    sz=cellfun(@(x)numel(x),s);
    if any((sz-sz(1))~=0)
        error(message('antenna:antennaerrors:DielectricSubstratesNotIdentical'));
    end
end

function checkValue(s)
    est=cellfun(@(x)transpose(x),s,'UniformOutput',false);
    est=cell2mat(est);
    if~isequal(est-est(:,1),zeros(size(est)))
        error(message('antenna:antennaerrors:DielectricSubstratesNotIdentical'));
    end

end