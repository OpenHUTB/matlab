function validateReferenceName(refName)


















    if~startsWith(refName,"&")
        error(message('devicetree:base:InvalidReferenceName',refName));
    end

end