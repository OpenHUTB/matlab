function[pGP,tGP]=meshGroundPlane(obj,varargin)









    if isprop(obj,'Substrate')
        subShape=obj.Substrate.Shape;
    else
        subShape='box';
    end

    switch subShape
    case 'box'
        groundShape='rectangular';
    case 'cylinder'
        groundShape='circular';
    end

    switch groundShape
    case 'rectangular'
        [pGP,tGP]=meshRectangularGroundPlane(obj,varargin{:});
    case 'circular'
        [pGP,tGP]=meshCircularGroundPlane(obj,varargin{:});
    end
