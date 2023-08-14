


classdef HiddenBufferBlockConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='The Simulink Code Inspector does not support automatic insertion of Signal Conversion blocks';
        end

        function obj=HiddenBufferBlockConstraint(varargin)
            obj.setEnum('HiddenBufferBlock');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)

            out=[];
            allBlocks=aObj.ParentModel().getBlocks();
            set=slci.compatibility.UniqueBlockSet;
            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>


            for blkidx=1:numel(allBlocks)
                try
                    blockObj=allBlocks{blkidx};
                    blkObj=blockObj.getParam('Object');
















                    if(~strcmpi(blkObj.BlockType,'Concatenate'))
                        blkH=blockObj.getParam('Handle');

                        pH=blkObj.PortHandles.Inport;
                        checkPort(aObj,pH,blkH,set);


                        if(strcmpi(blkObj.BlockType,'ModelReference'))
                            pH=blkObj.PortHandles.Enable;
                            checkPort(aObj,pH,blkH,set);
                            pH=blkObj.PortHandles.Trigger;
                            checkPort(aObj,pH,blkH,set);
                        end
                    end
                catch ME %#ok


                end
            end


            checkSF(aObj,set);


            if set.GetLength()>0
                out=[out,slci.compatibility.Incompatibility(...
                aObj,...
                'HiddenBufferBlock',...
                set.GetBlockStr())];
                out.setObjectsInvolved(set.GetBlockCell());
            end
        end

    end
    methods(Access=private)
        function refMdlRootOutport=isRefModelRootOutport(aObj,blkH)
            mdlObj=aObj.ParentModel();
            if mdlObj.getCheckAsRefModel
                parent=get_param(get_param(blkH,'Parent'),'Handle');
                isRootLevel=(parent==mdlObj.getHandle());
                if(strcmpi(get_param(blkH,'BlockType'),'Outport')...
                    &&isRootLevel)
                    refMdlRootOutport=true;
                    return;
                end
            end
            refMdlRootOutport=false;
        end

        function[inportgrpSrcObj,outportgrpSrcObj]=getGraphicalSrcAndDst(aObj,grpSrcObj)

            inportH=grpSrcObj.PortHandles.Inport;
            inportPObj=get_param(inportH,'Object');
            inportgrpSrc=inportPObj.getGraphicalSrc;
            inportgrpSrcBlk=get_param(inportgrpSrc,'ParentHandle');
            inportgrpSrcObj=get_param(inportgrpSrcBlk,'Object');


            outportH=grpSrcObj.PortHandles.Outport;
            outportPObj=get_param(outportH,'Object');
            outportgrpSrc=outportPObj.getGraphicalDst;
            outportgrpSrcBlk=get_param(outportgrpSrc,'ParentHandle');
            outportgrpSrcObj=get_param(outportgrpSrcBlk,'Object');
        end


        function checkPort(aObj,portH,blkH,set)
            registered=false;
            pIdx=1;
            while pIdx<=numel(portH)&&~registered
                try
                    pObj=get_param(portH(pIdx),'Object');
                    grpSrc=pObj.getGraphicalSrc;
                    grpSrcBlk=get_param(grpSrc,'ParentHandle');
                    grpSrcObj=get_param(grpSrcBlk,'Object');




                    if~isempty(grpSrcObj)&&grpSrcObj.isSynthesized&&...
                        strcmpi(grpSrcObj.BlockType,...
                        'SignalConversion')&&...
                        ~aObj.isParentBusSelector(grpSrcObj)&&...
                        ~aObj.isConnectedToArgBlock(grpSrcObj)


                        [inportgrpSrcObj,outportgrpSrcObj]=aObj.getGraphicalSrcAndDst(grpSrcObj);








                        if~strcmpi(inportgrpSrcObj.BlockType,...
                            'Inport')&&...
                            ~strcmpi(outportgrpSrcObj.BlockType,...
                            'Outport')&&~isRefModelRootOutport(aObj,blkH)...
                            ||slci.compatibility.FirstInitICPropagationConstraint.propagatesInFirstInit(grpSrcBlk)
                            registered=true;
                            set.AddBlock(blkH);
                        end
                    end
                catch ME1 %#ok


                end
                pIdx=pIdx+1;
            end
        end



        function checkSF(aObj,set)

            mlblocks=aObj.ParentModel().getBlockType('MatlabFunction');
            sfblocks=aObj.ParentModel().getBlockType('Stateflow');
            blks=[mlblocks,sfblocks];
            for k=1:numel(blks)
                sfBlk=blks{k};
                blkH=sfBlk.getParam('Handle');
                sfun=find_system(blkH,...
                'SearchDepth',1,...
                'AllBlocks','on',...
                'LookUnderMasks','on',...
                'FollowLinks','on',...
                'LookUnderReadProtectedSubsystems','on',...
                'BlockType','S-Function',...
                'FunctionName','sf_sfun');
                assert(numel(sfun)==1);
                sfunObj=get_param(sfun,'Object');
                pH=sfunObj.PortHandles.Inport;
                checkSFPort(aObj,pH,blkH,set);
            end
        end


        function checkSFPort(~,portH,sfBlk,set)
            for pIdx=1:numel(portH)
                try
                    pObj=get_param(portH(pIdx),'Object');
                    grpSrc=pObj.getGraphicalSrc;
                    grpSrcBlk=get_param(grpSrc,'ParentHandle');
                    grpSrcObj=get_param(grpSrcBlk,'Object');

                    if~isempty(grpSrcObj)&&grpSrcObj.isSynthesized&&...
                        strcmpi(grpSrcObj.BlockType,...
                        'SignalConversion')

                        set.AddBlock(sfBlk);
                        return;
                    end
                catch ME1 %#ok


                end
            end
        end


        function tf=isParentBusSelector(aObj,srcObject)
            portHandle=srcObject.PortHandles;
            portObj=get_param(portHandle.Inport,"Object");
            grahicalSrc=portObj.getGraphicalSrc;
            srcObject=get_param(grahicalSrc,"Object");
            portParent=get_param(srcObject.Handle,"Parent");
            parentBlocktype=get_param(portParent,"BlockType");
            tf=strcmpi(parentBlocktype,'BusSelector');
        end


        function out=isConnectedToArgBlock(aObj,sigConvObj)
            out=false;
            if(isa(sigConvObj,'Simulink.SignalConversion'))
                sigConvInportObj=get_param(sigConvObj.PortHandles.Inport,...
                'Object');
                sigConvSrcHandle=get_param(sigConvInportObj.getGraphicalSrc,...
                'ParentHandle');
                sigConvSrcObj=get_param(sigConvSrcHandle,'Object');
                if isa(sigConvSrcObj,'Simulink.ArgIn')
                    out=true;
                    return;
                end
                sigConvOutportObj=get_param(sigConvObj.PortHandles.Outport,...
                'Object');
                sigConvDstHandle=get_param(sigConvOutportObj.getGraphicalDst,...
                'ParentHandle');
                sigConvDstObj=get_param(sigConvDstHandle,'Object');
                if isa(sigConvDstObj,'Simulink.ArgOut')
                    out=true;
                    return;
                end
            end
        end
    end
end

