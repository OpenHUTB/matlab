




classdef LookupndBreakpointsDataTypeConstraint<slci.compatibility.Constraint

    properties(Access=private)
        fIncompatibleBPList=[];
    end

    methods(Access=private)


        function addIncompatibleBP(aObj,aBlk,bpNum)
            incompatibleBPStr=['breakpoints ',num2str(bpNum)];
            if~isKey(aObj.fIncompatibleBPList,aBlk.Handle)
                aObj.fIncompatibleBPList(aBlk.Handle)=incompatibleBPStr;
            else
                aObj.fIncompatibleBPList(aBlk.Handle)=[aObj.fIncompatibleBPList(aBlk.Handle),', ',incompatibleBPStr];
            end
        end

    end
    methods(Access=protected)


        function out=getIncompatibilityTextOrObj(aObj,aTextOrObj)
            out=getIncompatibilityTextOrObj@slci.compatibility.Constraint(...
            aObj,aTextOrObj,'LookupndBreakpointsDataType',...
            aObj.ParentBlock().getName(),...
            aObj.getIncompatibleBPList());
        end
    end

    methods


        function out=getDescription(aObj)%#ok<MANU>
            out='Lookup_n-D block must use the same data type for its breakpoints parameter and input.';
        end


        function obj=LookupndBreakpointsDataTypeConstraint()
            obj.setEnum('LookupndBreakpointsDataType');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end


        function out=getIncompatibleBPList(aObj)
            out=aObj.fIncompatibleBPList;
        end


        function checkBreakpointsDataType(aObj,aBlk,bp_num,expected_data_type)
            cmd=['aBlk.BreakpointsForDimension',num2str(bp_num),'DataTypeStr'];
            try
                bpDataTypeStr=eval(cmd);
            catch ME %#ok<NASGU>
            end
            dataSpec=aBlk.('DataSpecification');
            if strcmpi(dataSpec,'Lookup table object')
                bpDataTypeStr=slci.internal.getRuntimeParamFromBlock(...
                aBlk,...
                ['BreakpointsForDimension',num2str(bp_num)],...
                'DataType');
            end
            if~strcmpi(bpDataTypeStr,'Inherit: Same as corresponding input')&&...
                ~strcmpi(bpDataTypeStr,expected_data_type)
                if slcifeature('VLUTObject')&&slci.internal.hasTunableLUTObject(aBlk)
                    if~strcmpi(bpDataTypeStr,'double')&&...
                        ~strcmpi(bpDataTypeStr,'single')
                        aObj.addIncompatibleBP(aBlk,bp_num);
                    end
                else
                    aObj.addIncompatibleBP(aBlk,bp_num);
                end
            end
        end


        function checkBlock(aObj,aBlk)
            if~strcmp(aBlk.BreakpointsSpecification,'Explicit values')...
                ||strcmpi(aBlk.CompiledIsActive,'off')

                return;
            end
            try
                num_of_tab_dim=slResolve(aBlk.NumberOfTableDimensions,...
                aBlk.Handle);
            catch ME %#ok<NASGU>
                num_of_tab_dim=0;
            end
            compiledPortDataTypes=aBlk.CompiledPortDataTypes;
            for i=1:num_of_tab_dim
                aObj.checkBreakpointsDataType(aBlk,i,compiledPortDataTypes.Inport{1});
            end
        end


        function out=check(aObj)
            out=[];

            aObj.fIncompatibleBPList=containers.Map('KeyType','double',...
            'ValueType','char');
            badBlks={};
            badBlkStr={};
            incompatibleBPList={};


            sess=Simulink.CMI.EIAdapter(1001);%#ok<NASGU>


            blks=find_system(aObj.ParentModel().getName(),'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','Lookup_n-D');

            for blkIdx=1:numel(blks)
                currentBlk=get_param(blks{blkIdx},'Object');
                aObj.checkBlock(currentBlk);
                if isKey(aObj.fIncompatibleBPList,currentBlk.Handle)
                    blkName=slci.compatibility.getFullBlockName(blks(blkIdx));
                    if~isempty(badBlkStr)
                        badBlkStr=[badBlkStr,', '];%#ok<AGROW>
                    end
                    badBlkStr=[badBlkStr,blkName];%#ok<AGROW>
                    badBlks(end+1)=blks(blkIdx);%#ok<AGROW>
                    incompatibleBPList=[incompatibleBPList,aObj.fIncompatibleBPList(currentBlk.Handle)];%#ok<AGROW>
                end
            end

            if~isempty(badBlks)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'LookupndBreakpointsDataType',...
                aObj.ParentModel().getName());
                out.setObjectsInvolved({badBlks,incompatibleBPList});
            end
        end


        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            if status
                status='Pass';
            else
                status='Warn';
            end
            enum=aObj.getEnum();
            Information=DAStudio.message(['Slci:compatibility:',enum,'ConstraintInfo']);
            SubTitle=DAStudio.message(['Slci:compatibility:',enum,'ConstraintSubTitle']);
            RecAction=DAStudio.message(['Slci:compatibility:',enum,'ConstraintRecAction']);
            StatusText=DAStudio.message(['Slci:compatibility:',enum,'Constraint',status]);
        end
    end
end
