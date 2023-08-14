



function finalizeModuleInstrumentation(this)
    result=this.InstrumImpl.finalizeModuleInstrumentation();


    this.InstrumImpl.close();
end
