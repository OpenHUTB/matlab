function ConstantGammaClutterMountingAngle(obj)



    if isReleaseOrEarlier(obj.ver,'R2020b')


        ws=warning('off','radar:radar:ObsoletePropertyByOneProperties');

        blks=obj.findBlocksOfType('MATLABSystem');

        for ind=1:numel(blks)

            blk=blks{ind};
            blkSystem=get_param(blk,'System');

            if strcmp(blkSystem,'radar.internal.SimulinkConstantGammaClutter')||...
                strcmp(blkSystem,'gpuConstantGammaClutter')



                custStr=get_param(blk,'MountingAngles');
                val=eval(custStr);
                val=val(2);
                val=['"',num2str(val),'"'];

                if strcmp(blkSystem,'radar.internal.SimulinkConstantGammaClutter')
                    rule=slexportprevious.rulefactory.addParameterToBlock(...
                    '<SourceBlock|"radarlib/Constant Gamma Clutter">',...
                    'BroadsideDepressionAngle',val);
                else
                    rule=slexportprevious.rulefactory.addParameterToBlock(...
                    '<SourceBlock|"radarlib/GPU Constant Gamma Clutter">',...
                    'BroadsideDepressionAngle',val);
                end

                obj.appendRule(rule);

            end

        end


        warning(ws);

    end


