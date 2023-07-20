




classdef SameValueConstantInputConstraint<slci.compatibility.Constraint
    methods

        function out=getDescription(aObj)%#ok
            out='All input Blocks must not be constant block with same value.';
        end

        function aObj=SameValueConstantInputConstraint
            aObj.setEnum('SameValueConstantInput');
            aObj.setCompileNeeded(1);
            aObj.setFatal(false);
        end

        function out=check(aObj)
            oldf=slfeature('EngineInterface',Simulink.EngineInterfaceVal.byFiat);
            out=[];
            pH=aObj.ParentBlock().getParam('PortHandles');
            pH_in=pH.Inport;
            all_same=true;
            for i=1:numel(pH_in)
                if~aObj.isSourceConstantSameValue(pH_in(i))
                    all_same=false;
                    break;
                end
            end
            if all_same
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'SameValueConstantInput',...
                aObj.ParentBlock().getName());
            end
            slfeature('engineinterface',oldf);
        end


        function out=isSourceConstantSameValue(aObj,pHandle)%#ok
            out=false;
            pObj=get_param(pHandle,'Object');
            grpSrc=pObj.getActualSrc;
            for sIdx=1:size(grpSrc,1)
                grpSrcBlk=get_param(grpSrc(sIdx,1),'ParentHandle');
                grpSrcBlkType=get_param(grpSrcBlk,'BlockType');
                if strcmpi(grpSrcBlkType,'Constant')
                    vals=slResolve(get_param(grpSrcBlk,'Value'),grpSrcBlk);

                    if numel(vals)>1
                        out=true;
                        for i=2:numel(vals)
                            if vals(i)~=vals(1)
                                out=false;
                                break;
                            end
                        end
                    end
                end
            end
        end

    end

end
