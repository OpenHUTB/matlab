
function[inheritanceError,messages]=checkBaseClass(this,baseClassNode,messages)




    if strcmp(baseClassNode.kind,'AND')

        [inheritanceErrorLeft,messages]=this.checkBaseClass(baseClassNode.Left,messages);
        [inheritanceErrorRight,messages]=this.checkBaseClass(baseClassNode.Right,messages);
        inheritanceError=inheritanceErrorLeft||inheritanceErrorRight;
    else
        baseClassDefn=strtrim(baseClassNode.tree2str(0,1));
        switch baseClassDefn
        case{'handle','matlab.System','hdl.BlackBox'}
            inheritanceError=0;
        otherwise
            messages=this.addClassConstraintFailureMessage(messages,...
            baseClassNode,'Coder:FXPCONV:InheritanceError');
            inheritanceError=1;
        end
    end
end


