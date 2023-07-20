function MaskSupport(obj)


    if isR2011aOrEarlier(obj.ver)

        obj.appendRule('<Block<SFBlockType:remove>>');
    end


    machine=getStateflowMachine(obj);
    if isempty(machine)
        return;
    end


    if isR2012bOrEarlier(obj.ver)

        charts=sf('get',machine.Id,'machine.charts');
        instances=sf('get',charts,'chart.instance');
        blockHandles=sf('get',instances,'instance.simulinkBlock');

        for i=1:numel(blockHandles)
            chartId=sfprivate('block2chart',blockHandles(i));
            sfObj=idToHandle(sfroot,chartId);
            slObj=get_param(blockHandles(i),'Object');

            topMask=get_param(slObj.Handle,'MaskObject');

            if~isempty(topMask)
                deleteAllMasks(topMask);
            end

            slObj.MaskType='Stateflow';
            slObj.MaskSelfModifiable='on';
            slObj.MaskIconOpaque='off';
            sfprivate('set_mask_display',chartId);

            switch class(sfObj)
            case 'Stateflow.EMChart'
                slObj.MaskDescription='Embedded MATLAB block';
            case 'Stateflow.TruthTableChart'
                slObj.MaskDescription='Truth Table Block';
                slObj.MaskIconFrame='off';
            otherwise
                slObj.MaskDescription='Stateflow diagram';
                slObj.MaskIconFrame='off';
            end

            slObj.Mask='on';
        end

    end

end

function deleteAllMasks(mask)

    while~isempty(mask.BaseMask)
        baseMask=mask.BaseMask;
        mask.delete();
        mask=baseMask;
    end
    mask.delete();
end
