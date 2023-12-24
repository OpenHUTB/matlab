function registerSlTestEventMetadataBusObject
    slTestEventMetadata=load(fullfile(matlabroot,"toolbox","simulinktest",...
    "core","observer","observer","slTestEventMetadata.mat")).slTestEventMetadata;
    Simulink.Bus.register('slTestEventMetadata',slTestEventMetadata,'forceregister',true);
end
