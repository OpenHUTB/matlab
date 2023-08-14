function checkoutDatabaseToolboxLicense()






    if~builtin('license','test','Database_Toolbox')
        error(message('database:licensing:noLicense'));
    end


    [checkoutLogical,~]=builtin('license','checkout','Database_Toolbox');
    if~checkoutLogical
        error(message('database:licensing:noCheckout'));
    end

end

