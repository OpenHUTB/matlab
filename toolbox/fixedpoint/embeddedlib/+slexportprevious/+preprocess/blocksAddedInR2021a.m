function blocksAddedInR2021a(obj)











    if obj.ver.isReleaseOrEarlier('R2020b')
        blocks=addedBlocks;
        for k=1:length(blocks)
            block=obj.findLibraryLinksTo(blocks(k));
            obj.replaceWithEmptySubsystem(block);
        end
    end

end

function blocks=addedBlocks




    blocks=[
"embeddedmatrixsolveinternal/Burst Matrix Solve Q-less QR B Buffer Manager"
"embeddedmatrixsolveinternal/Burst Matrix Solve Q-less QR Forward-Substitute Buffer Manager"
"embeddedmatrixsolveinternal/Burst Matrix Solve Q-less QR Output Manager"
"embeddedmatrixsolveinternal/Partial-Systolic Matrix Solve Q-less QR B Buffer Manager"
"embeddedmatrixsolveinternal/Partial-Systolic Matrix Solve Q-less QR Forward Substitute Memory Manager"
"embeddedmatrixsolveinternal/Partial-Systolic Matrix Solve Q-less QR Output Manager"
"embeddedmatrixsolveinternal/Partial-Systolic Matrix Solve QR Output Memory Manager"
"embeddedutilities/Shift and cast to output type"
"embeddedutilities/Variable Left Shift"
"embeddedutilities/Variable Right Shift"
"embmathops/Divide by Constant and Round"
    sprintf("embmathops/Divide by Constant\nHDL Optimized")
"embmathops/Modulo by Constant"
    sprintf("embmathops/Modulo by Constant\nHDL Optimized")
"embreciprocals/Complex Divide HDL Optimized"
"embreciprocals/Real Divide HDL Optimized"
"embreciprocals/Real Reciprocal HDL Optimized"
    ];
end
