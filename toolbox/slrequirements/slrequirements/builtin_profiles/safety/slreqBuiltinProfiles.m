% Copyright 2022 The MathWorks, Inc.
% profilesStruct is an array, each element contains info for a profile
% Name: profile name
% Feature: feature linked to the bult-in profile. If feature is not
% available, the bult-in will not be shown in the menu
% Description: decription of the built-in profile

function profilesStruct = slreqBuiltinProfiles
    profilesStruct.Name = 'mwAutomotive.xml'; % it must be in the same folder
    
    if reqmgt('rmiFeature', 'SafetyProfiles') % TODO: replace with actual license when available
        profilesStruct.LicenseToCheck = 'Simulink_Requirements';
    else
        profilesStruct.LicenseToCheck = ' ';
    end
    profilesStruct.Description = message( "Slvnv:reqmgt:builtinsDescriptions:ASPICEDef").getString;

%     profilesStruct(2).Name = 'otherProfile';
%     profilesStruct(2).Feature = 'otherFeature';
%     profilesStruct(2).Description = 'otherString';
end
