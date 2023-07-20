function val=Constants(type)












%#codegen

    coder.allowpcode('plain');

    switch type
    case 'RegPrimal'

        val=coder.const(eps('double')^0.5);
    case 'BlockSizeL3BLAS'


        val=coder.internal.indexInt(48);
    case 'MaxBlockSizeL2BLAS'



        val=coder.internal.indexInt(128);
    otherwise
        val=0.0;
        assert(false,'Invalid DynamicRegSolver Option');
    end

end

