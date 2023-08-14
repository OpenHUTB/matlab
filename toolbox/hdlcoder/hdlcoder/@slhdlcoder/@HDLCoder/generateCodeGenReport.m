function generateCodeGenReport(this,reportInfo,p,tcgInventory)
    reportInfo.reset(this,p,tcgInventory);
    reportInfo.registerPages;
    reportInfo.emitHTML;
    reportInfo.show;

end

