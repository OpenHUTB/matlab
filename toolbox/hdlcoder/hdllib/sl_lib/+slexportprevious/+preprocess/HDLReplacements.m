function HDLReplacements(obj)




    if isR2017aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('hdlsllib/Discrete/Unit Delay Enabled Synchronous');
        obj.removeLibraryLinksTo('hdlsllib/Discrete/Unit Delay Resettable Synchronous');
        obj.removeLibraryLinksTo('hdlsllib/Discrete/Unit Delay Enabled Resettable Synchronous');
        obj.removeLibraryLinksTo('hdlsllib/HDL Floating Point Operations/Float Typecast');
        obj.removeLibraryLinksTo('hdlsllib/HDL Operations/Multiply-Accumulate');
        obj.removeLibraryLinksTo('hdlsllib/HDL RAMs/Dual Port RAM System');
        obj.removeLibraryLinksTo('hdlsllib/HDL RAMs/Simple Dual Port RAM System');
        obj.removeLibraryLinksTo('hdlsllib/HDL RAMs/Single Port RAM System');
    end

    if isR2015aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('hdlsllib/HDL Operations/Multiply-Add');
    end

