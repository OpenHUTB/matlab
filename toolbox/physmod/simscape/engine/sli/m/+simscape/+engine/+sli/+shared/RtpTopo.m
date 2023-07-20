classdef RtpTopo<handle























    properties(SetAccess=private,GetAccess=private)


        mHasRtps;


        mRtpBlock;


        mBlocks;


        mLines;
    end

    methods(Access=public)

        function obj=RtpTopo(name,graphIdx,paramInfo,rtpBlockType,rtpBlockParameters)


            hasRtps=simscape.engine.sli.internal.hasRuntimeParameters(paramInfo);
            if~hasRtps
                obj.mHasRtps=false;
                obj.mRtpBlock='';
                obj.mBlocks={};
                obj.mLines={};
                return
            end

            obj.mHasRtps=true;


            obj.mRtpBlock=sprintf('%s_%d',name,graphIdx);

            rtpBlockType=regexprep(rtpBlockType,'^built-in/','');
            obj.mBlocks{end+1}=simscape.compiler.sli.BlockInfo(...
            rtpBlockType,...
            obj.mRtpBlock,...
            3,...
rtpBlockParameters...
            );


            [ids,dims,~]=nesl_rtpsort(paramInfo);
            isIndexParameter=...
            @(id)~isempty(paramInfo.indices)&&...
            ismember(id,{paramInfo.indices.path});
            for j=1:numel(ids)
                id=ids{j};
                cstName=id;
                cstParams={'Value',id};

                if isIndexParameter(id)
                    cstParams=[cstParams,...
                    {'OutMin','0',...
                    'OutMax',sprintf('%d',intmax('int32'))}];%#ok<AGROW>
                end

                obj.mBlocks{end+1}=simscape.compiler.sli.BlockInfo(...
                'Constant',...
                cstName,...
                1,...
cstParams...
                );


                dim=dims(j);
                if dim==1
                    obj.mLines{end+1}={cstName,1,obj.mRtpBlock,j};
                else

                    rshpName=sprintf('%s_RESHAPE_%d_%d',name,graphIdx,j);
                    obj.mBlocks{end+1}=simscape.compiler.sli.BlockInfo(...
                    'Reshape',...
                    rshpName,...
                    2,...
                    {...
                    'OutputDimensions',sprintf('[%d,1]',dim)...
                    }...
                    );
                    obj.mLines{end+1}={cstName,1,rshpName,1};
                    obj.mLines{end+1}={rshpName,1,obj.mRtpBlock,j};
                end
            end

        end

        function connectTo(obj,dstBlock,dstPort)
            if obj.mHasRtps
                obj.mLines{end+1}={obj.mRtpBlock,1,dstBlock,dstPort};
            end
        end

        function data=slTopoData(obj)
            if obj.mHasRtps
                data=struct('Blocks',{obj.mBlocks},'Lines',{obj.mLines});
            else
                data=struct('Blocks',{},'Lines',{});
            end
        end



        function sysInfo=appendToSysInfo(obj,sysInfo)
            if obj.mHasRtps
                sysInfo=simscape.engine.sli.shared.RtpTopo.appendBlocksToSysInfo(sysInfo,obj.mBlocks);
                sysInfo=simscape.engine.sli.shared.RtpTopo.appendLinesToSysInfo(sysInfo,obj.mLines);
            end
        end

    end


    methods(Static)

        function sysInfo=appendBlocksToSysInfo(sysInfo,blocks)
            for i=1:numel(blocks)
                blocks{i}.Type=sprintf('built-in/%s',blocks{i}.Type);
            end
            sysInfo.Block=[sysInfo.Block,blocks];
        end

        function sysInfo=appendLinesToSysInfo(sysInfo,conns)
            for i=1:numel(conns)
                conn=conns{i};
                src=sprintf('%s/%d',conn{1},conn{2});
                dst=sprintf('%s/%d',conn{3},conn{4});
                conns{i}={src,dst};
            end
            sysInfo.Connection=[sysInfo.Connection,conns];
        end

    end

end
