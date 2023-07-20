



classdef SFunctionInstanceInfo<sldv.code.CodeInstanceInfo



    methods(Access=public)

        function obj=SFunctionInstanceInfo(varargin)
            obj@sldv.code.CodeInstanceInfo(varargin{:});
        end
    end

    methods(Access=public,Hidden=true)
        function setPortsFromRuntimeObject(obj,rt,getValues)
            if nargin<3
                getValues=true;
            end

            obj.InputPortInfo=struct([]);
            obj.OutputPortInfo=struct([]);
            obj.ParameterPortInfo=struct([]);
            obj.DialogParameterInfo=struct([]);
            obj.DWorkInfo=struct([]);
            obj.DiscStateInfo=struct([]);
            obj.DataStoreInfo=struct([]);

            numInputs=rt.NumInputPorts;
            numOutputs=rt.NumOutputPorts;
            numRtParams=rt.NumRuntimePrms;
            numDworks=rt.NumDworks;
            numDwDiscStates=rt.NumDworkDiscStates;

            numDlgParams=rt.NumDialogPrms;

            if numInputs>0
                obj.InputPortInfo(numInputs)=struct();
                for ii=1:numInputs
                    [type,dims]=sldv.code.sfcn.SFunctionInstanceInfo.getPortInfo(rt,rt.InputPort(ii),true);
                    obj.InputPortInfo(ii).Type=type;
                    obj.InputPortInfo(ii).Dim=dims;
                end
            end

            if numOutputs>0
                obj.OutputPortInfo(numOutputs)=struct();
                for ii=1:numOutputs
                    [type,dims]=sldv.code.sfcn.SFunctionInstanceInfo.getPortInfo(rt,rt.OutputPort(ii),true);
                    obj.OutputPortInfo(ii).Type=type;
                    obj.OutputPortInfo(ii).Dim=dims;
                end
            end

            if numRtParams>0
                obj.ParameterPortInfo(numRtParams)=struct();
                for ii=1:numRtParams
                    rtInfo=rt.RuntimePrm(ii);
                    [type,dims]=sldv.code.sfcn.SFunctionInstanceInfo.getPortInfo(rt,rtInfo);
                    value=rtInfo.Data;

                    obj.ParameterPortInfo(ii).Type=type;
                    obj.ParameterPortInfo(ii).Dim=dims;

                    if getValues
                        obj.ParameterPortInfo(ii).HasValue=true;
                        obj.ParameterPortInfo(ii).Value=value;
                    else
                        obj.ParameterPortInfo(ii).HasValue=false;
                        obj.ParameterPortInfo(ii).Value='';
                    end
                end
            end

            if numDlgParams>0
                obj.DialogParameterInfo(numDlgParams)=struct();
                for ii=1:numDlgParams
                    rtInfo=rt.DialogPrm(ii);
                    [type,dims]=sldv.code.sfcn.SFunctionInstanceInfo.getPortInfo(rt,rtInfo);
                    value=rtInfo.Data;

                    obj.DialogParameterInfo(ii).Type=type;
                    obj.DialogParameterInfo(ii).Dim=dims;

                    if getValues
                        obj.DialogParameterInfo(ii).HasValue=true;
                        obj.DialogParameterInfo(ii).Value=value;
                    else
                        obj.DialogParameterInfo(ii).HasValue=false;
                        obj.DialogParameterInfo(ii).Value='';
                    end
                end
            end


            if numDworks>0
                obj.DWorkInfo(numDworks)=struct();
                for ii=1:numDworks
                    rtInfo=rt.Dwork(ii);
                    [type,dims]=sldv.code.sfcn.SFunctionInstanceInfo.getPortInfo(rt,rtInfo);

                    obj.DWorkInfo(ii).Type=type;
                    obj.DWorkInfo(ii).Dim=dims;
                end
            end

            if numDwDiscStates~=0
                obj.DiscStateInfo(1)=struct();

                dsInfo=rt.DiscStates;
                type=sldv.code.sfcn.SFunctionInstanceInfo.getPortInfo(rt,dsInfo);
                value=dsInfo.Data;
                dims=dsInfo.Dimensions;

                obj.DiscStateInfo(1).Type=type;
                obj.DiscStateInfo(1).Dim=dims;

                obj.DiscStateInfo(1).HasValue=~isempty(value);
                obj.DiscStateInfo(1).Value=value;
            end
        end
    end

    methods(Static=true,Access=private)
        function[type,dims]=getPortInfo(rt,rtInfo,busAllowed)

            if nargin<3
                busAllowed=false;
            end

            dims=rtInfo.Dimensions;

            id=rtInfo.DatatypeID;
            if id<0
                type='';
            else
                name=rt.DatatypeName(id);
                if busAllowed&&rtInfo.IsBus

                    type=name;
                elseif rt.DataTypeIsFixedPoint(id)
                    type=rt.FixedPointNumericType(id);
                else
                    if any(strcmp(name,{'double','single','boolean'}))
                        type=numerictype(name);
                    else

                        type=name;
                    end
                end
            end
        end
    end

end
