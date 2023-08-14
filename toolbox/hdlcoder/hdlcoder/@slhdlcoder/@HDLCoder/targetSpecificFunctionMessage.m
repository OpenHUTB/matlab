function targetSpecificFunctionMessage(this,p)
    targetDriver=this.getTargetCodeGenDriver(p);
    if~isempty(targetDriver)&&~strcmpi(class(targetDriver),'targetcodegen.nfpdriver')
        hdldisp(message('hdlcommon:targetcodegen:ToolPath',targetDriver.getToolPath()));
    end
end