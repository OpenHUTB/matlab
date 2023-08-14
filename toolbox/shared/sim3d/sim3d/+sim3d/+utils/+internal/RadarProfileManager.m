classdef RadarProfileManager<handle
    properties(Constant,Access=private)
        radarData=sim3d.utils.internal.RadarData



    end

    methods
        function self=RadarProfileManager(...
            semanticActorTypes,semanticRcsProfiles,defaultRcsValue)
            self.radarData.semanticActorTypes=semanticActorTypes;
            self.radarData.semanticRcsInterpolants=...
            cellfun(@self.rcs_interpolant,semanticRcsProfiles,...
            "UniformOutput",false);
            self.radarData.defaultRcsValue=defaultRcsValue;
        end
    end

    methods(Static)
        function interpolant=rcs_interpolant(profile)
            if isscalar(profile)
                interpolant=profile;
            else
                inclinations=linspace(0,pi,size(profile,1));
                azimuths=linspace(0,2*pi,size(profile,2));

                interpolant=griddedInterpolant({inclinations,azimuths},profile);
            end
        end

        function rcs=interpolatedRCS(semanticType,theta,phi)
            radarData=sim3d.utils.internal.RadarProfileManager.radarData;

            mask=(radarData.semanticActorTypes==semanticType);
            if~any(mask)
                rcs=radarData.defaultRcsValue;
                return
            end

            interpolant=radarData.semanticRcsInterpolants{mask};
            if isnumeric(interpolant)
                rcs=interpolant;
                return
            end

            rcs=interpolant(theta,phi);
        end
    end
end