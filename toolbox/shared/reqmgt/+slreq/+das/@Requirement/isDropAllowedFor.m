function tf=isDropAllowedFor(this,dstDas,location,action)




    tf=false;

    if~strcmp(action,'move')||this.isExternal||this==dstDas...
        ||this.RequirementSet.isBackedBySlx()
        return;
    end


    if this.isJustification
        if isa(dstDas,'slreq.das.Requirement')&&dstDas.isJustification&&...
            ~dstDas.RequirementSet.isBackedBySlx()

            if~this.isAncestorOf(dstDas)
                if isa(dstDas.parent,'slreq.das.RequirementSet')
                    if strcmp(location,'on')


                        tf=true;
                    end
                else

                    tf=true;
                end
            end
        end
    else
        if isa(dstDas,'slreq.das.RequirementSet')&&~dstDas.isBackedBySlx()

            tf=true;
        elseif isa(dstDas,'slreq.das.Requirement')&&~dstDas.isExternal&&~dstDas.isJustification...
            &&~dstDas.RequirementSet.isBackedBySlx()
            if~this.isAncestorOf(dstDas)

                tf=true;
            end
        end
    end
end
