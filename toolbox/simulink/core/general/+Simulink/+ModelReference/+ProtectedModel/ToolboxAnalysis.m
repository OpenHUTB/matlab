classdef ToolboxAnalysis<handle %#ok<*TRYNC>
















    properties(Hidden)
        TopModelName='';
        AllModels={};

        FindSysOpts={};
        Toolboxes={};

        BlocksToAnalyze={};
    end

    methods

        function obj=ToolboxAnalysis(topModel)
            obj.TopModelName=topModel;

            if Simulink.internal.useFindSystemVariantsMatchFilter('DEFAULT_ALLVARIANTS')
                obj.AllModels=find_mdlrefs(topModel,...
                'MatchFilter',@Simulink.match.activeVariants);
                obj.FindSysOpts={'FollowLinks','off',...
                'LookUnderMasks','all',...
                'MatchFilter',@Simulink.match.activeVariants,...
                'LookUnderReadProtectedSubsystems','on'};
            else
                obj.AllModels=find_mdlrefs(topModel,'Variants','ActiveVariants');
                obj.FindSysOpts={'FollowLinks','off',...
                'LookUnderMasks','all',...
                'LookUnderReadProtectedSubsystems','on',...
                'Variants','ActiveVariants'};
            end
        end


        function tbxes=findToolboxesUsed(obj)
            try

                openAtStart=find_system('type','block_diagram');
                c1=onCleanup(@()obj.locCloseAdditionalModels(openAtStart));


                dependencies.internal.analysis.toolbox.ToolboxFinder().validate()
                for i=1:length(obj.AllModels)
                    model=obj.AllModels{i};


                    try
                        obj.analyzeOneModel(model);
                    end
                end
            end


            tbxes=unique(obj.Toolboxes);

        end


    end

    methods(Access=private)
        function analyzeOneModel(obj,model)
            load_system(model);



            obj.BlocksToAnalyze={};


            obj.findBlocksToAnalyze(model);

            blkIdx=0;

            while blkIdx<length(obj.BlocksToAnalyze)
                blkIdx=blkIdx+1;
                blk=obj.BlocksToAnalyze{blkIdx};


                if~strcmpi(get_param(blk,'Type'),'block')
                    continue;
                end




                try
                    obj.checkStateflowUsage(blk);
                end

                try
                    obj.checkBlock(blk);
                end

                try
                    obj.checkLibraries(blk);
                end
            end
        end

        function findBlocksToAnalyze(obj,component)
            blks=find_system(component,obj.FindSysOpts{:});

            obj.BlocksToAnalyze=[obj.BlocksToAnalyze;blks];
        end

        function checkStateflowUsage(obj,block)
            blkObj=get_param(block,'Object');

            if isa(blkObj,'Simulink.SubSystem')

                if~strcmpi(blkObj.SFBlockType,'NONE')&&...
                    ~strcmpi(blkObj.SFBlockType,'MATLAB Function')
                    obj.Toolboxes{end+1}='Stateflow';
                end
            end
        end





        function found=recordToolboxForFile(obj,filepath)
            found=false;

            tf=dependencies.internal.analysis.toolbox.ToolboxFinder;
            tbd=tf.fromPath(filepath);
            if~isempty(tbd)&&tbd.IsMathWorksToolbox
                found=true;

                if(strcmpi(tbd.Name,'Stateflow'))
                    return;
                end

                obj.Toolboxes{end+1}=tbd.Name;
            end
        end




        function checkBlock(obj,block)
            blkType=get_param(block,'BlockType');

            srcName='';
            switch(blkType)
            case 'MATLABSystem'
                srcName=get_param(block,'System');

            case 'S-Function'
                srcName=get_param(block,'FunctionName');
            end

            if~isempty(srcName)
                srcPath=which(srcName);
                obj.recordToolboxForFile(fileparts(srcPath));
            end
        end



        function checkLibraries(obj,block)
            refBlock=get_param(block,'ReferenceBlock');

            if~isempty(refBlock)
                pathSep=regexp(refBlock,'/','once');
                libName=refBlock(1:pathSep-1);

                libPath=which(libName);
                found=obj.recordToolboxForFile(fileparts(libPath));



                if~found
                    load_system(libName);
                    obj.findBlocksToAnalyze(refBlock);
                end
            end
        end


        function locCloseAdditionalModels(obj,openAtStart)
            openNow=find_system('type','block_diagram');



            close_system(setdiff(openNow,openAtStart));


        end
    end
end
