function sys=sm_create_urdf_system(URDFModel,homeConfig)




    urdfLinkName2smSystemIdMap=containers.Map;
    urdfJointName2smJointIdMap=containers.Map;
    urdfjointName2smJointMap=containers.Map;

    import sm.mli.internal.*

    sys=System;


    urdfJoints=URDFModel.Joints;
    urdfJointNames=urdfJoints.keys;
    iHC=1;
    for ii=1:numel(urdfJointNames)


        urdfJoint=urdfJoints(urdfJointNames{ii});


        switch urdfJoint.Type
        case{'revolute','continuous'}
            smJoint=RevoluteJoint;
            if~isempty(urdfJoint.Dynamics)
                smJoint.setDampingConstant(urdfJoint.Dynamics.Damping);
            end

            if strcmp(urdfJoint.Type,'revolute')
                if~isinf(urdfJoint.Limit.Lower)
                    smJoint.setLowerLimit(urdfJoint.Limit.Lower);
                end
                if~isinf(urdfJoint.Limit.Upper)
                    smJoint.setUpperLimit(urdfJoint.Limit.Upper);
                end
            end
            if~isempty(homeConfig)&&(length(homeConfig)>=iHC)
                smJoint.setPositionTarget(homeConfig(iHC));
                iHC=iHC+1;
            end

        case 'prismatic'
            smJoint=PrismaticJoint;
            if~isempty(urdfJoint.Dynamics)
                smJoint.setDampingConstant(urdfJoint.Dynamics.Damping);
            end

            if~isinf(urdfJoint.Limit.Lower)
                smJoint.setLowerLimit(urdfJoint.Limit.Lower);
            end
            if~isinf(urdfJoint.Limit.Upper)
                smJoint.setUpperLimit(urdfJoint.Limit.Upper);
            end
            if~isempty(homeConfig)&&(length(homeConfig)>=iHC)
                smJoint.setPositionTarget(homeConfig(iHC));
                iHC=iHC+1;
            end
        case 'fixed'
            smJoint=WeldJoint;
        case 'floating'
            smJoint=SixDofJoint;
        case 'planar'
            smJoint=PlanarJoint;
        otherwise
            pm_error('sm:import:urdf:InvalidJointType',...
            urdfJoint.Type,urdfJoint.Name);
        end


        smJointId=MlId(urdfJoint.Name);
        smJointId=sys.addJoint(smJointId,smJoint);



        urdfJointName2smJointIdMap(urdfJoint.Name)=smJointId;
        urdfjointName2smJointMap(urdfJoint.Name)=smJoint;
    end



    urdfLinks=URDFModel.Links;
    urdfLinkNames=urdfLinks.keys;
    for ii=1:numel(urdfLinkNames)


        urdfLink=URDFModel.Links(urdfLinkNames{ii});


        rb=RigidBody();


        inertial=urdfLink.Inertial;
        if~isempty(inertial)

            xyz=inertial.Origin.xyz;
            rpy=inertial.Origin.rpy;
            rot=RollPitchYawRotation(rpy);
            trans=CartesianTranslation(xyz);
            rt=RigidTransform(trans,rot);
            inFrameId=MlId('InertiaOrigin');
            inFrameId=rb.addFrame(rb.referenceFrameId,rt,inFrameId);


            mass=inertial.Mass;
            com=[0,0,0];
            inertia=inertial.Inertia;
            moi=[inertia.Ixx,inertia.Iyy,inertia.Izz];
            poi=[inertia.Iyz,inertia.Ixz,inertia.Ixy];
            inBlk=Inertia(mass,com,moi,poi);
            inBlkId=MlId('Inertia');
            rb.addInertia(inFrameId,inBlk,inBlkId);
        end


        for kk=1:numel(urdfLink.Visual)
            visual=urdfLink.Visual(kk);


            xyz=visual.Origin.xyz;
            rpy=visual.Origin.rpy;
            rot=RollPitchYawRotation(rpy);
            trans=CartesianTranslation(xyz);
            rt=RigidTransform(trans,rot);
            if~isempty(visual.Name)
                visBlkId=MlId(visual.Name);
            else
                visBlkId=MlId('Visual');
            end
            visFrameId=MlId([visBlkId.str,'Origin']);
            visFrameId=rb.addFrame(rb.referenceFrameId,rt,visFrameId);


            geometry=visual.Geometry;
            switch geometry.Type
            case 'box'
                dims=geometry.Size;
                visBlk=BrickGeometry(dims);
            case 'cylinder'
                rad=geometry.Radius;
                len=geometry.Length;
                visBlk=CylinderGeometry(rad,len);
            case 'sphere'
                rad=geometry.Radius;
                visBlk=SphereGeometry(rad);
            case 'mesh'
                filename=geometry.FileName;
                filename=strrep(filename,'package://','');
                filename=strrep(filename,'package:\\','');
                [~,name,ext]=fileparts(filename);
                switch lower(ext)
                case '.stl'



                    unit='m';
                    scaleX=geometry.Scale(1);
                    if all(scaleX==geometry.Scale)
                        if scaleX==0.01
                            unit='cm';
                        end
                        if scaleX==0.001
                            unit='mm';
                        end
                    end
                    visBlk=FileSolid(filename,unit);
                case{'.stp','.step'}
                    visBlk=FileSolid(filename);
                case ''
                    pm_error(...
                    'sm:import:urdf:VisualFileWithoutExtension',...
                    name,urdfLink.Name)
                otherwise



                    pm_warning(...
                    'sm:import:urdf:UnsupportedVisualFile',...
                    [name,ext],urdfLink.Name);
                    visBlk=FileSolid(filename,'m');
                end
            otherwise
                pm_error('sm:import:urdf:InvalidGeometry',...
                type,urdfLink.Name);
            end

            if~isempty(visual.Material)
                if~isempty(visual.Material.Color)
                    rgba=visual.Material.Color.rgba;
                    visBlk.setColor(rgba(1:3));
                    visBlk.setOpacity(rgba(4));
                end
            end

            rb.addGeometry(visFrameId,visBlk,visBlkId);
        end




        if~isempty(urdfLink.ParentJoint)
            urdfParentJoint=urdfJoints(urdfLink.ParentJoint);
            smParentJointId=urdfJointName2smJointIdMap(urdfLink.ParentJoint);
            if urdfParentJoint.hasAxis
                rt=getAxisTransform(urdfParentJoint);
                smParentJointFrameId=rb.addFrame(rb.referenceFrameId,rt,...
                MlId([urdfLink.ParentJoint,'_AxisInv']));
            else
                smParentJointFrameId=rb.referenceFrameId;
            end


            rb.exportFrame(smParentJointFrameId);
        end



        numChildJoints=numel(urdfLink.ChildJoints);
        smChildJointFrameIds=cell(1,numChildJoints);
        urdfChildJointNames=cell(1,numChildJoints);
        smChildJointIds=cell(1,numChildJoints);
        for jj=1:numChildJoints
            urdfChildJoint=URDFModel.Joints(urdfLink.ChildJoints{jj});
            smChildJointId=urdfJointName2smJointIdMap(urdfLink.ChildJoints{jj});


            xyz=urdfChildJoint.Origin.xyz;
            rpy=urdfChildJoint.Origin.rpy;
            rot=RollPitchYawRotation(rpy);
            trans=CartesianTranslation(xyz);
            rt=RigidTransform(trans,rot);
            smJointOriginFrameId=rb.addFrame(rb.referenceFrameId,rt,...
            MlId([urdfLink.ChildJoints{jj},'_Origin']));


            if urdfChildJoint.hasAxis
                rt=getAxisTransform(urdfChildJoint);
                smChildJointFrameId=rb.addFrame(smJointOriginFrameId,rt,...
                MlId([urdfLink.ChildJoints{jj},'_Axis']));
            else
                smChildJointFrameId=smJointOriginFrameId;
            end


            rb.exportFrame(smChildJointFrameId);

            urdfChildJointNames{jj}=urdfChildJoint.Name;
            smChildJointIds{jj}=smChildJointId;
            smChildJointFrameIds{jj}=smChildJointFrameId;
        end



        if strcmp(urdfLink.Name,URDFModel.RootLink)
            rootFrameId=rb.referenceFrameId;
            rb.exportFrame(rootFrameId);
        end


        rbsys=rb.computeSystem;


        if strcmp(urdfLink.Name,URDFModel.RootLink)
            rootExpFrameId=rbsys.setFrameExporterExportId(...
            rootFrameId,MlId('F'));
        end


        if~isempty(urdfLink.ParentJoint)
            smParentJointExpFrameId=rbsys.setFrameExporterExportId(...
            smParentJointFrameId,MlId('F'));
        end


        smChildJointExpFrameIds=cell(1,numChildJoints);
        for jj=1:numel(urdfLink.ChildJoints)
            smChildJointExpFrameIds{jj}=rbsys.setFrameExporterExportId(...
            smChildJointFrameIds{jj},MlId(['F',num2str(jj)]));
        end


        rbsysId=sys.addSubsystem(MlId(urdfLink.Name),rbsys);



        urdfLinkName2smSystemIdMap(urdfLink.Name)=rbsysId;


        if~isempty(urdfLink.ParentJoint)
            smParentJointBlk=urdfjointName2smJointMap(urdfLink.ParentJoint);
            sys.connect(rbsysId,smParentJointExpFrameId,...
            smParentJointId,smParentJointBlk.followerPortId);
        end


        for jj=1:numChildJoints
            smChildJointBlk=urdfjointName2smJointMap(urdfLink.ChildJoints{jj});
            sys.connect(rbsysId,smChildJointExpFrameIds{jj},...
            smChildJointIds{jj},smChildJointBlk.basePortId);
        end
    end


    rootId=urdfLinkName2smSystemIdMap(URDFModel.RootLink);


    WF=WorldFrame;
    WFId=sys.addWorldFrame(MlId('World'),WF);
    sys.connect(WFId,WF.worldFramePortId,rootId,rootExpFrameId);



    MC=MechanismConfiguration;
    if~isempty(URDFModel.Gravity)
        MC.setGravity(URDFModel.Gravity);
    end
    MCId=sys.addMechanismConfiguration(...
    MlId('MechanismConfiguration'),MC);
    sys.connect(MCId,MC.mechanismConfigurationPortId,rootId,rootExpFrameId);
end

function rt=getAxisTransform(urdfJoint)






















    import sm.mli.internal.*


    xyz=urdfJoint.Axis.xyz/norm(urdfJoint.Axis.xyz);

    th=acos(xyz(3));
    if th==0||th==pi
        ax=[1,0,0];
    else
        ax=[-xyz(2),xyz(1),0];
    end
    trans=CartesianTranslation([0,0,0]);
    rot=AngleAxisRotation(th,ax);
    rt=RigidTransform(trans,rot);
end
