function varargout=variable_spherical_solid(varargin)



    persistent BlockInfoCache
    mlock;

    if isempty(BlockInfoCache)
        BlockInfoCache=simmechanics.sli.internal.BlockInfo;
        mfname=mfilename('fullpath');
        BlockInfoCache.SourceFile=which(mfname);
        BlockInfoCache.InitialVersion='R2017b';

        BlockInfoCache.SLBlockProperties.Name=...
        pm_message('sm:library:bodyElements:variableMass:variableSphericalSolid:Name');
        BlockInfoCache.SLBlockProperties.Position=[10,10,50,50];
        BlockInfoCache.SLBlockProperties.MaskIconUnits='normalized';


        BlockInfoCache.IconFile=[mfname,'.svg'];


        reference_port=@simmechanics.library.helper.reference_port;
        BlockInfoCache.addPorts(reference_port('variableSphericalSolidBlock'));

        msgFcn=@pm_message;
        make_params=@simmechanics.library.helper.make_params;


        maskParams(1)=simmechanics.library.helper.get_class_name_param(...
        pm_message('sm:model:blockNames:variableSphericalSolidBlock:TypeId'));

        pa=simmechanics.library.helper.ParameterAccessor;
        pa.Namespace='mech2:messages:parameters:inertia:variableInertia:variableSphericalInertia';

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=pa.param('radiusType');
        maskParams(end).Value=pa.defComboValue('radiusType');

        maskParams=[maskParams...
        ,make_params(pa.param('radius'),...
        pa.defValue('radius'),...
        pa.units('radius'),...
        pa.defUnits('radius'),true)];

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=pa.param('massType');
        maskParams(end).Value=pa.defComboValue('massType');

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=pa.param('initialMassType');
        maskParams(end).Value=pa.defComboValue('initialMassType');

        maskParams=[maskParams...
        ,make_params(pa.param('initialMass'),...
        pa.defValue('initialMass'),...
        pa.units('initialMass'),...
        pa.defUnits('initialMass'),false)];

        maskParams=[maskParams...
        ,make_params(pa.param('density'),...
        pa.defValue('density'),...
        pa.units('density'),...
        pa.defUnits('density'),true)];


        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=pa.param('senseRadius');
        maskParams(end).Value=pa.defValue('senseRadius');

        pa.Namespace='mech2:messages:parameters:inertia:variableInertia';

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=pa.param('senseMass');
        maskParams(end).Value=pa.defValue('senseMass');

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=pa.param('senseCenterOfMass');
        maskParams(end).Value=pa.defValue('senseCenterOfMass');

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=pa.param('senseInertiaTensor');
        maskParams(end).Value=pa.defValue('senseInertiaTensor');



        graphic_params=@simmechanics.library.helper.graphic_params;
        maskParams=[maskParams,graphic_params('',...
        pm_message('mech2:sli:blockParameters:graphic:graphicType:fromGeometry:Value'))];

        BlockInfoCache.addMaskParameters(maskParams);
    end

    if nargin==1
        varargout={simmechanics.library.helper.generate_outputs(BlockInfoCache,varargin{1})};
    else
        varargout{1}=BlockInfoCache.copy;
    end

end


