


classdef ConstantPortConstraint<slci.compatibility.Constraint
    properties(Access=private)
        fPortKind='';
        fPortNumber=1;
        fIncompatiblePortListStr=[];
    end

    methods(Access=protected)

        function out=getPortKind(aObj)
            out=aObj.fPortKind;
        end

        function out=getPortNumber(aObj)
            out=aObj.fPortNumber;
        end

        function out=getIncompatiblePortList(aObj)
            out=aObj.fIncompatiblePortListStr;
        end

        function setPortKind(aObj,aPortKind)
            aObj.fPortKind=aPortKind;
        end

        function setPortNumber(aObj,aPortNumber)
            aObj.fPortNumber=aPortNumber;
        end

        function setIncompatiblePortList(aObj,aPortList)
            aObj.fIncompatiblePortListStr=aPortList;
        end


        function tf=isTunableConstantParameter(aObj,aBlockObj)
            tf=false;
            blockType=aBlockObj.BlockType;
            assert(strcmpi(blockType,'Constant'));


            defaultParameterBehavior=...
            aObj.ParentModel().getParam('DefaultParameterBehavior');
            isInlined=strcmpi(defaultParameterBehavior,'Inlined');
            if isInlined

                paramValue=aBlockObj.Value;
                try
                    param=...
                    slResolve(paramValue,...
                    Simulink.ID.getSID(aBlockObj.Handle),...
                    'variable');
                    if isa(param,'Simulink.Parameter')...
                        &&(strcmpi(param.CoderInfo.StorageClass,'ExportedGlobal')...
                        ||(strcmpi(param.CoderInfo.StorageClass,'Custom')...
                        &&strcmpi(param.CoderInfo.CustomStorageClass,'Const')))
                        tf=true;
                    end
                catch ME %#ok
                    tf=false;
                end
            else

            end
        end



        function out=isSrcConstantPort(aObj,pHandle)
            out=false;
            pObj=get_param(pHandle,'Object');
            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            grpSrc=pObj.getActualSrc;
            for sIdx=1:size(grpSrc,1)
                grpSrcBlk=get_param(grpSrc(sIdx,1),'ParentHandle');
                grpSrcBlkType=get_param(grpSrcBlk,'BlockType');
                grpSrcObj=get_param(grpSrcBlk,'Object');






                while(grpSrcObj.isSynthesized&&...
                    (strcmpi(grpSrcBlkType,'SignalConversion')||...
                    strcmpi(grpSrcBlkType,'SignalSpecification'))&&...
                    ~isempty(grpSrcObj.PortHandles.Inport))
                    tpH=grpSrcObj.getActualSrc;
                    grpSrcBlk=get_param(tpH(1,1),'ParentHandle');
                    grpSrcBlkType=get_param(grpSrcBlk,'BlockType');
                    grpSrcObj=get_param(grpSrcBlk,'Object');
                end

                if strcmpi(grpSrcObj.BlockType,'Constant')
                    out=~aObj.isTunableConstantParameter(grpSrcObj);
                    break;
                elseif aObj.isConstant(grpSrcBlk)
                    out=true;
                end
            end
        end


        function out=isConstant(aObj,blkHandle)
            blkType=get_param(blkHandle,'BlockType');
            blkParent=get_param(blkHandle,'Parent');
            if((strcmpi(blkType,'TriggerPort')...
                ||strcmpi(blkType,'EnablePort'))...
                &&~strcmpi(aObj.ParentModel().getParam('Name'),blkParent))
                compiledSampleTime=get_param(blkParent,'CompiledSampleTime');
            else
                compiledSampleTime=get_param(blkHandle,'CompiledSampleTime');
            end

            if iscell(compiledSampleTime)
                out=false;
            else
                st=slci.internal.SampleTime(compiledSampleTime);
                out=st.isConstant||st.isParameter;
            end
        end

    end

    methods


        function out=getDescription(aObj)%#ok
            out=['Block inport source must not be a Constant block '...
            ,'or other blocks which are constant'];
        end


        function obj=ConstantPortConstraint(aPortKind,aPortNumber)
            obj.setEnum('ConstantPort');
            obj.setCompileNeeded(1);
            obj.setFatal(false);

            obj.setPortKind(aPortKind);
            obj.setPortNumber(aPortNumber);
        end


        function out=checkConstSampleTime(aObj)
            out=[];




            blkObj=aObj.ParentBlock.getParam('Handle');
            isConst=aObj.isConstant(blkObj);
            if isConst


                out=slci.compatibility.Incompatibility(...
                aObj,...
                'ConstantPort',...
                aObj.ParentBlock().getName(),...
                aObj.getPortKind(),...
                num2str(aObj.getPortNumber()));
            end
        end


        function out=getPortHandle(aObj)
            if((strcmpi(aObj.ParentBlock().getParam('BlockType'),'TriggerPort')||...
                strcmpi(aObj.ParentBlock().getParam('BlockType'),'EnablePort'))&&...
                ~strcmpi(aObj.ParentModel().getParam('Name'),aObj.ParentBlock().getParam('Parent')))
                portHandles=get_param(aObj.ParentBlock().getParam('Parent'),'PortHandles');
            else
                portHandles=aObj.ParentBlock().getParam('PortHandles');
            end
            portKind=aObj.getPortKind();
            out=[];
            switch upper(portKind)
            case 'ENABLE'
                out=portHandles.Enable;
            case 'TRIGGER'
                out=portHandles.Trigger;
            case 'INPORT'
                out=portHandles.Inport;
            end
        end


        function incompatiblePorts=getIncompatiblePorts(aObj)
            pH=getPortHandle(aObj);
            incompatiblePorts=[];
            if isempty(pH)
                return;
            end
            tPortNumber=aObj.getPortNumber();

            for iPort=1:numel(tPortNumber)
                assert(tPortNumber(iPort)<=numel(pH));
                status=aObj.isSrcConstantPort(pH(tPortNumber(iPort)));

                if(status)
                    incompatiblePorts=[incompatiblePorts,tPortNumber(iPort)];
                end
            end
        end


        function updateIncompatiblePortList(aObj,incompatiblePorts)
            tIncompatiblePortListStr=[];
            numberOfIncompatiblePorts=numel(incompatiblePorts);
            for idx=1:numberOfIncompatiblePorts
                if 1==idx
                    tIncompatiblePortListStr=[tIncompatiblePortListStr,num2str(incompatiblePorts(idx))];
                elseif idx==numberOfIncompatiblePorts
                    tIncompatiblePortListStr=[tIncompatiblePortListStr,' and ',num2str(incompatiblePorts(idx))];
                else
                    tIncompatiblePortListStr=[tIncompatiblePortListStr,', ',num2str(incompatiblePorts(idx))];%#ok<*AGROW>
                end
            end
            aObj.setIncompatiblePortList(tIncompatiblePortListStr);
        end


        function out=check(aObj)
            out=[];
            if(strcmpi(aObj.ParentModel().getParam('DefaultParameterBehavior'),'Inlined'))
                out=checkConstSampleTime(aObj);
                if~isempty(out)
                    return;
                end


                sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
                incompatiblePorts=getIncompatiblePorts(aObj);
                if numel(incompatiblePorts)>0
                    updateIncompatiblePortList(aObj,incompatiblePorts);
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'ConstantPort',...
                    aObj.ParentBlock().getName(),...
                    aObj.getPortKind(),...
                    aObj.getIncompatiblePortList());
                end
                delete(sess);
            end
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,varargin)%#ok
            status=varargin{1};
            if status
                status='Pass';
            else
                status='Warn';
            end
            SubTitle=DAStudio.message('Slci:compatibility:ConstantPortConstraintSubTitle');
            Information=DAStudio.message('Slci:compatibility:ConstantPortConstraintInfo');
            StatusText=DAStudio.message(['Slci:compatibility:ConstantPortConstraint',status]);

            hasIncompatiblePorts=~isempty(aObj.getIncompatiblePortList());
            if(strcmpi(aObj.getPortKind(),'trigger')||...
                strcmpi(aObj.getPortKind(),'enable'))
                recMsgStr=[lower(aObj.getPortKind()),' port'];
            else
                if hasIncompatiblePorts...
                    &&~contains(aObj.getIncompatiblePortList(),',')

                    recMsgStr=[lower(aObj.getPortKind()),' ',aObj.getIncompatiblePortList()];
                else

                    recMsgStr=[lower(aObj.getPortKind()),'s ',aObj.getIncompatiblePortList()];
                end
            end
            RecAction=DAStudio.message('Slci:compatibility:ConstantPortConstraintRecAction',recMsgStr);


            if hasIncompatiblePorts...
                &&contains(aObj.getIncompatiblePortList(),',')

                RecAction=strrep(RecAction,'source','sources');
                RecAction=strrep(RecAction,'is','are');
                RecAction=strrep(RecAction,'a constant block','constant blocks');
            end
        end

    end
end
