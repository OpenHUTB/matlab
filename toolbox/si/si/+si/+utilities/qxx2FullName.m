function fullName=qxx2FullName(product)

    import si.utilities.*
    validateattributes(product,{'char','string'},{'nonempty'})
    product=string(product).lower;
    switch product
    case{"seriallinkdesigner"}
        fullName="Serial Link Designer";
    case{"parallellinkdesigner"}
        fullName="Parallel Link Designer";
    case{"siviewer"}
        fullName="SI Viewer";
    otherwise
        fullName=product;
    end
end

