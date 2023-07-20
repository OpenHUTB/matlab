


classdef GlobalDSMConstraint<slci.compatibility.Constraint

    methods
        function out=getDescription(aObj)%#ok
            out='Global data store memory blocks may not be used unless parameters are inlined, and the storage class of their InitialValue is auto';
        end

        function obj=GlobalDSMConstraint(varargin)
            obj.setEnum('GlobalDSM');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            try
                dsmStr='';
                dsms={};
                obj=get_param(aObj.ParentModel().getHandle(),'Object');
                blks=obj.SortedList;
                for i=1:numel(blks)
                    blk=blks(i);
                    blkHandle=get_param(blk,'Handle');
                    if slci.internal.isSynthDSMFromWSVar(blk)
                        dsName=get_param(blk,'DataStoreName');
                        sigObj=slResolve(dsName,blkHandle);

                        assert(isa(sigObj,'Simulink.Signal'));
                        initVal=sigObj.InitialValue;
                        inlineParams=aObj.ParentModel().getParam('InlineParams');
                        if strcmpi(inlineParams,'on')
                            ws_vars=aObj.ParentModel().getWSVarInfoTable();
                            problem=false;
                            if isKey(ws_vars,initVal)
                                use_obj=ws_vars(initVal);
                                assert(~isempty(use_obj));
                                keys=use_obj.keys;
                                data_obj=use_obj(keys{1});
                                problem=~strcmpi(data_obj.StorageClass,'Auto');
                            end

                        else
                            problem=true;
                        end
                        if problem
                            dsmName=get_param(blk,'DataStoreName');
                            if~isempty(dsmStr)
                                dsmStr=[dsmStr,', '];%#ok
                            end
                            dsmStr=[dsmStr,dsmName];%#ok
                            dsms{end+1}=dsmName;%#ok
                        end
                    end
                end
                if~isempty(dsmStr)
                    out=slci.compatibility.Incompatibility(...
                    aObj,'GlobalDSM',aObj.ParentModel().getName(),dsmStr);
                    out.setObjectsInvolved(dsms);
                end
            catch
            end
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,varargin)
            status=varargin{1};
            if nargin==3
                failureCode=varargin{2}.getCode;
            end
            id=strrep(class(aObj),'slci.compatibility.','');
            inlineParams=aObj.ParentModel().getParam('InlineParams');
            if strcmpi(inlineParams,'on')
                inlineParams=true;
            else
                inlineParams=false;
            end
            if status
                StatusText=DAStudio.message(['Slci:compatibility:',id,'Pass']);
            else
                if inlineParams
                    StatusText=DAStudio.message(['Slci:compatibility:',failureCode,'ConstraintWarnInlined']);
                else
                    StatusText=DAStudio.message(['Slci:compatibility:',failureCode,'ConstraintWarnNotinlined']);
                end
            end
            if inlineParams
                RecAction=DAStudio.message(['Slci:compatibility:',id,'RecActionInlined']);
            else
                RecAction=DAStudio.message(['Slci:compatibility:',id,'RecActionNotinlined']);
            end
            SubTitle=DAStudio.message(['Slci:compatibility:',id,'SubTitle']);
            Information=DAStudio.message(['Slci:compatibility:',id,'Info']);
        end

    end
end

