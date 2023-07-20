function tf=isArrayOnDielectricSubstrate(obj)

    tf=isprop(obj.Element(1),'Substrate')&&~isequal(obj.Element(1).Substrate.EpsilonR,ones(size(obj.Element(1).Substrate.EpsilonR)));