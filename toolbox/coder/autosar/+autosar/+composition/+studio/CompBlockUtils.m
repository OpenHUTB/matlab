classdef CompBlockUtils<handle




    methods(Static)


        function[m3iComp,m3iCompProto]=getM3IComp(blkH)
            compBlockFullName=getfullname(blkH);
            m3iCompProto=autosar.composition.Utils.findM3ICompPrototypeForCompBlock(blkH);
            assert(m3iCompProto.isvalid(),'%s is not a valid component or composition block.',compBlockFullName);
            m3iComp=m3iCompProto.Type;
            assert(m3iComp.isvalid(),'%s does not have a valid component.',compBlockFullName);
        end


        function routeLinesForBlk(blkH)
            lhStruct=get_param(blkH,'LineHandles');
            lhs=unique(struct2array(lhStruct));

            lhs=lhs(lhs~=-1);
            if~isempty(lhs)
                Simulink.BlockDiagram.routeLine(lhs);
            end
        end

        function refreshBlockIcon(blk)


            assert(autosar.composition.Utils.isComponentOrCompositionBlock(blk),...
            'block is not component or composition block');
            key=SLBlockIcon.getEffectiveBlockIconKey(blk);
            record=DVG.Registry.getRegRecord(key);
            DVG.Registry.registerIcon(key,record.file);
        end

        function setParam(mdlName,paramName,paramValue)


            configSetObj=getActiveConfigSet(mdlName);
            while isa(configSetObj,'Simulink.ConfigSetRef')
                configSetObj=configSetObj.getRefConfigSet();
            end
            configSetObj.set_param(paramName,paramValue);
        end
    end
end



