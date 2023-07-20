function blocksAddedInR2020a(obj)











    if obj.ver.isReleaseOrEarlier('R2019b')
        blocks=addedBlocks;
        for k=1:length(blocks)
            block=obj.findLibraryLinksTo(blocks(k));
            obj.replaceWithEmptySubsystem(block);
        end
    end

end

function blocks=addedBlocks



    blocks=[
"embeddedburstqr/Complex Burst Q-less QR Decomposition"
"embeddedburstqr/Complex Burst Q-less QR Decomposition Internal"
"embeddedburstqr/Real Burst Q-less QR Decomposition"
"embeddedburstqr/Real Burst Q-less QR Decomposition Internal"
"embeddedutilities/Latency Counter"
"embeddedutilities/Shorten Vector by One Element"
"embmathops/Hyperbolic Tangent HDL Optimized"
"embmatrixops/Complex Burst Back Substitute"
"embmatrixops/Complex Burst Matrix Solve Using Q-less QR Decomposition"
"embmatrixops/Complex Burst Matrix Solve Using QR Decomposition"
"embmatrixops/Complex Burst QR Decomposition"
"embmatrixops/Complex Burst QR Decomposition Internal"
"embmatrixops/Real Burst Back Substitute"
"embmatrixops/Real Burst Matrix Solve Using Q-less QR Decomposition"
"embmatrixops/Real Burst Matrix Solve Using QR Decomposition"
"embmatrixops/Real Burst QR Decomposition"
"embmatrixops/Real Burst QR Decomposition Internal"
"embreciprocals/Normalized Reciprocal HDL Optimized"
"embreciprocals/Positive Normalized Reciprocal HDL Optimized"
    sprintf("embreciprocals/Positive Real CORDIC Reciprocal Kernel\nHDL Optimized")
"embreciprocals/Positive Real Normalizer HDL Optimized"
    sprintf("embreciprocals/Real CORDIC Reciprocal Kernel\nHDL Optimized")
"embreciprocals/Real Normalizer HDL Optimized"
"embrowoperations/Complex Row Rotations/Complex Final Pivot Action"
"embrowoperations/Complex Row Rotations/Q-less QR Complex Row Rotations"
"embrowoperations/Complex Row Rotations/Q-less QR Rotate First Element To Real"
"embrowoperations/Complex Row Rotations/QR Complex Row Rotations"
"embrowoperations/Complex Row Rotations/Rotate First Element To Real"
"embrowoperations/Real Row Rotations/Q-less QR Real Indexed CORDIC Row Rotation"
"embrowoperations/Real Row Rotations/Q-less QR Real Row Rotations"
"embrowoperations/Real Row Rotations/QR Real Row Rotations"
"embrowoperations/Real Row Rotations/Real CORDIC Row Rotation"
"embrowoperations/Real Row Rotations/Real Final Pivot Action"
"embrowoperations/Real Row Rotations/Real Indexed CORDIC Row Rotation"
"embrowoperations/Real Row Rotations/Set Element To Zero"
"embrowoperations/Real Row Rotations/Shorten Vector by One Element"
"embrowoperations/Real Row Rotations/Systolic Q-less QR Real Row Rotations"
"embschedlib/QR Scheduling/Burst Q-less QR Memory Controller"
"embschedlib/QR Scheduling/Burst QR Memory Controller"
"embsubstitutions/Complex Burst Forward Substitute"
"embsubstitutions/Real Burst Forward Substitute"
"slutils/Cast to Union of Types"
"slutils/Same Datatype"
"slutils/Upcast Wordlength"
"slutils/ValidIn To Ready Logic"
    ];
end
