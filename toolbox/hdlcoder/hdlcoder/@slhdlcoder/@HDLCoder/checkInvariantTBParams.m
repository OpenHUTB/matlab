function checkInvariantTBParams(this,invariantTBParams)













    if this.CodeGenSuccessful
        vv='target_language';
        if~strcmp(invariantTBParams.(vv),this.getParameter(vv))
            emitInvTBWarning(this,vv,invariantTBParams.(vv),this.getParameter(vv));
        end


        vv='use_single_library';
        if invariantTBParams.(vv)~=this.getParameter(vv)
            emitInvTBWarning(this,vv,int2str(invariantTBParams.(vv)),...
            int2str(this.getParameter(vv)));
        end

        vv='vhdl_library_name';
        if~strcmp(invariantTBParams.(vv),this.getParameter(vv))
            emitInvTBWarning(this,vv,invariantTBParams.(vv),this.getParameter(vv));
        end
        vv='simulationtool';
        if~strcmp(invariantTBParams.(vv),this.getParameter(vv))
            emitInvTBWarning(this,vv,invariantTBParams.(vv),this.getParameter(vv));
        end
    end
end



function emitInvTBWarning(this,invParam,oldVal,newVal)
    this.CodeGenSuccessful=false;
    if isempty(oldVal)
        oldVal='';
    end
    errMsg=message('hdlcoder:makehdl:ParamChangedForTB',invParam,oldVal,newVal);
    this.addTestbenchCheck(this.ModelName,'warning',errMsg);
    warning(errMsg);
end
