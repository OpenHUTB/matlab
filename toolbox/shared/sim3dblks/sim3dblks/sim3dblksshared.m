function licStatus=sim3dblksshared(block)%#ok<INUSD>

    licType=sim3dblkssharedtest(block);
    licStatus=sim3dblkssharedeval(licType);
end

