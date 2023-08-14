classdef SubSystemLayoutManager<autosar.mm.mm2sl.layout.LayoutManager






    properties(Access=private)
        Subsystem;
    end

    methods
        function this=SubSystemLayoutManager(subsystem,layoutStrategy)
            assert(isa(layoutStrategy,'autosar.mm.mm2sl.layout.LayoutStrategy'),...
            'layoutStrategy is not of expected type');
            this.Subsystem=subsystem;
            this.LayoutStrategy=layoutStrategy;
        end

        function addBlock(this,blockPath,varargin)




            argParser=inputParser;
            argParser.addParameter('isCentral',true);
            argParser.addParameter('isServRunParent',false);
            argParser.parse(varargin{:});

            blockType=get_param(blockPath,'BlockType');


            blockCategory=autosar.mm.mm2sl.layout.LayoutHelper.BlockTypeToLayoutBlockCategoryMap(blockType);


            autosar.mm.mm2sl.layout.BlockBeautifier.beautifyBlock(blockPath);

            if~argParser.Results.isCentral
                this.LayoutStrategy.addBlocks(getfullname(blockPath));
            elseif argParser.Results.isServRunParent


                this.LayoutStrategy.addServRunSSBlocks(getfullname(blockPath));
            else
                switch blockCategory
                case 'CentralBlock'
                    this.LayoutStrategy.setBlockPosition(blockPath);
                case{'LeafBlock','BetweenBlock','FloatingBlock'}
                    this.LayoutStrategy.addBlocks(getfullname(blockPath));

                otherwise
                    assert(false,'Map contained invalid blockCategory');
                end
            end
        end

        function refresh(this)
            this.LayoutStrategy.refresh();
        end
    end
end


