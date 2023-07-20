function infos=getCandidateInfo(m2mObj)



    infos=struct('Parameters',{},...
    'LutPorts',{});
    for idx=1:length(m2mObj.fCollapsedCandidates)
        candInfo=m2mObj.fCollapsedCandidates(idx);
        info=struct('Parameters',[],...
        'LutPorts',candInfo.LutPorts);
        params=struct('Breakpoints',[],...
        'BreakpointDataTypeStr',[],...
        'FractionDataTypeStr',[],...
        'InterpMethod',[],...
        'ExtrapMethod',[],...
        'IndexSearchMethod',[],...
        'DiagnosticForOutOfRangeInput',[],...
        'RemoveProtectionInput',[],...
        'LockScale',[],...
        'RndMeth',[]);

        params.Breakpoints=candInfo.Parameters.bpVals;

        params.BreakpointDataTypeStr=candInfo.Parameters.bpDataType;

        params.FractionDataTypeStr=candInfo.Parameters.fracDataType;

        if candInfo.Parameters.interpMethod==0
            params.InterpMethod='Flat';
        elseif candInfo.Parameters.interpMethod==1
            params.InterpMethod='Linear';
        elseif candInfo.Parameters.interpMethod==3
            params.InterpMethod='Nearest';
        elseif candInfo.Parameters.interpMethod==4
            params.InterpMethod='LinearLagrange';
        elseif candInfo.Parameters.interpMethod==5
            params.InterpMethod='CubicSpline';
        end

        if candInfo.Parameters.extrapMethod==0
            params.ExtrapMethod='Clip';
        elseif candInfo.Parameters.extrapMethod==1
            params.ExtrapMethod='Linear';
        elseif candInfo.Parameters.extrapMethod==2
            params.ExtrapMethod='CubicSpline';
        end

        if candInfo.Parameters.idxSearchMethod==0
            params.IndexSearchMethod='Evenly spaced points';
        elseif candInfo.Parameters.idxSearchMethod==1
            params.IndexSearchMethod='Linear search';
        elseif candInfo.Parameters.idxSearchMethod==2
            params.IndexSearchMethod='Binary search';
        end

        if candInfo.Parameters.diagnoseOOR==0
            params.DiagnosticForOutOfRangeInput='off';
        else
            params.DiagnosticForOutOfRangeInput='on';
        end

        if candInfo.Parameters.rmInputProtectOnOOR==0
            params.RemoveProtectionInput='off';
        else
            params.RemoveProtectionInput='on';
        end

        if candInfo.Parameters.lockScale==0
            params.LockScale='off';
        else
            params.LockScale='on';
        end

        if candInfo.Parameters.rndMethod==0
            params.RndMeth='Zero';
        elseif candInfo.Parameters.rndMethod==1
            params.RndMeth='Nearest';
        elseif candInfo.Parameters.rndMethod==2
            params.RndMeth='Ceiling';
        elseif candInfo.Parameters.rndMethod==3
            params.RndMeth='Floor';
        elseif candInfo.Parameters.rndMethod==4
            params.RndMeth='Simplest';
        elseif candInfo.Parameters.rndMethod==5
            params.RndMeth='Round';
        elseif candInfo.Parameters.rndMethod==6
            params.RndMeth='Convergent';
        end

        info.Parameters=params;
        infos=[infos,info];
    end
end
