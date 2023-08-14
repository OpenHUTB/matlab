classdef CopyGraphicalInfo<handle




    properties(Constant)
        FilterPrms={'HiliteAncestors','Ports','IOType','AncestorBlock',...
        'ReferenceBlock','LinkStatus','Selected','RequirementInfo',...
        'StatePerturbationForJacobian','ParameterArgumentNames','Variant',...
        'CodeProfilingOverride','PreStartFcn'};
    end

    properties(SetAccess=private,GetAccess=public)
        BlockParameters={}
        ExtraBlockParameters={}
SrcBlock
SrcPrms
    end


    properties(SetAccess=protected,GetAccess=public)
DstPrms
    end


    methods(Access=public)
        function this=CopyGraphicalInfo(srcBlk)
            this.SrcBlock=srcBlk;
            this.init;
            this.SrcPrms=get_param(this.SrcBlock,'ObjectParameters');
            this.cacheBlockParameters;
            this.cacheExtraBlockParameters;
        end


        function copy(this,dstBlk)
            if slfeature('RightClickBuild')~=0






                blockType=get_param(dstBlk,'BlockType');
                if strcmp(blockType,'S-Function')
                    tempParams=this.BlockParameters;
                    idxices=find(strcmp(tempParams,'ArgumentsPromoteToTop')|...
                    strcmp(tempParams,'ShowModelPeriodicEventPorts')|...
                    strcmp(tempParams,'AutoFillPortDiscreteRates')|...
                    strcmp(tempParams,'ParameterArgumentValuesAsString')|...
                    strcmp(tempParams,'PortDiscreteRates')|...
                    strcmp(tempParams,'ScheduleRates')|...
                    strcmp(tempParams,'ScheduleRatesWith')|...
                    strcmp(tempParams,'BaseRate')|...
                    strcmp(tempParams,'InstanceParameters'));
                    idxices=[idxices,idxices+1];
                    tempParams(idxices)=[];
                    set_param(dstBlk,tempParams{:});
                else
                    set_param(dstBlk,this.BlockParameters{:});
                end
            else
                set_param(dstBlk,this.BlockParameters{:});
            end
            this.copyExtraParameters(dstBlk);

        end
    end


    methods(Static,Access=public)
        function obj=create(srcBlk)
            if~strcmp(get_param(srcBlk,'LinkStatus'),'none')
                obj=Simulink.ModelReference.Conversion.CopyGraphicalInfoForLinkedBlock(srcBlk);
            else
                obj=Simulink.ModelReference.Conversion.CopyGraphicalInfo(srcBlk);
            end
        end
    end


    methods(Access=protected)
        function init(this)
            this.DstPrms=get_param('built-in/ModelReference','ObjectParameters');
        end


        function results=isFiltered(this,prmName)
            results=any(strcmp(prmName,this.FilterPrms))||...
            strncmp(prmName,'Mask',4)||strncmp(prmName,'Ext',3);
        end

        function cacheExtraBlockParameters(this)
            this.ExtraBlockParameters{end+1}='ContentPreviewEnabled';
            this.ExtraBlockParameters{end+1}=get_param(this.SrcBlock,'ContentPreviewEnabled');


            this.ExtraBlockParameters{end+1}='PortSchema';
            this.ExtraBlockParameters{end+1}=get_param(this.SrcBlock,'PortSchema');
        end
    end


    methods(Access=private)
        function copyExtraParameters(this,dstBlk)
            if~isempty(this.ExtraBlockParameters)
                set_param(dstBlk,this.ExtraBlockParameters{:});
            end
        end


        function cacheBlockParameters(this)
            this.cacheCopiedParameters;
            num=length(this.BlockParameters)/2;
            for idx=1:num
                prmIdx=2*idx-1;
                prmValIdx=2*idx;
                thisPrm=this.BlockParameters{prmIdx};
                if(strcmp(thisPrm,'ForegroundColor')||strcmp(thisPrm,'BackgroundColor'))
                    this.BlockParameters{prmValIdx}=...
                    Simulink.ModelReference.Conversion.CopyGraphicalInfo.getBlockColor(this.SrcBlock,thisPrm);
                else
                    this.BlockParameters{prmValIdx}=get_param(this.SrcBlock,thisPrm);
                end
            end
        end


        function cacheCopiedParameters(this)
            srcPrmNames=fieldnames(this.SrcPrms);
            dstPrmNames=fieldnames(this.DstPrms);

            inSrcNotInDst=setdiff(srcPrmNames,dstPrmNames);
            copiedPrms=rmfield(this.SrcPrms,inSrcNotInDst);
            copiedPrmNames=fieldnames(copiedPrms);
            numberOfNewParameters=length(copiedPrmNames);
            for idx=1:numberOfNewParameters
                thisPrm=copiedPrmNames{idx};
                if~this.isFiltered(thisPrm)
                    isReadWrite=any(strcmp('read-write',copiedPrms.(thisPrm).Attributes));
                    isListType=strcmp(copiedPrms.(thisPrm).Type,'list');
                    if isReadWrite&&~isListType
                        this.BlockParameters{end+1}=thisPrm;
                        this.BlockParameters{end+1}=[];
                    end
                end
            end
        end
    end


    methods(Static,Access=private)
        function prmValue=getBlockColor(srcBlkH,thisPrm)
            assert((strcmp(thisPrm,'ForegroundColor')||strcmp(thisPrm,'BackgroundColor')));
            mdl=bdroot(srcBlkH);
            sampColor=get_param(mdl,'SampleTimeColors');
            isSampColorOn=strcmp(sampColor,'on');

            if isSampColorOn
                dirtyFlag=get_param(mdl,'dirty');
                set_param(mdl,'SampleTimeColors','off');
                prmValue=get_param(srcBlkH,thisPrm);
                set_param(mdl,'SampleTimeColors','on');
                set_param(mdl,'dirty',dirtyFlag);
            else
                prmValue=get_param(srcBlkH,thisPrm);
            end
        end
    end
end
