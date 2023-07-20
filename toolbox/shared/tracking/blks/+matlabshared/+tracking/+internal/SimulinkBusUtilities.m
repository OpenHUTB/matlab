


classdef(Hidden)SimulinkBusUtilities<matlab.System...
    &matlabshared.tracking.internal.SimulinkBusPropagation
%#codegen










    properties(Nontunable)

        BusNameSource='Auto';


        BusName=char.empty(1,0)
    end
    properties(Constant,Hidden)
        BusNameSourceSet=matlab.system.internal.MessageCatalogSet({'shared_tracking:SimulinkBusUtilities:BusNameSourceAuto',...
        'shared_tracking:SimulinkBusUtilities:BusNameSourceProperty'});
    end


    methods
        function obj=SimulinkBusUtilities


            coder.allowpcode('plain');
        end

        function val=get.BusName(obj)
            val=obj.BusName;
            val=getBusName(obj,val);
        end

        function set.BusName(obj,val)
            validateBusName(obj,val,'BusName')
            obj.BusName=val;
        end
    end

    methods(Access=protected)
        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.System(obj);
            s=saveBuses(obj,s);
        end

        function loadObjectImpl(obj,s,wasLocked)
            loadBuses(obj,s,wasLocked);
            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end

        function flag=isInactivePropertyImpl(obj,prop)
            flag=isInactiveBusProperty(obj,prop)...
            ||isInactivePropertyImpl@matlab.System(obj,prop);
        end

        function releaseImpl(obj)
            releaseBuses(obj);
        end

        function varargout=getOutputDataTypeImpl(obj)
            busIdx=getActiveBusIndices(obj);
            numBus=numel(busIdx);
            varargout=cell(1,numBus);
            [varargout{:}]=getBusDataTypes(obj);
        end
    end

    methods(Static,Access=protected)
        function groups=getPropertyGroupsImpl
            busGroups=matlabshared.tracking.internal.SimulinkBusUtilities.getBusPropertyGroups();
            groups=getPropertyGroupsImpl@matlab.System;
            if strcmpi(groups,'default')
                groups=busGroups;
            else
                groups=[groups(:);busGroups(:)]';
            end
        end
    end
end
