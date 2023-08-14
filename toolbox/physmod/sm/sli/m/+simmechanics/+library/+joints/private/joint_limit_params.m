function maskParams=joint_limit_params(prefix,primType)




    if nargin<1||isempty(prefix)
        prefix='';
    else
        prefix=genvarname(prefix);
    end

    msgFcn=@pm_message;
    make_params=@simmechanics.library.helper.make_params;
    pa=simmechanics.library.helper.ParameterAccessor;
    pa.Namespace='mech2:messages:parameters:jointLimit';


    maskParams(1)=pm.sli.MaskParameter;
    maskParams(end).VarName=[prefix,msgFcn(fullId('specify'))];
    maskParams(end).Evaluate=false;
    maskParams(end).Value='off';

    if strcmp(primType,'revolute')
        if strcmpi(prefix,'lower')
            bound='-90';
        else
            bound='90';
        end
        boundUnits='deg';
        stiffness='1e4';
        stiffnessUnits='N*m/deg';
        damping='10';
        dampingUnits='N*m/(deg/s)';
        transWidth='0.1';
        transWidthUnits='deg';
    elseif strcmp(primType,'spherical')
        if strcmpi(prefix,'lower')
            bound='15';
        else
            bound='45';
        end
        boundUnits='deg';
        stiffness='1e4';
        stiffnessUnits='N*m/deg';
        damping='10';
        dampingUnits='N*m/(deg/s)';
        transWidth='0.1';
        transWidthUnits='deg';
    else
        if strcmpi(prefix,'lower')
            bound='-1';
        else
            bound='1';
        end
        boundUnits='m';
        stiffness='1e6';
        stiffnessUnits='N/m';
        damping='1e3';
        dampingUnits='N/(m/s)';
        transWidth='1e-4';
        transWidthUnits='m';
    end

    maskParams=[maskParams...
    ,make_params([prefix,pa.param('bound')],...
    bound,...
    [prefix,pa.units('bound')],...
    boundUnits,true)];

    maskParams=[maskParams...
    ,make_params([prefix,pa.param('stiffness')],...
    stiffness,...
    [prefix,pa.units('stiffness')],...
    stiffnessUnits,true)];

    maskParams=[maskParams...
    ,make_params([prefix,pa.param('damping')],...
    damping,...
    [prefix,pa.units('damping')],...
    dampingUnits,true)];

    maskParams=[maskParams...
    ,make_params([prefix,pa.param('transitionRegionWidth')],...
    transWidth,...
    [prefix,pa.units('transitionRegionWidth')],...
    transWidthUnits,true)];

end

function fullMsgId=fullId(msgId)
    fullMsgId=['mech2:messages:parameters:jointLimit:',msgId,':ParamName'];
end
