



classdef Interpolation_n_DConstantPortConstraint<slci.compatibility.ConstantPortConstraint

    methods


        function out=getDescription(aObj)%#ok
            out='For an Interpolation_n-D block, all subtable selection '+...
            'inports must not connect to Constant blocks at the same time';
        end


        function obj=Interpolation_n_DConstantPortConstraint()
            obj=obj@slci.compatibility.ConstantPortConstraint('Inport',1);
            obj.setEnum('Interpolation_n_DConstantPort');
        end


        function out=getNumberOfTableDimensions(aObj)
            out=aObj.ParentBlock().getParam('NumberOfTableDimensions');
            out=str2num(out);%#ok<ST2NM>
        end


        function out=getNumSelectionDims(aObj)
            out=aObj.ParentBlock().getParam('NumSelectionDims');
            out=str2num(out(1));%#ok<ST2NM>
        end


        function out=check(aObj)
            out=[];
            if(strcmpi(aObj.ParentModel().getParam('InlineParams'),'on'))
                numberOfTableDimensions=getNumberOfTableDimensions(aObj);
                numSelectionDims=getNumSelectionDims(aObj);
                numInPair=numberOfTableDimensions-numSelectionDims;
                first=numInPair*2+1;
                last=numberOfTableDimensions+numInPair;
                aObj.setPortNumber((first:last));
                out=checkConstSampleTime(aObj);
                if~isempty(out)
                    return;
                end


                sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
                incompatiblePorts=getIncompatiblePorts(aObj);
                numberOfIncompatiblePorts=numel(incompatiblePorts);
                if numberOfIncompatiblePorts>0...
                    &&numberOfIncompatiblePorts==numel(aObj.getPortNumber())
                    updateIncompatiblePortList(aObj,incompatiblePorts);
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'Interpolation_n_DConstantPort',...
                    aObj.ParentBlock().getName());
                end
                delete(sess);
            end
        end

    end

end
