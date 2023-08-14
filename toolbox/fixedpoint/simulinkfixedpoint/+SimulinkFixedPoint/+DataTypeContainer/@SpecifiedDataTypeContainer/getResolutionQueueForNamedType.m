function resolutionQueue=getResolutionQueueForNamedType(this)








    resolutionQueue={''};
    if this.isVarName
        resolutionQueue={this.origDTString};


        if~isempty(this.childDTContainerObj)
            resolutionQueue=[resolutionQueue,getResolutionQueueForNamedType(this.childDTContainerObj)];
        end
    end
end
