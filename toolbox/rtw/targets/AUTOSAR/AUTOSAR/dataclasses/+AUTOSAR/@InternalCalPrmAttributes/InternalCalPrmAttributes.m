classdef InternalCalPrmAttributes<Simulink.CustomStorageClassAttributes




    properties(PropertyType='char',...
        AllowedValues={'Parameter shared by all instances of the Software Component';...
        'Each instance of the Software Component has its own copy of the parameter'})
        PerInstanceBehavior='Parameter shared by all instances of the Software Component';
    end

    methods

        function retVal=isAddressable(hObj,hCSCDefn,hData)%#ok



            assert(isa(hData,'Simulink.Data'));


            retVal=(numel(hData.Value)~=1)||isstruct(hData.Value);
        end

        function obj=InternalCalPrmAttributes()
            mlock;
        end
    end
end
