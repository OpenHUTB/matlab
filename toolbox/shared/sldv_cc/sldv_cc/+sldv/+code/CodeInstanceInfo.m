classdef CodeInstanceInfo<handle

    properties(Access=public)
StaticChecksum
InputPortInfo
OutputPortInfo
ParameterPortInfo
DialogParameterInfo
DWorkInfo
DiscStateInfo
DataStoreInfo
    end


    properties(Hidden=true)
IRMapping
    end

    properties(GetAccess=public,SetAccess=protected)

SID
    end


    methods(Access=public)

        function obj=CodeInstanceInfo(checksum)
            if nargin<1
                checksum='';
            end

            obj.StaticChecksum=checksum;

            obj.SID='';

            obj.InputPortInfo=struct([]);
            obj.OutputPortInfo=struct([]);
            obj.ParameterPortInfo=struct([]);
            obj.DialogParameterInfo=struct([]);
            obj.DiscStateInfo=struct([]);
            obj.DataStoreInfo=struct([]);

            obj.IRMapping=[];
        end


        function addInput(obj,type,dims)
            portInfo=sldv.code.CodeInstanceInfo.portInfo(type,dims);
            obj.InputPortInfo=[obj.InputPortInfo,portInfo];
        end


        function addOutput(obj,type,dims)
            portInfo=sldv.code.CodeInstanceInfo.portInfo(type,dims);
            obj.OutputPortInfo=[obj.OutputPortInfo,portInfo];
        end


        function addParameter(obj,type,dims,value)
            if nargin<=3
                paramInfo=sldv.code.CodeInstanceInfo.parameterInfo(type,dims);
            else
                paramInfo=sldv.code.CodeInstanceInfo.parameterInfo(type,dims,value);
            end
            obj.ParameterPortInfo=[obj.ParameterPortInfo,paramInfo];
        end

        function[compatible,parameterCount]=isValidDescriptionFor(obj,instance)
            if strcmp(obj.StaticChecksum,instance.StaticChecksum)&&...
                sldv.code.CodeInstanceInfo.compareIOPorts(obj.InputPortInfo,instance.InputPortInfo)&&...
                sldv.code.CodeInstanceInfo.compareIOPorts(obj.OutputPortInfo,instance.OutputPortInfo)&&...
                sldv.code.CodeInstanceInfo.compareIOPorts(obj.ParameterPortInfo,instance.ParameterPortInfo)&&...
                sldv.code.CodeInstanceInfo.compareIOPorts(obj.DialogParameterInfo,instance.DialogParameterInfo)
                [compatible,parameterCount]=sldv.code.CodeInstanceInfo.checkValues(...
                obj.ParameterPortInfo,...
                instance.ParameterPortInfo);
                if compatible
                    [compatible,dialogParameterCount]=sldv.code.CodeInstanceInfo.checkValues(...
                    obj.DialogParameterInfo,...
                    instance.DialogParameterInfo);
                    parameterCount=parameterCount+dialogParameterCount;
                end
            else
                compatible=false;
                parameterCount=0;
            end
        end








        function ok=isEquivalentDescriptor(obj,other)
            ok=strcmp(obj.StaticChecksum,other.StaticChecksum)&&...
            other.isValidDescriptionFor(obj);
            if ok&&~isempty(obj.ParameterPortInfo)
                ok=all([obj.ParameterPortInfo.HasValue]==[other.ParameterPortInfo.HasValue]);
            end

            if ok&&~isempty(obj.DialogParameterInfo)
                ok=all([obj.DialogParameterInfo.HasValue]==[other.DialogParameterInfo.HasValue]);
            end
        end




        function updateModelName(obj,analysisModelName,designModelName)
            if~isempty(obj.SID)
                try
                    blockHandle=Simulink.ID.getHandle(obj.SID);
                    fullPath=getfullname(blockHandle);

                    originalPath=[designModelName,fullPath(numel(analysisModelName)+1:end)];
                    handle=getSimulinkBlockHandle(originalPath);
                    if handle==-1
                        obj.SID=originalPath;
                    else
                        obj.SID=Simulink.ID.getSID(handle);
                    end
                catch ME
                    if sldv.code.internal.feature('disableErrorRecovery')
                        rethrow(ME);
                    end
                    obj.SID='';
                end
            end
        end




        function setInstanceIdFromHandle(obj,blockHandle)
            obj.SID=Simulink.ID.getSID(blockHandle);
        end





        function name=getInstanceName(obj)
            try
                name=Simulink.ID.getFullName(obj.SID);
            catch ME
                if sldv.code.internal.feature('disableErrorRecovery')
                    rethrow(ME);
                end
                name=obj.SID;
            end
        end
    end

    methods(Access=public,Hidden=true)



        function createIRMapping(this)
            this.IRMapping=sldv.code.internal.CppInstanceInfo;
        end
    end

    methods(Static=true)



        function portInfo=portInfo(type,dims)
            portInfo=struct('Type',type,'Dim',dims);
        end




        function portInfo=parameterInfo(type,dims,value)
            if nargin<=2
                hasValue=false;
                value='';
            else
                hasValue=true;
            end
            portInfo=struct('Type',type,...
            'Dim',dims,...
            'HasValue',hasValue,...
            'Value',value);
        end

    end

    methods(Static=true,Access=protected)




        function same=compareIOPorts(ports1,ports2)
            same=false;
            if numel(ports1)==numel(ports2)
                for ii=1:numel(ports1)
                    p1=ports1(ii);
                    p2=ports2(ii);

                    if ndims(p1.Dim)~=ndims(p2.Dim)||...
                        any(p1.Dim~=p2.Dim)
                        return
                    end


                    if isa(p1.Type,'embedded.type')&&isa(p2.Type,'embedded.type')
                        if~p1.Type.isequivalent(p2.Type)
                            return
                        end
                    elseif isa(p1.Type,'char')&&isa(p2.Type,'char')

                        if~strcmp(p1.Type,p2.Type)
                            return
                        end
                    else

                        return
                    end
                end
                same=true;
            end
        end







        function[ok,numValuated]=checkValues(declaredParams,actualParams)
            numValuated=0;
            ok=false;
            if numel(declaredParams)==numel(actualParams)
                for ii=1:numel(declaredParams)
                    declared=declaredParams(ii);
                    actual=actualParams(ii);
                    if declared.HasValue
                        if~actual.HasValue
                            ok=false;
                            return
                        else

                            if isequal(declared.Value,actual.Value)
                                numValuated=numValuated+1;
                            else

                                ok=false;
                                return
                            end
                        end
                    end
                end
                ok=true;
            end
        end
    end

end


