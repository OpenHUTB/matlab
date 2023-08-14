function KS=KinematicsSolver_implementation(KS,mdl,varargin)




    [mdl,varargin{:}]=convertCharsToStrings(mdl,varargin{:});

    p=inputParser;
    p.addRequired('mdl',@(mdl)validateModel(mdl));
    p.addParameter('DefaultLengthUnit',KS.DefaultLengthUnit,@validateLengthUnit);
    p.addParameter('DefaultAngleUnit',KS.DefaultAngleUnit,@validateAngleUnit);
    p.addParameter('DefaultLinearVelocityUnit',KS.DefaultLinearVelocityUnit,@validateLinearVelocityUnit);
    p.addParameter('DefaultAngularVelocityUnit',KS.DefaultAngularVelocityUnit,@validateAngularVelocityUnit);
    p.parse(mdl,varargin{:});

    KS.DefaultLengthUnit=p.Results.DefaultLengthUnit;
    KS.DefaultAngleUnit=p.Results.DefaultAngleUnit;
    KS.DefaultLinearVelocityUnit=p.Results.DefaultLinearVelocityUnit;
    KS.DefaultAngularVelocityUnit=p.Results.DefaultAngularVelocityUnit;





    if isa(mdl,'simscape.multibody.Multibody')

        modelName="Multibody";
        KS.ModelName=modelName;
        [sys,compErrs]=sm.mli.internal.multibodyToSystem(mdl,modelName);
    else

        KS.ModelName=mdl;
        [sys,compErrs,hasMultibody]=simmechanics.sli.internal.getSystems(p.Results.mdl);

        if isempty(compErrs)
            if~hasMultibody
                pm_error('sm:mli:kinematicsSolver:NoMultibodyMechanism',mdl);
            end
            if numel(sys)>1
                pm_error('sm:mli:kinematicsSolver:MultipleConfigurationSolvers',mdl)
            end
        end
    end


    if~isempty(compErrs)
        throw(compErrs)
    end


    sys.initializeKinematicSystem(KS.DefaultLengthUnit,KS.DefaultAngleUnit,...
    KS.DefaultLinearVelocityUnit,KS.DefaultAngularVelocityUnit);
    KS.mSystem=sys;
