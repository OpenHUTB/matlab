classdef PhysicalAttributes<sim3d.internal.BaseAttributes

    properties
        ActorName
        LinearVelocity(1,3)double;
        AngularVelocity(1,3)double;
        Mass(1,1)double;
        CenterOfMass(1,3)double;
        Gravity(1,1)logical
        Physics(1,1)logical
        Collisions(1,1)logical;
        LocationLocked(1,1)logical;
        RotationLocked(1,1)logical;
        Mobility(1,1)int32;
    end


    properties(Hidden)
        Inertia(1,3)double;
        Force(1,3)double;
        Torque(1,3)double;
        ContinuousMovement(1,1)logical;
        Friction(1,1)double
        Restitution(1,1)double;
        PreciseContacts(1,1)logical;
        Hidden(1,1)logical;
        ConstantAttributes(1,1)logical;

        % 2023a中引入
        WorldTranslation (1, 3) double{mustBeFinite};
        WorldRotation (1, 3) double{mustBeFinite};
        WorldScale (1, 3) double{mustBeFinite};
    end


    properties(Hidden,Constant)
        LinearVelocityID=1
        AngularVelocityID=2
        MassID=3
        InertiaID=4
        ForceID=5
        TorqueID=6
        CenterOfMassID=7
        GravityID=8
        PhysicsID=9
        ContinuousMovementID=10
        FrictionID=11
        RestitutionID=12;
        PreciseContactsID=13
        CollisionsID=14
        LocationLockedID=15;
        RotationLockedID=16
        MobilityID=17;
        HiddenID=18;
        ConstantAttributesID=19;
        Full=19
        Suffix_Out='PhysicalAttributes_OUT';
        Suffix_In='PhysicalAttributes_IN';
    end


    methods

        function self=PhysicalAttributes(varargin)
            self@sim3d.internal.BaseAttributes();
            r=sim3d.internal.PhysicalAttributes.parseInputs(varargin{:});
            self.setAttributes(r);
        end


        function setup(self,actorName)
            messageTopic=[actorName,self.Suffix_Out];
            setup@sim3d.internal.BaseAttributes(self,messageTopic);
        end


        function PhysicalAttribs=getAttributes(self)
            PhysicalAttribs=self.createPhysicalStruct(self);
        end


        function setAttributes(self,PhysicalStruct)
            if(isfield(PhysicalStruct,'Mobility'))
                self.Mobility=PhysicalStruct.Mobility;
            end
            if(isfield(PhysicalStruct,'LinearVelocity'))
                self.LinearVelocity=PhysicalStruct.LinearVelocity;
            end
            if(isfield(PhysicalStruct,'AngularVelocity'))
                self.AngularVelocity=PhysicalStruct.AngularVelocity;
            end
            if(isfield(PhysicalStruct,'Mass'))
                self.Mass=PhysicalStruct.Mass;
            end
            if(isfield(PhysicalStruct,'Inertia'))
                self.Inertia=PhysicalStruct.Inertia;
            end
            if(isfield(PhysicalStruct,'Force'))
                self.Force=PhysicalStruct.Force;
            end
            if(isfield(PhysicalStruct,'Torque'))
                self.Torque=PhysicalStruct.Torque;
            end
            if(isfield(PhysicalStruct,'CenterOfMass'))
                self.CenterOfMass=PhysicalStruct.CenterOfMass;
            end
            if(isfield(PhysicalStruct,'Gravity'))
                self.Gravity=PhysicalStruct.Gravity;
            end
            if(isfield(PhysicalStruct,'Physics'))
                self.Physics=PhysicalStruct.Physics;
            end
            if(isfield(PhysicalStruct,'ContinuousMovement'))
                self.ContinuousMovement=PhysicalStruct.ContinuousMovement;
            end
            if(isfield(PhysicalStruct,'Friction'))
                self.Friction=PhysicalStruct.Friction;
            end
            if(isfield(PhysicalStruct,'Restitution'))
                self.Restitution=PhysicalStruct.Restitution;
            end
            if(isfield(PhysicalStruct,'PreciseContacts'))
                self.PreciseContacts=PhysicalStruct.PreciseContacts;
            end
            if(isfield(PhysicalStruct,'Collisions'))
                self.Collisions=PhysicalStruct.Collisions;
            end
            if(isfield(PhysicalStruct,'LocationLocked'))
                self.LocationLocked=PhysicalStruct.LocationLocked;
            end
            if(isfield(PhysicalStruct,'RotationLocked'))
                self.RotationLocked=PhysicalStruct.RotationLocked;
            end
            if(isfield(PhysicalStruct,'Hidden'))
                self.Hidden=PhysicalStruct.Hidden;
            end
            if(isfield(PhysicalStruct,'ConstantAttributes'))
                self.ConstantAttributes=PhysicalStruct.ConstantAttributes;
            end

            if ( isfield( PhysicalStruct, 'WorldTranslation' ) )
                self.WorldTranslation = PhysicalStruct.WorldTranslation;
            end
            if ( isfield( PhysicalStruct, 'WorldRotation' ) )
                self.WorldRotation = PhysicalStruct.WorldRotation;
            end
            if ( isfield( PhysicalStruct, 'WorldScale' ) )
                self.WorldScale = PhysicalStruct.WorldScale;
            end

        end


        function set.LinearVelocity(self,LinearVelocity)
            if(max(abs(LinearVelocity))>1e-5&&self.Mobility==sim3d.utils.MobilityTypes.Static)
                warning(message("shared_sim3d:sim3dActor:UnsupportedMobilityType",'Linear Velocity'));
            end
            self.LinearVelocity=LinearVelocity;
            self.add2Buffer(self.LinearVelocityID);
        end


        function set.AngularVelocity(self,AngularVelocity)
            if(max(abs(AngularVelocity))>1e-5&&self.Mobility==sim3d.utils.MobilityTypes.Static)
                warning(message("shared_sim3d:sim3dActor:UnsupportedMobilityType",'Angular Velocity'));
            end
            self.AngularVelocity=AngularVelocity;
            self.add2Buffer(self.AngularVelocityID);
        end


        function set.Mass(self,Mass)
            if(Mass~=0&&self.Mobility==sim3d.utils.MobilityTypes.Static)
                warning(message("shared_sim3d:sim3dActor:UnsupportedMobilityType",'Mass'));
            end
            self.Mass=Mass;
            self.add2Buffer(self.MassID);
        end


        function set.Inertia(self,Inertia)
            self.Inertia=Inertia;
            self.add2Buffer(self.InertiaID);
        end


        function set.Force(self,Force)
            self.Force=Force;
            self.add2Buffer(self.ForceID);
        end


        function set.Torque(self,Torque)
            self.Torque=Torque;
            self.add2Buffer(self.TorqueID);
        end


        function set.CenterOfMass(self,CenterOfMass)
            if(max(abs(CenterOfMass))>1e-5&&self.Mobility==sim3d.utils.MobilityTypes.Static)
                warning(message("shared_sim3d:sim3dActor:UnsupportedMobilityType",'Center Of Mass'));
            end
            self.CenterOfMass=CenterOfMass;
            self.add2Buffer(self.CenterOfMassID);
        end


        function set.Gravity(self,Gravity)
            if(Gravity==true&&self.Mobility==sim3d.utils.MobilityTypes.Static)
                warning(message("shared_sim3d:sim3dActor:UnsupportedMobilityType",'Gravity'));
            end
            self.Gravity=Gravity;
            self.add2Buffer(self.GravityID);
        end


        function set.Physics(self,Physics)
            if(Physics==true&&self.Mobility==sim3d.utils.MobilityTypes.Static)
                warning(message("shared_sim3d:sim3dActor:UnsupportedMobilityType",'Physics'));
            end
            self.Physics=Physics;
            self.add2Buffer(self.PhysicsID);
        end


        function set.ContinuousMovement(self,ContinuousMovement)
            self.ContinuousMovement=ContinuousMovement;
            self.add2Buffer(self.ContinuousMovementID);
        end


        function set.Friction(self,Friction)
            self.Friction=Friction;
            self.add2Buffer(self.FrictionID);
        end


        function set.Restitution(self,Restitution)
            self.Restitution=Restitution;
            self.add2Buffer(self.RestitutionID);
        end


        function set.PreciseContacts(self,PreciseContacts)
            self.PreciseContacts=PreciseContacts;
            self.add2Buffer(self.PreciseContactsID);
        end


        function set.Collisions(self,Collisions)
            self.Collisions=Collisions;
            self.add2Buffer(self.CollisionsID);
        end


        function set.LocationLocked(self,LocationLocked)
            self.LocationLocked=LocationLocked;
            self.add2Buffer(self.LocationLockedID);
        end


        function set.RotationLocked(self,RotationLocked)
            self.RotationLocked=RotationLocked;
            self.add2Buffer(self.RotationLockedID);
        end


        function set.ConstantAttributes(self,ConstantAttributes)
            self.ConstantAttributes=ConstantAttributes;
            self.add2Buffer(self.ConstantAttributesID);
        end


        function set.WorldTranslation( self, WorldTranslation )
            self.WorldTranslation = WorldTranslation;
        end


        function set.WorldRotation( self, WorldRotation )
            self.WorldRotation = WorldRotation;
        end


        function set.WorldScale( self, WorldScale )
            self.WorldScale = WorldScale;
        end


        function set.Mobility(self,Mobility)
            self.Mobility=Mobility;
            self.add2Buffer(self.MobilityID);
        end


        function set.Hidden(self,Hidden)
            self.Hidden=Hidden;
            self.add2Buffer(self.HiddenID);
        end


        function copy(self,other)
            self.Mobility=other.Mobility;
            self.LinearVelocity=other.LinearVelocity;
            self.AngularVelocity=other.AngularVelocity;
            self.Mass=other.Mass;
            self.Inertia=other.Inertia;
            self.Force=other.Force;
            self.Torque=other.Torque;
            self.CenterOfMass=other.CenterOfMass;
            self.Gravity=other.Gravity;
            self.Physics=other.Physics;
            self.ContinuousMovement=other.ContinuousMovement;
            self.Friction=other.Friction;
            self.Restitution=other.Restitution;
            self.PreciseContacts=other.PreciseContacts;
            self.Collisions=other.Collisions;
            self.LocationLocked=other.LocationLocked;
            self.RotationLocked=other.RotationLocked;
            self.Hidden=other.Hidden;
            self.ConstantAttributes=other.ConstantAttributes;

            % r2023a中引入
            self.WorldTranslation = other.WorldTranslation;
            self.WorldRotation = other.WorldRotation;
            self.WorldScale = other.WorldScale;
        end


        function delete(self)
        end
    end


    methods(Access=private,Static)

        function r=parseInputs(varargin)
            defaultParams=struct(...
                'LinearVelocity',[0,0,0],...
                'AngularVelocity',[0,0,0],...
                'Mass',0,...
                'Inertia',[0,0,0],...
                'Force',[0,0,0],...
                'Torque',[0,0,0],...
                'CenterOfMass',[0,0,0],...
                'Gravity',false,...
                'Physics',false,...
                'ContinuousMovement',false,...
                'Friction',0.7,...
                'Restitution',0.3,...
                'PreciseContacts',false,...
                'Collisions',true,...
                'LocationLocked',false,...
                'RotationLocked',false,...
                'Mobility',int32(sim3d.utils.MobilityTypes.Static),...
                'Hidden',false,...
                'ConstantAttributes',false, ...
                'WorldTranslation', [0, 0, 0], ...
                'WorldRotation', [0, 0, 0], ...
                'WorldScale', [1, 1, 1]);

            parser=inputParser;
            parser.addParameter('LinearVelocity',defaultParams.LinearVelocity);
            parser.addParameter('AngularVelocity',defaultParams.AngularVelocity);
            parser.addParameter('Mass',defaultParams.Mass);
            parser.addParameter('Inertia',defaultParams.Inertia);
            parser.addParameter('Force',defaultParams.Force);
            parser.addParameter('Torque',defaultParams.Torque);
            parser.addParameter('CenterOfMass',defaultParams.CenterOfMass);
            parser.addParameter('Gravity',defaultParams.Gravity);
            parser.addParameter('Physics',defaultParams.Physics);
            parser.addParameter('ContinuousMovement',defaultParams.ContinuousMovement);
            parser.addParameter('Friction',defaultParams.Friction);
            parser.addParameter('Restitution',defaultParams.Restitution);
            parser.addParameter('PreciseContacts',defaultParams.PreciseContacts);
            parser.addParameter('Collisions',defaultParams.Collisions);
            parser.addParameter('LocationLocked',defaultParams.LocationLocked);
            parser.addParameter('RotationLocked',defaultParams.RotationLocked);
            parser.addParameter('Mobility',defaultParams.Mobility);
            parser.addParameter('Hidden',defaultParams.Hidden);
            parser.addParameter('ConstantAttributes',defaultParams.ConstantAttributes);
            % r2023a中引入
            parser.addParameter( 'WorldTranslation', defaultParams.WorldTranslation );
            parser.addParameter( 'WorldRotation', defaultParams.WorldRotation );
            parser.addParameter( 'WorldScale', defaultParams.WorldScale );

            parser.parse(varargin{:});
            r=parser.Results;
        end


        function PhysicalStruct=createPhysicalStruct(self)
            PhysicalStruct=struct('LinearVelocity',self.LinearVelocity,'AngularVelocity',self.AngularVelocity,...
                'Mass',self.Mass,'Inertia',self.Inertia,'Force',self.Force,'Torque',self.Torque,...
                'CenterOfMass',self.CenterOfMass,'Gravity',self.Gravity,'Physics',self.Physics,...
                'ContinuousMovement',self.ContinuousMovement,'Friction',self.Friction,...
                'Restitution',self.Restitution,'PreciseContacts',self.PreciseContacts,...
                'Collisions',self.Collisions,'LocationLocked',self.LocationLocked,'RotationLocked',self.RotationLocked,...
                'Mobility',self.Mobility,'Hidden',self.Hidden,'ConstantAttributes',self.ConstantAttributes, ...
                'WorldTranslation', self.WorldTranslation, 'WorldRotation', self.WorldRotation, 'WorldScale', self.WorldScale);
        end

    end


    methods(Hidden)

        function totalAttributes=getTotalAttributes(self)
            totalAttributes=self.Full;
        end


        function selectedAttributes=getSelectedAttributes(self,messageIds)
            selectedAttributes=struct();
            if(messageIds(self.Full)==1)
                selectedAttributes=self.getAttributes();
                return;
            end
            if(messageIds(self.LinearVelocityID)==1)
                selectedAttributes.LinearVelocity=self.LinearVelocity;
            end
            if(messageIds(self.AngularVelocityID)==1)
                selectedAttributes.AngularVelocity=self.AngularVelocity;
            end
            if(messageIds(self.MassID)==1)
                selectedAttributes.Mass=self.Mass;
            end
            if(messageIds(self.InertiaID)==1)
                selectedAttributes.Inertia=self.Inertia;
            end
            if(messageIds(self.ForceID)==1)
                selectedAttributes.Force=self.Force;
            end
            if(messageIds(self.TorqueID)==1)
                selectedAttributes.Torque=self.Torque;
            end
            if(messageIds(self.CenterOfMassID)==1)
                selectedAttributes.CenterOfMass=self.CenterOfMass;
            end
            if(messageIds(self.GravityID)==1)
                selectedAttributes.Gravity=self.Gravity;
            end
            if(messageIds(self.PhysicsID)==1)
                selectedAttributes.Physics=self.Physics;
            end
            if(messageIds(self.ContinuousMovementID)==1)
                selectedAttributes.ContinuousMovement=self.ContinuousMovement;
            end
            if(messageIds(self.FrictionID)==1)
                selectedAttributes.Friction=self.Friction;
            end
            if(messageIds(self.RestitutionID)==1)
                selectedAttributes.Restitution=self.Restitution;
            end
            if(messageIds(self.PreciseContactsID)==1)
                selectedAttributes.PreciseContacts=self.PreciseContacts;
            end
            if(messageIds(self.CollisionsID)==1)
                selectedAttributes.Collisions=self.Collisions;
            end
            if(messageIds(self.LocationLockedID)==1)
                selectedAttributes.LocationLocked=self.LocationLocked;
            end
            if(messageIds(self.RotationLockedID)==1)
                selectedAttributes.RotationLocked=self.RotationLocked;
            end
            if(messageIds(self.MobilityID)==1)
                selectedAttributes.Mobility=self.Mobility;
            end
            if(messageIds(self.HiddenID)==1)
                selectedAttributes.Hidden=self.Hidden;
            end
            if(messageIds(self.ConstantAttributesID)==1)
                selectedAttributes.ConstantAttributes=self.ConstantAttributes;
            end
        end

    end

end
