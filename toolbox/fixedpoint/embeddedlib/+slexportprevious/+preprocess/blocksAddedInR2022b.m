function blocksAddedInR2022b(obj)











    if obj.ver.isReleaseOrEarlier('R2022a')
        blocks=addedBlocks;
        for k=1:length(blocks)
            block=obj.findLibraryLinksTo(blocks(k));
            obj.replaceWithEmptySubsystem(block);
        end
    end

end

function blocks=addedBlocks




    blocks=[
"embschedlib/QR Scheduling/Burst QR Save and Output Whole R matrix"
"embschedlib/QR Scheduling/Burst Q-less QR With Forgetting Factor Memory Controller Whole R Output"
"embschedlib/QR Scheduling/Burst Q-less QR Memory Controller Whole R Output"
"embeddedburstqr/Real Burst Q-less QR Decomposition Whole R Output Internal"
"embeddedburstqr/Real Burst Q-less QR Decomposition Whole R Output"
"embeddedburstqr/Complex Burst Q-less QR Decomposition Whole R Output Internal"
"embeddedburstqr/Complex Burst Q-less QR Decomposition Whole R Output"
"embeddedburstqr/Real Burst Q-less QR Decomposition with Forgetting Factor Whole R Output Internal"
"embeddedburstqr/Real Burst Q-less QR Decomposition with Forgetting Factor Whole R Output"
"embeddedburstqr/Complex Burst Q-less QR Decomposition with Forgetting Factor Whole R Output Internal"
"embeddedburstqr/Complex Burst Q-less QR Decomposition with Forgetting Factor Whole R Output"
"embmatrixops/Real Burst Asynchronous Matrix Solve Using Q-less QR Decomposition"
"embmatrixops/Complex Burst Asynchronous Matrix Solve Using Q-less QR Decomposition"
"embmatrixops/Real Burst Matrix Solve Using Q-less QR Decomposition with Forgetting Factor"
"embmatrixops/Complex Burst Matrix Solve Using Q-less QR Decomposition with Forgetting Factor"
    ];
end
