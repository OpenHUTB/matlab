


classdef NFPModelChecker
    methods(Static)


        function blockList=getSupportedBlocks
            db=slhdlcoder.HDLImplDatabase;
            db.buildDatabase;


            [~,blockList]=db.dispNFPImplementations(1);
        end
    end
end

