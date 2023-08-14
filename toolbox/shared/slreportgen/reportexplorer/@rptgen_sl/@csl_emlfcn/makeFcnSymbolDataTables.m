function makeFcnSymbolDataTables(this,d,out,emlFcn)











    mlSymbolData=slreportgen.utils.MATLABFunctionSymbolData(emlFcn);
    rootFId=mlSymbolData.getRootFunctionID();



    if this.includeSupportingFunctions
        fIds=mlSymbolData.getFIdList();
    else
        fIds=rootFId;
    end

    for i=1:numel(fIds)
        fId=fIds(i);


        functionDetails=mlSymbolData.getFcnDetails(fId);





        if this.supportFunctionsToInclude==1||...
            (this.supportFunctionsToInclude==2&&...
            functionDetails.isUserVisible)


            makeFcnDetTable(this,d,out,emlFcn,fId,functionDetails,rootFId);


            symbolTableData=mlSymbolData.getSymbolTableDetails(fId);
            if~(isempty(symbolTableData))

                makeSymbolTable(this,d,out,symbolTableData);
            end


            operationsTableData=mlSymbolData.getOperTableDetails(fId);
            if~(isempty(operationsTableData))

                makeOperationsTable(this,d,out,operationsTableData);
            end


            fcnCallSiteTableData=mlSymbolData.getFcnCallSiteDetails(fId);
            if~(isempty(fcnCallSiteTableData))

                makeFcnCallSiteTable(this,d,out,fcnCallSiteTableData);
            end
        end
    end

end

