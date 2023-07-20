classdef Utility<handle





    properties(Access=private)

FoundDevices
    end


    methods(Static,Access=public)
        function obj=getInstance()



            mlock;
            persistent utility;

            if isempty(utility)
                utility=matlabshared.blelib.internal.Utility;
            end
            obj=utility;
        end

        function unlock()
            munlock('matlabshared.blelib.internal.Utility.getInstance');
        end
    end

    methods(Access=public)
        function setDevices(obj,addresses,info)

            if isempty(obj.FoundDevices)


                if numel(addresses)==1
                    obj.FoundDevices=containers.Map(addresses,info);
                else
                    obj.FoundDevices=containers.Map(addresses,num2cell(info));
                end
                return;
            end
            newDevices=obj.FoundDevices;
            for index=1:numel(addresses)
                if isKey(newDevices,addresses(index))

                    newInfo=newDevices(addresses(index));

                    if~isempty(info(index).Name)
                        newInfo.Name=info(index).Name;
                    end

                    newInfo.Connectable=info(index).Connectable;
                    newDevices(addresses(index))=newInfo;
                else

                    newDevices(addresses(index))=info(index);
                end
            end
            obj.FoundDevices=newDevices;
        end

        function devices=getDevices(obj)

            devices=obj.FoundDevices;
        end
    end

    methods(Access=private)
        function obj=Utility()
        end
    end
end