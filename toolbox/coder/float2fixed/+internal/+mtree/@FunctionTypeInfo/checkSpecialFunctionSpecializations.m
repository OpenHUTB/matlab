





function messages=checkSpecialFunctionSpecializations(this,messages,classdefNode)



    if~this.isDefinedInAClass()
        return;
    end
    classMetaData=meta.class.fromName(this.className);
    isDefnClassSystemObject=any(strcmp({classMetaData.SuperclassList.Name},'matlab.System'));
    SYSOBJMTDS={'step','setupImpl','stepImpl','resetImpl','updateImpl'};
    if isDefnClassSystemObject&&this.isASpecializedFunction()...
        &&any(strcmp(this.functionName,SYSOBJMTDS))
        classLink=coder.internal.Helper.getPrintLinkStrFor(which(this.className),classdefNode.lineno,classdefNode.charno);
        messages=this.addClassConstraintFailureMessage(messages,...
        classdefNode,'Coder:FXPCONV:SysObjMtdSpecializedNoSupport',this.functionName,this.className,strjoin(SYSOBJMTDS,', '),classLink);
    end
end


