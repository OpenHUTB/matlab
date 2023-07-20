
classdef BinaryStream<handle





















    properties(GetAccess=public,SetAccess=private)

Name

ReceiveCallback
    end

    methods
        function send(obj,message)





            connector.internal.binaryBuiltins.send(obj.Name,message);
        end

        function send64(obj,message)





            connector.internal.binaryBuiltins.send64(obj.Name,message);
        end

        function receive(obj,callback)







            if isa(callback,'function_handle')
                obj.ReceiveCallback=callback;
                map=instance();
                map(obj.Name)=matlab.internal.WeakHandle(obj);
            else
                ex=MException(message('MATLAB:connector:connector:InvalidInputParameter',obj.Name));
                ex.throw();
            end
            connector.internal.binaryBuiltins.receive(obj.Name);
        end

        function delete(obj)




            map=instance();
            if(isKey(map,obj.Name))
                remove(map,obj.Name);
            end
            connector.internal.binaryBuiltins.delete(obj.Name);
        end

        function out=state(obj)







            out=connector.internal.binaryBuiltins.state(obj.Name);
        end

        function obj=BinaryStream(name,varargin)



            obj.Name=name;
            if nargin==2&&isa(varargin{1},'containers.Map')
                options=varargin{1};
                k=keys(options);
                v=values(options);
                connector.internal.binaryBuiltins.create(name,k,v);
            elseif nargin>1&&mod((nargin-1),2)==0
                k=cell((nargin-1)/2);
                v=cell((nargin-1)/2);
                for i=1:2:nargin-1
                    k{i}=varargin{i};
                    v{i}=varargin{i+1};
                end
                connector.internal.binaryBuiltins.create(name,k,v);
            else
                connector.internal.binaryBuiltins.create(name);
            end
        end

    end

    methods(Hidden)

        function doCallback(obj,message)
            if~isempty(obj.ReceiveCallback)
                obj.ReceiveCallback(message);
            end
        end

    end

    methods(Hidden,Static)

        function weakRef=fetch(name)
            map=instance();
            if isKey(map,name)
                weakRef=map(name);
            end
        end

    end
end

function map=instance()
    persistent inner
    if(isempty(inner))
        inner=containers.Map();
    end
    map=inner;
end
