function has=hasFixptPointDesignerLicense()






    has=builtin('license','test','Fixed_Point_Toolbox')&&~isempty(ver('fixedpoint'));


    checkout=has;
    if has
        checkout=builtin('license','checkout','Fixed_Point_Toolbox');
    end
    if~has||~checkout
        error(message('fixed:fi:licenseCheckoutFailed'));
    end

end
