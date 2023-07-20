



function newObj=copyElement(this)


    newObj=copyElement@matlab.mixin.Copyable(this);


    this.forEachFunction(@(o,n,f)copyFcn(o,n,f));
    this.forEachDataSet(@(o,n,s)copyDataSet(o,n,s));

    newObj.DWorksForBus=copy(this.DWorksForBus);
    newObj.DWorksForNDArray=copy(this.DWorksForNDArray);

    function copyFcn(~,funKind,funSpec)
        newObj.(funKind)=copy(funSpec);
    end

    function copyDataSet(~,dataSetName,dataSet)
        newObj.(dataSetName)=copy(dataSet);
    end
end
