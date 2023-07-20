function checkSubArrayProps(obj)

    if isa(obj.Element,'em.Array')
        if isprop(obj.Element.Element,'Substrate')
            if isscalar(obj.Element.Element)
                if any(obj.Element.Element.Substrate.EpsilonR~=1)
                    error(message('antenna:antennaerrors:SubArraysWithDielectric'));
                end
            else
                error(message('antenna:antennaerrors:SubArraysWithDielectric'));
            end
        end
    end

end