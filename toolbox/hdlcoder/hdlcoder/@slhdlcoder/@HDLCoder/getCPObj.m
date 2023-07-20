function cpObj=getCPObj(this)

    if isempty(this.CoderParameterObject)
        this.createCPObj;
    end

    cpObj=this.CoderParameterObject;
end
