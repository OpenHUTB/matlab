function varargout=external_file_solid(varargin)




    persistent BlockInfoCache
    mlock;

    if isempty(BlockInfoCache)
        BlockInfoCache=simmechanics.sli.internal.BlockInfo;
        mfname=mfilename('fullpath');
        BlockInfoCache.SourceFile=which(mfname);
        BlockInfoCache.InitialVersion='R2018b';

        msgFcn=@pm_message;
        make_params=@simmechanics.library.helper.make_params;
        pa=simmechanics.library.helper.ParameterAccessor;

        BlockInfoCache.SLBlockProperties.Name=...
        msgFcn('sm:library:bodyElements:externalFileSolid:Name');
        BlockInfoCache.SLBlockProperties.Position=[10,10,50,50];
        BlockInfoCache.SLBlockProperties.MaskIconUnits='normalized';
        BlockInfoCache.SLBlockProperties.Orientation='right';


        BlockInfoCache.IconFile=[mfname,'.svg'];



        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.body_elements.external_file_solid_sl_postprocess_1',...
        0.0,6.12);



        BlockInfoCache.setTransformationFunction(...
        'simmechanics.library.body_elements.external_file_solid_sl_postprocess_2',...
        6.12,7.52);


        reference_port=@simmechanics.library.helper.reference_port;
        BlockInfoCache.addPorts(reference_port('solid'));


        maskParams(1)=simmechanics.library.helper.get_class_name_param(...
        pm_message('sm:model:blockNames:externalFileSolid:TypeId'));

        pa.Namespace='mech2:messages:parameters:geometry:fileGeometry';

        egfParams=make_params(pa.param('extGeomFileName'),...
        pa.defValue('extGeomFileName'));
        egfParams(1).Evaluate=false;
        maskParams=[maskParams,egfParams];

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=pa.param('unitType');
        maskParams(end).Value=pa.defComboValue('unitType');

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=pa.param('extGeomFileUnits');
        maskParams(end).Value=pa.defComboValue('extGeomFileUnits');





        stepReaderNamespace='mech2:externalFileSolid:parameters:stepReaderType:';
        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=pm_message([stepReaderNamespace,'ParamName']);
        maskParams(end).Value=...
        pm_message([stepReaderNamespace,'values:hex:Param']);
        maskParams(end).Hidden=true;
        maskParams(end).Visible=false;
        maskParams(end).Evaluate=false;

        pa.Namespace='sm:fileSolid:parameters:geometry:exportGeometry';





        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=pa.param('convexHull');
        maskParams(end).Value='off';
        maskParams(end).Evaluate=false;

        pa.Namespace='mech2:messages:parameters:externalFileSolid';
        maskParams=[maskParams,inertia_params('')];
        varNames={maskParams.VarName};
        idx=strcmp(varNames,pa.param('inertiaType'));

        inertiaTypeParam=maskParams(idx);
        inertiaTypeParam.Value=pa.defComboValue('inertiaType');
        maskParams(idx)=inertiaTypeParam;

        pa.Namespace='mech2:messages:parameters:inertia:geometricInertia';
        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=pa.param('basedOnType');
        maskParams(end).Value='DensityFromFile';
        maskParams(end).Evaluate=false;

        maskParams=[maskParams,make_params(...
        pa.param('density'),...
        pa.defValue('density'),...
        pa.units('density'),...
        pa.defUnits('density'),true)];

        pa.Namespace='mech2:messages:parameters:solid';
        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=pa.param('doExposeReferenceFrame');
        maskParams(end).Value=pa.defValue('doExposeReferenceFrame');

        maskParams(end+1)=pm.sli.MaskParameter;
        maskParams(end).VarName=pa.param('frames');
        maskParams(end).Value=pa.defValue('frames');

        pa.Namespace='mech2:messages:parameters:graphic';
        graphic_params=@simmechanics.library.helper.graphic_params;
        maskParams=[maskParams...
        ,graphic_params('',pa.defComboValue('graphicType'))];

        BlockInfoCache.addMaskParameters(maskParams);
    end
    BlockInfoCache.HasDialogGraphics=true;

    if nargin==1
        varargout={simmechanics.library.helper.generate_outputs(BlockInfoCache,varargin{1})};
    else
        varargout{1}=BlockInfoCache.copy;
    end

end


