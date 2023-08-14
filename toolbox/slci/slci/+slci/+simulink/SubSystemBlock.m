



classdef SubSystemBlock<slci.simulink.Block

    methods

        function obj=SubSystemBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);


            obj.addConstraint(...
            slci.compatibility.SupportedNonInlinedSubsystemConstraint);

            obj.addConstraint(...
            slci.compatibility.SupportedSubsystemBlockConstraint);

            obj.addConstraint(...
            slci.compatibility.SupportedReuseSubsystemConstraint);

            obj.addConstraint(...
            slci.compatibility.SupportedNonReuseSubsystemConstraint);

            obj.addConstraint(...
            slci.compatibility.ReuseSubsystemHiddenBufferConstraint);
            obj.addConstraint(slci.compatibility.CodeVariantConstraint());

            obj.addConstraint(...
            slci.compatibility.PropagateExecutionAcrossBoundaryConstraint());


            obj.addConstraint(...
            slci.compatibility.BlockMinimumAlgebraicLoopOccurrencesConstraint(...
            false,'MinAlgLoopOccurrences','off'));
            obj.addConstraint(...
            slci.compatibility.InconsistentPortNumberConstraint());
            obj.addConstraint(...
            slci.compatibility.MessageTriggeredSubSystemConstraint());

            isMasked=strcmp(obj.getParam('Mask'),'on');

            if isMasked

                maskParamNames=obj.getMaskParamNames();
                for idx=1:numel(maskParamNames)
                    maskParamName=maskParamNames{idx};
                    obj.addConstraint(...
                    slci.compatibility.RuntimeParamConstraint(maskParamName));
                end

                obj.addConstraint(...
                slci.compatibility.UnsupportedMaskedLookupTableObjectConstraint);
            end

            obj.setSupportsBuses(true);
            obj.setSupportsEnums(true);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end


    methods(Access=private)


        function maskParamNames=getMaskParamNames(obj)

            maskParamNames={};
            maskObject=Simulink.Mask.get(...
            getfullname(obj.ParentBlock().getHandle()));
            maskParameters=maskObject.Parameters;
            if isempty(maskParameters)
                return;
            end




            maskParams=maskParameters(...
            arrayfun(@(x)~obj.isDeprecatedProperty(x)...
            &&strcmp(x.Evaluate,'on'),...
            maskParameters));
            try


                for k=1:numel(maskParams)
                    mp=maskParams(k);
                    if~obj.isEmptyProperty(mp)
                        maskParamNames{end+1}=mp.Name;%#ok
                    end
                end
            catch
                maskParamNames={};
            end
        end



        function out=isDeprecatedProperty(~,maskParam)
            prop=maskParam.Name;
            deprecated_props={'DataType',...
            'FractionDataTypeMode',...
            'IndexDataTypeMode',...
            'LogicOutDataTypeMode',...
            'OutDataTypeMode',...
            'OutputDataTypeScalingMode',...
            'ParameterDataTypeMode',...
            'FractionDataType',...
            'IndexDataType',...
            'OutDataType',...
            'ParameterDataType',...
            'ConRadixGroup',...
            'VecRadixGroup',...
            'ParameterScalingMode',...
            'FractionScaling',...
            'OutScaling',...
'ParameterScaling'...
            };
            out=any(strcmp(prop,deprecated_props));
        end



        function out=isEmptyProperty(aObj,maskParam)
            out=false;%#ok
            maskParamValue=maskParam.Value;
            if isempty(maskParamValue)
                out=true;
                return;
            end

            if strcmp(maskParam.Evaluate,'on')
                try
                    parameterValue=slResolve(...
                    maskParamValue,...
                    aObj.ParentBlock().getSID());
                    out=isempty(parameterValue)||any(isinf(parameterValue));
                catch ME %#ok, ok to ignore unresolved or non-numeric value except for lut obj
                    out=~isa(parameterValue,'Simulink.LookupTable');
                    return;
                end
            else

                out=any(isinf(maskParamValue));
            end
        end
    end

end
