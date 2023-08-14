function setParam(m2mObj,aBlk,aParam,aVal)



    if strcmpi(get_param([m2mObj.fPrefix,aBlk],'BlockType'),'PreLookup')
        if strcmpi(aParam,'BreakpointsSpecification')
            if strcmpi(aVal,'0')
                set_param([m2mObj.fPrefix,aBlk],aParam,'Explicit values');
            elseif strcmpi(aVal,'1')
                set_param([m2mObj.fPrefix,aBlk],aParam,'Even spacing');
            else
            end
        elseif strcmpi(aParam,'BreakpointsDataSource')
            if strcmpi(aVal,'0')
                set_param([m2mObj.fPrefix,aBlk],aParam,'Dialog');
            elseif strcmpi(aVal,'1')
                set_param([m2mObj.fPrefix,aBlk],aParam,'Input port');
            else
            end
        elseif strcmpi(aParam,'IndexSearchMethod')
            if strcmpi(aVal,'0')
                set_param([m2mObj.fPrefix,aBlk],aParam,'Evenly spaced points');
            elseif strcmpi(aVal,'1')
                set_param([m2mObj.fPrefix,aBlk],aParam,'Linear search');
            elseif strcmpi(aVal,'2')
                set_param([m2mObj.fPrefix,aBlk],aParam,'Binary search');
            else
            end
        elseif strcmpi(aParam,'ExtrapMethod')
            if strcmpi(aVal,'0')
                set_param([m2mObj.fPrefix,aBlk],aParam,'Clip');
            elseif strcmpi(aVal,'1')
                set_param([m2mObj.fPrefix,aBlk],aParam,'Linear');
            else
            end
        elseif strcmpi(aParam,'DiagnosticForOutOfRangeInput')
            if strcmpi(aVal,'1')
                set_param([m2mObj.fPrefix,aBlk],aParam,'None');
            else
            end
        elseif strcmpi(aParam,'RemoveProtectionInput')||strcmpi(aParam,'LockScale')
            if strcmpi(aVal,'0')
                set_param([m2mObj.fPrefix,aBlk],aParam,'off');
            elseif strcmpi(aVal,'1')
                set_param([m2mObj.fPrefix,aBlk],aParam,'on');
            else
            end
        elseif strcmpi(aParam,'RndMeth')
            if strcmpi(aVal,'4')
                set_param([m2mObj.fPrefix,aBlk],aParam,'Simplest');
            end
        elseif strcmpi(aParam,'OutputOnlyIndex')
            if strcmpi(aVal,'1')
                set_param([m2mObj.fPrefix,aBlk],'OutputSelection','Index only');
            else
                set_param([m2mObj.fPrefix,aBlk],'OutputSelection','Index and fraction');
            end
        elseif strcmpi(aParam,'OutputSelection')
            if strcmpi(aVal,'0')
                set_param([m2mObj.fPrefix,aBlk],'OutputSelection','Index and fraction');
            elseif strcmpi(aVal,'1')
                set_param([m2mObj.fPrefix,aBlk],'OutputSelection','Index and fraction as bus');
            elseif strcmpi(aVal,'2')
                set_param([m2mObj.fPrefix,aBlk],'OutputSelection','Index only');
            end
        else
            set_param([m2mObj.fPrefix,aBlk],aParam,aVal);
        end
    elseif strcmpi(get_param([m2mObj.fPrefix,aBlk],'BlockType'),'Interpolation_n-D')
        if strcmpi(aParam,'TableSpecification')
            if strcmpi(aVal,'0')
                set_param([m2mObj.fPrefix,aBlk],aParam,'Explicit values');
            elseif strcmpi(aVal,'1')
                set_param([m2mObj.fPrefix,aBlk],aParam,'Lookup table object');
            else
            end
        elseif strcmpi(aParam,'TableSource')
            if strcmpi(aVal,'0')
                set_param([m2mObj.fPrefix,aBlk],aParam,'Dialog');
            elseif strcmpi(aVal,'1')
                set_param([m2mObj.fPrefix,aBlk],aParam,'Input port');
            else
            end
        elseif strcmpi(aParam,'InterpMethod')
            if strcmpi(aVal,'0')
                set_param([m2mObj.fPrefix,aBlk],aParam,'Flat');
            elseif strcmpi(aVal,'1')
                set_param([m2mObj.fPrefix,aBlk],aParam,'Linear point-slope');
            elseif strcmpi(aVal,'2')
                set_param([m2mObj.fPrefix,aBlk],aParam,'Linear Lagrange');
            elseif strcmpi(aVal,'4')
                set_param([m2mObj.fPrefix,aBlk],aParam,'Nearest');
            else
            end
        elseif strcmpi(aParam,'ExtrapMethod')
            if strcmpi(aVal,'0')
                set_param([m2mObj.fPrefix,aBlk],aParam,'Clip');
            elseif strcmpi(aVal,'1')
                set_param([m2mObj.fPrefix,aBlk],aParam,'Linear');
            else
            end
        elseif strcmpi(aParam,'DiagnosticForOutOfRangeInput')
            if strcmpi(aVal,'0')
                set_param([m2mObj.fPrefix,aBlk],aParam,'None');
            else
            end
        elseif strcmpi(aParam,'RemoveProtectionIndex')||strcmpi(aParam,'LockScale')||strcmpi(aParam,'SaturateOnIntegerOverflow')
            if strcmpi(aVal,'0')
                set_param([m2mObj.fPrefix,aBlk],aParam,'off');
            elseif strcmpi(aVal,'1')
                set_param([m2mObj.fPrefix,aBlk],aParam,'on');
            else
            end
        elseif strcmpi(aParam,'RndMeth')
            if strcmpi(aVal,'4')
                set_param([m2mObj.fPrefix,aBlk],aParam,'Simplest');
            end
        elseif strcmpi(aParam,'InternalRulePriority')
            if strcmpi(aVal,'0')
                set_param([m2mObj.fPrefix,aBlk],aParam,'Speed');
            elseif strcmpi(aVal,'1')
                set_param([m2mObj.fPrefix,aBlk],aParam,'Precision');
            else
            end
        else
            set_param([m2mObj.fPrefix,aBlk],aParam,aVal);
        end
    else
        set_param([m2mObj.fPrefix,aBlk],aParam,aVal);
    end
end
