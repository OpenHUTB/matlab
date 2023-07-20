






function status=checkForLicensesAndProducts(productnames)
    status=cellfun(@dig.isProductInstalled,productnames);
end