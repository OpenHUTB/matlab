function MountOffsetToggle(Block)
    if autoblkschecksimstopped(Block)
        offsetFlag=get_param(Block,'offsetFlag');

        if strcmp(offsetFlag,'on')
            if~strcmp(get_param(Block,'ReferenceBlock'),'sim3dlib/Simulation 3D Lidar')
                autoblksenableparameters(Block,{'tmountOffset','rmountOffset'});
            else
                autoblksenableparameters(Block,{'tmountOffset'});
            end
        else
            if~strcmp(get_param(Block,'ReferenceBlock'),'sim3dlib/Simulation 3D Lidar')
                autoblksenableparameters(Block,{},{'tmountOffset','rmountOffset'});
            else
                autoblksenableparameters(Block,{},{'tmountOffset'});
            end
        end
    end
end