function blocksAddedInR2020b(obj)











    if obj.ver.isReleaseOrEarlier('R2020a')
        blocks=addedBlocks;
        for k=1:length(blocks)
            block=obj.findLibraryLinksTo(blocks(k));
            obj.replaceWithEmptySubsystem(block);
        end
    end

end

function blocks=addedBlocks




    blocks=[
"embeddedpartialsystolicqr/Complex Partial-Systolic Q-less QR Decomposition"
"embeddedpartialsystolicqr/Complex Partial-Systolic Q-less QR with Forgetting Factor"
"embeddedpartialsystolicqr/Complex Partial-Systolic QR Decomposition"
"embeddedpartialsystolicqr/Real Partial-Systolic Q-less QR Decomposition"
"embeddedpartialsystolicqr/Real Partial-Systolic Q-less QR with Forgetting Factor"
"embeddedpartialsystolicqr/Real Partial-Systolic QR Decomposition"
"embeddedpartialsystolicqrinternal/Complex Partial-Systolic CORDIC QR Row Rotation"
"embeddedpartialsystolicqrinternal/Complex Partial-Systolic Q-less QR CORDIC Row Rotation"
"embeddedpartialsystolicqrinternal/Complex Partial-Systolic Q-less QR Decomposition Section"
"embeddedpartialsystolicqrinternal/Complex Partial-Systolic Q-less QR Decomposition with Forgetting Factor Section"
"embeddedpartialsystolicqrinternal/Complex Partial-Systolic Q-less QR For-Each Subsystem"
"embeddedpartialsystolicqrinternal/Complex Partial-Systolic Q-less QR Row Rotations"
"embeddedpartialsystolicqrinternal/Complex Partial-Systolic Q-less QR with Forgetting Factor For-Each Subsystem"
"embeddedpartialsystolicqrinternal/Complex Partial-Systolic QR Decomposition Section"
"embeddedpartialsystolicqrinternal/Complex Partial-Systolic QR For-Each Subsystem"
"embeddedpartialsystolicqrinternal/Complex Partial-Systolic QR Row Rotations"
"embeddedpartialsystolicqrinternal/Partial Systolic QR Memory Controller"
"embeddedpartialsystolicqrinternal/Partial-Systolic Q-less QR Memory Controller"
"embeddedpartialsystolicqrinternal/Partial-Systolic Q-less QR Output Memory Manager"
"embeddedpartialsystolicqrinternal/Partial-Systolic Q-less QR Validate Sizes"
"embeddedpartialsystolicqrinternal/Partial-Systolic Q-less QR with Forgetting Factor Memory Controller"
"embeddedpartialsystolicqrinternal/Partial-Systolic Q-less QR with Forgetting Factor Output Memory Manager"
"embeddedpartialsystolicqrinternal/Partial-Systolic QR Output Memory Manager"
"embeddedpartialsystolicqrinternal/Partial-Systolic QR Validate Sizes"
"embeddedpartialsystolicqrinternal/Q-less QR 2nd and 3rd Quadrant Compensation"
"embeddedpartialsystolicqrinternal/QR 2nd and 3rd Quadrant Compensation"
"embeddedpartialsystolicqrinternal/Real Partial-Systolic Q-less QR Decomposition Section"
"embeddedpartialsystolicqrinternal/Real Partial-Systolic Q-less QR Decomposition with Forgetting Factor Section"
"embeddedpartialsystolicqrinternal/Real Partial-Systolic Q-less QR For-Each Subsystem"
"embeddedpartialsystolicqrinternal/Real Partial-Systolic Q-less QR with Forgetting Factor For-Each Subsystem"
"embeddedpartialsystolicqrinternal/Real Partial-Systolic QR Decomposition Section"
"embeddedpartialsystolicqrinternal/Real Partial-Systolic QR For-Each Subsystem"
"embeddedutilities/Inverse CORDIC Gain"
"embeddedutilities/Validate QR Sizes"
"embsubstitutions/Complex Burst Back Substitute with Matrix Output"
"embsubstitutions/Complex Burst Forward Substitute with Matrix Output"
"embsubstitutions/Complex Q-less QR Forward Backward Substitute"
"embsubstitutions/Real Burst Back Substitute with Matrix Output"
"embsubstitutions/Real Burst Forward Substitute with Matrix Output"
"embsubstitutions/Real Q-less QR Forward Backward Substitute"
"embsystolicmatrixops/Complex Partial-Systolic Matrix Solve Using Q-less QR Decomposition"
"embsystolicmatrixops/Complex Partial-Systolic Matrix Solve Using Q-less QR Decomposition with Forgetting Factor"
"embsystolicmatrixops/Complex Partial-Systolic Matrix Solve Using QR Decomposition"
"embsystolicmatrixops/Real Partial-Systolic Matrix Solve Using Q-less QR Decomposition"
"embsystolicmatrixops/Real Partial-Systolic Matrix Solve Using Q-less QR Decomposition with Forgetting Factor"
"embsystolicmatrixops/Real Partial-Systolic Matrix Solve Using QR Decomposition"
    ];
end
