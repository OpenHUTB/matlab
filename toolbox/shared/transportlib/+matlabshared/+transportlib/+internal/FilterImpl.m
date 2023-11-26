classdef FilterImpl<handle

%#codegen

    properties

        Transport(1,1){mustBeNonempty};
    end

    properties(Access=private)

        InputFilterPlugins={};


        InputFilterOptions={};


        OutputFilterPlugins={};


        OutputFilterOptions={};
    end

    methods
        function obj=FilterImpl(transport)








            narginchk(1,1);


            if~isa(transport,'matlabshared.transportlib.internal.IFilterable')
                if isempty(coder.target())

                    throw(MException('transportlib:transport:invalidTransportType',...
                    message('transportlib:transport:invalidTransportType').getString()));
                else
                    coder.internal.error('transportlib:transport:invalidTransportType');
                end
            end
            obj.Transport=transport;
        end


        function addInputFilter(obj,filter,options)





            narginchk(3,3);


            hasConnection=obj.Transport.Connected;

            try
                validateattributes(filter,{'string','char'},{},mfilename,'filter',2);

                alreadyAdded=any(cellfun(@(s)strcmpi(filter,s),obj.InputFilterPlugins));
                if~alreadyAdded




                    if hasConnection
                        obj.Transport.disconnect();
                    end
                    obj.InputFilterPlugins{end+1}=filter;
                    obj.InputFilterOptions{end+1}=options;
                    if hasConnection
                        obj.Transport.connect();
                    end
                else
                    warning(message('transportlib:filter:filterAreadyAdded','input'));
                end
            catch asyncioError

                obj.Transport.disconnect();

                obj.InputFilterPlugins(end)=[];
                obj.InputFilterOptions(end)=[];


                obj.Transport.connect();
                throw(asyncioError);
            end
        end

        function removeInputFilter(obj,filter)





            narginchk(2,2);


            hasConnection=obj.Transport.Connected;

            idx=find(cellfun(@(s)strcmpi(filter,s),obj.InputFilterPlugins),1);
            if~isempty(idx)
                try




                    if hasConnection
                        obj.Transport.disconnect();
                    end
                    obj.InputFilterPlugins(idx)=[];
                    obj.InputFilterOptions(idx)=[];
                    if hasConnection
                        obj.Transport.connect();
                    end
                catch asyncioError


                    if hasConnection&&~obj.Transport.Connected
                        obj.Transport.connect();
                    end
                    throw(asyncioError);
                end
            end
        end

        function addOutputFilter(obj,filter,options)





            narginchk(3,3);


            hasConnection=obj.Transport.Connected;

            try
                validateattributes(filter,{'string','char'},{},mfilename,'filter',2);

                alreadyAdded=any(cellfun(@(s)strcmpi(filter,s),obj.OutputFilterPlugins));
                if~alreadyAdded




                    if hasConnection
                        obj.Transport.disconnect();
                    end
                    obj.OutputFilterPlugins{end+1}=filter;
                    obj.OutputFilterOptions{end+1}=options;
                    if hasConnection
                        obj.Transport.connect();
                    end
                else
                    warning(message('transportlib:filter:filterAreadyAdded','output'));
                end
            catch asyncioError

                obj.Transport.disconnect();

                obj.OutputFilterPlugins(end)=[];
                obj.OutputFilterOptions(end)=[];


                obj.Transport.connect();
                throw(asyncioError);
            end
        end

        function removeOutputFilter(obj,filter)





            narginchk(2,2);


            hasConnection=obj.Transport.Connected;

            idx=find(cellfun(@(s)strcmpi(filter,s),obj.OutputFilterPlugins),1);
            if~isempty(idx)
                try




                    if hasConnection
                        obj.Transport.disconnect();
                    end
                    obj.OutputFilterPlugins(idx)=[];
                    obj.OutputFilterOptions(idx)=[];
                    if hasConnection
                        obj.Transport.connect();
                    end
                catch asyncioError


                    if hasConnection&&~obj.Transport.Connected
                        obj.Transport.connect();
                    end
                    throw(asyncioError);
                end
            end
        end

        function[inputFilters,inputFilterOptions]=getInputFilters(obj)









            inputFilters=obj.InputFilterPlugins;
            inputFilterOptions=obj.InputFilterOptions;
        end

        function[outputFilters,outputFilterOptions]=getOutputFilters(obj)









            outputFilters=obj.OutputFilterPlugins;
            outputFilterOptions=obj.OutputFilterOptions;
        end
    end
end

