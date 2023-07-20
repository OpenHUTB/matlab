



classdef History<handle
    properties
Data
StartingIndex
    end

    properties(SetAccess=private)
DelayedVariables

Offset
Scale
    end

    methods




        function o=History(step,num_freqs,delayed_variables,delays)
            max_delay=max([0;delays(:)]);

            history_length=ceil(max_delay/step)+1;





            o.Data=zeros(length(delayed_variables),2*num_freqs-1,history_length);
            o.DelayedVariables=delayed_variables;



            offset=delays/step;
            left=floor(offset);
            scale=offset-left;
            scale(left==0)=1;

            o.Offset=left-1;
            o.Scale=scale;

            o.initialize;
        end

        function push_back(o,X)
            if isempty(o.DelayedVariables)
                return;
            end

            o.StartingIndex=o.index(-1);
            o.Data(:,:,o.StartingIndex)=X(o.DelayedVariables,:);
        end





        function Z=interpolate(o)
            n=size(o.Data,1);
            Z=zeros(n,size(o.Data,2));
            if isempty(Z)
                return;
            end

            for i=1:n
                a=o.Scale(i);
                offset=o.Offset(i);
                Z(i,:)=(1-a)*o.Data(i,:,o.index(offset))+a*o.Data(i,:,o.index(offset+1));
            end
        end





        function Z=convolve(o,impulse)
            num_variables=size(o.Data,1);
            num_freqs=(size(o.Data,2)+1)/2;


            Z=zeros(num_variables,num_freqs);
            if isempty(Z)
                return;
            end

            N=min(size(o.Data,3),size(impulse,3))-1;




            for i=1:N
                k=o.index(i-1);
                d=o.Data(:,:,k);
                data=[d(:,1),d(:,2:num_freqs)+1j*d(:,num_freqs+1:end)];

                imp=impulse(:,:,i+1);

                Z=Z+data.*imp;
            end



        end




        function i=index(o,offset)
            n=size(o.Data,3);


            i=mod(o.StartingIndex+offset-1,n)+1;
        end




        function initialize(o,varargin)
            o.StartingIndex=1;
            if isempty(varargin)
                o.Data=zeros(size(o.Data));
            else
                X=varargin{1};

                if(size(X,3)==1)
                    o.Data=repmat(X(o.DelayedVariables,:),[1,1,size(o.Data,3)]);
                else
                    o.Data(:,:,1:size(X,3))=X(o.DelayedVariables,:,:);
                end
            end
        end

    end
end
