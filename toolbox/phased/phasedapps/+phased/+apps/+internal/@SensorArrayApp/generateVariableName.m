function str=generateVariableName(obj)





    if~obj.pFromSimulink
        for i=1:length(obj.ToolStripDisplay.ArrayGalleryItems)
            if obj.ToolStripDisplay.ArrayGalleryItems{i}.Value

                str=obj.ToolStripDisplay.ArrayGalleryItems{i}.Tag;
            end
        end
        if obj.IsSubarray
            switch class(obj.CurrentArray)
            case 'phased.ReplicatedSubarray'
                str=['Replicated_',str];
            case 'phased.PartitionedArray'
                str=['Partitioned_',str];
            end
        end
    else
        switch class(obj.CurrentArray)
        case 'phased.ULA'
            str='Uniform_linear_array';
        case 'phased.URA'
            str='Uniform_rectangular_array';
        case 'phased.UCA'
            str='Uniform_circular_array';
        case 'phased.ConformalArray'
            str='Conformal_array';
        case 'phased.ReplicatedSubarray'
            str='Replicated_subarray';
        case 'phased.PartitionedArray'
            str='Partitioned_array';
        end
    end