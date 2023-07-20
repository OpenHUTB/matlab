function[urdfModel,translationData]=systemToURDF(system)






    import matlabshared.multibody.internal.*;

    translationData=struct('IsTree',{true},...
    'CutJoints',{{}},...
    'Constraints',{{}},...
    'VariableInertias',{{}},...
    'FlexibleBodies',{{}},...
    'ImplicitJoints',{{}},...
    'LinkComponents',{containers.Map.empty},...
    'JointMap',{containers.Map.empty});

    cPaths=system.getConstraintPaths;
    if~isempty(cPaths)
        translationData.Constraints=cPaths;
    end

    cBodies=system.getCoalescedBodies();
    fBodyPaths=system.getFlexibleBodyPaths;
    [cJoints,isTree,cutJoints]=system.getTreeJoints();

    if(~isTree||~isempty(cPaths))
        translationData.IsTree=false;
        translationData.CutJoints=cutJoints;
    end

    if~isempty(fBodyPaths)
        translationData.FlexibleBodies=fBodyPaths;
    end

    urdfModel=urdf.Model;


    nBodies=size(cBodies)+size(translationData.FlexibleBodies);
    parentJoints=cell(nBodies);
    childJoints=cell(nBodies);

    cJointPathToIndexMap=containers.Map;
    implicitJoints={};
    for idx=1:length(cJoints)

        if(cJoints(idx).isImplicit)
            jointPath=implicitJointName(cJoints(idx),idx);
            implicitJoints{end+1}=jointPath;
        else
            jointPath=system.getPath(cJoints(idx).getContainmentIndex);
        end

        joint=matlabshared.multibody.internal.urdf.Joint(jointPath,'SM');
        joint.Type=cJoints(idx).getType;
        isRevOrPris=any(strcmp(joint.Type,{'Revolute Joint','Prismatic Joint'}));

        if cJoints(idx).getFollBodyIndex==(idx+1)

            joint.ParentLink=linkName(cJoints(idx).getBaseBodyIndex);
            joint.ChildLink=linkName(cJoints(idx).getFollBodyIndex);
            parentJoints{cJoints(idx).getFollBodyIndex}=joint.Name;
            childJoints{cJoints(idx).getBaseBodyIndex}=...
            [childJoints{cJoints(idx).getBaseBodyIndex},joint.Name];
            if isRevOrPris
                joint.Axis=[0,0,1];
            end
        else

            joint.ChildLink=linkName(cJoints(idx).getBaseBodyIndex);
            joint.ParentLink=linkName(cJoints(idx).getFollBodyIndex);
            parentJoints{cJoints(idx).getBaseBodyIndex}=joint.Name;
            childJoints{cJoints(idx).getFollBodyIndex}=...
            [childJoints{cJoints(idx).getFollBodyIndex},joint.Name];
            if isRevOrPris




                joint.Axis=[0,0,-1];
            end
        end


        if isRevOrPris
            lims=cJoints(idx).getLimits;
            if any(~isnan(lims))
                L=matlabshared.multibody.internal.urdf.Limit();
                if~isnan(lims(1))
                    L.Lower=lims(1);
                else
                    L.Lower=-Inf;
                end
                if~isnan(lims(2))
                    L.Upper=lims(2);
                else
                    L.Upper=Inf;
                end
                joint.Limit=L;
            end

            joint.HomePosition=cJoints(idx).getPositionTarget;
        end

        urdfModel.addJoint(joint);
        cJointPathToIndexMap(jointPath)=idx;

        translationData.JointMap(jointPath)=cJoints(idx).getSlPath;
    end
    translationData.ImplicitJoints=implicitJoints;


    variableInertias={};
    for idx=1:length(cBodies)
        variableInertias=[variableInertias;cBodies(idx).getVariableInertiaPaths];

        principalInertia=cBodies(idx).getPrincipalMomentsOfInertia();

        urdfInertia=matlabshared.multibody.internal.urdf.Inertia;
        urdfInertia.Ixx=principalInertia(1);
        urdfInertia.Iyy=principalInertia(2);
        urdfInertia.Izz=principalInertia(3);

        urdfInertial=urdf.Inertial;
        urdfInertial.Inertia=urdfInertia;
        urdfInertial.Mass=cBodies(idx).getMass();

        urdfLink=urdf.Link(linkName(idx));
        urdfLink.Inertial=urdfInertial;

        cBodyComps=system.getCoalescedBodyComponents(cBodies(idx));
        translationData.LinkComponents(urdfLink.Name)=cBodyComps;

        if~isempty(parentJoints{idx})
            urdfLink.ParentJoint=parentJoints{idx};
        else
            urdfModel.RootLink=urdfLink.Name;



            bodyToRefFrame=cBodies(idx).getBodyToRefTransform;
            orig=matlabshared.multibody.internal.urdf.Origin;
            orig.xyz=bodyToRefFrame.getTranslation';
            orig.rpy=sm.mli.internal.quaternionToRpy(bodyToRefFrame.getRotation);
            urdfLink.Inertial.Origin=orig;
        end

        if~isempty(childJoints{idx})
            urdfLink.ChildJoints=childJoints(idx);
        end

        urdfModel.addLink(urdfLink);
    end

    urdfModel.Name=system.getName;

    if~isempty(variableInertias)
        translationData.VariableInertias=variableInertias;
    end


    for idx=1:length(cJoints)


        jointToParentBodyXform=sm.mli.internal.Transform3;%#ok<NASGU>
        jointToChildBodyXform=sm.mli.internal.Transform3;%#ok<NASGU>



        if cJoints(idx).getFollBodyIndex==(idx+1)

            jointToParentBodyXform=cJoints(idx).getBaseAttachmentToBodyFrameTransform;
            jointToChildBodyXform=cJoints(idx).getFollAttachmentToBodyFrameTransform;
        else

            jointToParentBodyXform=cJoints(idx).getFollAttachmentToBodyFrameTransform;
            jointToChildBodyXform=cJoints(idx).getBaseAttachmentToBodyFrameTransform;
        end

        if(cJoints(idx).isImplicit)
            jointPath=implicitJointName(cJoints(idx),idx);
        else
            jointPath=system.getPath(cJoints(idx).getContainmentIndex);
        end
        joint=urdfModel.Joints(jointPath);
        parentLink=joint.ParentLink;
        parentJoint=[];
        if urdfModel.Links.isKey(parentLink)

            parentJoint=urdfModel.Links(parentLink).ParentJoint;
        end
        pJointToParentBodyXform=sm.mli.internal.Transform3;

        if~isempty(parentJoint)
            pCJointIndex=cJointPathToIndexMap(parentJoint);
            parentCJoint=cJoints(pCJointIndex);


            if parentCJoint.getFollBodyIndex==(pCJointIndex+1)
                pJointToParentBodyXform=parentCJoint.getFollAttachmentToBodyFrameTransform;
            else
                pJointToParentBodyXform=parentCJoint.getBaseAttachmentToBodyFrameTransform;
            end
        end

        jointToParentRefXform=pJointToParentBodyXform.inverseCompose(jointToParentBodyXform);

        orig=matlabshared.multibody.internal.urdf.Origin;
        orig.xyz=jointToParentRefXform.getTranslation';
        orig.rpy=sm.mli.internal.quaternionToRpy(jointToParentRefXform.getRotation);
        joint.Origin=orig;


        if urdfModel.Links.isKey(joint.ChildLink)

            urdfChildLink=urdfModel.Links(joint.ChildLink);
            childBodyToJointXform=jointToChildBodyXform.inverse;
            orig=matlabshared.multibody.internal.urdf.Origin;
            orig.xyz=childBodyToJointXform.getTranslation';
            orig.rpy=sm.mli.internal.quaternionToRpy(childBodyToJointXform.getRotation);
            urdfChildLink.Inertial.Origin=orig;
        end
    end

    urdfModel.Gravity=system.gravity;


    function lname=linkName(idx)
        lname=['CoalescedBody',num2str(idx)];

        function jname=implicitJointName(joint,idx)
            jname=['Implicit_',strrep(joint.getType,' ','_'),'_',num2str(idx)];
