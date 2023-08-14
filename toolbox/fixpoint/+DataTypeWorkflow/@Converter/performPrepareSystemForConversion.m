function reportObject=performPrepareSystemForConversion(this,enumSimOrDerive)



    reportObject=DataTypeWorkflow.Advisor.runChecks(this.SelectedSystemToScale,enumSimOrDerive,this.TopModel);

end

