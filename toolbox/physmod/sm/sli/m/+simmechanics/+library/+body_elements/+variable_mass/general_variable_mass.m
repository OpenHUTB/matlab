function varargout=general_variable_mass(varargin)



    persistent BlockInfoCache
    mlock;

    if isempty(BlockInfoCache)
        BlockInfoCache=simmechanics.sli.internal.BlockInfo;
        mfname=mfilename('fullpath');
        BlockInfoCache.SourceFile=which(mfname);
        BlockInfoCache.InitialVersion='R2017a';

        BlockInfoCache.SLBlockProperties.Name=...
        pm_message('sm:library:bodyElements:variableMass:generalVariableMass:Name');
        BlockInfoCache.SLBlockProperties.Position=[10,10,50,50];
        BlockInfoCache.SLBlockProperties.MaskIconUnits='normalized';


        BlockInfoCache.IconFile=[mfname,'.svg'];


        reference_port=@simmechanics.library.helper.reference_port;
        BlockInfoCache.addPorts(reference_port('generalVariableMassBlock'));


        maskParams(1)=simmechanics.library.helper.get_class_name_param(...
        pm_message('sm:model:blockNames:generalVariableMassBlock:TypeId'));

        maskParams=[maskParams,var_inertia_params];

        graphic_params=@simmechanics.library.helper.graphic_params;
        maskParams=[maskParams,graphic_params('',...
        pm_message('mech2:sli:blockParameters:graphic:graphicType:inertiaEllipsoid:Value'))];

        BlockInfoCache.addMaskParameters(maskParams);
    end

    if nargin==1
        varargout={simmechanics.library.helper.generate_outputs(BlockInfoCache,varargin{1})};
    else
        varargout{1}=BlockInfoCache.copy;
    end

end
