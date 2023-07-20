function[tf,tfOnElement,tfExciter]=isDielectricSubstrate(obj)
    tf=false;
    tfOnElement=false;
    tfExciter=false;
    if isprop(obj,'Substrate')
        tf=~isequal(obj.Substrate.EpsilonR,ones(size(obj.Substrate.EpsilonR)));
    elseif isa(obj,'conformalArray')
        if iscell(obj.Element)
            [elementWithSub,~,elementExciterWithSub]=cellfun(@(x)isDielectricSubstrate(x),obj.Element);
        else
            [elementWithSub,~,elementExciterWithSub]=arrayfun(@(x)isDielectricSubstrate(x),obj.Element);
        end
        if(any(elementWithSub)||any(elementExciterWithSub))
            tfOnElement=true;
        end
    end
    if isa(obj,'em.BackingStructure')&&~isempty(obj.Exciter)&&isprop(obj.Exciter,'Substrate')
        tfExciter=~isequal(obj.Exciter.Substrate.EpsilonR,ones(size(obj.Exciter.Substrate.EpsilonR)));
    end
end

