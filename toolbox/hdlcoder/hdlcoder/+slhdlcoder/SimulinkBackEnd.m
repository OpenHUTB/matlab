classdef SimulinkBackEnd<slpir.PIR2SL
    methods
        function this=SimulinkBackEnd(hPir,varargin)
            this@slpir.PIR2SL(hPir,varargin{:});
        end

        function reportCheck(~,lvlB,msgObj,varargin)
            slhdlcoder.HDLCoder.addCheckCurrentDriver(lvlB,msgObj,varargin{:});
        end

        function genmodeldisp(~,msg,level,flag)
            if nargin<3
                hdldisp(msg);
            elseif nargin<4
                hdldisp(msg,level);
            else
                hdldisp(msg,level,flag);
            end
        end

        function paramvalue=genmodelgetparameter(~,param)
            paramvalue=hdlgetparameter(param);
        end


        function newSlBlockName=drawSerializerComp(~,slBlockName,hC)
            idle=hC.getIdleCycles;
            load_system('hdlstreaminglib');

            idleNeeded=~isempty(idle)&&idle>0;
            if~idleNeeded
                newSlBlockName=addBlock(hC,'hdlstreaminglib/Serializer_Base',slBlockName);
            else
                newSlBlockName=addBlock(hC,'hdlstreaminglib/Serializer',slBlockName);
            end
            set_param(newSlBlockName,'inputLen',...
            sprintf('%d',max(hC.PirInputSignals(1).Type.getDimensions)));
            set_param(newSlBlockName,'serialFactor',...
            sprintf('%d',max(hC.PirOutputSignals(1).Type.getDimensions)));
            if idleNeeded
                set_param(newSlBlockName,'idleCycles',sprintf('%d',idle));
            end
            hT=hC.PirInputSignals.Type.BaseType;
            if hT.isEnumType
                enumStr=[hT.Name,'.',hT.EnumNames{hT.getDefaultOrdinal+1}];
                set_param(newSlBlockName,'EnumInit',enumStr);
            end
        end



        function newSlBlockName=drawDeserializerComp(~,slBlockName,hC)
            inDims=max(hC.PirInputSignals(1).Type.getDimensions);
            outDims=max(hC.PirOutputSignals(1).Type.getDimensions);

            lib=hC.getLibraryName;
            if~isempty(lib)
                load_system(lib);
            end

            if inDims==1
                blkpath='hdlstreaminglib/Deserializer2';
            else
                blkpath='hdlstreaminglib/Deserializer';
            end
            idle=hC.getIdleCycles;

            idleNeeded=~isempty(idle)&&idle>0;
            if~idleNeeded
                blkpath=[blkpath,'_Base'];
            end

            newSlBlockName=addBlock(hC,blkpath,slBlockName);
            setParams(newSlBlockName,hC);
            set_param(newSlBlockName,'outputLen',sprintf('%d',outDims));

            if idleNeeded
                set_param(newSlBlockName,'idleCycles',sprintf('%d',idle));
            end

            if inDims>1
                set_param(newSlBlockName,'serialFactor',sprintf('%d',inDims));
            end
        end

        function newSlBlockName=drawRecipSqrtNewtonComp(~,slBlockName,hC)
            newSlBlockName=slBlockName;
            implClass=hdldefaults.RecipSqrtNewton;
            implClass.generateSLBlock(hC,slBlockName);
        end


        function newSlBlockName=drawSqrtNewtonComp(~,slBlockName,hC)
            newSlBlockName=slBlockName;
            implClass=hdldefaults.SqrtNewton;
            implClass.generateSLBlock(hC,slBlockName);
        end

        function drawReciCompNewtonImp(~,slBlockName,hC)

            if hC.getIsRsqrtBased
                if hC.getIsMultirate
                    implClass=hdldefaults.ReciprocalRsqrtBasedNewton;
                else
                    implClass=hdldefaults.ReciprocalRsqrtBasedNewtonSingleRate;
                end
            else
                if hC.getIsMultirate
                    implClass=hdldefaults.ReciprocalNewton;
                else
                    implClass=hdldefaults.ReciprocalNewtonSingleRate;
                end
            end
            implClass.generateSLBlock(hC,slBlockName);
        end

        function modelgenset_param(~,varargin)
            hdlset_param(varargin{:});
        end


        function drawcomp=shouldDrawComp(~,hC)
            drawcomp=true;
            if~hC.shouldDraw
                drawcomp=false;
            end
        end


        function valid=isValidComp(~,hC,useDotLayout)

            isInterfacePipeReg=hC.getIsPipelineReg&&~useDotLayout;

            valid=hC.shouldDraw&&~isInterfacePipeReg&&~hC.isAnnotation;
        end


        function valid=isValidPort(~,hP)
            valid=~isempty(hP.Signal);
        end

    end
end